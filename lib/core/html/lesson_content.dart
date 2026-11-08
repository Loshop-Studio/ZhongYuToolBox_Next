import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import 'column_content.dart';

/// 优客畅学章节 HTML 的附件改写（复刻 composables/useContentRenderer.ts）
///
/// 旧版在 WebView 内把 `<object>` / `<video>` / `<div data-type|data-id>` 改写为
/// 「附件：名 在线查看 点击下载」。Flutter 版在 Dart 侧预处理成同样的链接，
/// 由 WebView 拦截 `zyattachment://` scheme 打开附件查看器。
class LessonContentProcessor {
  LessonContentProcessor._();

  static const String attachmentStyle = '''
  .lesson-attachment { padding: 8px 10px; border-bottom: 1px solid rgba(0,0,0,.08); }
  .lesson-attachment .lesson-attachment-actions { margin-top: 4px; }
  .lesson-attachment a { margin-right: 12px; }
  .lesson-notice { opacity: .7; }
''';

  static String process(
    String html, {
    required String Function(String url) resolveUrl,
  }) {
    if (html.trim().isEmpty) return html;
    final document = html_parser.parse(html);

    _changeObjects(document, resolveUrl);
    _changeVideos(document, resolveUrl);
    _changeDivs(document, resolveUrl);

    final body = document.body?.innerHtml ?? html;
    return '<style>$attachmentStyle</style>$body';
  }

  /// 是否仍有未渲染的附件（对应旧版 hasRawAttachments）
  static bool hasRawAttachments(String html) {
    if (html.trim().isEmpty) return false;
    final document = html_parser.parse(html);
    if (document.querySelector('object') != null) return true;
    for (final video in document.querySelectorAll('video')) {
      if (!(video.attributes.containsKey('controls'))) return true;
    }
    for (final div in document.querySelectorAll('div')) {
      if (div.attributes.containsKey('data-type') ||
          div.attributes.containsKey('data-id')) {
        return true;
      }
    }
    return false;
  }

  static void _changeObjects(dom.Document document, String Function(String) resolve) {
    for (final object in document.querySelectorAll('object').toList()) {
      final data = object.attributes['data'] ?? '';
      if (data.isEmpty) continue;
      final name = (object.attributes['name'] ?? '').trim().isNotEmpty
          ? object.attributes['name']!.trim()
          : '附件';
      _insertRow(
        object,
        name: name,
        viewUrl: resolve(data),
        downloadUrl: resolve(data),
      );
    }
  }

  static void _changeVideos(dom.Document document, String Function(String) resolve) {
    for (final video in document.querySelectorAll('video').toList()) {
      if (video.attributes.containsKey('controls')) continue;
      final src = video.attributes['src'] ?? '';
      if (src.isEmpty) continue;
      _insertRow(
        video,
        name: '视频',
        viewUrl: resolve(src),
        downloadUrl: resolve(src),
        kind: 'video',
      );
    }
  }

  static void _changeDivs(dom.Document document, String Function(String) resolve) {
    for (final div in document.querySelectorAll('div').toList()) {
      final type = (div.attributes['data-type'] ?? '').toLowerCase();
      final dataId = div.attributes['data-id'];
      if (type.isEmpty && (dataId == null || dataId.isEmpty)) continue;

      if (type == 'ppt') {
        final name = (div.attributes['data-name'] ?? '').trim();
        final url = div.attributes['data-url'] ?? '';
        if (url.isEmpty) continue;
        // 查看走原始地址（供 Office Online 预览），下载走资源地址
        _insertRow(
          div,
          name: name.isNotEmpty ? name : '课件',
          viewUrl: url,
          downloadUrl: resolve(url),
          kind: 'ppt',
        );
      } else if (type == 'pdf') {
        final name = (div.attributes['data-name'] ?? '').trim();
        final url = div.attributes['data-url'] ?? '';
        if (url.isEmpty) continue;
        _insertRow(
          div,
          name: name.isNotEmpty ? name : '文档',
          viewUrl: resolve(url),
          downloadUrl: resolve(url),
          kind: 'pdf',
        );
      } else if (type == 'image-block') {
        final img = div.querySelector('img');
        final src = img?.attributes['src'] ?? '';
        if (src.isEmpty) continue;
        final resolved = resolve(src);
        final fragment = html_parser.parseFragment(
          '<img src="$resolved" style="width:100%">',
        );
        div.replaceWith(fragment);
      } else if (dataId != null && dataId.isNotEmpty) {
        final name = (div.attributes['data-name'] ?? '').trim();
        _insertNotice(div, '无法查看习题：${name.isNotEmpty ? name : dataId}');
      } else {
        _insertNotice(div, '暂不支持的附件类型：$type');
      }
    }
  }

  static void _insertRow(
    dom.Element element, {
    required String name,
    required String viewUrl,
    required String downloadUrl,
    String kind = 'file',
  }) {
    final parent = element.parent;
    if (parent == null) {
      element.remove();
      return;
    }
    final row = html_parser.parseFragment('''
<div class="lesson-attachment">
  <div class="lesson-attachment-name">附件：$name</div>
  <div class="lesson-attachment-actions">
    <a class="lesson-attachment-view" href="${ColumnContentProcessor.encodeParams(url: viewUrl, kind: kind, name: name)}">在线查看</a>
    <a class="lesson-attachment-download" href="${ColumnContentProcessor.encodeDownload(downloadUrl, name)}">点击下载</a>
  </div>
</div>
''');
    parent.insertBefore(row, element);
    element.remove();
  }

  static void _insertNotice(dom.Element element, String text) {
    final parent = element.parent;
    if (parent == null) {
      element.remove();
      return;
    }
    final row = html_parser.parseFragment('<p class="lesson-notice">$text</p>');
    parent.insertBefore(row, element);
    element.remove();
  }
}
