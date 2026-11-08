import 'dart:developer';
import 'dart:typed_data';

import '../../core/html/question_html.dart';
import '../../core/storage/session_manager.dart';
import '../../data/api/exam_api.dart';
import '../../data/api/exam_mistake_api.dart';
import '../../data/api/mistake_api.dart';
import '../../data/api/oss_api.dart';
import 'exam_review_store.dart';

/// 测评错题同步（复刻 src/utils/examMistakes.ts 的 syncExamMistakes）
///
/// 流程：读取本地识别结果 → 拉取题目分析 → 逐个错题取官方视图 →
/// 解析题干 → 生成缩略图上传 OSS → 加入官方错题本。
class ExamSyncService {
  ExamSyncService._();

  /// [capture] 由页面提供：把 HTML 渲染成截图（错题缩略图）
  static Future<({int total, int saved, int pending})> syncExamMistakes(
    int taskId,
    String accountKey,
    String studentId, {
    required Future<Uint8List?> Function(String html) capture,
    bool Function()? isActive,
  }) async {
    void ensureActive() {
      if (isActive != null && !isActive()) throw Exception('同步已取消或账号已切换');
      if (SessionManager.instance.session.userId != studentId) {
        throw Exception('同步已取消或账号已切换');
      }
    }

    ensureActive();
    final task = await ExamApi.getTask(taskId);
    ensureActive();
    final examId = (task['examId'] as num?)?.toInt() ?? 0;
    if (examId <= 0) throw Exception('测评缺少有效 examId');

    final snapshot = await ExamReviewStore.instance.getReview(accountKey, taskId);
    final review = snapshot?.questionIds;
    if (review == null || review.isEmpty) {
      throw Exception('请先完成自动识别');
    }

    final analysis = await ExamApi.getQuestionAnalysis(examId);
    ensureActive();
    final detected = ExamReviewStore.analysisWrongQuestions(task, analysis, studentId);
    if (detected.unmatched > 0) {
      throw Exception('题目分析存在无法匹配的题目，请刷新后重试');
    }
    final wrong = detected.questions
        .where((q) => review.contains((q['id'] as num?)?.toInt()))
        .toList();

    var entries = await ExamReviewStore.instance.listLocalMistakes(accountKey);
    var saved = 0;
    final seen = <String>{};

    for (final question in wrong) {
      ensureActive();
      final id = (question['id'] as num?)?.toInt() ?? 0;
      final related = question['answerByGroup'] == true &&
          ((question['relatedGroupId'] as num?)?.toInt() ?? 0) > 0;
      final questionId =
          related ? (question['relatedGroupId'] as num?)?.toInt() ?? 0 : id;
      final localId = 'local:$examId:${related ? 'group' : 'q'}:$questionId';
      if (questionId <= 0 || seen.contains(localId)) {
        // 自定义（无题目 id）或重复的题目：记日志后跳过，避免静默丢失。
        if (questionId <= 0) {
          log(
            '[错题同步] 跳过无题目ID的错题（自定义）'
            ' examId=$examId detectedId=$id related=$related'
            ' number=${question['number'] ?? question['name'] ?? ''}'
            ' subject=${task['topicName'] ?? ''}',
            name: 'ExamSync',
          );
        }
        continue;
      }
      seen.add(localId);

      var alreadyAdded = false;
      final existingIndex = entries.indexWhere((e) => e.id == localId);
      LocalMistake item;
      if (existingIndex >= 0) {
        item = entries[existingIndex];
      } else {
        final views = await ExamMistakeApi.officialView(
          examId,
          questionId,
          related: related,
        );
        ensureActive();
        if (views.isEmpty) throw Exception('官方题目详情为空，未进行同步');
        alreadyAdded = views.every((view) => view['isInMistakeBook'] == true);
        item = await _buildItem(
          views: views,
          localId: localId,
          examId: examId,
          questionId: questionId,
          related: related,
          task: task,
          question: question,
          alreadyAdded: alreadyAdded,
          ensureActive: ensureActive,
        );
        entries = [...entries, item];
        await ExamReviewStore.instance.saveLocalMistakes(accountKey, entries);
      }

      if (alreadyAdded) {
        item = item.copyWith(sync: 'synced', syncError: '');
        await _persist(accountKey, entries, item);
        continue;
      }

      try {
        // 每次重试都重新核对官方成员状态（复刻旧版注释：POST 超时后也必须复查）
        final recheck = await ExamMistakeApi.officialView(
          examId,
          questionId,
          related: related,
        );
        ensureActive();
        if (recheck.every((view) => view['isInMistakeBook'] == true)) {
          item = item.copyWith(sync: 'synced', syncError: '');
          await _persist(accountKey, entries, item);
          continue;
        }
        if (item.stemShoot.isEmpty) {
          final shot = await capture(item.stem);
          ensureActive();
          if (shot == null || shot.isEmpty) throw Exception('题目截图失败');
          final url = await OssApi.uploadBytes(
            bytes: shot,
            fileName: 'stem.png',
            userId: studentId,
            fc: 'mistake_v2',
            mime: 'image/png',
          );
          ensureActive();
          item = item.copyWith(stemShoot: url);
          await _persist(accountKey, entries, item);
        }
        ensureActive();
        await ExamMistakeApi.addToMistakeBook(
          examId: examId,
          questionId: questionId,
          isRelatedGroup: related,
          stemShoot: item.stemShoot,
        );
        ensureActive();
        item = item.copyWith(sync: 'synced', syncError: '');
        saved++;
        await _persist(accountKey, entries, item);
      } catch (e) {
        ensureActive();
        item = item.copyWith(sync: 'pending', syncError: e.toString());
        await _persist(accountKey, entries, item);
        log(
          '[错题同步] 单题同步失败'
          ' examId=$examId questionId=$questionId related=$related'
          ' number=${item.number} source=${item.source}: $e',
          name: 'ExamSync',
        );
      }
    }

    final pending =
        entries.where((e) => seen.contains(e.id) && e.sync == 'pending').length;
    return (total: seen.length, saved: saved, pending: pending);
  }

