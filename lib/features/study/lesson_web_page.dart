import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../core/config/app_config.dart';
import '../../core/storage/session_manager.dart';
import '../../core/web/js_bridge.dart';
import '../../shared/widgets/common.dart';
import 'attachment_opener.dart';

/// 优客畅学（平板端 Web）
///
/// 官方地址形如：
/// `http://ykcx-pad.school.zykj.org/?token=<jwt>&url=<apiHost>#/?entry=study&catalogId=..&courseId=..`
///
/// 章节内容直接用官方页面渲染，视频、互动题、附件都跟官方一致；
/// 不带 catalogId 时打开课程列表首页（`#/`）。
class LessonWebPage extends StatefulWidget {
  const LessonWebPage({
    super.key,
    this.courseId = 0,
    this.catalogId = '',
    this.title = '',
  });

  final int courseId;
  final String catalogId;
  final String title;

  @override
  State<LessonWebPage> createState() => _LessonWebPageState();
}

class _LessonWebPageState extends State<LessonWebPage> {
  InAppWebViewController? _controller;
  bool _loading = true;
  bool _canGoBack = false;
  String? _error;
  int _reloadKey = 0;

  String get _entryUrl {
    final session = SessionManager.instance.session;
    final apiHost = session.apiBaseUrl.isNotEmpty
        ? session.apiBaseUrl
        : AppConfig.defaultApiBaseUrl;
    // token / apiHost 按官方格式直接拼，不做额外编码（JWT 只含安全字符）
    final query = 'token=${session.token}&url=$apiHost';
    final hash = widget.courseId > 0 && widget.catalogId.isNotEmpty
        ? '#/?entry=study&catalogId=${widget.catalogId}&courseId=${widget.courseId}'
        : '#/';
    return '${AppConfig.lessonPadBase}?$query$hash';
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title.isNotEmpty
        ? widget.title
        : (widget.catalogId.isEmpty ? '优客畅学' : '章节内容');
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: Text(title, overflow: TextOverflow.ellipsis),
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
      body: Stack(
        children: [
          Positioned.fill(child: _buildWebView()),
          if (_loading)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.white,
                child: LoadingView(text: '正在加载课程内容…'),
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
        supportZoom: true,
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
      ),
      initialUserScripts: UnmodifiableListView<UserScript>([
        UserScript(
          source: legacyBridgeScript,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
        ),
        UserScript(
          source: jsToJavaBridgeScript,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
        ),
      ]),
      onWebViewCreated: (controller) {
        _controller = controller;
        registerAttachmentHandlers(controller, context, 'LessonWeb');
        registerLessonHandlers(
          controller,
          context,
          onUnsupported: (label) => showToast(context, '$label将在后续版本提供'),
        );
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
