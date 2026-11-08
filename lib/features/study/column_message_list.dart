import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_exception.dart';
import '../../core/util/formatters.dart';
import '../../data/api/column_api.dart';
import '../../data/models/column.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/user_avatar.dart';

/// 专栏消息列表（复刻 StudyPage 的「我的消息」tab）。
/// 点击后标记已读并跳转到对应专栏文章。
///
/// 后端 `GetMyMessageListAsync` 为分页接口（Type + skipCount + MaxResultCount，
/// 返回 totalCount），这里按滚动懒加载逐页追加，避免消息超 20 条时截断。
class ColumnMessageList extends StatefulWidget {
  const ColumnMessageList({super.key});

  @override
  State<ColumnMessageList> createState() => _ColumnMessageListState();
}

class _ColumnMessageListState extends State<ColumnMessageList> {
  final ScrollController _controller = ScrollController();

  List<AppMessage> _messages = <AppMessage>[];
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
      final result = await ColumnApi.getMyMessageList(skipCount: 0);
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(result.items);
        _total = result.total;
        _hasMore = result.items.isNotEmpty && _messages.length < _total;
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
      final result = await ColumnApi.getMyMessageList(skipCount: _messages.length);
      if (!mounted) return;
      setState(() {
        _messages.addAll(result.items);
        _hasMore = result.items.isNotEmpty && _messages.length < _total;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView(text: '正在加载消息…');
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _reload);
    }
    if (_messages.isEmpty) {
      return const EmptyView(icon: Icons.notifications_none, text: '还没有消息');
    }
    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView.separated(
        controller: _controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
        itemCount: _messages.length + (_loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index >= _messages.length) {
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
          final message = _messages[index];
          return ListTile(
            leading: Badge(
              isLabelVisible: !message.isRead,
              child: UserAvatar(
                name: message.senderName,
                photo: message.senderPhoto,
                radius: 18,
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
            onTap: () async {
              if (message.pageId > 0) {
                if (!message.isRead) {
                  ColumnApi.setMessageRead(message.id).catchError((_) {});
                }
                if (!mounted) return;
                context.push('/article/${message.pageId}');
              } else {
                showToast(context, '该消息没有可跳转的文章');
              }
            },
          );
        },
      ),
    );
  }
}
