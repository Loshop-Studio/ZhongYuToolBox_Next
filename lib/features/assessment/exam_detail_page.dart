import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/storage/session_manager.dart';
import '../../core/util/file_saver.dart';
import '../../core/web/app_webview_environment.dart';
import '../../data/api/exam_api.dart';
import '../../data/api/exam_mistake_api.dart';
import '../../data/models/exam.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/html_capture.dart';
import 'exam_review_store.dart';
import 'exam_sync_service.dart';

/// 测评详情：题目 / 概览 / 题目分析（复刻 ExamQuestionsView + Overview + Analysis）
class ExamDetailPage extends StatefulWidget {
  const ExamDetailPage({super.key, required this.taskId, required this.name});

  final int taskId;
  final String name;

  @override
  State<ExamDetailPage> createState() => _ExamDetailPageState();
}

class _ExamDetailPageState extends State<ExamDetailPage> {
  final SessionManager _session = SessionManager.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _numberScroll = ScrollController();

  bool _loading = true;
  String? _error;
  Map<String, dynamic> _task = <String, dynamic>{};
  int _examId = 0;
  List<ExamQuestion> _questions = <ExamQuestion>[];

  /// 当前视图：0 题目 / 1 概览 / 2 分析
  int _view = 0;

  /// 当前题目（直接 WebView 加载 `/Question/View/{id}?showAnalysis=true`）
  int _selectedQuestion = 0;
  bool _questionLoading = true;
  String? _questionError;
  int _questionReload = 0;

  Map<String, dynamic>? _overview;
  Map<String, dynamic>? _analysis;
  ExamReview? _review;

  bool _recognizing = false;
  bool _syncing = false;
  bool _exporting = false;

  String? _captureHtml;
  Completer<Uint8List?>? _captureCompleter;

  String get _accountKey =>
      '${Uri.tryParse(_session.session.apiBaseUrl)?.origin ?? ''}|${_session.session.userId}';

  String get _studentId => _session.session.userId;

