import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import 'question_html.dart';

/// 专栏文章 HTML 的附件处理（复刻 ColumnDetailView 的
/// proxyContentImages / processVideos / processPdfs + 事件委托）
///
/// 处理结果：
/// - `<img src>` 走 resolveUrl 替换（alicdn → OSS）
/// - `<video src>` / `.pdf-wrapper[data-url]` 变成附件卡片链接
/// - 链接统一为 `zyattachment://` 自定义 scheme，由 WebView 拦截后打开附件查看器
class ColumnContentProcessor {
  ColumnContentProcessor._();

  static const String scheme = 'zyattachment://open';
  static const String downloadScheme = 'zyattachment://download';

  static String encodeParams({
    required String url,
    required String kind,
    String name = '',
  }) {
    final query = <String>[
      'url=${Uri.encodeQueryComponent(url)}',
      'kind=${Uri.encodeQueryComponent(kind)}',
      'name=${Uri.encodeQueryComponent(name)}',
    ].join('&');
    return '$scheme?$query';
  }

  static String encodeDownload(String url, String name) {
    return '$downloadScheme?url=${Uri.encodeQueryComponent(url)}'
        '&name=${Uri.encodeQueryComponent(name)}';
  }

  /// 解析 zyattachment 链接
  static AttachmentLink? parseUri(String uri) {
    if (!uri.startsWith('zyattachment://')) return null;
    final parsed = Uri.parse(uri);
    final isDownload = parsed.host == 'download';
    final url = parsed.queryParameters['url'] ?? '';
    if (url.isEmpty) return null;
    return AttachmentLink(
      url: url,
      kind: parsed.queryParameters['kind'] ?? 'file',
      name: parsed.queryParameters['name'] ?? '',
      download: isDownload,
    );
  }

  static String process(
    String html, {
    required String Function(String url) resolveUrl,
  }) {
    if (html.trim().isEmpty) return html;
    final document = html_parser.parse(html);

    // 1) 图片地址处理
    for (final img in document.querySelectorAll('img').toList()) {
      final src = img.attributes['src'] ?? '';
      if (src.isEmpty) continue;
      img.attributes['src'] = resolveUrl(src);
    }

    // 2) 视频 → 附件卡片
    for (final video in document.querySelectorAll('video').toList()) {
      final src = video.attributes['src'] ?? '';
      if (src.isEmpty) continue;
      _replaceWithCard(
        video,
        url: resolveUrl(src),
        kind: 'video',
        name: _fileNameOf(src),
      );
    }

    // 3) PDF 附件块 → 附件卡片
    for (final wrapper in document.querySelectorAll('.pdf-wrapper').toList()) {
      final rawUrl = wrapper.attributes['data-url'] ?? '';
      if (rawUrl.isEmpty) continue;
      final url = resolveUrl(rawUrl);
      final anchor = wrapper.querySelector('a');
      final name = (anchor?.text ?? '').trim().isNotEmpty
          ? anchor!.text.trim()
          : tryDecodeUriComponent(_fileNameOf(rawUrl));
      _replaceWithCard(wrapper, url: url, kind: 'pdf', name: name);
    }

    return document.body?.innerHtml ?? html;
  }

  static String _fileNameOf(String url) {
    final path = Uri.tryParse(url)?.path ?? url;
    final segment = path.split('/').where((e) => e.isNotEmpty).toList();
    final last = segment.isEmpty ? path : segment.last;
    return tryDecodeUriComponent(last);
  }

  static void _replaceWithCard(
    dom.Element element, {
    required String url,
    required String kind,
    required String name,
  }) {
    final parent = element.parent;
    if (parent == null) {
      element.remove();
      return;
    }
    final card = html_parser.parseFragment('''
<div class="col-file-card" data-file-kind="$kind">
  <span class="col-file-name">附件：$name</span>
  <a class="col-file-link" href="${encodeParams(url: url, kind: kind, name: name)}">在线查看</a>
</div>
''');
    parent.insertBefore(card, element);
    element.remove();
  }
}

class AttachmentLink {
  const AttachmentLink({
    required this.url,
    required this.kind,
    required this.name,
    required this.download,
  });

  final String url;
  final String kind;
  final String name;
  final bool download;
}
