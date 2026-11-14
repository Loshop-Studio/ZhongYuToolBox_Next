import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/session_manager.dart';
import '../../core/storage/local_store.dart';
import '../../core/util/formatters.dart';
import '../../core/util/urls.dart';
import '../../data/api/mistake_v2_api.dart';
import '../../data/models/mistake_v2.dart';
import '../../shared/widgets/common.dart';
import '../../core/web/app_webview_environment.dart';
import '../assessment/mistake_pages.dart';

class MistakeBookEntryPage extends StatefulWidget {
  const MistakeBookEntryPage({super.key});

  @override
  State<MistakeBookEntryPage> createState() => _MistakeBookEntryPageState();
}

class _MistakeBookEntryPageState extends State<MistakeBookEntryPage> {
  String? _version;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await LocalStore.instance.init();
    final saved = LocalStore.instance.getString(
      LocalStore.keyMistakeBookVersion,
    );
    if (!mounted) return;
    if (saved == 'v1' || saved == 'v2') {
      setState(() => _version = saved);
      return;
    }
    final selected = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('选择错题本版本'),
        content: const Text('请选择要使用的错题本，之后可以在设置中切换。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'v1'),
            child: const Text('旧版错题本'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'v2'),
            child: const Text('新版错题本'),
          ),
        ],
      ),
    );
    if (selected == null || !mounted) return;
    await LocalStore.instance.setString(
      LocalStore.keyMistakeBookVersion,
      selected,
    );
    setState(() => _version = selected);
  }

  @override
  Widget build(BuildContext context) {
    if (_version == null)
      return const Scaffold(body: LoadingView(text: '正在准备错题本…'));
    return _version == 'v2' ? const MistakeV2Page() : const MistakeBooksPage();
  }
}

class MistakeV2Page extends StatefulWidget {
  const MistakeV2Page({super.key});

  @override
  State<MistakeV2Page> createState() => _MistakeV2PageState();
}

class _MistakeV2PageState extends State<MistakeV2Page> {
  final ScrollController _scrollController = ScrollController();
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  List<MistakeTopic> _topics = const [];
  List<MistakeItemV2> _items = const [];
  Set<int> _selectedTopics = <int>{};
  int _total = 0;
  bool get _hasMore => _items.length < _total;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final topics = await MistakeV2Api.getTopics();
      final result = await MistakeV2Api.search(
        topicIds: _selectedTopics.toList(),
      );
      if (!mounted) return;
      setState(() {
        _topics = topics;
        _items = result.items;
        _total = result.total;
        _loading = false;
      });
      _scheduleAutoLoad();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _loading || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final result = await MistakeV2Api.search(
        topicIds: _selectedTopics.toList(),
        skipCount: _items.length,
      );
      if (!mounted) return;
      setState(() {
        _items = [..._items, ...result.items];
        _total = result.items.isEmpty ? _items.length : result.total;
        _loadingMore = false;
      });
      _scheduleAutoLoad();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
      showToast(context, e.toString());
    }
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.extentAfter < 320) {
      _loadMore();
    }
  }

  void _scheduleAutoLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _onScroll();
    });
  }

  Future<void> _filter() async {
    final result = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          _TopicFilterSheet(topics: _topics, selected: _selectedTopics),
    );
    if (result == null) return;
    setState(() => _selectedTopics = result);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Text('错题本'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '首页'),
              Tab(text: '所有错题'),
              Tab(text: '错题集'),
            ],
          ),
          actions: [
            IconButton(
              tooltip: '筛选科目',
              onPressed: _topics.isEmpty ? null : _filter,
              icon: const Icon(Icons.filter_list),
            ),
            IconButton(
              tooltip: '刷新',
              onPressed: _load,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            const _ReviewHomeTab(),
            Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: _body(),
              ),
            ),
            const _CollectionsTab(),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) return const LoadingView(text: '正在加载新版错题…');
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_items.isEmpty)
      return const EmptyView(icon: Icons.task_alt, text: '暂无错题');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            _selectedTopics.isEmpty
                ? '全部科目 · 共 $_total 道'
                : '已筛选 ${_selectedTopics.length} 个科目 · 共 $_total 道',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            itemCount: _items.length + (_loadingMore ? 1 : 0),
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) => index == _items.length
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _loadingMore
                          ? const CircularProgressIndicator()
                          : const SizedBox.shrink(),
                    ),
                  )
                : _itemTile(_items[index], index),
          ),
        ),
      ],
    );
  }

  Widget _itemTile(MistakeItemV2 item, int index) {
    final image = item.stemShoot.isEmpty
        ? null
        : imageDisplayUrl(absoluteOssUrl(item.stemShoot));
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      leading: SizedBox(
        width: 76,
        height: 64,
        child: image == null
            ? const Icon(Icons.image_outlined, size: 28)
            : CachedNetworkImage(imageUrl: image, fit: BoxFit.cover),
      ),
      title: Text(
        item.displayTitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        [
          item.topicName,
          if (item.number?.isNotEmpty ?? false) '第${item.number}题',
          formatDateTime(item.creationTime),
        ].where((e) => e.isNotEmpty).join(' · '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _openMistake(context, item),
    );
  }
}