  bool get _active => mounted && _session.session.userId == _studentId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _numberScroll.dispose();
    super.dispose();
  }

  /// 桌面鼠标滚轮只能产生 dy，题号条是横向列表，这里映射成横向滚动
  void _onNumberPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (!_numberScroll.hasClients) return;
    final delta = event.scrollDelta.dy != 0
        ? event.scrollDelta.dy
        : event.scrollDelta.dx;
    if (delta == 0) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (_) {
      final position = _numberScroll.position;
      final target = (position.pixels + delta).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      _numberScroll.jumpTo(target);
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final task = await ExamApi.getTask(widget.taskId);
      final examId = (task['examId'] as num?)?.toInt() ?? 0;
      if (examId <= 0) throw ApiException('测评缺少有效 examId');

      final overviewFuture = ExamApi.getOverview(
        examId,
      ).then<Map<String, dynamic>?>((v) => v).catchError((_) => null);
      final analysisFuture = ExamApi.getQuestionAnalysis(
        examId,
      ).then<Map<String, dynamic>?>((v) => v).catchError((_) => null);

      final questions = ExamApi.questionsOf(task);

      final overview = await overviewFuture;
      final analysis = await analysisFuture;

      ExamReview? review = await ExamReviewStore.instance.getReview(
        _accountKey,
        widget.taskId,
      );
      if (ExamReviewStore.canAnalyzeWrongQuestions(analysis)) {
        try {
          review = await _saveReview(task, analysis!, examId);
        } catch (e, stackTrace) {
          // 错题识别是附加能力，失败不能阻止用户进入测评。
          log(
            '[测评详情] 自动识别错题失败 taskId=${widget.taskId}: $e',
            name: 'Assessment',
            stackTrace: stackTrace,
          );
        }
      }

      if (!mounted) return;
      setState(() {
        _task = task;
        _examId = examId;
        _questions = questions;
        _selectedQuestion = questions.isEmpty ? 0 : questions.first.id;
        _questionLoading = _selectedQuestion > 0;
        _questionError = null;
        _overview = overview;
        _analysis = analysis;
        _review = review;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = errorText(e);
        _loading = false;
      });
    }
  }

  Future<ExamReview> _saveReview(
    Map<String, dynamic> task,
    Map<String, dynamic> analysis,
    int examId,
  ) async {
    final detected = ExamReviewStore.analysisWrongQuestions(
      task,
      analysis,
      _studentId,
    );
    final review = ExamReview(
      taskId: widget.taskId,
      examId: examId,
      name: (task['examName'] ?? '测评').toString(),
      questionIds: detected.questions
          .map((q) => (q['id'] as num?)?.toInt() ?? 0)
          .where((e) => e > 0)
          .toList(),
      numbers: detected.questions
          .map((q) => (q['number'] ?? q['name'] ?? '').toString())
          .toList(),
      unmatched: detected.unmatched,
      checkedAt: DateTime.now().toIso8601String(),
    );
    await ExamReviewStore.instance.saveReview(_accountKey, review);
    return review;
  }

  Future<void> _recognize() async {
    setState(() => _recognizing = true);
    try {
      final task = await ExamApi.getTask(widget.taskId);
      final analysis = await ExamApi.getQuestionAnalysis(_examId);
      final review = await _saveReview(task, analysis, _examId);
      if (!mounted) return;
      setState(() => _review = review);
      showToast(context, '已重新识别本人错题');
    } catch (e) {
      if (!mounted) return;
      showToast(context, errorText(e));
    } finally {
      if (mounted) setState(() => _recognizing = false);
    }
  }

  Future<void> _syncMistakes() async {
    final review = _review;
    if (review == null || review.questionIds.isEmpty) {
      showToast(context, '请先完成自动识别');
      return;
    }
    setState(() => _syncing = true);
    try {
      final result = await ExamSyncService.syncExamMistakes(
        widget.taskId,
        _accountKey,
        _studentId,
        capture: _capture,
        isActive: () => _active,
      );
      if (!mounted) return;
      final buffer = StringBuffer();
      if (result.saved > 0) buffer.write('已加入官方错题本 ${result.saved} 题');
      if (result.pending > 0) buffer.write('，${result.pending} 题待同步');
      if (buffer.isEmpty) buffer.write('没有需要同步的错题');
      showToast(context, buffer.toString());
      await ExamReviewStore.instance.setReviewMessage(
        _accountKey,
        widget.taskId,
        buffer.toString(),
      );
      if (!mounted) return;
      final refreshed = await ExamReviewStore.instance.getReview(
        _accountKey,
        widget.taskId,
      );
      setState(() => _review = refreshed);
    } catch (e) {
      if (!mounted) return;
      showToast(context, errorText(e));
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<Uint8List?> _capture(String html) async {
    final completer = Completer<Uint8List?>();
    setState(() {
      _captureHtml = html;
      _captureCompleter = completer;
    });
    return completer.future;
  }

  void _onCaptured(Uint8List? bytes) {
    final completer = _captureCompleter;
    _captureCompleter = null;
    _captureHtml = null;
    if (mounted) setState(() {});
    completer?.complete(bytes);
  }

  Future<void> _exportAnswers() async {
    setState(() => _exporting = true);
    try {
      final bytes = await ExamMistakeApi.exportObjectiveAnswers(_examId);
      final name = (_task['examName'] ?? '测评').toString();
      final path = await FileSaver.save('$name-客观题答案.xlsx', bytes);
      if (!mounted) return;
      showToast(context, path == null ? '已取消保存' : '已保存：$path');
    } catch (e) {
      if (!mounted) return;
      showToast(context, errorText(e));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: context.isPhoneLayout ? _buildSettingsDrawer() : null,
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: Text(
          widget.name.isEmpty ? '测评详情' : widget.name,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (context.isPhoneLayout)
            _buildMoreButton()
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Center(
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('题目')),
                    ButtonSegment(value: 1, label: Text('概览')),
                    ButtonSegment(value: 2, label: Text('分析')),
                  ],
                  selected: {_view},
                  onSelectionChanged: (values) =>
                      setState(() => _view = values.first),
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    padding: WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 10),
                    ),
                    textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 12)),
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: _wrongCount > 0 ? '加入错题本（$_wrongCount 题）' : '加入错题本',
              onPressed: _syncing ? null : _syncMistakes,
              icon: _syncing
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.playlist_add_check),
            ),
            IconButton(
              tooltip: '重新识别',
              onPressed: _recognizing ? null : _recognize,
              icon: _recognizing
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
            ),
            IconButton(
              tooltip: '导出客观题答案',
              onPressed: _exporting ? null : _exportAnswers,
              icon: const Icon(Icons.download_outlined),
            ),
          ],
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          // 分栏布局要铺满整页：Align + maxWidth 会让左右两侧留白
          Positioned.fill(child: _buildBody()),
          if (_captureHtml != null)
            Positioned(
              left: -4000,
              top: 0,
              child: SizedBox(
                width: 720,
                child: HtmlCapture(
                  html: _captureHtml!,
                  onCaptured: _onCaptured,
                ),
              ),
            ),
        ],
      ),
    );
  }

  int get _wrongCount => _review?.questionIds.length ?? 0;

  /// 移动端标题栏放不下，收进「⋯」，点开是右侧抽屉
  Widget _buildMoreButton() {
    return IconButton(
      tooltip: '更多',
      icon: const Icon(Icons.more_vert),
      onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
    );
  }

  Widget _buildSettingsDrawer() {
    final scheme = Theme.of(context).colorScheme;
    final count = _wrongCount;

    Widget viewTile(String label, IconData icon, int value) {
      final selected = _view == value;
      return ListTile(
        leading: Icon(icon, color: selected ? scheme.primary : null),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? scheme.primary : null,
          ),
        ),
        trailing: selected
            ? Icon(Icons.check, size: 18, color: scheme.primary)
            : null,
        selected: selected,
        onTap: () {
          Navigator.of(context).pop();
          setState(() => _view = value);
        },
      );
    }

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text(
                widget.name.isEmpty ? '测评详情' : widget.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            viewTile('题目', Icons.list_alt_outlined, 0),
            viewTile('概览', Icons.dashboard_outlined, 1),
            viewTile('分析', Icons.insights_outlined, 2),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.playlist_add_check),
              title: const Text('加入错题本'),
              subtitle: Text(count > 0 ? '已识别 $count 题' : '尚未识别错题'),
              enabled: !_syncing,
              onTap: _syncing
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      unawaited(_syncMistakes());
                    },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('重新识别本人错题'),
              enabled: !_recognizing,
              onTap: _recognizing
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      unawaited(_recognize());
                    },
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('导出客观题答案'),
              enabled: !_exporting,
              onTap: _exporting
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      unawaited(_exportAnswers());
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView(text: '正在加载测评…');
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);

    // 移动端：题号条放底部横向滚动
    if (context.isPhoneLayout) {
      return Column(
        children: [
          Expanded(child: _buildContent()),
          if (_view == 0) _buildBottomNumbers(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 概览 / 分析没有题号可跳，左栏整条收起，右侧铺满
        if (_view == 0) ...[
          SizedBox(width: 128, child: _buildNumberList()),
          const VerticalDivider(width: 1),
        ],
        Expanded(child: _buildContent()),
      ],
    );
  }

  /// 移动端底部横向题号条
  Widget _buildBottomNumbers() {
    final scheme = Theme.of(context).colorScheme;
    if (_questions.isEmpty) return const SizedBox.shrink();
    final wrong = _review?.questionIds.toSet() ?? const <int>{};

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: ScrollConfiguration(
        // 桌面默认不允许鼠标拖动列表，这里放开，和随身答的横向消息条一致
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: const {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.stylus,
            PointerDeviceKind.invertedStylus,
          },
        ),
        child: Listener(
          onPointerSignal: _onNumberPointerSignal,
          child: ListView.separated(
            controller: _numberScroll,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            itemCount: _questions.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final question = _questions[index];
              final selected = question.id == _selectedQuestion;
              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _selectQuestion(question.id),
                child: Container(
                  constraints: const BoxConstraints(minWidth: 44),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? scheme.primaryContainer
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected ? scheme.primary : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _questionNumber(question, index),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: selected ? scheme.onPrimaryContainer : null,
                        ),
                      ),
                      if (wrong.contains(question.id)) ...[
                        const SizedBox(width: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: scheme.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_view) {
      case 1:
        return _buildOverview();
      case 2:
        return _buildAnalysis();
      default:
        return _buildQuestionWeb();
    }
  }

  Widget _buildNumberList() {
    if (_questions.isEmpty) {
      return const Center(child: Text('暂无题目', style: TextStyle(fontSize: 12)));
    }
    final wrong = _review?.questionIds.toSet() ?? const <int>{};
    final scheme = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _questions.length,
      itemBuilder: (context, index) {
        final question = _questions[index];
        final selected = question.id == _selectedQuestion;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Material(
            color: selected ? scheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _selectQuestion(question.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _questionNumber(question, index),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: selected ? scheme.onPrimaryContainer : null,
                        ),
                      ),
                    ),
                    if (wrong.contains(question.id))
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: scheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _questionNumber(ExamQuestion question, int index) {
    final value = question.raw['number'] ?? question.raw['name'];
    final text = value?.toString() ?? '';
    return text.isEmpty ? '第 ${index + 1} 题' : text;
  }

  void _selectQuestion(int id) {
    if (id <= 0 || id == _selectedQuestion) return;
    setState(() {
      _selectedQuestion = id;
      _questionLoading = true;
      _questionError = null;
    });
  }

  /// 直接 WebView 加载官方单题页（含解析），保真且不用逐题解析 HTML
  Widget _buildQuestionWeb() {
    final id = _selectedQuestion;
    if (id <= 0) {
      return const EmptyView(icon: Icons.help_outline, text: '请选择题目');
    }
    final webViewError = AppWebViewEnvironment.initializationError;
    if (webViewError != null) {
      return ErrorView(message: webViewError);
    }
    final token = _session.session.token;
    final url = ApiClient.instance.resolveUrl(
      '/Question/View/$id?showAnalysis=true',
      null,
    );
    return Stack(
      children: [
        Positioned.fill(
          child: InAppWebView(
            key: ValueKey<String>('$id-$_questionReload'),
            webViewEnvironment: AppWebViewEnvironment.instance,
            initialUrlRequest: URLRequest(
              url: WebUri(url),
              headers: token.isEmpty
                  ? null
                  : {'Authorization': 'Bearer $token'},
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              transparentBackground: true,
              supportZoom: true,
              allowsInlineMediaPlayback: true,
              mediaPlaybackRequiresUserGesture: true,
            ),
            onLoadStop: (controller, uri) {
              if (!mounted) return;
              setState(() {
                _questionLoading = false;
                _questionError = null;
              });
            },
            onReceivedError: (controller, request, error) {
              if (request.isForMainFrame != true) return;
              if (!mounted) return;
              setState(() {
                _questionLoading = false;
                _questionError = '题目加载失败：${error.description}';
              });
            },
          ),
        ),
        if (_questionLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.white,
              child: LoadingView(text: '正在加载题目…'),
            ),
          ),
        if (_questionError != null)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.white,
              child: ErrorView(
                message: _questionError!,
                onRetry: () => setState(() {
                  _questionError = null;
                  _questionLoading = true;
                  _questionReload++;
                }),
              ),
            ),
          ),
      ],
    );
  }

  // ---------- 概览 ----------
  Widget _buildOverview() {
    final overview = _overview;
    if (overview == null) {
      return const EmptyView(
        icon: Icons.data_exploration_outlined,
        text: '暂无概览数据',
      );
    }
    final progressItems =
        <({String label, Map<String, dynamic>? data, Color color})>[
          (
            label: '未提交',
            data: _map(overview['unSubmitItem']),
            color: Theme.of(context).colorScheme.error,
          ),
          (
            label: '未批改',
            data: _map(overview['unCorrectItem']),
            color: Theme.of(context).colorScheme.tertiary,
          ),
          (
            label: '未修订',
            data: _map(overview['unRevisingItem']),
            color: Theme.of(context).colorScheme.primary,
          ),
          (
            label: '修订未批',
            data: _map(overview['unRevisingCorrectItem']),
            color: Theme.of(context).colorScheme.secondary,
          ),
          (
            label: '已完成',
            data: _map(overview['finishItem']),
            color: Theme.of(context).colorScheme.primary,
          ),
        ];

    final students = _list(overview['studentGrades']);
    final unSubmit = _list(overview['unSubmitStudents']);
    final unRevising = _list(overview['unRevisingStudents']);

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatCard(label: '总分', value: _num(overview['examTotalScore'])),
            _StatCard(
              label: '均分',
              value: _num(overview['averageScoreOfCourse']),
            ),
            _StatCard(
              label: '最高分',
              value: _num(overview['highestScoreOfCourse']),
            ),
            _StatCard(
              label: '最低分',
              value: _num(overview['lowestScoreOfCourse']),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in progressItems)
              _ProgressCard(
                label: item.label,
                count: _int(item.data?['count']),
                rate: _rate(item.data?['rate']),
                color: item.color,
              ),
          ],
        ),
        if (unSubmit.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '未提交学生（${unSubmit.length}）',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _names(unSubmit),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
        if (unRevising.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '未修订学生（${unRevising.length}）',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _names(unRevising),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text('学生成绩', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Card(
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('学号')),
                DataColumn(label: Text('姓名')),
                DataColumn(label: Text('班级')),
                DataColumn(label: Text('得分')),
                DataColumn(label: Text('得分率')),
                DataColumn(label: Text('课程排名')),
              ],
              rows: [
                for (final student in students)
                  DataRow(
                    cells: [
                      DataCell(
                        Text((student['studentNumber'] ?? '').toString()),
                      ),
                      DataCell(Text((student['studentName'] ?? '').toString())),
                      DataCell(Text((student['className'] ?? '').toString())),
                      DataCell(Text(_num(student['score']))),
                      DataCell(
                        Text(
                          '${_rate(student['scoreRate']).toStringAsFixed(2)}%',
                        ),
                      ),
                      DataCell(
                        Text((student['rankingOfCourse'] ?? '').toString()),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------- 分析 ----------
  Widget _buildAnalysis() {
    final analysis = _analysis;
    if (analysis == null) {
      return const EmptyView(icon: Icons.insights_outlined, text: '暂无分析数据');
    }
    final groups = _list(analysis['testGroupAnalysis']);
    final studentMap = _studentMap();
    final review = _review;

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
      children: [
        if (review != null)
          Card(
            child: ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: Text('已识别本人错题 ${review.questionIds.length} 题'),
              subtitle: Text(
                review.numbers.isEmpty ? '—' : '题号：${review.numbers.join('、')}',
              ),
            ),
          ),
        const SizedBox(height: 8),
        for (final group in groups)
          _AnalysisGroup(group: group, studentMap: studentMap),
      ],
    );
  }

  Map<String, String> _studentMap() {
    final map = <String, String>{};
    for (final student in _list(_overview?['studentGrades'])) {
      map[(student['studentId'] ?? '').toString()] =
          (student['studentName'] ?? student['studentId'] ?? '').toString();
    }
    return map;
  }
}

class _AnalysisGroup extends StatelessWidget {
  const _AnalysisGroup({required this.group, required this.studentMap});

  final Map<String, dynamic> group;
  final Map<String, String> studentMap;

  @override
  Widget build(BuildContext context) {
    final questions = _list(group['testQuestionAnalysis']);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${(group['number'] ?? '').toString()}、${(group['title'] ?? '').toString()}'
              '（共 ${(group['score'] ?? '').toString()} 分）',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            for (final question in questions)
              _AnalysisQuestion(
                question: question,
                studentMap: studentMap,
                depth: 0,
              ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisQuestion extends StatelessWidget {
  const _AnalysisQuestion({
    required this.question,
    required this.studentMap,
    required this.depth,
  });

  final Map<String, dynamic> question;
  final Map<String, String> studentMap;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorStudents = _list(question['errorStudents']);
    final names = errorStudents
        .map((s) => studentMap[_studentKey(s)] ?? _studentKey(s))
        .join('、');
    return Padding(
      padding: EdgeInsets.only(left: depth * 14.0, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 13,
                child: Text(
                  (question['number'] ?? '').toString(),
                  style: theme.textTheme.labelSmall,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${(question['name'] ?? '').toString()}（${(question['score'] ?? '').toString()} 分）',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Text(
                '错误 ${(question['errorCount'] as num?)?.toInt() ?? 0} 人',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          if (names.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('错误学生：$names', style: theme.textTheme.bodySmall),
          ],
          for (final child in _list(question['childrenAnalysis']))
            _AnalysisQuestion(
              question: child,
              studentMap: studentMap,
              depth: depth + 1,
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.label,
    required this.count,
    required this.rate,
    required this.color,
  });

  final String label;
  final int count;
  final double rate;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text('$count', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 2),
              Text(
                '${rate.toStringAsFixed(0)}%',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _studentKey(dynamic student) {
  if (student is Map) {
    return (student['studentUserId'] ??
            student['studentId'] ??
            student['id'] ??
            '')
        .toString();
  }
  return student.toString();
}

Map<String, dynamic>? _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;
List<Map<String, dynamic>> _list(dynamic value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

int _int(dynamic value) => (value as num?)?.toInt() ?? 0;

double _rate(dynamic value) {
  final rate = (value as num?)?.toDouble() ?? 0;
  return rate <= 1 ? rate * 100 : rate;
}

String _num(dynamic value) {
  if (value == null) return '-';
  if (value is num) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();
  }
  return value.toString();
}

String _names(List<Map<String, dynamic>> students) {
  final values = students
      .map((e) => (e['studentName'] ?? e['name'] ?? '').toString())
      .where((e) => e.isNotEmpty)
      .toList();
  return values.isEmpty ? '—' : values.join('、');
}
