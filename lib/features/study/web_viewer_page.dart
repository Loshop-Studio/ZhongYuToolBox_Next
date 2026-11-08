import 'dart:collection';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../core/network/api_exception.dart';
import '../../core/util/urls.dart';
import '../../core/web/js_bridge.dart';
import '../../shared/widgets/common.dart';
import 'attachment_opener.dart';

enum _LoadMode { probing, url, data }

/// 直接打开一个 .html 页面（附件里的网页文件、open_file 传入的 html）
///
/// OSS 上的 html 经常带 `Content-Disposition: attachment` 或被标成
/// `application/octet-stream`，WebView 拿到这种响应只会触发下载、页面一片空白。
/// 所以先探测一次响应头：能直接渲染就交给 WebView，不能就把文本拉下来自己灌进去。
class WebViewerPage extends StatefulWidget {
  const WebViewerPage({super.key, required this.url, this.name = ''});

  final String url;
  final String name;

  @override
  State<WebViewerPage> createState() => _WebViewerPageState();
}

class _WebViewerPageState extends State<WebViewerPage> {
  _LoadMode _mode = _LoadMode.probing;
  String? _html;
  String? _error;
  bool _saving = false;
  int _reloadKey = 0;

  String get _displayUrl => imageDisplayUrl(absoluteOssUrl(widget.url));

  @override
  void initState() {
    super.initState();
    _probe();
  }

  Future<void> _probe() async {
    try {
      final response = await Dio().get<List<int>>(
        _displayUrl,
        options: Options(
          responseType: ResponseType.bytes,
          validateStatus: (_) => true,
        ),
      );
      if (!mounted) return;
      final status = response.statusCode ?? 0;
      if (status >= 400) {
        setState(() => _error = '页面加载失败（HTTP $status）');
        return;
      }
      final contentType = (response.headers.value('content-type') ?? '')
          .toLowerCase();
      final disposition = (response.headers.value('content-disposition') ?? '')
          .toLowerCase();
      final bytes = response.data ?? const <int>[];
      final direct =
          (contentType.contains('text/html') ||
              contentType.contains('application/xhtml')) &&
          !disposition.contains('attachment');
      setState(() {
        if (direct) {
          _mode = _LoadMode.url;
        } else {
          _html = utf8.decode(bytes, allowMalformed: true);
          _mode = _LoadMode.data;
        }
      });
    } catch (_) {
      // 探测失败就退回普通加载，交给 WebView 自己判断
      if (!mounted) return;
      setState(() => _mode = _LoadMode.url);
    }
  }

  void _retry() {
    setState(() {
      _error = null;
      _html = null;
      _mode = _LoadMode.probing;
      _reloadKey++;
    });
    _probe();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final path = await downloadAttachment(widget.url, widget.name);
      if (!mounted) return;
      showToast(context, path == null ? '已取消保存' : '已保存：$path');
    } catch (e) {
      if (!mounted) return;
      showToast(context, errorText(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: Text(
          widget.name.isEmpty ? '网页' : widget.name,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: '下载',
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _error != null
          ? ErrorView(message: _error!, onRetry: _retry)
          : (_mode == _LoadMode.probing
                ? const LoadingView(text: '正在加载页面…')
                : _buildWebView()),
    );
  }

  Widget _buildWebView() {
    final data = _mode == _LoadMode.data ? _html : null;
    final isData = data != null;

    return InAppWebView(
      key: ValueKey<int>(_reloadKey),
      initialUrlRequest: isData ? null : URLRequest(url: WebUri(_displayUrl)),
      initialData: isData
          ? InAppWebViewInitialData(
              data: data,
              baseUrl: WebUri(_displayUrl),
              mimeType: 'text/html',
              encoding: 'utf-8',
            )
          : null,
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        domStorageEnabled: true,
        databaseEnabled: true,
        supportZoom: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      initialUserScripts: UnmodifiableListView<UserScript>([
        UserScript(
          source: jsToJavaBridgeScript,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
        ),
      ]),
      onWebViewCreated: (controller) {
        registerAttachmentHandlers(controller, context, 'WebViewerPage');
      },
      onConsoleMessage: (controller, message) {
        if (!message.message.contains('JsToJava')) return;
        debugPrint('[WebViewerPage][js] ${message.message}');
      },
      onLoadStop: (controller, url) {
        if (!mounted) return;
        setState(() => _error = null);
      },
      onReceivedError: (controller, request, error) {
        if (request.isForMainFrame != true) return;
        if (!mounted) return;
        setState(() => _error = '页面加载失败：${error.description}');
      },
      onReceivedHttpError: (controller, request, response) {
        if (request.isForMainFrame != true) return;
        final status = response.statusCode ?? 0;
        if (status < 400) return;
        if (!mounted) return;
        setState(() => _error = '页面加载失败（HTTP $status）');
      },
    );
  }
}
