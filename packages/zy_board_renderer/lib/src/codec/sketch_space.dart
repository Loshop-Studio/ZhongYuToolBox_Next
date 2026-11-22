part of 'board_file.dart';

const _identity = <double>[1, 0, 0, 0, 1, 0, 0, 0, 1];

// ActionExecute.buildMatrix copies the supplied values into a zeroed float[9].
List<double> _snapshotMatrix(List<double> values) {
  if (values.length > 9 || values.any((v) => !v.isFinite)) {
    throw const FormatException('画板快照的变换矩阵无效');
  }
  return [...values, ...List.filled(9 - values.length, 0.0)];
}

Offset _sketchPoint(List<double> m, Offset p) {
  final w = m[6] * p.dx + m[7] * p.dy + m[8];
  if (w == 0) return Offset.zero;
  return Offset(
    (m[0] * p.dx + m[1] * p.dy + m[2]) / w,
    (m[3] * p.dx + m[4] * p.dy + m[5]) / w,
  );
}

List<double> _sketchInverse(List<double> m) {
  try {
    return _inverse(m);
  } on FormatException {
    // GraphExtKt.inverts returns the fresh identity Matrix if invert fails.
    return _identity;
  }
}

/// Native stroke graphs map their points before drawing, leaving pen width in viewport units.
class _SketchSpace {
  _SketchSpace(this.root, this.children);
  final List<double> root, children;
  late final forward = _mul(root, children);
  late final backward = _mul(_sketchInverse(children), _sketchInverse(root));
  late final unchanged = _isIdentity();
  bool _isIdentity() {
    for (int i = 0; i < 9; i++) {
      if (forward[i] != _identity[i]) return false;
    }
    return true;
  }

  Offset local(Offset p) => unchanged ? p : _sketchPoint(backward, p);
  Offset screen(Offset p) => unchanged ? p : _sketchPoint(forward, p);
  Ink display(Ink s) => unchanged
      ? s
      : Ink(
          s.points.map(screen).toList(),
          s.argb,
          s.width,
          erase: s.erase,
          dashed: s.dashed,
          shape: s.shape,
        );

  _SketchSpace pan(double dx, double dy) =>
      _SketchSpace(_mul([1, 0, dx, 0, 1, dy, 0, 0, 1], root), children);

  _SketchSpace translate(sk.ActionTranslation a) {
    if (a.keep) return pan(a.transX.value, a.transY.value);
    final m = List.of(root);
    if (a.hasTransX()) m[2] = a.transX.value;
    if (a.hasTransY() || !a.hasTransX()) m[5] = a.transY.value;
    return _SketchSpace(m, children);
  }

  _SketchSpace zoom(sk.ActionZoom a) {
    final m = a.keep ? root : <double>[1, 0, root[2], 0, 1, root[5], 0, 0, 1];
    return _SketchSpace(
      _mul([
        a.scaleX,
        0,
        a.centerX * (1 - a.scaleX),
        0,
        a.scaleY,
        a.centerY * (1 - a.scaleY),
        0,
        0,
        1,
      ], m),
      children,
    );
  }
}
