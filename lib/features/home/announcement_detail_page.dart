import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../core/config/app_config.dart';
import '../../core/storage/session_manager.dart';
import '../../core/web/app_webview_environment.dart';
import '../../core/web/js_bridge.dart';
import '../../data/api/column_api.dart';
import '../../shared/widgets/common.dart';
import '../study/attachment_opener.dart';

/// 公告详情：复刻 NotificationDetailFragment。
///
/// 加载官方 `{webServer}/fastWork.html#noticeMessage`，
/// 注入与专栏相同的 JS 桥（open_file 等附件入口），
/// 页面加载完成后用 API 取到的公告 HTML 内容（UTF-8 字节 base64）注入
/// `window.notificationContent(...)`，由官方页面渲染。
class AnnouncementDetailPage extends StatefulWidget {
  const AnnouncementDetailPage({
    super.key,
    required this.noticeId,
    required this.messageId,
    required this.title,
  });

  /// parameter.id（公告正文 id）
  final int noticeId;

  /// 消息 id，用于标记已读
  final String messageId;

  final String title;

  @override
  State<AnnouncementDetailPage> createState() => _AnnouncementDetailPageState();
}

class _AnnouncementDetailPageState extends State<AnnouncementDetailPage> {
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
    final entry = Uri.parse('$base/fastWork.html').replace(
      queryParameters: {'apiHost': apiHost, 'apiToken': session.token},
    );
    return '$entry#noticeMessage';
  }

  @override
  void initState() {
    super.initState();
    if (widget.messageId.isNotEmpty) {
      ColumnApi.setMessageRead(widget.messageId).catchError((_) {});
    }
  }

  /// 取公告正文并以 base64 注入到 webview 的 window.notificationContent。
  Future<void> _injectContent(InAppWebViewController controller) async {
    try {
      final notice = await ColumnApi.getNotice(widget.noticeId);
      final b64 = base64Encode(utf8.encode(notice.content));
      await controller.evaluateJavascript(
        source: "window.notificationContent('$b64')",
      );
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '加载公告内容失败：$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final webViewError = AppWebViewEnvironment.initializationError;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: Text(
          widget.title.isEmpty ? '公告详情' : widget.title,
          overflow: TextOverflow.ellipsis,
        ),
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
                      child: LoadingView(text: '正在加载公告…'),
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
        UserScript(
          source: columnVideoReplaceScript,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
        ),
      ]),
      onWebViewCreated: (controller) {
        registerAttachmentHandlers(controller, context, 'Announcement');
      },
      onConsoleMessage: (controller, message) {
        if (!message.message.contains('JsToJava')) return;
        debugPrint('[Announcement][js] ${message.message}');
      },
      onLoadStop: (controller, url) async {
        // 兜底再跑一次：异步渲染出来的 video 换成附件卡片
        await controller.evaluateJavascript(source: columnVideoReplaceScript);
        await _injectContent(controller);
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
