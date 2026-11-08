import 'package:flutter_test/flutter_test.dart';
import 'package:zhongyu_toolbox/shared/widgets/content_html_view.dart';

void main() {
  test('题目那种完整文档（没有 head）也会注入样式', () {
    const raw =
        '<html><body><div class="stem"><img src="a.png" width="800"></div></body></html>';
    final wrapped = wrapContentHtml(raw);
    expect(wrapped.contains('max-width: 20% !important'), isTrue);
    // 样式必须出现在内容之后，才能压住题目自带的 img 规则
    expect(
      wrapped.indexOf('max-width: 20%'),
      greaterThan(wrapped.indexOf('<div class="stem">')),
    );
    expect(wrapped.trimRight().endsWith('</body></html>'), isTrue);
  });

  test('带 head 的文档把 viewport 放进 head、样式留在 body 末尾', () {
    const raw =
        '<html><head><title>t</title></head><body><p>x</p></body></html>';
    final wrapped = wrapContentHtml(raw);
    expect(wrapped.contains('name="viewport"'), isTrue);
    expect(
      wrapped.indexOf('name="viewport"'),
      lessThan(wrapped.indexOf('</head>')),
    );
    expect(
      wrapped.indexOf('max-width: 20%'),
      greaterThan(wrapped.indexOf('<p>x</p>')),
    );
  });

  test('HTML 片段会被包成完整文档', () {
    final wrapped = wrapContentHtml('<p>hi</p>');
    expect(wrapped.startsWith('<!DOCTYPE html>'), isTrue);
    expect(wrapped.contains('<body><p>hi</p></body>'), isTrue);
  });

  test('img 的内联 width/height/style 会被剥掉并统一尺寸', () {
    const raw = '<html><body>'
        '<img src="a.png" width="800" height="600" style="width:800px !important">'
        '<img src="b.png">'
        '</body></html>';
    final wrapped = wrapContentHtml(raw);
    expect(wrapped.contains('width="800"'), isFalse);
    expect(wrapped.contains('height="600"'), isFalse);
    expect(wrapped.contains('width:800px'), isFalse);
    expect(
      RegExp(r'<img style="max-width:20% !important;height:auto !important"')
          .allMatches(wrapped)
          .length,
      2,
    );
    expect(wrapped.contains('src="a.png"'), isTrue);
    expect(wrapped.contains('src="b.png"'), isTrue);
  });
}
