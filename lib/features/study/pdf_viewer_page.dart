import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

import '../../core/network/api_exception.dart';
import '../../core/util/urls.dart';
import '../../shared/widgets/common.dart';
import 'attachment_opener.dart';

/// 原生 PDF 预览：下载到本地缓存后用 PDFium（pdfx）在 Flutter 里绘制。
///
/// 大文件按页懒加载：`ListView.builder` + `itemExtent` 只构建可见页，
/// 滚动到哪一页才渲染哪一页，离屏即释放，几千页的 PDF 也只占几页内存。
class PdfDocumentView extends StatefulWidget {
  const PdfDocumentView({super.key, required this.url});

  final String url;

  @override
  State<PdfDocumentView> createState() => _PdfDocumentViewState();
}

class _PdfDocumentViewState extends State<PdfDocumentView> {
  static const double _minScale = 0.6;
  static const double _maxScale = 2.5;
  static const double _pageGap = 8;

  final ScrollController _scroll = ScrollController();
  final Map<int, Offset> _pointers = {};

  PdfDocument? _document;
  int _pageCount = 0;
  double _aspect = 1.4142;
  double _scale = 1;
  double _gestureScale = 1;
  double _renderWidth = 800;
  double _devicePixelRatio = 1;
  double? _pinchStartDistance;
  PdfControllerPinch? _mobileController;
  int _currentPage = 1;
  bool _loading = true;
  double _progress = 0;
  String? _error;

  /// PDFium 不允许并行渲染（Android 明确禁止），所有渲染串成一条队列
  Future<void> _renderQueue = Future<void>.value();

  /// 同一页同一宽度只渲染一次：ListView 每次 build 都会重新取 provider，
  /// 不缓存的话会重复排队渲染
  final Map<String, Future<PdfPageImage>> _renderCache = {};

  String _documentId = '';

  String get _displayUrl => imageDisplayUrl(absoluteOssUrl(widget.url));

