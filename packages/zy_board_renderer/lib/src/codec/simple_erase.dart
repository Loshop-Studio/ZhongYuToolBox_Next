part of 'board_file.dart';

/// SimpleBoard stores the expanded bounds when the path is built. The eraser
/// tests that rectangle before measuring its current radius against segments.
extension SimpleBoardEraser on BoardFile {
  static const defaultRadius = 40.0;

  List<simple.Path> get _paths => (message as simple.SimpleBoardData).path;

  Rect _simpleBounds(List<Offset> points, double radius) {
    if (points.isEmpty) return Rect.zero;
    var left = points.first.dx, right = left;
    var top = points.first.dy, bottom = top;
    for (final p in points.skip(1)) {
      left = math.min(left, p.dx);
      right = math.max(right, p.dx);
      top = math.min(top, p.dy);
      bottom = math.max(bottom, p.dy);
    }
    // The native path includes every stored vertex as an endpoint or quadratic
    // control point. Android expands each thin axis independently.
    final x = right - left < 2 * radius ? radius : 0.0;
    final y = bottom - top < 2 * radius ? radius : 0.0;
    return Rect.fromLTRB(left - x, top - y, right + x, bottom + y);
  }

  List<double> get simpleBoundsRadii => [
    for (final path in _paths) _pathRadii[path] ?? defaultRadius,
  ];

  void restoreSimpleBounds(List<double> radii) {
    if (radii.length != _paths.length) return;
    for (var i = 0; i < radii.length; i++) {
      _pathRadii[_paths[i]] = radii[i];
      _simpleHitBounds[i] = _simpleBounds(strokes[i].points, radii[i]);
    }
  }

  bool eraseSimpleAt(
    Offset center,
    double radius, {
    void Function()? beforeChange,
  }) {
    if (format != BoardFormat.simple || !radius.isFinite || radius <= 0)
      return false;
    var removed = false;
    for (var i = strokes.length - 1; i >= 0; i--) {
      if (!_simpleHitBounds[i].contains(center)) continue;
      final points = strokes[i].points;
      for (var end = 1; end < points.length; end++) {
        if (!_simpleSegmentHit(center, points[end - 1], points[end], radius))
          continue;
        if (!removed) beforeChange?.call();
        _paths.removeAt(i);
        _simpleHitBounds.removeAt(i);
        strokes.removeAt(i);
        removed = true;
        break;
      }
    }
    if (removed) dirty = true;
    return removed;
  }
}

// The two packaged distance helpers operate on Android floats. Rounding each
// intermediate matters at the radius: for the segment (20,48)–(260,48),
// the touch at (130,8) measures just over 40 in both APKs.
final _singlePrecision = Float32List(1);
double _float32(double n) {
  _singlePrecision[0] = n;
  return _singlePrecision[0];
}

double _simpleDistance(Offset from, Offset to) {
  final x = _float32(_float32(from.dx) - _float32(to.dx));
  final y = _float32(_float32(from.dy) - _float32(to.dy));
  return _float32(math.sqrt(_float32(_float32(x * x) + _float32(y * y))));
}

bool _simpleSegmentHit(Offset point, Offset from, Offset to, double radius) {
  final limit = _float32(radius);
  final length = _simpleDistance(from, to);
  final first = _simpleDistance(point, from);
  final last = _simpleDistance(point, to);
  if (_float32(first + last) == length) return true;
  if (length <= 1e-6) return first <= limit;
  final length2 = _float32(length * length);
  final first2 = _float32(first * first), last2 = _float32(last * last);
  if (last2 >= _float32(length2 + first2)) return first <= limit;
  if (first2 >= _float32(length2 + last2)) return last <= limit;
  final half = _float32(_float32(_float32(length + first) + last) / 2);
  final areaTerm = _float32(_float32(half - length) * half);
  final product = _float32(
    _float32(areaTerm * _float32(half - first)) * _float32(half - last),
  );
  return _float32(2 * math.sqrt(product) / length) <= limit;
}
