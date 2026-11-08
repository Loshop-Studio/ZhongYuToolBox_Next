import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/util/urls.dart';
import '../../shared/widgets/common.dart';
import 'attachment_opener.dart';
import 'pdf_viewer_page.dart';
import 'video_player_page.dart';

/// 附件查看器（kind = video / pdf / image / 其它）
///
/// 全部走 Flutter 原生实现，且右上角都能下载：
/// - pdf  → PDFium 渲染 + 下载
/// - video → media_kit 原生播放 + 下载
/// - image → 原生图片 + 手势缩放 + 下载
/// - 其它   → 提示下载
class LessonViewerPage extends StatefulWidget {
  const LessonViewerPage({
    super.key,
    required this.kind,
    required this.url,
    required this.name,
  });

  final String kind;
  final String url;
  final String name;

  @override
  State<LessonViewerPage> createState() => _LessonViewerPageState();
}

class _LessonViewerPageState extends State<LessonViewerPage> {
  bool _downloading = false;

  String get _displayUrl => imageDisplayUrl(absoluteOssUrl(widget.url));

  bool get _isVideo => widget.kind == 'video';
  bool get _isPdf => widget.kind == 'pdf';

  bool get _isImage {
    if (widget.kind == 'image') return true;
    final path = Uri.tryParse(widget.url)?.path.toLowerCase() ?? '';
    return path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.gif') ||
        path.endsWith('.webp') ||
        path.endsWith('.bmp');
  }

  Future<void> _download() async {
    if (_downloading) return;
    setState(() => _downloading = true);
    try {
      final path = await downloadAttachment(widget.url, widget.name);
      if (!mounted) return;
      showToast(context, path == null ? '已取消保存' : '已保存：$path');
    } catch (e) {
      if (!mounted) return;
      showToast(context, errorText(e));
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = _isVideo;
    final isPdf = _isPdf;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: Text(
          widget.name.isEmpty
              ? (isVideo ? '视频' : (isPdf ? 'PDF' : '附件'))
              : widget.name,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: '下载',
            onPressed: _downloading ? null : _download,
            icon: _downloading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: isPdf
              ? PdfDocumentView(url: widget.url)
              : (isVideo
                    ? NativeVideoView(url: widget.url, title: widget.name)
                    : (_isImage
                          ? _buildImageView()
                          : EmptyView(
                              icon: Icons.insert_drive_file_outlined,
                              text: '该附件暂不支持在线查看\n可点右上角下载后用其它应用打开',
                            ))),
        ),
      ),
    );
  }

  Widget _buildImageView() {
    return InteractiveViewer(
      maxScale: 4,
      minScale: 0.5,
      child: Center(
        child: CachedNetworkImage(
          imageUrl: _displayUrl,
          fit: BoxFit.contain,
          placeholder: (_, __) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (_, __, ___) => const Text('图片加载失败'),
        ),
      ),
    );
  }
}