class _TopicFilterSheet extends StatefulWidget {
  const _TopicFilterSheet({required this.topics, required this.selected});
  final List<MistakeTopic> topics;
  final Set<int> selected;
  @override
  State<_TopicFilterSheet> createState() => _TopicFilterSheetState();
}

void _openMistake(BuildContext context, MistakeItemV2 item) {
  final query = Uri(
    queryParameters: {
      'custom': item.isCustom.toString(),
      'stem': item.stemShoot,
    },
  ).query;
  context.push('/mistake-v2/item/${item.id}?$query');
}

class _ReviewHomeTab extends StatefulWidget {
  const _ReviewHomeTab();
  @override
  State<_ReviewHomeTab> createState() => _ReviewHomeTabState();
}

class _ReviewHomeTabState extends State<_ReviewHomeTab> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await MistakeV2Api.getReviewHome();
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView(text: '正在加载复习概览…');
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    final data = _data ?? const <String, dynamic>{};
    final performance = data['performance'] is Map
        ? Map<String, dynamic>.from(data['performance'])
        : const <String, dynamic>{};
    final modes = [
      ('推荐练习', data['recommend']),
      ('待加强', data['needStrengthen']),
      ('巩固中', data['consolidating']),
      ('已掌握', data['mastered']),
    ];
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          Text('复习概览', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text((performance['summaryText'] ?? '暂无复习概览').toString()),
          const SizedBox(height: 16),
          for (final entry in modes) ...[
            _ReviewModeCard(name: entry.$1, data: entry.$2),
            const Divider(height: 1),
          ],
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _Metric(label: '新增错题', value: performance['newMistakeCount']),
                _Metric(
                  label: '练习题数',
                  value: performance['practiceQuestionCount'],
                ),
                _Metric(label: '复习天数', value: performance['practiceDayCount']),
                _Metric(
                  label: '连续复习',
                  value: performance['continuousReviewDays'],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewModeCard extends StatelessWidget {
  const _ReviewModeCard({required this.name, required this.data});
  final String name;
  final dynamic data;
  @override
  Widget build(BuildContext context) {
    final map = data is Map
        ? Map<String, dynamic>.from(data)
        : const <String, dynamic>{};
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.school_outlined),
      title: Text(name),
      subtitle: Text((map['description'] ?? '').toString()),
      trailing: Text('${map['count'] ?? 0} 题'),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final dynamic value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('${value ?? 0}', style: Theme.of(context).textTheme.titleLarge),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

class _CollectionsTab extends StatefulWidget {
  const _CollectionsTab();
  @override
  State<_CollectionsTab> createState() => _CollectionsTabState();
}

class _CollectionsTabState extends State<_CollectionsTab> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _collections = const [];
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await MistakeV2Api.getCollections();
      if (mounted)
        setState(() {
          _collections = rows;
          _loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView(text: '正在加载错题集…');
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => _createCollection(),
              icon: const Icon(Icons.create_new_folder_outlined),
              label: const Text('添加错题集'),
            ),
          ),
          const SizedBox(height: 12),
          if (_collections.isEmpty)
            const EmptyView(icon: Icons.folder_open_outlined, text: '暂无错题集')
          else
            for (var i = 0; i < _collections.length; i++) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.folder_outlined),
                title: Text((_collections[i]['name'] ?? '未命名错题集').toString()),
                subtitle: Text('${_collections[i]['itemCount'] ?? 0} 道错题'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        MistakeCollectionItemsPage(collection: _collections[i]),
                  ),
                ),
              ),
              if (i < _collections.length - 1) const Divider(height: 1),
            ],
        ],
      ),
    );
  }

  Future<void> _createCollection() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加错题集'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 30,
          decoration: const InputDecoration(hintText: '请输入错题集名称'),
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('创建'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;
    try {
      await MistakeV2Api.createCollection(name);
      await _load();
      if (mounted) showToast(context, '错题集已创建');
    } catch (e) {
      if (mounted) showToast(context, e.toString());
    }
  }
}

