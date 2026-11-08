import 'dart:convert';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

/// 官方题目 HTML 解析（复刻 src/utils/questionHtml.ts）
///
/// - `parseQuestionHtml`：取 `.stem` / `.answers` / `.analysis`，并剔除 `.toolBar`、`h3`
/// - `safeQuestionHtml`：白名单过滤，保留公式占位（data-math-latex）与图片
class QuestionHtml {
  QuestionHtml._();

  static const Set<String> _allowedTags = {
    'div', 'p', 'span', 'br', 'b', 'strong', 'i', 'em', 'u', 's', 'strike',
    'sup', 'sub', 'table', 'thead', 'tbody', 'tfoot', 'tr', 'td', 'th',
    'ul', 'ol', 'li', 'img', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
    'pre', 'code', 'blockquote', 'hr', 'a', 'font', 'label', 'caption',
  };

  static final RegExp _imgSrcOk =
      RegExp(r'^(https?:|data:image/(png|jpeg|jpg|webp|gif);base64,)', caseSensitive: false);

  static dom.Document parse(String html) => html_parser.parse(html);

  static String innerHtmlOf(dom.Element? element) {
    if (element == null) return '';
    return element.innerHtml.trim();
  }

  static void _stripChrome(dom.Document document) {
    for (final selector in ['.toolBar', 'h3']) {
      for (final node in document.querySelectorAll(selector).toList()) {
        node.remove();
      }
    }
  }

  static void _stripChromeIn(dom.Element scope) {
    for (final selector in ['.toolBar', 'h3']) {
      for (final node in scope.querySelectorAll(selector).toList()) {
        node.remove();
      }
    }
  }

  /// 白名单过滤后的安全 HTML
  static String safeQuestionHtml(String html) {
    if (html.trim().isEmpty) return '';
    final document = parse('<div id="__root">$html</div>');
    final root = document.getElementById('__root');
    if (root == null) return '';
    _sanitizeChildren(root);
    return root.innerHtml.trim();
  }

  static void _sanitizeChildren(dom.Element parent) {
    for (final child in parent.nodes.toList()) {
      if (child is dom.Text) continue;
      if (child is! dom.Element) {
        child.remove();
        continue;
      }
      final tag = child.localName?.toLowerCase() ?? '';
      if (!_allowedTags.contains(tag)) {
        // 非白名单：保留子节点，去掉标签本身
        _sanitizeChildren(child);
        _unwrap(child);
        continue;
      }
      _sanitizeAttributes(child);
      _sanitizeChildren(child);
    }
  }

  static void _unwrap(dom.Element element) {
    final parent = element.parent;
    if (parent == null) {
      element.remove();
      return;
    }
    final children = element.nodes.toList();
    for (final child in children) {
      child.remove();
      parent.insertBefore(child, element);
    }
    element.remove();
  }

  static void _sanitizeAttributes(dom.Element element) {
    final tag = element.localName?.toLowerCase();
    final keep = <String>{};
    for (final key in element.attributes.keys.toList()) {
      final name = key.toString().toLowerCase();
      if (name.startsWith('data-math-')) {
        keep.add(name);
        continue;
      }
      if (tag == 'img') {
        if (name == 'src') {
          final value = element.attributes[key] ?? '';
          if (_imgSrcOk.hasMatch(value.trim())) {
            keep.add(name);
          }
        } else if (name == 'alt' ||
            name == 'width' ||
            name == 'height' ||
            name.startsWith('data-print-')) {
          keep.add(name);
        }
      } else if (tag == 'td' || tag == 'th') {
        if (name == 'colspan' || name == 'rowspan') keep.add(name);
      }
    }
    for (final key in element.attributes.keys.toList()) {
      if (!keep.contains(key.toString().toLowerCase())) {
        element.attributes.remove(key);
      }
    }
  }

  /// 解析题目 HTML 为结构化字段
  static ParsedQuestion parseQuestionHtml(String html) {
    final document = parse(html);
    _stripChrome(document);
    final stem = innerHtmlOf(document.querySelector('.stem'));
    final answerElement = document.querySelector('.answers');
    var answer = innerHtmlOf(answerElement);
    if (answer.isEmpty) answer = '官方未提供答案';

    final analysisElements = document.querySelectorAll('.analysis').toList();
    var analysis = '';
    var knowledge = '';
    if (analysisElements.isNotEmpty) {
      for (final element in analysisElements) {
        _stripChromeIn(element);
      }
      analysis = innerHtmlOf(analysisElements.first);
      if (analysisElements.length > 1) {
        knowledge = innerHtmlOf(analysisElements[1]);
      }
    }
    return ParsedQuestion(
      stem: safeQuestionHtml(stem),
      answer: safeQuestionHtml(answer),
      analysis: safeQuestionHtml(analysis),
      knowledge: safeQuestionHtml(knowledge),
    );
  }
}

class ParsedQuestion {
  const ParsedQuestion({
    required this.stem,
    required this.answer,
    required this.analysis,
    required this.knowledge,
  });

  final String stem;
  final String answer;
  final String analysis;
  final String knowledge;

  bool get isEmpty => stem.trim().isEmpty;
}

/// URL 编解码小工具
String tryDecodeUriComponent(String value) {
  try {
    return Uri.decodeComponent(value);
  } catch (_) {
    return value;
  }
}

String jsonPretty(dynamic value) => const JsonEncoder.withIndent('  ').convert(value);
