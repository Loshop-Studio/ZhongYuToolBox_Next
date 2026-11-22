import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'cloud_note_local_document.dart';
import 'cloud_note_snapshot.dart';

/// Renders the native 中育云笔记 snapshot format without using the older
/// ZIP/blackboard renderer.
class CloudNoteSnapshotView extends StatefulWidget {
  const CloudNoteSnapshotView({
    super.key,
    required this.snapshot,
    this.page,
    this.background = Colors.white,
    this.minScale = 0.2,
    this.maxScale = 8,
  });

  final CloudNoteSnapshot snapshot;
  final CloudNoteLocalPage? page;
  final Color background;
  final double minScale;
  final double maxScale;

  @override
  State<CloudNoteSnapshotView> createState() => _CloudNoteSnapshotViewState();
}

class _CloudNoteSnapshotViewState extends State<CloudNoteSnapshotView> {
  late Future<Map<String, ui.Image>> _images;

  @override
  void initState() {
    super.initState();
    _images = _loadImages();
  }

  @override
  void didUpdateWidget(covariant CloudNoteSnapshotView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.snapshot, widget.snapshot) ||
        oldWidget.page?.directory.path != widget.page?.directory.path) {
      final oldImages = _images;
      _images = _loadImages();
      _releaseImages(oldImages);
    }
  }

  void _releaseImages(
    Future<Map<String, ui.Image>> future, {
    bool afterFrame = true,
  }) {
    future.then((images) {
      void release() {
        for (final image in images.values) {
          image.dispose();
        }
      }

      if (afterFrame) {
        WidgetsBinding.instance.addPostFrameCallback((_) => release());
      } else {
        release();
      }
    }, onError: (Object _) {});
  }

  @override
  void dispose() {
    _releaseImages(_images, afterFrame: false);
    super.dispose();
  }

  Future<Map<String, ui.Image>> _loadImages() async {
    final result = <String, ui.Image>{};
    final paths = <String>{};
    void collect(CloudNoteGraph? graph) {
      if (graph == null) return;
      final path = graph.filePath;
      if (path != null && path.isNotEmpty) paths.add(path);
      for (final child in graph.childGraph) {
        collect(child);
      }
    }

    collect(widget.snapshot.graphSnapshot);
    for (final path in paths) {
      final file = widget.page?.resolveImage(path);
      if (file == null || !await file.exists()) continue;
      try {
        final bytes = await file.readAsBytes();
        final image = await _decodeImage(bytes);
        result[path] = image;
      } catch (_) {
        // A missing/corrupt optional image must not prevent other graph nodes
        // from rendering.
      }
    }
    return result;
  }

  Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    try {
      return (await codec.getNextFrame()).image;
    } finally {
      codec.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, ui.Image>>(
      future: _images,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        return InteractiveViewer(
          minScale: widget.minScale,
          maxScale: widget.maxScale,
          boundaryMargin: const EdgeInsets.all(80),
          child: ColoredBox(
            color: widget.background,
            child: CustomPaint(
              painter: CloudNoteSnapshotPainter(
                snapshot: widget.snapshot,
                images: snapshot.data ?? const <String, ui.Image>{},
              ),
              child: const SizedBox.expand(),
            ),
          ),
        );
      },
    );
  }
}

/// Reads one local page and uses its screenshot when the snapshot references
/// database-backed stroke/text data that is not embedded in `snapshot.bin`.
class CloudNoteLocalPagePreview extends StatefulWidget {
  const CloudNoteLocalPagePreview({super.key, required this.page});

  final CloudNoteLocalPage page;

  @override
  State<CloudNoteLocalPagePreview> createState() =>
      _CloudNoteLocalPagePreviewState();
}

