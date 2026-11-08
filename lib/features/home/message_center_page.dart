import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_exception.dart';
import '../../core/util/formatters.dart';
import '../../data/api/column_api.dart';
import '../../data/models/column.dart';
import '../../shared/widgets/common.dart';
import '../study/column_message_list.dart';

/// 消息中心：公告 + 专栏消息 两种。
class MessageCenterPage extends StatefulWidget {
  const MessageCenterPage({super.key});

  @override
  State<MessageCenterPage> createState() => _MessageCenterPageState();
}

class _MessageCenterPageState extends State<MessageCenterPage>
    with SingleTickerProviderStateMixin {
  static const List<String> _tabs = ['公告', '专栏消息'];

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: const Text('消息中心'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [for (final label in _tabs) Tab(text: label)],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AnnouncementList(),
          ColumnMessageList(),
        ],
      ),
    );
  }
}

/// 公告列表（type=3）。点击进入 webview 详情。
class _AnnouncementList extends StatefulWidget {
  const _AnnouncementList();

  @override
  State<_AnnouncementList> createState() => _AnnouncementListState();
}

class _AnnouncementListState extends State<_AnnouncementList> {
  final ScrollController _controller = ScrollController();

  List<AppMessage> _items = <AppMessage>[];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    _reload();
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 240) {
      _loadMore();
    }
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ColumnApi.getMyMessageList(type: 3, skipCount: 0);
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(result.items);
        _total = result.total;
        _hasMore = result.items.isNotEmpty && _items.length < _total;
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

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final result =
          await ColumnApi.getMyMessageList(type: 3, skipCount: _items.length);
      if (!mounted) return;
      setState(() {
        _items.addAll(result.items);
        _hasMore = result.items.isNotEmpty && _items.length < _total;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView(text: '正在加载公告…');
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _reload);
    }
    if (_items.isEmpty) {
      return const EmptyView(icon: Icons.campaign_outlined, text: '暂无公告');
    }
    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView.separated(
        controller: _controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
        itemCount: _items.length + (_loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          final message = _items[index];
          final theme = Theme.of(context);
          return ListTile(
            leading: Badge(
              isLabelVisible: !message.isRead,
              child: Icon(
                Icons.campaign_outlined,
                color: theme.colorScheme.primary,
              ),
            ),
            title: Text(
              message.title.isEmpty ? '（无标题）' : message.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: message.isRead ? FontWeight.w400 : FontWeight.w600,
              ),
            ),
            subtitle: Text(
              [
                if (message.senderName.isNotEmpty) message.senderName,
                formatDateTime(message.creationTime),
              ].join(' · '),
            ),
            trailing: const Icon(Icons.chevron_right, size: 18),
            onTap: () => context.push(
              '/announcement'
              '?noticeId=${message.pageId}'
              '&messageId=${Uri.encodeComponent(message.id)}'
              '&title=${Uri.encodeComponent(message.title)}',
            ),
          );
        },
      ),
    );
  }
}
