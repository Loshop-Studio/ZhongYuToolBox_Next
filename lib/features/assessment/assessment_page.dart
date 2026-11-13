import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_exception.dart';
import '../../core/responsive/breakpoints.dart';
import '../../data/api/exam_api.dart';
import '../../data/models/exam.dart';
import '../../shared/widgets/common.dart';

/// 测评 tab：新测评列表（已完成作业 / 待处理作业 / 全部作业）
class AssessmentPage extends StatefulWidget {
  const AssessmentPage({super.key});

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage>
    with SingleTickerProviderStateMixin {
  static const List<({String label, int type})> _tabs = [
    (label: '已完成作业', type: 4),
    (label: '待处理作业', type: 1),
    (label: '全部作业', type: 2),
  ];

  final ScrollController _controller = ScrollController();
  late final TabController _tabController;
  final List<ExamTask> _tasks = <ExamTask>[];
  int _listType = 4;
  int _page = 1;
  int _total = 0;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _requestSeq = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    final initial = _tabs.indexWhere((tab) => tab.type == _listType);
    _tabController.index = initial < 0 ? 0 : initial;
    _tabController.addListener(_onTabChanged);
    _controller.addListener(_onScroll);
    _reload();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final type = _tabs[_tabController.index].type;
    if (type == _listType) return;
    setState(() {
      _listType = type;
      _tasks.clear();
    });
    _reload();
  }

  void _onScroll() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 240) {
      _loadMore();
    }
  }

  /// 列表底部：加载中 / 加载更多 / 已全部加载
  Widget _buildFooter() {
    if (_loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (_hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: TextButton(onPressed: _loadMore, child: const Text('加载更多')),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          '已全部加载（${_tasks.length} 项）',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }

  /// 后端对「已完成作业」的 totalCount 只按单页返回（恒为 20），
  /// 因此不能拿 totalCount 判断到底，改为「本页是否满页」，
  /// 由 [_loadMore] 的去重逻辑在拿到重复/空页时收尾。
  bool _computeHasMore({required int returned}) {
    return returned >= ExamApi.pageSize;
  }

  String _taskKey(ExamTask task) {
    return task.id > 0
        ? 'id:${task.id}'
        : 'name:${task.name}|${task.createTime}';
  }

  Future<void> _reload() async {
    final seq = ++_requestSeq;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ExamApi.getTasks(1, taskListType: _listType);
      if (!mounted || seq != _requestSeq) return;
      setState(() {
        _tasks
          ..clear()
          ..addAll(result.items);
        _total = result.total;
        _page = 1;
        _hasMore = _computeHasMore(returned: result.items.length);
        _loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _fillViewport(seq));
    } catch (e) {
      if (!mounted || seq != _requestSeq) return;
      setState(() {
        _error = errorText(e);
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasMore) return;
    final seq = _requestSeq;
    setState(() => _loadingMore = true);
    try {
      final result = await ExamApi.getTasks(_page + 1, taskListType: _listType);
      if (!mounted || seq != _requestSeq) return;
      final known = _tasks.map(_taskKey).toSet();
      final fresh = <ExamTask>[];
      for (final task in result.items) {
        if (known.add(_taskKey(task))) fresh.add(task);
      }
      setState(() {
        if (fresh.isEmpty) {
          // 后端不支持翻页时会重复返回同一页，这里收尾
          _hasMore = false;
        } else {
          _page += 1;
          _tasks.addAll(fresh);
          if (result.total > _total) _total = result.total;
          _hasMore = _computeHasMore(returned: result.items.length);
        }
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted || seq != _requestSeq) return;
      setState(() => _loadingMore = false);
    }
  }

  /// 首屏未填满时自动续拉（复刻 old fillViewport）
  Future<void> _fillViewport(int seq) async {
    for (var guard = 0; guard < 20; guard++) {
      if (!mounted || seq != _requestSeq || !_hasMore || _loadingMore) return;
      if (!_controller.hasClients) return;
      final position = _controller.position;
      if (position.maxScrollExtent > position.viewportDimension + 160) return;
      await _loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktopLayout;
    return Scaffold(
      appBar: AppBar(
        title: const Text('测评'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/mistake'),
            icon: const Icon(Icons.menu_book_outlined, size: 18),
            label: const Text('错题本'),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [for (final tab in _tabs) Tab(text: tab.label)],
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: desktop ? 980 : 760),
          child: Column(
            children: [
              if (!_loading && _error == null && _tasks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _total > _tasks.length
                          ? '共 $_total 项，已加载 ${_tasks.length} 项'
                          : '已加载 ${_tasks.length} 项',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView(text: '正在加载测评…');
    if (_error != null) return ErrorView(message: _error!, onRetry: _reload);
    if (_tasks.isEmpty) {
      return const EmptyView(icon: Icons.assignment_outlined, text: '暂无测评任务');
    }
    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView.separated(
        controller: _controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        itemCount: _tasks.length + 1,
        separatorBuilder: (_, index) => index < _tasks.length - 1
            ? const Divider(height: 1, indent: 56, endIndent: 16)
            : const SizedBox.shrink(),
        itemBuilder: (context, index) {
          if (index >= _tasks.length) return _buildFooter();
          final task = _tasks[index];
          return ListTile(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            leading: Icon(
              Icons.assignment_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              task.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            subtitle: task.subject.isEmpty && task.createTime.isEmpty
                ? null
                : Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      [
                        if (task.subject.isNotEmpty) task.subject,
                        if (task.createTime.isNotEmpty) task.createTime,
                      ].join(' · '),
                    ),
                  ),
            trailing: Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onTap: () => context.push(
              '/exam/${task.id}?name=${Uri.encodeComponent(task.name)}',
            ),
          );
        },
      ),
    );
  }
}
