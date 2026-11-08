import 'dart:convert';

import '../../core/storage/local_store.dart';

/// 本人错题识别结果（复刻 src/utils/examReview.ts）
class ExamReview {
  const ExamReview({
    required this.taskId,
    required this.examId,
    required this.name,
    required this.questionIds,
    required this.numbers,
    required this.unmatched,
    required this.checkedAt,
    this.message = '',
  });

  final int taskId;
  final int examId;
  final String name;
  final List<int> questionIds;
  final List<String> numbers;
  final int unmatched;
  final String checkedAt;
  final String message;

  factory ExamReview.fromJson(Map<String, dynamic> json) {
    return ExamReview(
      taskId: (json['taskId'] as num?)?.toInt() ?? 0,
      examId: (json['examId'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      questionIds: (json['questionIds'] is List)
          ? (json['questionIds'] as List)
              .map((e) => (e as num).toInt())
              .toList(growable: true)
          : <int>[],
      numbers: (json['numbers'] is List)
          ? (json['numbers'] as List).map((e) => e.toString()).toList(growable: true)
          : <String>[],
      unmatched: (json['unmatched'] as num?)?.toInt() ?? 0,
      checkedAt: (json['checkedAt'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        'examId': examId,
        'name': name,
        'questionIds': questionIds,
        'numbers': numbers,
        'unmatched': unmatched,
        'checkedAt': checkedAt,
        'message': message,
      };

  ExamReview copyWith({String? message}) => ExamReview(
        taskId: taskId,
        examId: examId,
        name: name,
        questionIds: questionIds,
        numbers: numbers,
        unmatched: unmatched,
        checkedAt: checkedAt,
        message: message ?? this.message,
      );
}

/// 本地错题记录（复刻 LocalMistake）
class LocalMistake {
  const LocalMistake({
    required this.id,
    required this.examId,
    required this.questionId,
    required this.isRelatedGroup,
    required this.subject,
    required this.source,
    required this.number,
    required this.creationTime,
    required this.stem,
    required this.answer,
    required this.analysis,
    required this.stemShoot,
    required this.earned,
    required this.full,
    required this.sync,
    this.syncError = '',
  });

  final String id;
  final int examId;
  final int questionId;
  final bool isRelatedGroup;
  final String subject;
  final String source;
  final String number;
  final String creationTime;
  final String stem;
  final String answer;
  final String analysis;
  final String stemShoot;
  final num earned;
  final num full;
  final String sync; // pending | synced
  final String syncError;

  factory LocalMistake.fromJson(Map<String, dynamic> json) => LocalMistake(
        id: (json['id'] ?? '').toString(),
        examId: (json['examId'] as num?)?.toInt() ?? 0,
        questionId: (json['questionId'] as num?)?.toInt() ?? 0,
        isRelatedGroup: json['isRelatedGroup'] == true,
        subject: (json['subject'] ?? '').toString(),
        source: (json['source'] ?? '').toString(),
        number: (json['number'] ?? '').toString(),
        creationTime: (json['creationTime'] ?? '').toString(),
        stem: (json['stem'] ?? '').toString(),
        answer: (json['answer'] ?? '').toString(),
        analysis: (json['analysis'] ?? '').toString(),
        stemShoot: (json['stemShoot'] ?? '').toString(),
        earned: (json['earned'] as num?) ?? 0,
        full: (json['full'] as num?) ?? 0,
        sync: (json['sync'] ?? 'pending').toString(),
        syncError: (json['syncError'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'examId': examId,
        'questionId': questionId,
        'isRelatedGroup': isRelatedGroup,
        'subject': subject,
        'source': source,
        'number': number,
        'creationTime': creationTime,
        'stem': stem,
        'answer': answer,
        'analysis': analysis,
        'stemShoot': stemShoot,
        'earned': earned,
        'full': full,
        'sync': sync,
        'syncError': syncError,
      };

  LocalMistake copyWith({
    String? stemShoot,
    String? sync,
    String? syncError,
  }) =>
      LocalMistake(
        id: id,
        examId: examId,
        questionId: questionId,
        isRelatedGroup: isRelatedGroup,
        subject: subject,
        source: source,
        number: number,
        creationTime: creationTime,
        stem: stem,
        answer: answer,
        analysis: analysis,
        stemShoot: stemShoot ?? this.stemShoot,
        earned: earned,
        full: full,
        sync: sync ?? this.sync,
        syncError: syncError ?? this.syncError,
      );
}

/// 本地识别 / 错题记录的存储与识别逻辑
class ExamReviewStore {
  ExamReviewStore._();

  static final ExamReviewStore instance = ExamReviewStore._();

  final Map<String, ExamReview> _reviews = <String, ExamReview>{};

  String _reviewKey(String accountKey, int taskId) => 'exam_review_${_safe(accountKey)}_$taskId';

  String _mistakesKey(String accountKey) => 'mistakes_${_safe(accountKey)}';

  String _safe(String value) => value.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

  Future<ExamReview?> getReview(String accountKey, int taskId) async {
    final cached = _reviews[_reviewKey(accountKey, taskId)];
    if (cached != null) return cached;
    final raw = await LocalStore.instance.readSecret(_reviewKey(accountKey, taskId));
    if (raw == null || raw.isEmpty) return null;
    try {
      final review = ExamReview.fromJson(Map<String, dynamic>.from(jsonDecode(raw)));
      _reviews[_reviewKey(accountKey, taskId)] = review;
      return review;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveReview(String accountKey, ExamReview review) async {
    _reviews[_reviewKey(accountKey, review.taskId)] = review;
    await LocalStore.instance
        .writeSecret(_reviewKey(accountKey, review.taskId), jsonEncode(review.toJson()));
  }

  Future<void> setReviewMessage(
    String accountKey,
    int taskId,
    String message,
  ) async {
    final review = await getReview(accountKey, taskId);
    if (review == null) return;
    await saveReview(accountKey, review.copyWith(message: message));
  }

  Future<List<LocalMistake>> listLocalMistakes(String accountKey) async {
    final raw = await LocalStore.instance.readSecret(_mistakesKey(accountKey));
    if (raw == null || raw.isEmpty) return <LocalMistake>[];
    try {
      final list = jsonDecode(raw);
      if (list is! List) return <LocalMistake>[];
      return list
          .whereType<Map>()
          .map((e) => LocalMistake.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return <LocalMistake>[];
    }
  }

  Future<void> saveLocalMistakes(String accountKey, List<LocalMistake> items) async {
    await LocalStore.instance
        .writeSecret(_mistakesKey(accountKey), jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  /// 依据官方题目分析识别本人错题（复刻 analysisWrongQuestions）
  ///
  /// 只信 errorStudents 中的本人 studentId，不用班级错误数/姓名/分数。
  static ({List<Map<String, dynamic>> questions, int unmatched}) analysisWrongQuestions(
    Map<String, dynamic> task,
    Map<String, dynamic> data,
    String studentId,
  ) {
    if (studentId.isEmpty) throw Exception('无法识别当前学生 ID，请重新登录');
    final groups = data['testGroupAnalysis'];
    if (groups is! List) throw Exception('官方未返回题目分析，不能判断本人错题');

    final questions = <Map<String, dynamic>>[];
    final taskGroups = task['groups'];
    if (taskGroups is List) {
      for (final group in taskGroups) {
        if (group is Map && group['questions'] is List) {
          for (final question in group['questions'] as List) {
            if (question is Map) questions.add(Map<String, dynamic>.from(question));
          }
        }
      }
    }
    final byId = <int, Map<String, dynamic>>{};
    for (final question in questions) {
      final id = (question['id'] as num?)?.toInt();
      if (id != null) byId[id] = question;
    }

    final selected = <int, Map<String, dynamic>>{};
    var unmatched = 0;

    void visit(dynamic node, Map<String, dynamic>? parent) {
      if (node is! Map) return;
      final id = (node['questionId'] as num?)?.toInt();
      final question = (id != null ? byId[id] : null) ?? parent;
      final errorStudents = node['errorStudents'];
      var personalError = false;
      if (errorStudents is List) {
        for (final student in errorStudents) {
          final value = student is Map
              ? (student['studentUserId'] ?? student['studentId'] ?? student['id']).toString()
              : student.toString();
          if (value == studentId) {
            personalError = true;
            break;
          }
        }
      }
      if (personalError) {
        final questionId = (question?['id'] as num?)?.toInt();
        if (questionId != null && questionId > 0) {
          selected[questionId] = question!;
        } else {
          unmatched++;
        }
      }
      final children = node['childrenAnalysis'];
      if (children is List) {
        for (final child in children) {
          visit(child, question);
        }
      }
    }

    for (final group in groups) {
      if (group is! Map) continue;
      final nodes = group['testQuestionAnalysis'];
      if (nodes is List) {
        for (final node in nodes) {
          visit(node, null);
        }
      }
    }

    return (questions: selected.values.toList(), unmatched: unmatched);
  }

  /// 已公布分数且得分低于满分的题目（复刻 gradedWrongQuestions）
  static List<Map<String, dynamic>> gradedWrongQuestions(Map<String, dynamic> task) {
    if (task['enableScore'] != true) return <Map<String, dynamic>>[];
    final result = <Map<String, dynamic>>[];
    final groups = task['groups'];
    if (groups is! List) return result;
    for (final group in groups) {
      if (group is! Map) continue;
      final questions = group['questions'];
      if (questions is! List) continue;
      for (final raw in questions) {
        if (raw is! Map) continue;
        final question = Map<String, dynamic>.from(raw);
        final id = (question['id'] as num?)?.toInt();
        final earned = question['originScore'];
        final full = question['score'];
        if (id == null || id <= 0) continue;
        if (earned is! num || !earned.isFinite || earned < 0) continue;
        if (full is! num || !full.isFinite || full <= 0) continue;
        if (earned < full) result.add(question);
      }
    }
    return result;
  }
}
