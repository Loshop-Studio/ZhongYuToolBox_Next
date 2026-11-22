part of 'board_file.dart';

/// V2 restores the whole graph on the last touch sample. Retain its tree,
/// including opaque protobuf fields, and any WebView actions following it.
class _V2Scene {
  snapshot.GraphData? _root;
  final _decks = <snapshot.GraphData>[];

  void restore(snapshot.GraphData root) {
    _root = root;
    _decks.clear();
  }

  void addDeck(sk.ActionWebViewConfig config, SketchPresentation deck) {
    final file = snapshot.File(
      fileName: config.path,
      width: config.width,
      height: config.height,
      viewWidth: config.viewWidth,
      viewHeight: config.viewHeight,
    );
    _decks.add(
      snapshot.GraphData(
        graphType: snapshot.GraphType.WEB_VIEW_GRAPH,
        name: deck.id,
        color: -16777216,
        matrix: deck.localMatrix,
        childExtendMatrix: _identity,
        extra: Any(
          typeUrl: 'type.googleapis.com/File',
          value: file.writeToBuffer(),
        ),
      ),
    );
  }

  snapshot.GraphData after(Ink ink, Iterable<Offset> samples, Int64 start) {
    var root =
        _root?.deepCopy() ??
        snapshot.GraphData(matrix: _identity, childExtendMatrix: _identity);
    root.childGraph.addAll(_decks);
    final space = _SketchSpace(
      _snapshotMatrix(root.matrix),
      _snapshotMatrix(root.childExtendMatrix),
    );
    // A missing native snapshot builds a zero matrix. Keep that subtree while
    // adding future ink in visible board coordinates.
    final inverse = _tryInverse(space.forward);
    Offset local(Offset p) => inverse == null ? p : _sketchPoint(inverse, p);
    if (inverse == null) {
      root = snapshot.GraphData(
        matrix: _identity,
        childExtendMatrix: _identity,
        childGraph: [root],
      );
    }
    if (ink.erase) {
      void eraseFrom(snapshot.GraphData node, List<double> parent) {
        final world = _mul(parent, _snapshotMatrix(node.matrix));
        final children = _mul(world, _snapshotMatrix(node.childExtendMatrix));
        node.childGraph.removeWhere((child) {
          if (child.graphType == snapshot.GraphType.STROKE_GRAPH &&
              child.extra.typeUrl.endsWith('/Touch')) {
            final matrix = _mul(children, _snapshotMatrix(child.matrix));
            final touch = snapshot.Touch.fromBuffer(child.extra.value);
            return touch.pointF.any((xy) {
              final p = _sketchPoint(matrix, Offset(xy.x, xy.y));
              return ink.points.any(
                (q) => (p - q).distance <= math.max(9, ink.width),
              );
            });
          }
          eraseFrom(child, children);
          return false;
        });
      }

      eraseFrom(root, _identity);
      return root;
    }
    final touch = snapshot.Touch(
      pointF: samples.map(local).map((p) => snapshot.PointF(x: p.dx, y: p.dy)),
    );
    final stroke = snapshot.GraphData(
      graphType: snapshot.GraphType.STROKE_GRAPH,
      name: 'web-stroke-$start',
      width: ink.width,
      color: ink.argb.toSigned(32),
      matrix: _identity,
      childExtendMatrix: _identity,
      extra: Any(
        typeUrl: 'type.googleapis.com/Touch',
        value: touch.writeToBuffer(),
      ),
    );
    root.childGraph.add(
      snapshot.GraphData(
        graphType: snapshot.GraphType.WRITING_GROUP_GRAPH,
        name: 'web-group-$start',
        matrix: _identity,
        childExtendMatrix: _identity,
        childGraph: [stroke],
      ),
    );
    return root;
  }
}