class MistakeCollectionItemsPage extends StatefulWidget {
  const MistakeCollectionItemsPage({super.key, required this.collection});
  final Map<String, dynamic> collection;
  @override
  State<MistakeCollectionItemsPage> createState() =>
      _MistakeCollectionItemsPageState();
}

class _MistakeCollectionItemsPageState
    extends State<MistakeCollectionItemsPage> {
  bool _loading = true;
  String? _error;
  List<MistakeItemV2> _items = const [];
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await MistakeV2Api.getCollectionItems(
        '${widget.collection['id']}',
      );
      if (mounted)
        setState(() {
          _items = result.items;
          _loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text((widget.collection['name'] ?? '错题集').toString()),
    ),
    body: _loading
        ? const LoadingView(text: '正在加载错题…')
        : _error != null
        ? ErrorView(message: _error!, onRetry: _load)
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final item = _items[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.displayTitle),
                subtitle: Text(item.topicName),
                trailing: IconButton(
                  tooltip: '移出错题集',
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => _removeItem(item),
                ),
                onTap: () => _openMistake(context, item),
              );
            },
          ),
  );

  Future<void> _removeItem(MistakeItemV2 item) async {
    final ok = await confirmDialog(
      context,
      title: '移出错题集',
      content: '只会从当前错题集中移除，不会删除错题。',
      confirmText: '移除',
      danger: true,
    );
    if (!ok) return;
    try {
      await MistakeV2Api.removeItemsFromCollection(
        collectionId: (widget.collection['id'] as num?)?.toInt() ?? 0,
        itemIds: [int.tryParse(item.id) ?? 0],
      );
      await _load();
      if (mounted) showToast(context, '已移出错题集');
    } catch (e) {
      if (mounted) showToast(context, e.toString());
    }
  }
}

class _TopicFilterSheetState extends State<_TopicFilterSheet> {
  late Set<int> _selected = {...widget.selected};
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '筛选科目',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () => setState(_selected.clear),
                child: const Text('清空'),
              ),
            ],
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final topic in widget.topics)
                    FilterChip(
                      label: Text('${topic.name} ${topic.count}'),
                      selected: _selected.contains(topic.id),
                      onSelected: (value) => setState(
                        () => value
                            ? _selected.add(topic.id)
                            : _selected.remove(topic.id),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context, _selected),
              child: const Text('应用筛选'),
            ),
          ),
        ],
      ),
    ),
  );
}

class MistakeV2DetailPage extends StatefulWidget {
  const MistakeV2DetailPage({
    super.key,
    required this.itemId,
    required this.custom,
    this.fallbackStem = '',
  });
  final String itemId;
  final bool custom;
  final String fallbackStem;
  @override
  State<MistakeV2DetailPage> createState() => _MistakeV2DetailPageState();
}

