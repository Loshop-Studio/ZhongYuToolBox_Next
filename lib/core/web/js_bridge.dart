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

/// 把在线专栏页面里的 `<video>` / `<audio>` 连同媒体包裹层一起替换成附件卡片。
/// 视频使用 `ic_video`，音频使用 `ic_audio`；有包裹层时替换整个容器，避免留下空播放器。
///
/// onclick 里的 URL 用视频自身的 src（mp4）；模板中 `'pdf' === 'html'` 恒假，
/// 实际走 `window.JsToJava.open_file(url)`，Flutter 侧进入原生播放器并支持下载。
/// 用原始字符串（r'''）保留 JS 里的 \' 转义，避免 Dart 先吃掉反斜杠。
///
/// MutationObserver 兜住 SPA 路由切换后的重新渲染，回调做了 60ms 合并。
const String columnVideoReplaceScript = r'''
(function () {
  function build(url, type) {
    var safe = String(url).replace(/'/g, '%27');
    var isAudio = type === 'audio';
    var icon = isAudio ? 'ic_audio' : 'ic_video';
    var label = isAudio ? '音频' : '视频';
    var html =
      '<div class="easy-editor-upload pdf-wrapper" data-url="' + safe + '">' +
        '<div class="easy-editor-upload__wrapper">' +
          '<i class="easy-editor-icon ' + icon + '"></i>' +
          '<div class="easy-editor-upload__name">' +
          '<a onclick="if(window.JsToJava &amp;&amp; \'pdf\' === \'html\') {window.JsToJava.open_html(\'' + safe + '\')} else if(window.JsToJava) {window.JsToJava.open_file(\'' + safe + '\')}else {window.open(\'' + safe + '\')}">' + label + '</a>' +
          '</div>' +
        '</div>' +
      '</div>';
    var holder = document.createElement('div');
    holder.innerHTML = html;
    return holder.firstChild;
  }

  function wrapperOf(media, type) {
    var node = media;
    var wrapperClass = type === 'audio' ? 'audio-wrap' : 'video-wrap';
    while (node && node !== document.body) {
      if (node.classList &&
          node.classList.contains('media-wrap') &&
          node.classList.contains(wrapperClass)) {
        return node;
      }
      node = node.parentElement;
    }
    return media;
  }

  function replaceMedia(type) {
    var medias = document.querySelectorAll(type);
    for (var i = 0; i < medias.length; i++) {
      var media = medias[i];
      if (media.getAttribute('data-zy-replaced')) continue;

      var src = media.getAttribute('src') || '';
      if (!src) {
        var source = media.querySelector('source');
        if (source) src = source.getAttribute('src') || '';
      }
      if (!src) continue;

      var target = wrapperOf(media, type);
      if (target.getAttribute('data-zy-replaced')) continue;
      if (!target.parentNode) continue;

      target.setAttribute('data-zy-replaced', '1');
      target.parentNode.replaceChild(build(src, type), target);
    }
  }

  function replace() {
    replaceMedia('video');
    replaceMedia('audio');
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

/// 删除移动端在线专栏页面底部的“最近更新”时间。
/// MutationObserver 兜住 SPA 异步渲染和文章切换后重新插入的节点。
const String columnRemoveMobileUpdateTimeScript = r'''
(function () {
  function removeUpdateTime() {
    var els = document.querySelectorAll('.bottom-time-span');
    for (var i = 0; i < els.length; i++) {
      if (els[i].parentNode) {
        els[i].parentNode.removeChild(els[i]);
      }
    }
  }
  removeUpdateTime();
  if (!window.__zyRemoveMobileUpdateTime) {
    var timer = null;
    window.__zyRemoveMobileUpdateTime = new MutationObserver(function () {
      if (timer) return;
      timer = setTimeout(function () {
        timer = null;
        removeUpdateTime();
      }, 60);
    });
    window.__zyRemoveMobileUpdateTime.observe(document.documentElement, {
      childList: true,
      subtree: true
    });
  }
})();
''';

/// 接管在线专栏网页里的评论入口。
///
/// 在 document start 阶段先注册捕获监听，抢在网页框架的事件委托之前阻断点击；
/// 同时 clone 节点以移除节点及其子元素上的监听器，再清除内联 on* 属性。
/// MutationObserver 负责处理 SPA 异步渲染和文章切换后的新节点。
const String columnCommentTakeoverScript = r'''
(function () {
  function isCommentEntry(element) {
    if (!element || !element.querySelector) return false;
    var uses = element.querySelectorAll('use');
    for (var i = 0; i < uses.length; i++) {
      var href = uses[i].getAttribute('href') ||
        uses[i].getAttribute('xlink:href') || '';
      if (href === '#icon-pinglun') return true;
    }
    return false;
  }

  function commentEntryOf(target) {
    var node = target;
    if (node && node.nodeType === 3) node = node.parentElement;
    while (node && node !== document) {
      if (node.classList &&
          node.classList.contains('common-content') &&
          isCommentEntry(node)) {
        return node;
      }
      node = node.parentElement;
    }
    return null;
  }

  function stripInlineHandlers(root) {
    var nodes = [root];
    var descendants = root.querySelectorAll('*');
    for (var i = 0; i < descendants.length; i++) {
      nodes.push(descendants[i]);
    }
    for (var j = 0; j < nodes.length; j++) {
      var attributes = nodes[j].attributes;
      for (var k = attributes.length - 1; k >= 0; k--) {
        if (/^on/i.test(attributes[k].name)) {
          nodes[j].removeAttribute(attributes[k].name);
        }
      }
    }
  }

  function stopEvent(event) {
    event.preventDefault();
    event.stopPropagation();
    if (event.stopImmediatePropagation) event.stopImmediatePropagation();
  }

  function openComments(event) {
    if (!commentEntryOf(event.target)) return;
    stopEvent(event);
    try {
      if (window.flutter_inappwebview &&
          window.flutter_inappwebview.callHandler) {
        window.flutter_inappwebview.callHandler('open_article_comments');
      }
    } catch (e) {}
  }

  function stopCommentPointerEvent(event) {
    if (!commentEntryOf(event.target)) return;
    event.stopPropagation();
    if (event.stopImmediatePropagation) event.stopImmediatePropagation();
  }

  if (!window.__zyCommentCaptureInstalled) {
    window.__zyCommentCaptureInstalled = true;
    document.addEventListener('click', openComments, true);
    document.addEventListener('keydown', function (event) {
      if (event.key === 'Enter' || event.key === ' ') openComments(event);
    }, true);
    document.addEventListener('pointerdown', stopCommentPointerEvent, true);
    document.addEventListener('pointerup', stopCommentPointerEvent, true);
    document.addEventListener('touchstart', stopCommentPointerEvent, true);
    document.addEventListener('touchend', stopCommentPointerEvent, true);
  }

  function takeOver() {
    var entries = document.querySelectorAll('.common-content');
    for (var i = 0; i < entries.length; i++) {
      var entry = entries[i];
      if (!isCommentEntry(entry) ||
          entry.getAttribute('data-zy-comment-entry') === '1' ||
          !entry.parentNode) {
        continue;
      }

      var replacement = entry.cloneNode(true);
      replacement.setAttribute('data-zy-comment-entry', '1');
      replacement.setAttribute('role', 'button');
      replacement.setAttribute('tabindex', '0');
      replacement.style.cursor = 'pointer';
      stripInlineHandlers(replacement);
      entry.parentNode.replaceChild(replacement, entry);
    }
  }

  function startTakeover() {
    if (!document.documentElement) {
      document.addEventListener('DOMContentLoaded', startTakeover, {
        once: true
      });
      return;
    }
    takeOver();
    if (window.__zyCommentTakeover) return;

    var timer = null;
    window.__zyCommentTakeover = new MutationObserver(function () {
      if (timer) return;
      timer = setTimeout(function () {
        timer = null;
        takeOver();
      }, 60);
    });
    window.__zyCommentTakeover.observe(document.documentElement, {
      childList: true,
      subtree: true
    });
  }

  startTakeover();
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
