import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/app_config.dart';
import '../../core/storage/session_manager.dart';
import '../../core/web/js_bridge.dart';
import '../../shared/widgets/common.dart';
import 'attachment_opener.dart';

/// 在线专栏文章：直接加载官方 Web 页面
/// `{webHost}/navPage.html?apiHost=...&apiToken=...`#/ArticlePage?id=xxx
class ArticlePage extends StatefulWidget {
  const ArticlePage({super.key, required this.pageId});

  final int pageId;

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  final SessionManager _session = SessionManager.instance;

  bool _loading = true;
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
      '$base/navPage.html',
    ).replace(queryParameters: {'apiHost': apiHost, 'apiToken': session.token});
    return '$entry#/ArticlePage?id=${widget.pageId}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: const Text('文章详情', overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: '浏览器打开',
            icon: const Icon(Icons.open_in_browser),
            onPressed: () async {
              final uri = Uri.tryParse(_entryUrl);
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else if (mounted) {
                showToast(context, '无法打开链接');
              }
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: _buildWebView()),
          if (_loading)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.white,
                child: LoadingView(text: '正在加载文章…'),
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
        // 专栏里的 <video> 换成官方附件卡片，点击走 open_file → 原生播放
        UserScript(
          source: columnVideoReplaceScript,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
        ),
        // 隐藏官方自带的返回箭头（AppBar 已有返回键）
        UserScript(
          source: columnHideBackArrowScript,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
        ),
      ]),
      onWebViewCreated: (controller) {
        registerAttachmentHandlers(controller, context, 'ArticlePage');
      },
      onConsoleMessage: (controller, message) {
        if (!message.message.contains('JsToJava')) return;
        debugPrint('[ArticlePage][js] ${message.message}');
      },
      onLoadStop: (controller, url) async {
        // 兜底再跑一次：异步渲染出来的 video 也要换成附件卡片
        await controller.evaluateJavascript(source: columnVideoReplaceScript);
        // 兜底隐藏官方返回箭头（SPA 可能晚于首次渲染才插入）
        await controller.evaluateJavascript(source: columnHideBackArrowScript);
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = null;
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
