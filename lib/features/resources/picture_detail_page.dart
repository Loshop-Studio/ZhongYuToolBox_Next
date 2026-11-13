import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/network/api_exception.dart';
import '../../core/storage/image_cache_manager.dart';
import '../../core/util/file_saver.dart';
import '../../core/util/formatters.dart';
import '../../data/api/picture_api.dart';
import '../../data/models/picture.dart';
import '../../shared/widgets/common.dart';
import 'gallery_page.dart';

/// 图片详情（复刻 PictureDetailView：大图 + 打开原图 + 下载 + 回收站）
class PictureDetailPage extends StatefulWidget {
  const PictureDetailPage({
    super.key,
    required this.items,
    required this.initialIndex,
    this.recycle = false,
  });

  final List<PictureItem> items;
  final int initialIndex;
  final bool recycle;

  @override
  State<PictureDetailPage> createState() => _PictureDetailPageState();
}

class _PictureDetailPageState extends State<PictureDetailPage> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;
  bool _downloading = false;

  PictureItem get _item => widget.items[_index];

  String get _url => galleryImageUrl(_item.picture);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openOriginal() async {
    final uri = Uri.tryParse(_url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _download() async {
    if (_downloading) return;
    setState(() => _downloading = true);
    try {
      final response = await Dio().get<dynamic>(
        _url,
        options: Options(
          responseType: ResponseType.bytes,
          validateStatus: (_) => true,
        ),
      );
      final data = response.data;
      if (data is! List<int> || data.isEmpty) throw ApiException('图片读取失败');
      final bytes = Uint8List.fromList(data);
      final contentType = response.headers.value('content-type');
      final base = _item.name.isNotEmpty ? _item.name : _fileName();
      final name = _withExtension(base, contentType, _url, bytes);
      final path = await FileSaver.save(name, bytes);
      if (!mounted) return;
      showToast(context, path == null ? '已取消保存' : '已保存：$path');
    } catch (e) {
      if (!mounted) return;
      showToast(context, errorText(e));
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _remove() async {
    final ok = await confirmDialog(
      context,
      title: widget.recycle ? '彻底删除' : '移入回收站',
      content: widget.recycle ? '删除后无法恢复，确定继续？' : '将这张图片移入图库回收站？',
      confirmText: widget.recycle ? '删除' : '移入',
      danger: true,
    );
    if (!ok) return;
    try {
      if (widget.recycle) {
        await PictureApi.deletePermanently([_item.id]);
      } else {
        await PictureApi.moveToRecycleBin([_item.id]);
      }
      if (!mounted) return;
      showToast(context, widget.recycle ? '已删除' : '已移入回收站');
      Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      showToast(context, errorText(e));
    }
  }

  String _fileName() {
    final segments = Uri.tryParse(_url)?.pathSegments ?? const <String>[];
    return segments.isEmpty ? 'image.png' : segments.last;
  }

  /// 缺扩展名时按 MIME、文件头或 URL 推导，避免保存出无后缀文件。
  String _withExtension(
    String base,
    String? mime,
    String url,
    Uint8List bytes,
  ) {
    if (RegExp(r'\.[a-z0-9]+$', caseSensitive: false).hasMatch(base)) {
      return base;
    }
    final ext =
        _extFromMime(mime) ?? _extFromBytes(bytes) ?? _extFromUrl(url) ?? 'png';
    return '$base.$ext';
  }

  String? _extFromMime(String? mime) {
    const map = <String, String>{
      'image/jpeg': 'jpg',
      'image/png': 'png',
      'image/gif': 'gif',
      'image/webp': 'webp',
      'image/bmp': 'bmp',
      'image/svg+xml': 'svg',
    };
    if (mime == null) return null;
    return map[mime.split(';').first.trim().toLowerCase()];
  }

  String? _extFromBytes(Uint8List bytes) {
    if (bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4e &&
        bytes[3] == 0x47) {
      return 'png';
    }
    if (bytes.length >= 3 &&
        bytes[0] == 0xff &&
        bytes[1] == 0xd8 &&
        bytes[2] == 0xff) {
      return 'jpg';
    }
    if (bytes.length >= 3 &&
        bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46) {
      return 'gif';
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'webp';
    }
    if (bytes.length >= 2 && bytes[0] == 0x42 && bytes[1] == 0x4d) {
      return 'bmp';
    }
    return null;
  }

  String? _extFromUrl(String url) {
    final segments = Uri.tryParse(url)?.pathSegments ?? const <String>[];
    if (segments.isEmpty) return null;
    final match = RegExp(r'\.([a-z0-9]+)$', caseSensitive: false)
        .firstMatch(segments.last);
    return match?.group(1)?.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _item.name.isEmpty ? '图片' : _item.name,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text('${_index + 1}/${widget.items.length}'),
            ),
          ),
          IconButton(
            tooltip: '打开原图',
            onPressed: _openOriginal,
            icon: const Icon(Icons.open_in_new),
          ),
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
          IconButton(
            tooltip: widget.recycle ? '彻底删除' : '移入回收站',
            onPressed: _remove,
            icon: const Icon(Icons.delete_outline),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.items.length,
        onPageChanged: (value) => setState(() => _index = value),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: CachedNetworkImage(
                imageUrl: galleryImageUrl(widget.items[index].picture),
                cacheManager: ZyImageCacheManager.instance,
                fit: BoxFit.contain,
                placeholder: (_, __) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.broken_image_outlined, size: 36),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '创建时间：${formatDateTime(_item.createTime)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text(
                _item.sizeText,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
