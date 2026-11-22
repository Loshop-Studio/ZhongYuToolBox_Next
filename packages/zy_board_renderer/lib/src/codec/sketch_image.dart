part of 'board_file.dart';

/// The original ImageGraph render matrix depends on the decoded bitmap width.
/// Keep its bytes in the archive and resolve that last scale at display time.
class SketchBitmap implements _SketchLayer {
  SketchBitmap._(this.filename, this.bytes, this.opacity, this.localMatrix);
  final String filename;
  final Uint8List bytes;
  final double opacity;
  final List<double> Function(double bitmapWidth) localMatrix;

  factory SketchBitmap.backing(
    Uint8List bytes,
    int width,
    int height,
    Size view,
  ) {
    // RecordControl.loadData uses addAdapterImage with mode 23 and flag 0:
    // centre the bitmap, shrinking it proportionally only if it exceeds the view.
    final scale = math.min(
      1.0,
      math.min(view.width / width, view.height / height),
    );
    return SketchBitmap.fromAction(
      sk.ActionImageConfig(
        path: 'thumbnail.jpg',
        width: (width * scale).toInt(),
        height: (height * scale).toInt(),
        viewWidth: view.width.toInt(),
        viewHeight: view.height.toInt(),
      ),
      bytes,
      _SketchSpace(_identity, _identity),
    );
  }

  factory SketchBitmap.fromAction(
    sk.ActionImageConfig image,
    Uint8List bytes,
    _SketchSpace space,
  ) {
    final flag = image.positionFlag;
    final dx = (image.viewWidth - image.width).toDouble();
    final dy = (image.viewHeight - image.height).toDouble();
    final x = switch (flag) {
      1 || 4 || 7 => 0.0,
      3 || 6 || 9 => dx,
      _ => dx / 2,
    };
    final y = switch (flag) {
      1 || 2 || 3 => 0.0,
      7 || 8 || 9 => dy,
      _ => dy / 2,
    };
    final inverse = _sketchInverse(space.forward);
    return SketchBitmap._(image.path, bytes, 1, (bitmapWidth) {
      final scale = image.width / bitmapWidth;
      // Android onMeasure post-scales the inverse world matrix, then post-translates.
      return _mul([scale, 0, x, 0, scale, y, 0, 0, 1], inverse);
    });
  }

  factory SketchBitmap.fromSnapshot(
    snapshot.File ref,
    Uint8List bytes,
    List<double> world,
    snapshot.GraphData graph,
  ) {
    final recordedWidth = graph.outRect.right - graph.outRect.left;
    return SketchBitmap._(ref.fileName, bytes, (graph.color >>> 24 & 255) / 255, (
      bitmapWidth,
    ) {
      if (bitmapWidth == recordedWidth) return world;
      // checkOldData rescales old snapshots whose bounds used the requested display width.
      final s = ref.width / bitmapWidth;
      return _mul(world, [s, 0, 0, 0, s, 0, 0, 0, 1]);
    });
  }

  List<double> displayMatrix(List<double> root, double bitmapWidth) =>
      _mul(root, localMatrix(bitmapWidth));
}

SketchFrame _sketchFrame(
  List<_SketchLayer> scene,
  _SketchSpace space,
  int color, {
  Rect? drawArea,
}) {
  final ink = <Ink>[], art = <PageArtwork>[];
  for (final node in scene) {
    switch (node) {
      case Ink stroke:
        ink.add(space.display(stroke));
      case SketchPresentation deck:
        art.add(
          PageArtwork(
            ink.length,
            _mul(space.forward, deck.localMatrix),
            Rect.zero,
            paint.Paint(),
          )..presentation = deck,
        );
      case SketchBitmap bitmap:
        art.add(
          PageArtwork(ink.length, space.forward, Rect.zero, paint.Paint())
            ..sketchBitmap = bitmap,
        );
    }
  }
  return SketchFrame(ink, color, art, sketchDrawArea: drawArea);
}
