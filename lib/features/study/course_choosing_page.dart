import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../core/config/app_config.dart';
import '../../core/storage/session_manager.dart';
import '../../core/web/app_webview_environment.dart';
import '../../core/web/js_bridge.dart';
import '../../shared/widgets/common.dart';
import 'attachment_opener.dart';

/// 选课：官方内嵌页
/// `{webServer}/index.html?apiHost=...&apiToken=...#/index/courseChoosing/StudentsCoursesList`
///
/// 旧项目就是内嵌 iframe，这里用 WebView 加载同一个地址，不跳系统浏览器。
class CourseChoosingPage extends StatefulWidget {
  const CourseChoosingPage({super.key});

  @override
  State<CourseChoosingPage> createState() => _CourseChoosingPageState();
}

class _CourseChoosingPageState extends State<CourseChoosingPage> {
  final SessionManager _session = SessionManager.instance;

  InAppWebViewController? _controller;
  bool _loading = true;
  bool _canGoBack = false;
  String? _error;
  int _reloadKey = 0;

  String get _entryUrl {
    final session = _session.session;
    final webServer = session.webServer.isNotEmpty
        ? session.webServer
        : 'http://sxz.school.zykj.org';
    final apiHost = session.apiBaseUrl.isNotEmpty
        ? session.apiBaseUrl
        : AppConfig.defaultApiBaseUrl;
    final base = webServer.replaceAll(RegExp(r'/+$'), '');
    final entry = Uri.parse(
      '$base/index.html',
    ).replace(queryParameters: {'apiHost': apiHost, 'apiToken': session.token});
    return '$entry#/index/courseChoosing/StudentsCoursesList';
  }

  @override
  Widget build(BuildContext context) {
    final webViewError = AppWebViewEnvironment.initializationError;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: const Text('选课'),
        actions: [
          IconButton(
            tooltip: '页面后退',
            onPressed: _canGoBack ? () => _controller?.goBack() : null,
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
          IconButton(
            tooltip: '刷新',
            onPressed: () => _controller?.reload(),
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: webViewError != null
          ? ErrorView(message: webViewError)
          : Stack(
              children: [
                Positioned.fill(child: _buildWebView()),
                if (_loading)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Colors.white,
                      child: LoadingView(text: '正在加载选课页面…'),
                    ),
                  ),
                if (_error != null)
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.white,
                      child: ErrorView(
                        message: _error!,
                        onRetry: () => setState(() {
                          _error = null;
                          _loading = true;
                          _reloadKey++;
                        }),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildWebView() {
    return InAppWebView(
      key: ValueKey<int>(_reloadKey),
      webViewEnvironment: AppWebViewEnvironment.instance,
      initialUrlRequest: URLRequest(url: WebUri(_entryUrl)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        domStorageEnabled: true,
        databaseEnabled: true,
        supportZoom: false,
        mediaPlaybackRequiresUserGesture: false,
        transparentBackground: false,
      ),
      initialUserScripts: UnmodifiableListView<UserScript>([
        UserScript(
          source: jsToJavaBridgeScript,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
        ),
      ]),
      onWebViewCreated: (controller) {
        _controller = controller;
        registerAttachmentHandlers(controller, context, 'CourseChoosing');
      },
      onLoadStop: (controller, url) async {
        final canGoBack = await controller.canGoBack();
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = null;
          _canGoBack = canGoBack;
        });
      },
      onReceivedError: (controller, request, error) {
        if (request.isForMainFrame != true) return;
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = '页面加载失败：${error.description}';
        });
      },
      onReceivedHttpError: (controller, request, response) {
        if (request.isForMainFrame != true) return;
        final status = response.statusCode ?? 0;
        if (status < 400) return;
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = '页面加载失败（HTTP $status）';
        });
      },
    );
  }
}
