import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../core/network/api_exception.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/storage/image_cache_manager.dart';
import '../../core/util/urls.dart';
import '../../data/api/quora_api.dart';
import '../../data/models/quora.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/user_avatar.dart';

/// 随身答列表（复刻 QuoraView：领域 / 学科 / 关键词 / 时间 / 关注筛选 + 滚动懒加载）
class QaPage extends StatefulWidget {
  const QaPage({super.key});

  @override
  State<QaPage> createState() => _QaPageState();
}

class _QaPageState extends State<QaPage> {
  static const int _take = 12;

  final ScrollController _controller = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<QuoraCatalog> _catalogs = <QuoraCatalog>[];
  final List<QuoraSession> _sessions = <QuoraSession>[];

  int _catalogId = 0;
  int _topicId = 0;
  String _keyword = '';
  int _watchMode = 0; // 0 全部 / 1 我关注 / 2 已回复 / 3 未回复
  DateTimeRange? _updateRange;
  DateTimeRange? _joinRange;
  bool _filterExpanded = false;

  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    _bootstrap();
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 240) {
      _loadMore();
    }
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final catalogs = await QuoraApi.getCatalogs();
      if (!mounted) return;
      setState(() => _catalogs = catalogs);
      await _reload();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = errorText(e);
        _loading = false;
      });
    }
  }

  List<int> get _justWatch {
    switch (_watchMode) {
      case 1:
        return const <int>[1];
      case 2:
        return const <int>[2];
      case 3:
        return const <int>[3];
      default:
        return const <int>[1, 2, 3, 4];
    }
  }

  String _day(DateTime time) {
    String pad(int v) => v.toString().padLeft(2, '0');
    return '${time.year}-${pad(time.month)}-${pad(time.day)}';
  }

  ({String start, String end}) _range(DateTimeRange? range) {
    if (range == null) return (start: '', end: '');
    return (
      start: '${_day(range.start)}T00:00:00',
      end: '${_day(range.end)}T23:59:59',
    );
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final update = _range(_updateRange);
      final join = _range(_joinRange);
      final sessions = await QuoraApi.getSessions(
        keyword: _keyword,
        catalogId: _catalogId,
        topicId: _topicId,
        skip: 0,
        take: _take,
        justWatch: _justWatch,
        updateStart: update.start,
        updateEnd: update.end,
        joinStart: join.start,
        joinEnd: join.end,
      );
      if (!mounted) return;
      setState(() {
        _sessions
          ..clear()
          ..addAll(sessions);
        _hasMore = sessions.length >= _take;
        _loading = false;
      });
      // 未填满可视区时自动续拉（复刻 fillViewport）
      if (_hasMore && _sessions.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _fillViewport(update, join),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = errorText(e);
        _loading = false;
      });
    }
  }

  Future<void> _fillViewport(
    ({String start, String end}) update,
    ({String start, String end}) join,
  ) async {
    for (var guard = 0; guard < 30; guard++) {
      if (!mounted || !_hasMore || _loadingMore) return;
      if (_controller.hasClients &&
          _controller.position.maxScrollExtent <=
              _controller.position.viewportDimension + 240) {
        final loaded = await _loadMorePage(update, join);
        if (!loaded) return;
      } else {
        return;
      }
    }
  }

  Future<bool> _loadMorePage(
    ({String start, String end}) update,
    ({String start, String end}) join,
  ) async {
    setState(() => _loadingMore = true);
    try {
      final sessions = await QuoraApi.getSessions(
        keyword: _keyword,
        catalogId: _catalogId,
        topicId: _topicId,
        skip: _sessions.length,
        take: _take,
        justWatch: _justWatch,
        updateStart: update.start,
        updateEnd: update.end,
        joinStart: join.start,
        joinEnd: join.end,
      );
      if (!mounted) return false;
      setState(() {
        _sessions.addAll(sessions);
        _hasMore = sessions.length >= _take;
        _loadingMore = false;
      });
      return sessions.isNotEmpty;
    } catch (_) {
      if (!mounted) return false;
      setState(() => _loadingMore = false);
      return false;
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasMore) return;
    await _loadMorePage(_range(_updateRange), _range(_joinRange));
  }

  Future<void> _pickDate({required bool update}) async {
    final now = DateTime.now();
    final current =
        (update ? _updateRange : _joinRange) ??
        DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1),
      initialDateRange: current,
    );
    if (picked == null) return;
    setState(() {
      if (update) {
        _updateRange = picked;
      } else {
        _joinRange = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktopLayout;
    return Scaffold(
      appBar: AppBar(
        title: const Text('问答'),
        actions: [
          IconButton(
            tooltip: '筛选',
            icon: Badge(
              isLabelVisible: _filterActive,
              child: const Icon(Icons.tune),
            ),
            onPressed: () => setState(() => _filterExpanded = !_filterExpanded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: desktop ? 900 : 760),
          child: Column(
            children: [
              _buildCatalogBar(),
              if (_filterExpanded) _buildFilterPanel(),
              const Divider(height: 1),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  bool get _filterActive =>
      _topicId != 0 ||
      _keyword.isNotEmpty ||
      _watchMode != 0 ||
      _updateRange != null ||
      _joinRange != null;

  Widget _buildCatalogBar() {
    if (_catalogs.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          // 没有「全部」分类：默认即全部，再点一次已选中的分类可取消筛选
          for (var index = 0; index < _catalogs.length; index++)
            Padding(
              padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
              child: FilterChip(
                label: Text(
                  _catalogs[index].name.isEmpty ? '未命名' : _catalogs[index].name,
                ),
                selected: _catalogId.toString() == _catalogs[index].id,
                onSelected: (selected) {
                  setState(() {
                    _catalogId = selected
                        ? int.tryParse(_catalogs[index].id) ?? 0
                        : 0;
                  });
                  _reload();
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: _searchController,
              hint: '关键词',
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                setState(() => _keyword = value.trim());
                _reload();
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _topicId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: '学科',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<int>(value: 0, child: Text('全部学科')),
                for (final subject in AppConfig.subjects)
                  DropdownMenuItem<int>(
                    value: subject.id,
                    child: Text(subject.name),
                  ),
              ],
              onChanged: (value) => setState(() => _topicId = value ?? 0),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickDate(update: true),
                  icon: const Icon(Icons.event_outlined, size: 18),
                  label: Text(
                    _updateRange == null
                        ? '更新时间'
                        : '更新 ${_day(_updateRange!.start)} ~ ${_day(_updateRange!.end)}',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _pickDate(update: false),
                  icon: const Icon(Icons.event_available_outlined, size: 18),
                  label: Text(
                    _joinRange == null
                        ? '参与时间'
                        : '参与 ${_day(_joinRange!.start)} ~ ${_day(_joinRange!.end)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment<int>(value: 0, label: Text('全部')),
                ButtonSegment<int>(value: 1, label: Text('我关注')),
                ButtonSegment<int>(value: 2, label: Text('已回复')),
                ButtonSegment<int>(value: 3, label: Text('未回复')),
              ],
              selected: <int>{_watchMode},
              onSelectionChanged: (selection) =>
                  setState(() => _watchMode = selection.first),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _topicId = 0;
                      _keyword = '';
                      _watchMode = 0;
                      _updateRange = null;
                      _joinRange = null;
                      _searchController.clear();
                    });
                    _reload();
                  },
                  child: const Text('重置'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () {
                    setState(() => _keyword = _searchController.text.trim());
                    _reload();
                  },
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text('搜索'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView(text: '正在加载问题…');
    if (_error != null) return ErrorView(message: _error!, onRetry: _reload);
    if (_sessions.isEmpty) {
      return const EmptyView(icon: Icons.forum_outlined, text: '暂时没有可查看的问题');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        // 按可用宽度决定每行卡片数
        final columns = constraints.maxWidth >= 880
            ? 3
            : (constraints.maxWidth >= 520 ? 2 : 1);
        final rows = (_sessions.length / columns).ceil();
        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView.separated(
            controller: _controller,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
            itemCount: rows + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, rowIndex) {
              if (rowIndex >= rows) return _buildFooter();
              final start = rowIndex * columns;
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < columns; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: start + i < _sessions.length
                            ? _SessionCard(
                                session: _sessions[start + i],
                                onTap: () => context.push(
                                  '/qa/${_sessions[start + i].id}'
                                  '?askUserPhoto=${Uri.encodeComponent(_sessions[start + i].askUserPhoto)}',
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

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
          '已全部加载（${_sessions.length} 个问题）',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}

/// 单个问题卡片（多列时高度自适应）
class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.onTap});

  final QuoraSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UserAvatar(
                    name: session.askUserName,
                    photo: session.askUserPhoto,
                    radius: 14,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      session.askUserName.isEmpty
                          ? '匿名提问'
                          : session.askUserName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  if (session.unRead)
                    Icon(Icons.circle, size: 8, color: theme.colorScheme.error),
                  if (session.topicName.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        session.topicName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                session.summary.isEmpty ? '无标题' : session.summary,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              if (session.snapshot.isNotEmpty) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: imageDisplayUrl(absoluteOssUrl(session.snapshot)),
                    cacheManager: ZyImageCacheManager.instance,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
