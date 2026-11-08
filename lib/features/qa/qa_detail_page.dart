import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/util/formatters.dart';
import '../../core/util/urls.dart';
import '../../data/api/quora_api.dart';
import '../../data/models/quora.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/user_avatar.dart';

/// 问答详情：左侧消息列表 + 右侧内容 + 右下角回复按钮
class QaDetailPage extends StatefulWidget {
  const QaDetailPage({
    super.key,
    required this.sessionId,
    this.askUserPhoto = '',
  });

  final String sessionId;

  /// 会话里提问者的头像：GetMessages 不带头像时用作兜底
  final String askUserPhoto;

  @override
  State<QaDetailPage> createState() => _QaDetailPageState();
}

class _QaDetailPageState extends State<QaDetailPage> {
  final ScrollController _replyListController = ScrollController();

  bool _loading = true;
  String? _error;
  List<QuoraMessage> _messages = <QuoraMessage>[];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _replyListController.dispose();
    super.dispose();
  }

  /// 桌面端鼠标滚轮只能产生 dy，横向列表只吃 dx，这里映射并正式注册到 resolver
  void _onReplyListPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (!_replyListController.hasClients) return;
    final delta = event.scrollDelta.dy != 0
        ? event.scrollDelta.dy
        : event.scrollDelta.dx;
    if (delta == 0) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (_) {
      final position = _replyListController.position;
      final target = (position.pixels + delta).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      _replyListController.jumpTo(target);
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final messages = await QuoraApi.getMessages(widget.sessionId);
      if (!mounted) return;
      setState(() {
        _messages = messages;
        _selectedIndex = messages.isEmpty ? 0 : messages.length - 1;
        _loading = false;
      });
      QuoraApi.resetReadState(widget.sessionId).catchError((_) {});
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = errorText(e);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: const Text('问题详情'),
        actions: [
          IconButton(
            tooltip: '刷新',
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView(text: '正在加载对话…');
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_messages.isEmpty) {
      return const EmptyView(icon: Icons.chat_bubble_outline, text: '还没有消息');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 700;
        if (!wide) {
          return Column(
            children: [
              SizedBox(height: 56, child: _buildHorizontalList()),
              const Divider(height: 1),
              Expanded(child: _buildContent()),
            ],
          );
        }
        return Row(
          children: [
            SizedBox(width: 220, child: _buildVerticalList()),
            const VerticalDivider(width: 1),
            Expanded(child: _buildContent()),
          ],
        );
      },
    );
  }

  /// 桌面/平板：左侧竖排消息条
  Widget _buildVerticalList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _messages.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final message = _messages[index];
        return ListTile(
          dense: true,
          selected: index == _selectedIndex,
          selectedTileColor: Theme.of(context).colorScheme.secondaryContainer,
          leading: CircleAvatar(
            radius: 12,
            child: Text(
              '${index + 1}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          title: Text(
            message.userName.isEmpty ? '未知用户' : message.userName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          subtitle: Text(
            formatDateTime(message.sendTime, pattern: 'MM-dd HH:mm'),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          onTap: () => setState(() => _selectedIndex = index),
        );
      },
    );
  }

  /// 窄屏：顶部横排消息条（紧凑、竖线分隔、可横向滚动）
  ///
  /// 桌面端要额外处理两件事：允许鼠标拖拽，以及把滚轮 dy 映射到横向 dx。
  Widget _buildHorizontalList() {
    final theme = Theme.of(context);
    return ScrollConfiguration(
      behavior: const _ReplyListScrollBehavior(),
      child: Listener(
        onPointerSignal: _onReplyListPointerSignal,
        child: Scrollbar(
          controller: _replyListController,
          thumbVisibility: true,
          thickness: 4,
          radius: const Radius.circular(2),
          scrollbarOrientation: ScrollbarOrientation.bottom,
          child: ListView.separated(
            controller: _replyListController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _messages.length,
            separatorBuilder: (_, __) =>
                const VerticalDivider(width: 1, indent: 10, endIndent: 10),
            itemBuilder: (context, index) {
              final message = _messages[index];
              final selected = index == _selectedIndex;
              return InkWell(
                onTap: () => setState(() => _selectedIndex = index),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 72,
                    maxWidth: 108,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.userName.isEmpty ? '未知' : message.userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: selected ? theme.colorScheme.primary : null,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          formatDateTime(
                            message.sendTime,
                            pattern: 'MM-dd HH:mm',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 2,
                          width: 20,
                          color: selected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                        ),
                      ],
                    ),
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
    final message = _messages[_selectedIndex.clamp(0, _messages.length - 1)];
    final theme = Theme.of(context);
    final isBoard = _isBoardContent(message);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        Row(
          children: [
            UserAvatar(
              name: message.userName,
              photo: message.userPhoto.isNotEmpty
                  ? message.userPhoto
                  : widget.askUserPhoto,
              radius: 16,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.userName.isEmpty ? '未知用户' : message.userName,
                    style: theme.textTheme.titleSmall,
                  ),
                  Text(
                    formatDateTime(message.sendTime),
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            if (message.isPrimary) const Chip(label: Text('公开')),
          ],
        ),
        const SizedBox(height: 16),
        if (message.snapshot.isNotEmpty) ...[
          GestureDetector(
            onTap: () => _previewImage(context, message.snapshot),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imageDisplayUrl(absoluteOssUrl(message.snapshot)),
                width: double.infinity,
                fit: BoxFit.fitWidth,
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (isBoard && message.snapshot.isEmpty)
          const ListTile(
            leading: Icon(Icons.draw_outlined),
            title: Text('画板附件'),
            subtitle: Text('暂无预览图片'),
          )
        else if (!isBoard && message.content.isNotEmpty)
          SelectableText(
            message.content,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
          )
        else
          Text('', style: theme.textTheme.bodyMedium),
      ],
    );
  }

  bool _isBoardContent(QuoraMessage message) {
    final content = message.content;
    return content.startsWith('http') && !content.contains(' ');
  }

  void _previewImage(BuildContext context, String snapshot) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: imageDisplayUrl(absoluteOssUrl(snapshot)),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

/// 桌面端允许鼠标拖拽滚动（Flutter 默认只允许触摸）
class _ReplyListScrollBehavior extends MaterialScrollBehavior {
  const _ReplyListScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const <PointerDeviceKind>{
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
  };
}
