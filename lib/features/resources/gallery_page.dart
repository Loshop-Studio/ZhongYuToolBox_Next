import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/util/formatters.dart';
import '../../core/util/urls.dart';
import '../../data/api/oss_api.dart';
import '../../data/api/picture_api.dart';
import '../../data/models/picture.dart';
import '../../shared/widgets/app_actions.dart';
import '../../shared/widgets/common.dart';
import 'picture_detail_page.dart';

/// 图库（网格 + 大图查看）
class GalleryTab extends StatefulWidget {
  const GalleryTab({super.key, this.recycle = false});

  final bool recycle;

  @override
  State<GalleryTab> createState() => GalleryTabState();
}

class GalleryTabState extends State<GalleryTab>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _controller = ScrollController();

  final List<PictureItem> _items = <PictureItem>[];
  bool _loading = false;
  bool _loadingMore = false;
  bool _uploading = false;
  String? _error;
  bool _hasMore = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    reload();
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

  Future<void> reload() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await PictureApi.getPictures(
        recycle: widget.recycle,
        skip: 0,
      );
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(page.items);
        _hasMore = _items.length < page.total && page.items.isNotEmpty;
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
      final page = await PictureApi.getPictures(
        recycle: widget.recycle,
        skip: _items.length,
      );
      if (!mounted) return;
      setState(() {
        _items.addAll(page.items);
        _hasMore = page.items.isNotEmpty && _items.length < page.total;
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
    if (_loading) return const LoadingView(text: '正在加载图库…');
    if (_error != null) return ErrorView(message: _error!, onRetry: reload);
    if (_items.isEmpty) {
      return Stack(
        children: [
          EmptyView(
            icon: Icons.photo_library_outlined,
            text: widget.recycle ? '回收站是空的' : '图库里还没有图片',
          ),
          if (!widget.recycle) _buildUploadButton(),
        ],
      );
    }

    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1200
        ? 6
        : (width >= 900 ? 5 : (width >= 600 ? 4 : 3));

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: reload,
          child: GridView.builder(
            controller: _controller,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _items.length + (_loadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= _items.length) {
                return const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              final item = _items[index];
              return _GalleryTile(
                item: item,
                recycle: widget.recycle,
                onTap: () => _openViewer(index),
                onMore: (position) => _showActions(item, anchor: position),
              );
            },
          ),
        ),
        if (!widget.recycle) _buildUploadButton(),
      ],
    );
  }

  Widget _buildUploadButton() {
    return Positioned(
      right: 16,
      bottom: 16,
      child: FloatingActionButton(
        onPressed: _uploading ? null : _upload,
        tooltip: '上传图片',
        child: _uploading
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add_photo_alternate_outlined),
      ),
    );
  }

  void _openViewer(int index) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PictureDetailPage(items: _items, initialIndex: index),
      ),
    );
  }

  /// 上传图片（复刻 PictureView.beforeUpload：OSS note_v2 → nonce 取 URL 倒数第二段）
  Future<void> _upload() async {
    if (_uploading) return;
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;
    setState(() => _uploading = true);
    var uploaded = 0;
    try {
      for (final file in picked.files) {
        final bytes = file.bytes;
        if (bytes == null || bytes.isEmpty) continue;
        final userId = await OssApi.fetchUserId();
        final url = await OssApi.uploadBytes(
          bytes: Uint8List.fromList(bytes),
          fileName: file.name,
          userId: userId,
          fc: 'note_v2',
          mime: 'image/${_extOf(file.name)}',
        );
        final segments = Uri.parse(url).pathSegments;
        final nonce = segments.length >= 2 ? segments[segments.length - 2] : '';
        final sizeText = formatFileSize(bytes.length);
        await PictureApi.addPicture(url, nonce, sizeText);
        uploaded++;
      }
      if (!mounted) return;
      showToast(context, uploaded > 0 ? '已上传 $uploaded 张' : '没有可上传的图片');
      await reload();
    } catch (e) {
      if (!mounted) return;
      showToast(context, errorText(e));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  String _extOf(String name) {
    final lower = name.toLowerCase();
    for (final ext in ['png', 'jpg', 'jpeg', 'webp', 'gif', 'bmp']) {
      if (lower.endsWith('.$ext')) return ext == 'jpg' ? 'jpeg' : ext;
    }
    return 'jpeg';
  }

  Future<void> _showActions(PictureItem item, {Offset? anchor}) async {
    final action = await showAppActions(
      context,
      title: item.name.isEmpty ? '图片操作' : item.name,
      anchor: anchor,
      actions: [
        AppAction(
          value: 'delete',
          label: widget.recycle ? '彻底删除' : '移入回收站',
          icon: widget.recycle
              ? Icons.delete_forever_outlined
              : Icons.delete_outline,
          danger: true,
        ),
      ],
    );
    if (action != 'delete' || !mounted) return;
    final ok = await confirmDialog(
      context,
      title: widget.recycle ? '彻底删除' : '移入回收站',
      content: widget.recycle ? '删除后无法恢复，确定继续？' : '将「${item.name}」移入图库回收站？',
      confirmText: widget.recycle ? '删除' : '移入',
      danger: true,
    );
    if (!ok) return;
    try {
      if (widget.recycle) {
        await PictureApi.deletePermanently([item.id]);
      } else {
        await PictureApi.moveToRecycleBin([item.id]);
      }
      if (!mounted) return;
      showToast(context, widget.recycle ? '已删除' : '已移入回收站');
      reload();
    } catch (e) {
      if (!mounted) return;
      showToast(context, errorText(e));
    }
  }
}

String galleryImageUrl(String picture) {
  return imageDisplayUrl(absoluteOssUrl(picture));
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({
    required this.item,
    required this.recycle,
    required this.onTap,
    required this.onMore,
  });

  final PictureItem item;
  final bool recycle;
  final VoidCallback onTap;

  /// 移动端长按 / 桌面端右键
  final void Function(Offset? position) onMore;

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktopLayout;
    return GestureDetector(
      onSecondaryTapDown: desktop
          ? (details) => onMore(details.globalPosition)
          : null,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: desktop ? null : () => onMore(null),
          child: GridTile(
            footer: GridTileBar(
              title: Text(
                item.name.isEmpty ? item.sizeText : item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            child: CachedNetworkImage(
              imageUrl: galleryImageUrl(item.picture),
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.broken_image_outlined),
            ),
          ),
        ),
      ),
    );
  }
}
