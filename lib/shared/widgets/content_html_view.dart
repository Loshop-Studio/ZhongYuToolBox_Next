import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// 图片统一尺寸（内容区 1/5）
const String _imgInlineStyle = 'max-width:20% !important;height:auto !important';

/// 把 `<img>` 上的 width/height/style 全部剥掉，再写入统一尺寸。
///
/// 只靠 CSS 压不住：题目 HTML 里常见 `<img style="width:800px !important">`，
/// 内联 `!important` 的优先级高于样式表里的 `!important`，只能在 Dart 侧改写标签。
String _cleanImgTags(String html) {
  return html.replaceAllMapped(
    RegExp(r'<img\b[^>]*>', caseSensitive: false),
    (match) {
      var tag = match[0]!;
      // 页面自己声明的整幅图片（如错题笔记截图）不做 1/5 收缩
      if (RegExp(
        r'''class\s*=\s*["'][^"']*note-shot''',
        caseSensitive: false,
      ).hasMatch(tag)) {
        return tag;
      }
      tag = tag.replaceAll(
        RegExp(
          r'''\s(?:width|height)\s*=\s*(?:"[^"]*"|'[^']*'|[^\s>]+)''',
          caseSensitive: false,
        ),
        '',
      );
      tag = tag.replaceAll(
        RegExp(r'''\sstyle\s*=\s*(?:"[^"]*"|'[^']*')''', caseSensitive: false),
        '',
      );
      return tag.replaceFirst(
        RegExp(r'<img', caseSensitive: false),
        '<img style="$_imgInlineStyle"',
      );
    },
  );
}

/// 注入到所有 HTML 的公共样式。
///
/// 题干图片常带 `width`/`height` 属性或内联 `style="width:800px"`，
/// 必须用 `!important` 才能压住；桌面宽屏下会被撑满，这里统一按内容区 1/5 显示
/// （`max-width` 只限制上限，16/24px 的小图标不受影响）。
const String _contentHtmlStyle = '''
html, body { margin: 0; padding: 0; }
body { padding: 16px; word-break: break-word; }
img,
.stem img, .qststem img, .answers img, .options img {
  max-width: 20% !important;
  height: auto !important;
}
/* 视频 / 附件 iframe 是整幅内容，不能跟着图片压到 1/5 */
video, iframe { max-width: 100% !important; }
svg { max-width: 100% !important; height: auto !important; }
/* 笔记截图 / 整幅图片：按内容区全宽显示 */
.note-shot { max-width: 100% !important; height: auto !important; }
table { border-collapse: collapse; max-width: 100% !important; }
td, th { max-width: 100% !important; }
pre { overflow-x: auto; }
.toolBar { display: none; }
''';

/// 把公共样式注入任意 HTML。
///
/// 两个坑：
/// 1. 题目 HTML 是完整文档但没有 `<head>`，早先直接 return 原串，样式完全没注入；
/// 2. 题目自带的 `<style>` 里可能有 `img { max-width: 100% }`，同属性后出现的会赢，
///    所以样式必须插到 `</body>` 之前（文档最后）。
String wrapContentHtml(String raw) {
  const meta =
      '<meta name="viewport" content="width=device-width, initial-scale=1">';
  final styleTag = '<style>$_contentHtmlStyle</style>';
  raw = _cleanImgTags(raw);
  final lower = raw.toLowerCase();

  if (!lower.contains('<html')) {
    return '<!DOCTYPE html><html><head><meta charset="utf-8">$meta$styleTag'
        '</head><body>$raw</body></html>';
  }

  var result = raw;
  if (lower.contains('</body>')) {
    result = result.replaceFirstMapped(
      RegExp(r'</body>', caseSensitive: false),
      (match) => '$styleTag</body>',
    );
  } else if (lower.contains('<body')) {
    result = result.replaceFirstMapped(
      RegExp(r'<body[^>]*>', caseSensitive: false),
      (match) => '${match[0]}$styleTag',
    );
  } else {
    result = '$styleTag$result';
  }

  if (lower.contains('<head')) {
    result = result.replaceFirstMapped(
      RegExp(r'<head[^>]*>', caseSensitive: false),
      (match) => '${match[0]}$meta',
    );
  }
  return result;
}