class _MistakeV2DetailPageState extends State<MistakeV2DetailPage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _detail;
  int _reloadKey = 0;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final detail = await MistakeV2Api.getDetail(
        widget.itemId,
        custom: widget.custom,
      );
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      if (widget.custom && widget.fallbackStem.isNotEmpty) {
        setState(() {
          _error = null;
          _loading = false;
        });
      } else {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stems =
        (_detail?['extraStems'] is List
                ? (_detail!['extraStems'] as List)
                : const [])
            .map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList();
    final qstPath = (_detail?['qstPath'] ?? '').toString();
    final questionId = (_detail?['questionId'] as num?)?.toInt() ?? 0;
    final hasQuestionPage =
        qstPath.isNotEmpty && (!widget.custom || questionId > 0);
    final webViewError = AppWebViewEnvironment.initializationError;
    final body = _loading
        ? const LoadingView(text: '正在加载错题…')
        : _error != null
        ? ErrorView(message: _error!, onRetry: _load)
        : _detail == null && (!widget.custom || widget.fallbackStem.isEmpty)
        ? const EmptyView(text: '该错题详情暂不可用')
        : webViewError != null && hasQuestionPage
        ? ErrorView(message: webViewError)
        : hasQuestionPage
        ? _questionWebView(qstPath)
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final url
                  in stems.isEmpty && widget.fallbackStem.isNotEmpty
                      ? [widget.fallbackStem]
                      : stems)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CachedNetworkImage(
                    imageUrl: imageDisplayUrl(absoluteOssUrl(url)),
                    fit: BoxFit.contain,
                  ),
                ),
              if (stems.isEmpty && widget.fallbackStem.isEmpty)
                const EmptyView(
                  icon: Icons.image_not_supported_outlined,
                  text: '暂无题目图片',
                ),
            ],
          );
    return Scaffold(
      appBar: AppBar(
        title: const Text('错题详情'),
        actions: [
          IconButton(
            tooltip: '加入错题集',
            icon: const Icon(Icons.create_new_folder_outlined),
            onPressed: _addToCollection,
          ),
        ],
      ),
      body: body,
    );
  }

  Future<void> _addToCollection() async {
    final collections = await MistakeV2Api.getCollections();
    if (!mounted) return;
    if (collections.isEmpty) {
      showToast(context, '请先创建错题集');
      return;
    }
    final selected = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('加入错题集'),
        children: [
          for (final collection in collections)
            SimpleDialogOption(
              onPressed: () =>
                  Navigator.pop(context, (collection['id'] as num?)?.toInt()),
              child: Text((collection['name'] ?? '未命名错题集').toString()),
            ),
        ],
      ),
    );
    if (selected == null) return;
    try {
      await MistakeV2Api.addItemsToCollections(
        collectionIds: [selected],
        itemIds: [int.tryParse(widget.itemId) ?? 0],
      );
      if (mounted) showToast(context, '已加入错题集');
    } catch (e) {
      if (mounted) showToast(context, e.toString());
    }
  }

  Widget _questionWebView(String qstPath) {
    final uri = Uri.parse(ApiClient.instance.resolveUrl(qstPath, null));
    final url = uri.replace(
      queryParameters: {...uri.queryParameters, 'showAnalysis': 'true'},
    );
    final token = SessionManager.instance.session.token;
    return InAppWebView(
      key: ValueKey(_reloadKey),
      webViewEnvironment: AppWebViewEnvironment.instance,
      initialUrlRequest: URLRequest(
        url: WebUri(url.toString()),
        headers: token.isEmpty ? null : {'Authorization': 'Bearer $token'},
      ),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        supportZoom: true,
        transparentBackground: true,
      ),
      onReceivedError: (controller, request, error) {
        if (request.isForMainFrame == true && mounted)
          setState(() => _error = '题目加载失败：${error.description}');
      },
      onReceivedHttpError: (controller, request, response) {
        if (request.isForMainFrame == true &&
            (response.statusCode ?? 0) >= 400 &&
            mounted)
          setState(() => _error = '题目加载失败（HTTP ${response.statusCode}）');
      },
    );
  }
}
