import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/network/api_exception.dart';
import '../../core/util/formatters.dart';
import '../../data/api/column_api.dart';
import '../../data/models/column.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/user_avatar.dart';

class ArticleCommentsPage extends StatefulWidget {
  const ArticleCommentsPage({super.key, required this.pageId});

  final int pageId;

  @override
  State<ArticleCommentsPage> createState() => _ArticleCommentsPageState();
}

class _ArticleCommentsPageState extends State<ArticleCommentsPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<_CommentListPaneState> _publicKey = GlobalKey();
  final GlobalKey<_CommentListPaneState> _myKey = GlobalKey();
  final TextEditingController _commentController = TextEditingController();

  late final TabController _tabController;
  int _currentTab = 0;
  bool _myCommentsEnabled = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    final index = _tabController.index;
    if (index == _currentTab && (index != 1 || _myCommentsEnabled)) return;
    setState(() {
      _currentTab = index;
      if (index == 1) _myCommentsEnabled = true;
    });
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty || _submitting) return;
    setState(() => _submitting = true);
    try {
      await ColumnApi.createPageComment(widget.pageId, content);
      if (!mounted) return;
      _commentController.clear();
      setState(() => _submitting = false);
      showToast(context, '评论已提交');
      await _myKey.currentState?.reload();
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      showToast(context, errorText(e));
    }
  }

  Future<void> _reply(ColumnComment comment) async {
    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ReplyComposerSheet(comment: comment),
    );
    if (submitted != true || !mounted) return;
    showToast(context, '回复已提交');
    await _publicKey.currentState?.reload();
    await _myKey.currentState?.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: const Text('评论'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '公开评论'),
            Tab(text: '我的评论'),
          ],
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: TabBarView(
            controller: _tabController,
            children: [
              _CommentListPane(
                key: _publicKey,
                pageId: widget.pageId,
                enabled: true,
                publicOnly: true,
                myOnly: false,
                emptyText: '还没有公开评论',
                onReply: _reply,
              ),
              _CommentListPane(
                key: _myKey,
                pageId: widget.pageId,
                enabled: _myCommentsEnabled,
                publicOnly: false,
                myOnly: true,
                emptyText: '你还没有发表过评论',
                onReply: _reply,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _currentTab == 1 ? _buildCommentComposer() : null,
    );
  }

  Widget _buildCommentComposer() {
    final canSend = !_submitting && _commentController.text.trim().isNotEmpty;
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      enabled: !_submitting,
                      minLines: 1,
                      maxLines: 3,
                      maxLength: 100,
                      inputFormatters: [LengthLimitingTextInputFormatter(100)],
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: '写评论（最多 100 字）',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: '发送评论',
                    onPressed: canSend ? _submitComment : null,
                    icon: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CommentListPane extends StatefulWidget {
  const _CommentListPane({
    super.key,
    required this.pageId,
    required this.enabled,
    required this.publicOnly,
    required this.myOnly,
    required this.emptyText,
    required this.onReply,
  });

  final int pageId;
  final bool enabled;
  final bool publicOnly;
  final bool myOnly;
  final String emptyText;
  final ValueChanged<ColumnComment> onReply;

  @override
  State<_CommentListPane> createState() => _CommentListPaneState();
}

class _CommentListPaneState extends State<_CommentListPane>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final List<ColumnComment> _comments = <ColumnComment>[];

  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _total = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    if (widget.enabled) reload();
  }

  @override
  void didUpdateWidget(covariant _CommentListPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !oldWidget.enabled) reload();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 240) {
      _loadMore();
    }
  }

  Future<void> reload() async {
    if (!widget.enabled) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ColumnApi.getPageComments(
        widget.pageId,
        publicOnly: widget.publicOnly,
        myOnly: widget.myOnly,
      );
      if (!mounted) return;
      setState(() {
        _comments
          ..clear()
          ..addAll(result.items);
        _total = result.total;
        _hasMore = result.items.isNotEmpty && _comments.length < _total;
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
    if (_loading || _loadingMore || !_hasMore || !widget.enabled) return;
    setState(() => _loadingMore = true);
    try {
      final result = await ColumnApi.getPageComments(
        widget.pageId,
        publicOnly: widget.publicOnly,
        myOnly: widget.myOnly,
        skipCount: _comments.length,
      );
      if (!mounted) return;
      setState(() {
        _comments.addAll(result.items);
        _total = result.total;
        _hasMore = result.items.isNotEmpty && _comments.length < _total;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!widget.enabled || _loading) {
      return const LoadingView(text: '正在加载评论…');
    }
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: reload);
    }
    if (_comments.isEmpty) {
      return RefreshIndicator(
        onRefresh: reload,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.55,
              child: EmptyView(
                icon: Icons.chat_bubble_outline,
                text: widget.emptyText,
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: reload,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
        itemCount: _comments.length + (_loadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index >= _comments.length) {
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
          return _CommentCard(
            comment: _comments[index],
            onReply: widget.onReply,
          );
        },
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  const _CommentCard({required this.comment, required this.onReply});

  final ColumnComment comment;
  final ValueChanged<ColumnComment> onReply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(
                name: comment.userName,
                photo: comment.userPicture,
                radius: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            comment.userName.isEmpty
                                ? '匿名用户'
                                : comment.userName,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        if (!comment.isActive && !comment.isDeleted) ...[
                          const SizedBox(width: 6),
                          const Chip(
                            label: Text('不公开'),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      formatDateTime(comment.commentTime),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (comment.allowReply && !comment.isDeleted)
                IconButton(
                  tooltip: '回复',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => onReply(comment),
                  icon: const Icon(Icons.reply, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(comment.isDeleted ? '该评论已删除' : comment.content),
          if (comment.replies.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < comment.replies.length; i++) ...[
                    if (i > 0) const Divider(height: 18),
                    _ReplyRow(reply: comment.replies[i]),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReplyRow extends StatelessWidget {
  const _ReplyRow({required this.reply});

  final ColumnCommentReply reply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserAvatar(name: reply.userName, photo: reply.userPicture, radius: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      reply.userName.isEmpty ? '匿名用户' : reply.userName,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                  Text(
                    formatDateTime(reply.replyTime),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(reply.content),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReplyComposerSheet extends StatefulWidget {
  const _ReplyComposerSheet({required this.comment});

  final ColumnComment comment;

  @override
  State<_ReplyComposerSheet> createState() => _ReplyComposerSheetState();
}

class _ReplyComposerSheetState extends State<_ReplyComposerSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ColumnApi.replyPageComment(widget.comment.id, content);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = errorText(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSend = !_submitting && _controller.text.trim().isNotEmpty;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '回复 ${widget.comment.userName.isEmpty ? '该用户' : widget.comment.userName}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            enabled: !_submitting,
            minLines: 2,
            maxLines: 4,
            maxLength: 100,
            inputFormatters: [LengthLimitingTextInputFormatter(100)],
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '输入回复（最多 100 字）',
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: canSend ? _submit : null,
              icon: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send, size: 18),
              label: const Text('发送'),
            ),
          ),
        ],
      ),
    );
  }
}
