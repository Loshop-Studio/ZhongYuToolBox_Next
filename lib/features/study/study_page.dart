import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_exception.dart';
import '../../core/responsive/breakpoints.dart';
import '../../data/api/column_api.dart';
import '../../data/models/column.dart';
import '../../shared/widgets/common.dart';
import 'column_message_list.dart';

/// 学习 tab：在线专栏 / 我的收藏 / 我的消息（顶部按钮进入优客畅学）
class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage>
    with SingleTickerProviderStateMixin {
  static const List<String> _tabs = ['在线专栏', '我的收藏', '我的消息'];

  late final TabController _tabController;
  final TextEditingController _topicKeywordController = TextEditingController();

  bool _loading = true;
  String? _error;
  List<TopicSpecial> _topics = <TopicSpecial>[];

  bool _favoritesLoading = false;
  String? _favoritesError;
  List<ColumnCatalog> _favorites = <ColumnCatalog>[];

  int get _tab => _tabController.index;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _load();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _topicKeywordController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final topics = await ColumnApi.getTopicSpecial();
      if (!mounted) return;
      setState(() {
        _topics = topics;
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

  Future<void> _loadFavorites() async {
    setState(() {
      _favoritesLoading = true;
      _favoritesError = null;
    });
    try {
      final favorites = await ColumnApi.getSpecialCatalog();
      if (!mounted) return;
      setState(() {
        _favorites = favorites;
        _favoritesLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _favoritesError = errorText(e);
        _favoritesLoading = false;
      });
    }
  }

  void _onTabChanged() {
    final index = _tabController.index;
    if (mounted) setState(() {});
    if (index == 1 && _favorites.isEmpty && !_favoritesLoading) {
      _loadFavorites();
    }
  }

  List<TopicSpecial> get _filteredTopics {
    final keyword = _topicKeywordController.text.trim().toLowerCase();
    if (keyword.isEmpty) return _topics;
    return _topics
        .map((topic) {
          final cols = topic.cols
              .where(
                (col) =>
                    col.name.toLowerCase().contains(keyword) ||
                    topic.topicName.toLowerCase().contains(keyword),
              )
              .toList();
          return TopicSpecial(
            topicId: topic.topicId,
            topicName: topic.topicName,
            cols: cols,
          );
        })
        .where((topic) => topic.cols.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktopLayout;
    return Scaffold(
      appBar: AppBar(
        title: const Text('学习'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/lesson'),
            icon: const Icon(Icons.school_outlined, size: 18),
            label: const Text('优客畅学'),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [for (final label in _tabs) Tab(text: label)],
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: desktop ? 980 : 760),
          child: Column(
            children: [
              if (_tab == 1)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: '刷新',
                      icon: const Icon(Icons.refresh, size: 20),
                      onPressed: _loadFavorites,
                    ),
                  ),
                ),
              Expanded(child: _buildCurrent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrent() {
    switch (_tab) {
      case 1:
        return _buildFavorites();
      case 2:
        return const ColumnMessageList();
      default:
        return _buildTopics();
    }
  }

  Widget _buildTopics() {
    if (_loading) return const LoadingView(text: '正在加载专栏…');
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_topics.isEmpty) {
      return const EmptyView(icon: Icons.monitor_outlined, text: '暂时没有可查看的专栏');
    }
    final topics = _filteredTopics;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 12, bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppTextField(
              controller: _topicKeywordController,
              hint: '搜索专栏名称',
              onSubmitted: (_) => setState(() {}),
              suffix: IconButton(
                icon: const Icon(Icons.search, size: 20),
                onPressed: () => setState(() {}),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (topics.isEmpty)
            const EmptyView(icon: Icons.search_off, text: '没有匹配的专栏')
          else
            for (final topic in topics)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.label_outline,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            topic.topicName.isEmpty ? '未命名学科' : topic.topicName,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                    for (var index = 0; index < topic.cols.length; index++) ...[
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 2,
                        ),
                        leading: const Icon(Icons.article_outlined, size: 20),
                        title: Text(
                          topic.cols[index].name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () => context.push(
                          '/column/${topic.cols[index].id}?name=${Uri.encodeComponent(topic.cols[index].name)}',
                        ),
                      ),
                      if (index < topic.cols.length - 1)
                        const Divider(height: 1, indent: 56, endIndent: 16),
                    ],
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildFavorites() {
    if (_favoritesLoading) return const LoadingView(text: '正在加载收藏夹…');
    if (_favoritesError != null) {
      return ErrorView(message: _favoritesError!, onRetry: _loadFavorites);
    }
    if (_favorites.isEmpty) {
      return const EmptyView(icon: Icons.bookmark_border, text: '还没有收藏夹');
    }
    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        itemCount: _favorites.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, indent: 52, endIndent: 16),
        itemBuilder: (context, index) {
          final catalog = _favorites[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            leading: Icon(
              Icons.bookmark_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              catalog.name.isEmpty ? '未命名收藏夹' : catalog.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${catalog.collectCount} 篇',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, size: 18),
              ],
            ),
            onTap: () => context.push(
              '/favorites/${catalog.id}?name=${Uri.encodeComponent(catalog.name)}',
            ),
          );
        },
      ),
    );
  }
}