  double get _itemExtent => _renderWidth * _aspect + _pageGap * 2;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _mobileController?.dispose();
    final document = _document;
    _document = null;
    document?.close();
    super.dispose();
  }

  void _onScroll() {
    if (_pageCount <= 0) return;
    final page = ((_scroll.offset / _itemExtent).floor() + 1).clamp(
      1,
      _pageCount,
    );
    if (page != _currentPage) setState(() => _currentPage = page);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _progress = 0;
    });
    final old = _document;
    _document = null;
    await old?.close();

    try {
      final file = await _localFile();
      final document = await PdfDocument.openFile(file.path);
      // 只取第一页的宽高比，后续页面按同一比例排版（课件类 PDF 基本一致）
      final first = await document.getPage(1);
      final aspect = first.width > 0 ? first.height / first.width : 1.4142;
      await first.close();
      if (!mounted) {
        await document.close();
        return;
      }
      final mobileController = PdfControllerPinch(
        document: Future<PdfDocument>.value(document),
      );
      final oldMobileController = _mobileController;
      _mobileController = mobileController;
      oldMobileController?.dispose();
      setState(() {
        _document = document;
        _documentId = document.id;
        _pageCount = document.pagesCount;
        _aspect = aspect;
        _currentPage = 1;
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

  /// 下载 + 临时目录缓存，重复进入同一份 PDF 不用重新拉
  Future<File> _localFile() async {
    final dir = await getTemporaryDirectory();
    final cacheDir = Directory('${dir.path}/zy_pdf');
    if (!await cacheDir.exists()) await cacheDir.create(recursive: true);
    final key = _displayUrl.hashCode.toRadixString(16);
    final file = File('${cacheDir.path}/$key.pdf');
    if (await file.exists() && await file.length() > 1024) return file;

    final temp = File('${file.path}.part');
    await Dio().download(
      _displayUrl,
      temp.path,
      onReceiveProgress: (received, total) {
        if (!mounted || total <= 0) return;
        setState(() => _progress = received / total);
      },
    );
    if (await temp.exists()) await temp.rename(file.path);
    return file;
  }

  /// 按需渲染单页（带缓存），排队执行避免平台端并发渲染
  Future<PdfPageImage> _renderPage(int pageNumber, double width) {
    final pixelWidth = (width * _devicePixelRatio).roundToDouble();
    final key = '$pageNumber@${pixelWidth.round()}';
    final cached = _renderCache[key];
    if (cached != null) return cached;
    // 只保留最近的渲染任务，避免翻过很多页后缓存无限增长
    while (_renderCache.length >= 24) {
      _renderCache.remove(_renderCache.keys.first);
    }
    final task = _render(pageNumber, pixelWidth);
    _renderCache[key] = task;
    return task;
  }

  Future<PdfPageImage> _render(int pageNumber, double width) {
    final task = _renderQueue.then((_) async {
      final document = _document;
      if (document == null) throw StateError('文档已关闭');
      final page = await document.getPage(pageNumber);
      try {
        final image = await page.render(
          width: width,
          height: width * page.height / page.width,
          format: PdfPageImageFormat.png,
          backgroundColor: '#FFFFFF',
        );
        if (image == null) throw StateError('第 $pageNumber 页渲染失败');
        return image;
      } finally {
        await page.close();
      }
    });
    _renderQueue = task.then((_) {}, onError: (_) {});
    return task;
  }

  void _setScalePreservingPosition(double next) {
    if ((next - _scale).abs() < 0.001) return;
    final oldExtent = _itemExtent;
    final oldOffset = _scroll.hasClients ? _scroll.offset : 0.0;
    final pageIndex = (oldOffset / oldExtent).floor();
    final pageProgress = (oldOffset - pageIndex * oldExtent) / oldExtent;
    setState(() => _scale = next);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final target = (pageIndex + pageProgress) * _itemExtent;
      _scroll.jumpTo(target.clamp(0.0, _scroll.position.maxScrollExtent));
    });
  }

  void _zoomBy(double factor) {
    final next = (_scale * factor).clamp(_minScale, _maxScale);
    _setScalePreservingPosition(next);
  }

  void _resetZoom() {
    _setScalePreservingPosition(1);
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    final keys = HardwareKeyboard.instance.logicalKeysPressed;
    final controlPressed = keys.contains(LogicalKeyboardKey.controlLeft) ||
        keys.contains(LogicalKeyboardKey.controlRight);
    if (!controlPressed || event.scrollDelta.dy == 0) return;
    _zoomBy(event.scrollDelta.dy < 0 ? 1.15 : 1 / 1.15);
  }

  double _pointerDistance() {
    final points = _pointers.values.toList();
    if (points.length < 2) return 0;
    return (points[0] - points[1]).distance;
  }

  void _endPointer(int pointer) {
    _pointers.remove(pointer);
    if (_pointers.length >= 2 || _pinchStartDistance == null) return;
    _pinchStartDistance = null;
    final next = (_scale * _gestureScale).clamp(_minScale, _maxScale);
    _setScalePreservingPosition(next);
    setState(() => _gestureScale = 1);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 180,
              child: LinearProgressIndicator(
                value: _progress > 0 ? _progress : null,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _progress > 0
                  ? '正在加载 PDF ${(_progress * 100).toStringAsFixed(0)}%'
                  : '正在加载 PDF…',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _load);
    }

    if ((Platform.isAndroid || Platform.isIOS) && _mobileController != null) {
      final controller = _mobileController!;
      return PdfViewPinch(
        controller: controller,
        minScale: 1,
        maxScale: 8,
        padding: _pageGap,
        backgroundDecoration: const BoxDecoration(color: Color(0xffeeeeee)),
        onPageChanged: (page) {
          // 页码变化不重建外层页面，避免缩放手势中的布局跳动。
          _currentPage = page;
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        _devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
        final viewportWidth = constraints.maxWidth - 24;
        final width = (viewportWidth * _scale).clamp(
          240.0,
          viewportWidth * _maxScale,
        );
        _renderWidth = width;

        final pages = SizedBox(
          width: width,
          child: ListView.builder(
            controller: _scroll,
            physics: _gestureScale == 1
                ? null
                : const NeverScrollableScrollPhysics(),
            itemExtent: _itemExtent,
            cacheExtent: 600,
            itemCount: _pageCount,
            itemBuilder: (context, index) => _buildPage(index + 1),
          ),
        );
        final scrollablePages = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: pages,
        );

        return Stack(
          children: [
            Positioned.fill(
              child: Listener(
                onPointerSignal: _onPointerSignal,
                onPointerDown: (event) {
                  _pointers[event.pointer] = event.localPosition;
                  if (_pointers.length == 2) {
                    _pinchStartDistance = _pointerDistance();
                  }
                },
                onPointerMove: (event) {
                  if (!_pointers.containsKey(event.pointer)) return;
                  _pointers[event.pointer] = event.localPosition;
                  final start = _pinchStartDistance;
                  if (_pointers.length < 2 || start == null || start <= 0) {
                    return;
                  }
                  final next = (_pointerDistance() / start).clamp(0.5, 3.0);
                  if ((next - _gestureScale).abs() > 0.02) {
                    setState(() => _gestureScale = next);
                  }
                },
                onPointerUp: (event) => _endPointer(event.pointer),
                onPointerCancel: (event) => _endPointer(event.pointer),
                child: _gestureScale == 1
                    ? scrollablePages
                    : Transform.scale(
                        scale: _gestureScale,
                        child: scrollablePages,
                      ),
              ),
            ),
            Positioned(left: 12, bottom: 12, child: _pageBadge()),
            Positioned(right: 12, bottom: 12, child: _zoomBar()),
          ],
        );
      },
    );
  }

  Widget _buildPage(int pageNumber) {
    final width = _renderWidth;
    final height = width * _aspect;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _pageGap),
      child: Center(
        child: Container(
          width: width,
          height: height,
          color: Colors.white,
          child: Image(
            image: PdfPageImageProvider(
              _renderPage(pageNumber, width),
              pageNumber,
              _documentId,
              scale: _devicePixelRatio,
            ),
            fit: BoxFit.contain,
            gaplessPlayback: true,
            filterQuality: FilterQuality.medium,
            errorBuilder: (context, error, stack) => const Center(
              child: Text('该页渲染失败', style: TextStyle(fontSize: 12)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pageBadge() {
    if (_pageCount <= 0) return const SizedBox.shrink();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          '$_currentPage / $_pageCount',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  Widget _zoomBar() {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(20),
      color: Colors.white.withValues(alpha: 0.94),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: '缩小',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.remove, size: 20),
              onPressed: () => _zoomBy(1 / 1.25),
            ),
            IconButton(
              tooltip: '放大',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.add, size: 20),
              onPressed: () => _zoomBy(1.25),
            ),
            IconButton(
              tooltip: '适应宽度',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.fit_screen_outlined, size: 20),
              onPressed: _resetZoom,
            ),
          ],
        ),
      ),
    );
  }
}

/// 独立的 PDF 预览页（附件 / 网页 open_file 共用）
class PdfViewerPage extends StatefulWidget {
  const PdfViewerPage({super.key, required this.url, this.name = ''});

  final String url;
  final String name;

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  bool _saving = false;

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final path = await downloadAttachment(widget.url, widget.name);
      if (!mounted) return;
      showToast(context, path == null ? '已取消保存' : '已保存：$path');
    } catch (e) {
      if (!mounted) return;
      showToast(context, errorText(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: Text(
          widget.name.isEmpty ? 'PDF 预览' : widget.name,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: '下载',
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: PdfDocumentView(url: widget.url),
    );
  }
}
