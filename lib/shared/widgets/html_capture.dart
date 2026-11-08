import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// 离屏渲染 HTML 并截图（用于错题缩略图 stemShoot，替代旧版 html2canvas）
class HtmlCapture extends StatefulWidget {
  const HtmlCapture({
    super.key,
    required this.html,
    required this.onCaptured,
    this.width = 720,
  });

  final String html;
  final void Function(Uint8List? bytes) onCaptured;
  final double width;

  @override
  State<HtmlCapture> createState() => _HtmlCaptureState();
}

class _HtmlCaptureState extends State<HtmlCapture> {
  InAppWebViewController? _controller;
  bool _done = false;

  static const String _style = '''
  html, body { margin: 0; padding: 12px; background: #ffffff; }
  body { font-size: 15px; line-height: 1.6; color: #000000; }
  img { max-width: 100%; height: auto; }
  table { border-collapse: collapse; }
  td, th { border: 1px solid #999; padding: 4px 6px; }
''';

  String _wrap(String raw) {
    if (raw.toLowerCase().contains('<html')) return raw;
    return '<!DOCTYPE html><html><head><meta charset="utf-8">'
        '<meta name="viewport" content="width=device-width, initial-scale=1">'
        '<style>$_style</style></head><body>$raw</body></html>';
  }

  Future<void> _capture() async {
    if (_done) return;
    final controller = _controller;
    if (controller == null) return;
    _done = true;
    try {
      final shot = await controller.takeScreenshot();
      if (!mounted) return;
      widget.onCaptured(shot);
    } catch (_) {
      if (!mounted) return;
      widget.onCaptured(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
      child: SizedBox(
        width: widget.width,
        height: 1,
        child: InAppWebView(
          initialData: InAppWebViewInitialData(
            data: _wrap(widget.html),
            mimeType: 'text/html',
            encoding: 'utf-8',
          ),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            transparentBackground: false,
          ),
          onWebViewCreated: (controller) => _controller = controller,
          onLoadStop: (controller, url) => _capture(),
        ),
      ),
    );
  }
}