  static Future<void> _persist(
    String accountKey,
    List<LocalMistake> entries,
    LocalMistake item,
  ) async {
    final index = entries.indexWhere((e) => e.id == item.id);
    if (index >= 0) entries[index] = item;
    await ExamReviewStore.instance.saveLocalMistakes(accountKey, entries);
  }

  static Future<LocalMistake> _buildItem({
    required List<Map<String, dynamic>> views,
    required String localId,
    required int examId,
    required int questionId,
    required bool related,
    required Map<String, dynamic> task,
    required Map<String, dynamic> question,
    required bool alreadyAdded,
    required void Function() ensureActive,
  }) async {
    final stems = <String>[];
    final answers = <String>[];
    final analyses = <String>[];
    for (final view in views) {
      final path = (view['path'] ?? '').toString();
      if (path.isEmpty) throw Exception('题目没有可读取的题干，未进行同步');
      final html = await MistakeApi.fetchQuestionHtml(path);
      ensureActive();
      final parsed = QuestionHtml.parseQuestionHtml(html);
      stems.add(parsed.stem);
      answers.add(parsed.answer);
      analyses.add(parsed.analysis);
    }
    if (stems.every((e) => e.trim().isEmpty)) {
      throw Exception('题干解析为空，未进行同步');
    }
    return LocalMistake(
      id: localId,
      examId: examId,
      questionId: questionId,
      isRelatedGroup: related,
      subject: (task['topicName'] ?? '未分类').toString(),
      source: (task['examName'] ?? '测评错题').toString(),
      number: (question['number'] ?? question['name'] ?? '').toString(),
      creationTime: DateTime.now().toIso8601String(),
      stem: stems.join('<hr>'),
      answer: answers.join('<hr>'),
      analysis: analyses.join('<hr>'),
      stemShoot: '',
      earned: (question['originScore'] as num?) ?? 0,
      full: (question['score'] as num?) ?? 0,
      sync: alreadyAdded ? 'synced' : 'pending',
    );
  }

  /// 批量核对（复刻 collectExamTasks）
  static Future<void> collectExamTasks(
    List<Map<String, dynamic>> tasks,
    String accountKey,
    String studentId, {
    required Future<Uint8List?> Function(String html) capture,
    void Function(String message)? onProgress,
    bool Function()? isActive,
  }) async {
    var errors = 0;
    var pending = 0;
    for (var index = 0; index < tasks.length; index++) {
      if (isActive != null && !isActive()) break;
      final raw = tasks[index];
      final id = (raw['examTaskId'] as num?)?.toInt() ??
          (raw['id'] as num?)?.toInt() ??
          0;
      if (id <= 0) continue;
      onProgress?.call(
        '正在核对本人错题 ${index + 1}/${tasks.length}：${raw['examName'] ?? ''}',
      );
      try {
        final result = await syncExamMistakes(
          id,
          accountKey,
          studentId,
          capture: capture,
          isActive: isActive,
        );
        pending += result.pending;
      } catch (e) {
        errors++;
        log(
          '[错题同步] 测评读取失败'
          ' examTaskId=$id name=${raw['examName'] ?? ''}: $e',
          name: 'ExamSync',
        );
      }
    }
    final buffer = StringBuffer('本人错题核对完成');
    if (pending > 0) buffer.write('，$pending 题待同步官方');
    if (errors > 0) buffer.write('，$errors 个测评未能读取');
    onProgress?.call(buffer.toString());
  }
}