class _CloudNoteLocalPagePreviewState extends State<CloudNoteLocalPagePreview> {
  late Future<CloudNoteSnapshot?> _snapshot;
  late Future<Uint8List?> _screenshot;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didUpdateWidget(covariant CloudNoteLocalPagePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page.directory.path != widget.page.directory.path) {
      _reload();
    }
  }

  void _reload() {
    _snapshot = _readSnapshot();
    _screenshot = _readScreenshot();
  }

  Future<CloudNoteSnapshot?> _readSnapshot() async {
    try {
      return await widget.page.readParsedSnapshot();
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List?> _readScreenshot() async {
    try {
      return await widget.page.readScreenshot();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CloudNoteSnapshot?>(
      future: _snapshot,
      builder: (context, snapshotState) {
        if (snapshotState.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final parsed = snapshotState.data;
        if (parsed?.graphSnapshot != null &&
            !_needsScreenshot(parsed!.graphSnapshot!)) {
          return CloudNoteSnapshotView(snapshot: parsed, page: widget.page);
        }
        return FutureBuilder<Uint8List?>(
          future: _screenshot,
          builder: (context, imageState) {
            if (imageState.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final bytes = imageState.data;
            if (bytes == null) {
              return const Center(child: Text('该页没有可用的本地预览'));
            }
            return InteractiveViewer(
              minScale: 0.2,
              maxScale: 8,
              child: Center(child: Image.memory(bytes, fit: BoxFit.contain)),
            );
          },
        );
      },
    );
  }

  bool _needsScreenshot(CloudNoteGraph graph) {
    final sourceFileName = graph.sourceFileName;
    if (sourceFileName != null && sourceFileName.isNotEmpty) return true;
    if ((graph.graphEnum == 3 || graph.graphEnum == 4) &&
        graph.pointList.isEmpty) {
      return true;
    }
    if (graph.graphEnum == 5 && graph.content == null) return true;
    if (graph.graphEnum == 2) {
      final path = graph.filePath;
      final image = path == null ? null : widget.page.resolveImage(path);
      if (image == null || !image.existsSync()) return true;
    }
    if (graph.graphEnum < 0 || graph.graphEnum > 6) return true;
    return graph.childGraph.any(_needsScreenshot);
  }
}

class CloudNoteSnapshotPainter extends CustomPainter {
  CloudNoteSnapshotPainter({
    required this.snapshot,
    this.images = const <String, ui.Image>{},
  });

  final CloudNoteSnapshot snapshot;
  final Map<String, ui.Image> images;

  @override
  void paint(Canvas canvas, Size size) {
    final root = snapshot.graphSnapshot;
    if (root == null) return;

    final sourceBounds = _graphBounds(root);
    final cameraBounds = _transformRect(sourceBounds, snapshot.cameraMatrix);
    final width = cameraBounds.width.abs();
    final height = cameraBounds.height.abs();
    if (width <= 0 || height <= 0 || !width.isFinite || !height.isFinite) {
      _drawGraph(canvas, root);
      return;
    }

    final scale = _fitScale(size, width, height);
    final dx = (size.width - width * scale) / 2 - cameraBounds.left * scale;
    final dy = (size.height - height * scale) / 2 - cameraBounds.top * scale;
    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale, scale);
    _applyMatrix(canvas, snapshot.cameraMatrix);
    _drawGraph(canvas, root);
    canvas.restore();
  }

  double _fitScale(Size size, double width, double height) {
    if (size.width <= 0 || size.height <= 0) return 1;
    final scale = mathMin(size.width / width, size.height / height);
    if (!scale.isFinite || scale <= 0) return 1;
    return scale;
  }

  void _drawGraph(Canvas canvas, CloudNoteGraph graph) {
    canvas.save();
    _applyMatrix(canvas, graph.matrix);
    _drawNode(canvas, graph);
    for (final child in graph.childGraph) {
      _drawGraph(canvas, child);
    }
    canvas.restore();
  }

  void _drawNode(Canvas canvas, CloudNoteGraph graph) {
    final rect = _rect(graph.outRect);
    if (graph.backgroundColorArgb != 0 && rect != null) {
      canvas.drawRect(rect, Paint()..color = Color(graph.backgroundColorArgb));
    }
    switch (graph.graphEnum) {
      case 2:
        _drawImage(canvas, graph);
      case 3:
      case 4:
        _drawStroke(canvas, graph, straight: graph.graphEnum == 4);
      case 5:
        _drawText(canvas, graph);
      case 6:
        _drawGeometry(canvas, graph);
      case 0:
      case 1:
      default:
        // Containers and groups are represented by their children.
        break;
    }
  }

  void _drawImage(Canvas canvas, CloudNoteGraph graph) {
    final rect = _rect(graph.outRect);
    if (rect == null || rect.width <= 0 || rect.height <= 0) return;
    final path = graph.filePath;
    final image = path == null ? null : images[path];
    if (image == null) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0x55333333);
      canvas.drawRect(rect, paint);
      return;
    }
    final source = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    canvas.drawImageRect(
      image,
      source,
      rect,
      Paint()..filterQuality = FilterQuality.high,
    );
  }

  void _drawStroke(
    Canvas canvas,
    CloudNoteGraph graph, {
    required bool straight,
  }) {
    if (graph.pointList.isEmpty) return;
    final paint = _paint(graph.paint, forceStroke: true);
    final path = ui.Path();
    final points = graph.pointList;
    path.moveTo(points.first.x, points.first.y);
    if (straight || points.length == 2) {
      for (final point in points.skip(1)) {
        path.lineTo(point.x, point.y);
      }
    } else {
      var previous = points.first;
      for (var index = 1; index < points.length; index++) {
        final point = points[index];
        final midpoint = Offset(
          (previous.x + point.x) / 2,
          (previous.y + point.y) / 2,
        );
        path.quadraticBezierTo(
          previous.x,
          previous.y,
          midpoint.dx,
          midpoint.dy,
        );
        previous = point;
      }
      path.lineTo(previous.x, previous.y);
    }
    canvas.drawPath(path, paint);
  }

  void _drawText(Canvas canvas, CloudNoteGraph graph) {
    final content = graph.content;
    final rect = _rect(graph.outRect);
    if (content == null || content.isEmpty || rect == null || rect.width <= 0) {
      return;
    }
    final paint = _paint(graph.paint);
    final textSize = graph.paint?.textSize ?? 16;
    final color = paint.color;
    final textPainter = TextPainter(
      text: TextSpan(
        text: content,
        style: TextStyle(
          color: color,
          fontSize: textSize > 0 ? textSize : 16,
          height: 1.15,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: rect.width);
    textPainter.paint(canvas, Offset(rect.left, rect.top));
  }

  void _drawGeometry(Canvas canvas, CloudNoteGraph graph) {
    final rect = _rect(graph.outRect);
    if (rect == null) return;
    final paint = _paint(graph.paint);
    final path = ui.Path();
    if (graph.pointList.length >= 3) {
      path.moveTo(graph.pointList.first.x, graph.pointList.first.y);
      for (final point in graph.pointList.skip(1)) {
        path.lineTo(point.x, point.y);
      }
      path.close();
    } else {
      path.addOval(rect);
    }
    canvas.drawPath(path, paint);
  }

  Paint _paint(CloudNotePaint? source, {bool forceStroke = false}) {
    final paint = Paint()..isAntiAlias = true;
    if (source == null) {
      paint
        ..color = Colors.black
        ..strokeWidth = 1
        ..style = forceStroke ? PaintingStyle.stroke : PaintingStyle.fill;
      return paint;
    }
    var color = Color(source.colorArgb);
    if ((source.colorArgb & 0xff000000) == 0 && source.colorArgb != 0) {
      color = color.withAlpha(0xff);
    }
    paint
      ..color = color
      ..strokeWidth = source.width > 0 ? source.width : 1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = forceStroke ? PaintingStyle.stroke : _style(source.style);
    return paint;
  }

  PaintingStyle _style(int value) {
    switch (value) {
      case 1:
        return PaintingStyle.stroke;
      case 2:
        // Flutter exposes fill and stroke separately.  Fill-and-stroke is
        // rendered as fill here; the graph's bounds remain visible through
        // its child/stroke nodes when present.
        return PaintingStyle.fill;
      default:
        return PaintingStyle.fill;
    }
  }

  Rect? _rect(CloudNoteRect? rect) {
    if (rect == null) return null;
    return Rect.fromLTRB(rect.left, rect.top, rect.right, rect.bottom);
  }

  Rect _graphBounds(
    CloudNoteGraph graph, [
    _CloudMatrix parent = const _CloudMatrix.identity(),
  ]) {
    final transform = parent.multiply(_CloudMatrix.fromSnapshot(graph.matrix));
    final ownRect = _rect(graph.outRect) ?? Rect.zero;
    var result = transform.transformRect(ownRect);
    for (final child in graph.childGraph) {
      result = result.expandToInclude(_graphBounds(child, transform));
    }
    return result;
  }

  Rect _transformRect(Rect rect, CloudNoteMatrix? matrix) {
    return _CloudMatrix.fromSnapshot(matrix).transformRect(rect);
  }

  void _applyMatrix(Canvas canvas, CloudNoteMatrix? matrix) {
    if (matrix == null) return;
    canvas.transform(Float64List.fromList(matrix.values));
  }

  @override
  bool shouldRepaint(covariant CloudNoteSnapshotPainter oldDelegate) =>
      !identical(oldDelegate.snapshot, snapshot) ||
      !identical(oldDelegate.images, images);
}

double mathMin(double a, double b) => a < b ? a : b;

class _CloudMatrix {
  const _CloudMatrix._(this.values);

  const _CloudMatrix.identity()
    : values = const <double>[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1];

  final List<double> values;

  factory _CloudMatrix.fromSnapshot(CloudNoteMatrix? matrix) {
    return matrix == null
        ? const _CloudMatrix.identity()
        : _CloudMatrix._(matrix.values);
  }

  _CloudMatrix multiply(_CloudMatrix other) {
    final result = List<double>.filled(16, 0);
    for (var column = 0; column < 4; column++) {
      for (var row = 0; row < 4; row++) {
        for (var index = 0; index < 4; index++) {
          result[column * 4 + row] +=
              values[index * 4 + row] * other.values[column * 4 + index];
        }
      }
    }
    return _CloudMatrix._(result);
  }

  Rect transformRect(Rect rect) {
    final points = <Offset>[
      _transformPoint(Offset(rect.left, rect.top)),
      _transformPoint(Offset(rect.right, rect.top)),
      _transformPoint(Offset(rect.right, rect.bottom)),
      _transformPoint(Offset(rect.left, rect.bottom)),
    ];
    if (points.any((point) => !point.dx.isFinite || !point.dy.isFinite)) {
      return Rect.zero;
    }
    return Rect.fromLTRB(
      points.map((point) => point.dx).reduce((a, b) => a < b ? a : b),
      points.map((point) => point.dy).reduce((a, b) => a < b ? a : b),
      points.map((point) => point.dx).reduce((a, b) => a > b ? a : b),
      points.map((point) => point.dy).reduce((a, b) => a > b ? a : b),
    );
  }

  Offset _transformPoint(Offset point) {
    final x = values[0] * point.dx + values[4] * point.dy + values[12];
    final y = values[1] * point.dx + values[5] * point.dy + values[13];
    final w = values[3] * point.dx + values[7] * point.dy + values[15];
    if (w == 0 || !w.isFinite) return const Offset(double.nan, double.nan);
    return Offset(x / w, y / w);
  }
}
