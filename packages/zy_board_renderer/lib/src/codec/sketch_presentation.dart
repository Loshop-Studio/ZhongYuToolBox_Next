part of 'board_file.dart';

/// A Sketch WebViewGraph scales a 720 x 450 Android WebView capture to the
/// requested bitmap dimensions, then draws it with the graph's render matrix.
class SketchPresentation implements _SketchLayer {
  SketchPresentation._(
    this.id,
    this.filename,
    this.width,
    this.height,
    this.opacity,
    this.localMatrix,
    this._read,
  );
  final String id, filename;
  final int width, height;
  final double opacity;
  final List<double> localMatrix;
  final Uint8List? Function(String)? _read;

  static bool _validPath(String path) =>
      path.isNotEmpty &&
      !path.contains('\\') &&
      !path.contains(':') &&
      !path.split('/').any((p) => p.isEmpty || p == '.' || p == '..');

  // The player opens res/ppt/<entry>. The recorder's addPPT copies the source
  // directory contents directly into res/. Keep every relative reference in
  // the directory of the selected HTML, including when both layouts exist.
  late final String _prefix =
      _validPath(filename) && _read?.call('ppt/$filename') != null
      ? 'ppt/'
      : '';
  Uint8List? resource(String path) =>
      _validPath(path) ? _read?.call('$_prefix$path') : null;

  bool get hasHtml =>
      RegExp(r'\.html?$', caseSensitive: false).hasMatch(filename) &&
      resource(filename) != null;

  String get missingLabel => '课件资源 res/ppt/$filename 或 res/$filename';

  factory SketchPresentation.action(
    sk.ActionWebViewConfig config,
    String id,
    Uint8List? Function(String)? read,
  ) {
    final w = config.width,
        h = config.height,
        vw = config.viewWidth,
        vh = config.viewHeight;
    final factor = (vw > 0 && vh > 0) ? math.min(w / vw, h / vh) : 0.0;
    // getSaleCenterMatrix divides dimensions as integers for the pivot and
    // translation, but takes both aspect ratios using float division.
    final cx = vw ~/ 2, cy = vh ~/ 2;
    return SketchPresentation._(id, config.path, w, h, 1, [
      factor,
      0,
      cx * (1 - factor) + cx - w ~/ 2,
      0,
      factor,
      cy * (1 - factor) + cy - h ~/ 2,
      0,
      0,
      1,
    ], read);
  }
}