/// 富文本 HTML 渲染（专栏文章 / 章节内容 / 题目）。
///
/// 只做必要的排版约束，颜色、字体全部沿用平台默认样式。
///
/// 父级 rebuild 不应该重建 WebView：只有 html 真正变化时才换 key 重新加载，
/// 否则每次 setState 都会重载整页 HTML。
class ContentHtmlView extends StatefulWidget {
  const ContentHtmlView({
    super.key,
    required this.html,
    this.baseUrl = 'https://hagateway.zykj.org/',
    this.loadingText = '正在加载内容…',
    this.onLinkTap,
    this.autoHeight = false,
    this.minHeight = 240,
  });

  final String html;
  final String baseUrl;
  final String loadingText;

  /// 拦截页面内链接（附件 / zyattachment:// 自定义 scheme）
  final void Function(String url)? onLinkTap;

  /// 内容在无界高度容器（ListView / Column）里时必须开启：
  /// WebView 拿到无限高度约束会导致布局卡死。
  final bool autoHeight;

  final double minHeight;

  @override
  State<ContentHtmlView> createState() => _ContentHtmlViewState();
}

class _ContentHtmlViewState extends State<ContentHtmlView> {
  /// 每次调整注入规则时 +1：热重载会复用 State，靠它强制重新生成 HTML
  static const int _styleVersion = 3;

  late String _html;
  late String _wrapped;
  int _version = 0;
  int _wrappedVersion = 0;

  /// autoHeight 模式下量出的内容高度
  double? _contentHeight;

  @override
  void initState() {
    super.initState();
    _html = widget.html;
    _wrapped = wrapContentHtml(widget.html);
    _wrappedVersion = _styleVersion;
  }

  @override
  void didUpdateWidget(covariant ContentHtmlView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(oldWidget.html, widget.html)) return;
    if (oldWidget.html == widget.html) return;
    _html = widget.html;
    _wrapped = wrapContentHtml(widget.html);
    _version++;
    _contentHeight = null;
  }

  @override
  Widget build(BuildContext context) {
    // 热重载复用 State 时也重新生成，避免一直用旧样式
    if (_wrappedVersion != _styleVersion) {
      _html = widget.html;
      _wrapped = wrapContentHtml(widget.html);
      _wrappedVersion = _styleVersion;
      _version++;
      _contentHeight = null;
    }
    if (_html.trim().isEmpty) {
      return Center(
        child: Text('暂无内容', style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    final webView = InAppWebView(
      key: ValueKey<int>(_version),
      initialData: InAppWebViewInitialData(
        data: _wrapped,
        baseUrl: WebUri(widget.baseUrl),
        mimeType: 'text/html',
        encoding: 'utf-8',
      ),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        transparentBackground: true,
        disableContextMenu: true,
        supportZoom: true,
        allowsInlineMediaPlayback: true,
        mediaPlaybackRequiresUserGesture: true,
      ),
      onLoadStop: widget.autoHeight ? _measureHeight : null,
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final url = navigationAction.request.url?.toString() ?? '';
        if (url.isEmpty) return NavigationActionPolicy.ALLOW;
        final link = widget.onLinkTap;
        if (link != null && url.startsWith('zyattachment://')) {
          link(url);
          return NavigationActionPolicy.CANCEL;
        }
        return NavigationActionPolicy.ALLOW;
      },
    );

    if (!widget.autoHeight) return webView;
    return SizedBox(
      height: _contentHeight ?? widget.minHeight,
      child: webView,
    );
  }

  Future<void> _measureHeight(
    InAppWebViewController controller,
    WebUri? url,
  ) async {
    try {
      final result = await controller.evaluateJavascript(
        source:
            'Math.max(document.body.scrollHeight, document.documentElement.scrollHeight)',
      );
      final height = double.tryParse('$result');
      if (!mounted || height == null || height <= 0) return;
      // 单块内容限高，避免超长页面（大量图片）把 WebView 内存撑爆
      final next = height.clamp(widget.minHeight, 8000.0).toDouble();
      if (_contentHeight == null || (_contentHeight! - next).abs() > 1) {
        setState(() => _contentHeight = next);
      }
    } catch (_) {
      // 量高度失败就保持最小高度，不影响内容展示
    }
  }
}
