/// 注入到 WebView 页面的 JS 桥。
///
/// 官方网页对附件是**按类型分别调用**的，例如：
/// ```html
/// onclick="if(window.JsToJava && 'html' === 'html') {
///   window.JsToJava.open_html(url)
/// } else if(window.JsToJava) {
///   window.JsToJava.open_file(url)
/// } else { window.open(url) }"
/// ```
/// 所以只要 `window.JsToJava` 存在但缺 `open_html`，就会抛
/// `undefined is not a function`，后面的 fallback 也不会执行 —— 页面点击直接没反应。
/// 这里把常见的几个入口都补全，Dart 侧统一注册同名 handler。
const String jsToJavaBridgeScript = '''
(function () {
  var bridge = window.JsToJava || {};

  function call(name, url) {
    try { console.log('[JsToJava] ' + name + ': ' + url); } catch (e) {}
    try {
      if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
        window.flutter_inappwebview.callHandler(name, String(url));
      }
    } catch (e) {}
  }

  bridge.open_file = function (url) { call('open_file', url); };
  bridge.open_html = function (url) { call('open_html', url); };
  bridge.open_pdf = function (url) { call('open_pdf', url); };
  bridge.open_video = function (url) { call('open_video', url); };

  window.JsToJava = bridge;
})();
''';

/// 把在线专栏页面里的 `<video>` 连同外层 `.media-wrap.video-wrap` 一起替换成附件卡片：
/// 整块容器换成 `div.easy-editor-upload__wrapper`，不留下空的播放器外壳。
/// 页面没这个包裹层时退回只替换 `<video>` 本身。
///
/// 把在线专栏页面里的 `<video>` **整个节点**替换成官方编辑器输出的附件卡片：
/// 外层包 `<div class="easy-editor-upload pdf-wrapper" data-url="...">`，
/// 内层为 `<div class="easy-editor-upload__wrapper">` + `ic_video` + 内联 `onclick` 的 `<a>视频</a>`。
///
/// onclick 里的 URL 用视频自身的 src（mp4）；模板中 `'pdf' === 'html'` 恒假，
/// 实际走 `window.JsToJava.open_file(url)`，Flutter 侧进入原生播放器并支持下载。
/// 用原始字符串（r'''）保留 JS 里的 \' 转义，避免 Dart 先吃掉反斜杠。
///
/// MutationObserver 兜住 SPA 路由切换后的重新渲染，回调做了 60ms 合并。
const String columnVideoReplaceScript = r'''
(function () {
  function build(url) {
    var safe = String(url).replace(/'/g, '%27');
    var html =
      '<div class="easy-editor-upload pdf-wrapper" data-url="' + safe + '">' +
        '<div class="easy-editor-upload__wrapper">' +
          '<i class="easy-editor-icon ic_video"></i>' +
          '<div class="easy-editor-upload__name">' +
          '<a onclick="if(window.JsToJava &amp;&amp; \'pdf\' === \'html\') {window.JsToJava.open_html(\'' + safe + '\')} else if(window.JsToJava) {window.JsToJava.open_file(\'' + safe + '\')}else {window.open(\'' + safe + '\')}">视频</a>' +
          '</div>' +
        '</div>' +
      '</div>';
    var holder = document.createElement('div');
    holder.innerHTML = html;
    return holder.firstChild;
  }

  // 往上找 .media-wrap.video-wrap，整块一起换掉
  function wrapperOf(video) {
    var node = video;
    while (node && node !== document.body) {
      if (node.classList &&
          node.classList.contains('media-wrap') &&
          node.classList.contains('video-wrap')) {
        return node;
      }
      node = node.parentElement;
    }
    return video;
  }

  function replace() {
    var videos = document.querySelectorAll('video');
    for (var i = 0; i < videos.length; i++) {
      var video = videos[i];
      if (video.getAttribute('data-zy-replaced')) continue;

      var src = video.getAttribute('src') || '';
      if (!src) {
        var source = video.querySelector('source');
        if (source) src = source.getAttribute('src') || '';
      }
      if (!src) continue;

      var target = wrapperOf(video);
      if (target.getAttribute('data-zy-replaced')) continue;
      if (!target.parentNode) continue;

      target.setAttribute('data-zy-replaced', '1');
      var card = build(src);
      target.parentNode.replaceChild(card, target);
    }
  }

  replace();
  if (!window.__zyVideoReplacer) {
    var timer = null;
    window.__zyVideoReplacer = new MutationObserver(function () {
      if (timer) return;
      timer = setTimeout(function () {
        timer = null;
        replace();
      }, 60);
    });
    window.__zyVideoReplacer.observe(document.documentElement, {
      childList: true,
      subtree: true
    });
  }
})();
''';

/// 隐藏在线专栏页面里官方自带的返回箭头
/// `<i class="anticon anticon-left card-icon">`：App 侧 AppBar 已有返回键，
/// 避免与官方返回箭头重复。MutationObserver 兜住 SPA 异步渲染。
const String columnHideBackArrowScript = r'''
(function () {
  function hide() {
    var els = document.querySelectorAll('.anticon-left.card-icon');
    for (var i = 0; i < els.length; i++) {
      els[i].style.display = 'none';
    }
  }
  hide();
  if (!window.__zyHideChrome) {
    var timer = null;
    window.__zyHideChrome = new MutationObserver(function () {
      if (timer) return;
      timer = setTimeout(function () {
        timer = null;
        hide();
      }, 60);
    });
    window.__zyHideChrome.observe(document.documentElement, {
      childList: true,
      subtree: true
    });
  }
})();
''';

/// `window.flutter_inappwebview._callHandler(name, funcName, JSON.stringify(args))`
///
/// flutter_inappwebview 6.x 只提供 `callHandler(name, ...args)`，
/// 所以这里补一层转发，让页面原生的 `video_play` / `open_file` / `exercise` 等调用能落到 Dart。
const String legacyBridgeScript = '''
(function () {
  var bridge = window.flutter_inappwebview;
  if (!bridge || bridge._callHandler) return;
  bridge._callHandler = function (handlerName, funcName, argsJson) {
    try {
      var args = [];
      if (argsJson) {
        args = JSON.parse(argsJson);
        if (!Array.isArray(args)) args = [args];
      }
      console.log('[JsToJava] ' + handlerName + '.' + funcName + ' ' + JSON.stringify(args));
      return bridge.callHandler.apply(bridge, [handlerName].concat(args));
    } catch (e) {
      return null;
    }
  };
})();
''';
