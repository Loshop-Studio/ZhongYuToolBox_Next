import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/html/column_content.dart';
import '../../core/network/api_exception.dart';
import '../../core/util/file_saver.dart';
import '../../core/util/urls.dart';
import '../../shared/widgets/common.dart';

/// 附件统一分发：
/// - `.pdf`   → 原生 PDF 预览
/// - `.html`  → 内置浏览器直接打开
/// - 视频     → 内嵌播放器
/// - 其它     → 交给系统应用
///
/// 入参既可能是网页 `window.JsToJava.open_file(url)` 的裸地址，
/// 也可能是文章里的 `zyattachment://open?...` 包装链接。
void openAttachment(BuildContext context, String rawUrl, {String? forceKind}) {
  final raw = rawUrl.trim();
  if (raw.isEmpty) {
    debugPrint('[openAttachment] 参数为空，忽略');
    return;
  }

  final link = ColumnContentProcessor.parseUri(raw);
  final url = (link != null && link.url.isNotEmpty) ? link.url : raw;
  final declaredKind = (forceKind != null && forceKind.isNotEmpty)
      ? forceKind
      : (link?.kind ?? '');
  final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
  final name = link != null && link.name.isNotEmpty
      ? link.name
      : _fileNameOf(url);
  debugPrint(
    '[openAttachment] raw=$raw\n'
    '  url=$url\n'
    '  kind=${declaredKind.isEmpty ? "(按后缀判断)" : declaredKind} '
    'path=$path name=$name',
  );

  if (declaredKind == 'pdf' || path.endsWith('.pdf')) {
    debugPrint('[openAttachment] -> PDF 原生预览页');
    context.push(
      '/file/pdf?url=${Uri.encodeQueryComponent(url)}'
      '&name=${Uri.encodeQueryComponent(name)}',
    );
    return;
  }
  if (declaredKind == 'html' ||
      path.endsWith('.html') ||
      path.endsWith('.htm')) {
    debugPrint('[openAttachment] -> HTML 内置浏览器');
    context.push(
      '/file/web?url=${Uri.encodeQueryComponent(url)}'
      '&name=${Uri.encodeQueryComponent(name)}',
    );
    return;
  }
  if (declaredKind == 'image' ||
      path.endsWith('.png') ||
      path.endsWith('.jpg') ||
      path.endsWith('.jpeg') ||
      path.endsWith('.gif') ||
      path.endsWith('.webp') ||
      path.endsWith('.bmp')) {
    debugPrint('[openAttachment] -> 原生图片预览');
    context.push(
      '/lesson/viewer?kind=image'
      '&url=${Uri.encodeQueryComponent(url)}'
      '&name=${Uri.encodeQueryComponent(name)}',
    );
    return;
  }
  if (declaredKind == 'video' ||
      path.endsWith('.mp4') ||
      path.endsWith('.m3u8') ||
      path.endsWith('.mov')) {
    debugPrint('[openAttachment] -> 原生视频播放器');
    context.push(
      '/lesson/video?url=${Uri.encodeQueryComponent(url)}'
      '&name=${Uri.encodeQueryComponent(name)}',
    );
    return;
  }
  debugPrint('[openAttachment] -> 系统外部应用');
  _launchExternal(context, url);
}

/// 给 WebView 注册 JS 桥的接收端。
///
/// 官方页面按类型分发调用（`open_html` / `open_pdf` / `open_video` / `open_file`），
/// 必须逐个注册同名 handler，否则 JS 侧调用到未注册的名字会抛异常，
/// 页面上的 fallback 分支也不会执行。
void registerAttachmentHandlers(
  InAppWebViewController controller,
  BuildContext context,
  String tag,
) {
  const handlers = <String, String?>{
    'open_file': null,
    'open_html': 'html',
    'open_pdf': 'pdf',
    'open_video': 'video',
  };
  for (final entry in handlers.entries) {
    controller.addJavaScriptHandler(
      handlerName: entry.key,
      callback: (args) {
        debugPrint('[$tag] JsToJava.${entry.key} args=$args');
        if (args.isEmpty) return null;
        openAttachment(context, args.first.toString(), forceKind: entry.value);
        return null;
      },
    );
  }
}

/// 优客畅学（平板端 Web）的旧式桥 handler。
///
/// 页面通过 `window.flutter_inappwebview._callHandler(name, func, JSON.stringify(args))`
/// 调用这些名字，其中视频/附件复用统一分发，练习类暂无对应页面，交给 [onUnsupported] 提示。
void registerLessonHandlers(
  InAppWebViewController controller,
  BuildContext context, {
  required void Function(String label) onUnsupported,
}) {
  void reg(String name, void Function(List<dynamic> args) onArgs) {
    controller.addJavaScriptHandler(
      handlerName: name,
      callback: (args) {
        debugPrint('[LessonWeb] $name args=$args');
        onArgs(args);
        return null;
      },
    );
  }

  reg('video_play', (args) {
    final url = args.isNotEmpty ? args.first.toString() : '';
    if (url.isEmpty) return;
    openAttachment(context, url, forceKind: 'video');
  });

  reg('micro_play', (args) {
    final url = args.isNotEmpty ? args.first.toString() : '';
    if (url.isEmpty) return;
    openAttachment(context, url, forceKind: 'video');
  });

  reg('exercise_view', (_) => onUnsupported('练习查看'));
  reg('exercise', (_) => onUnsupported('练习'));
  reg('exercise_statistic', (_) => onUnsupported('练习统计'));
}

String _fileNameOf(String url) {
  final segments = Uri.tryParse(url)?.pathSegments ?? const <String>[];
  return segments.isEmpty ? '附件' : segments.last;
}

Future<void> _launchExternal(BuildContext context, String url) async {
  try {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) showToast(context, '无法打开该附件');
    }
  } catch (_) {
    if (context.mounted) showToast(context, '打开附件失败');
  }
}

/// 下载附件到本地（PDF 预览页与附件查看器共用），返回保存路径
Future<String?> downloadAttachment(String rawUrl, String name) async {
  final displayUrl = imageDisplayUrl(absoluteOssUrl(rawUrl));
  final response = await Dio().get<dynamic>(
    displayUrl,
    options: Options(
      responseType: ResponseType.bytes,
      validateStatus: (_) => true,
    ),
  );
  final data = response.data;
  if (data is! List<int> || data.isEmpty) {
    throw ApiException('附件为空或无法读取');
  }
  final fileName = name.isNotEmpty ? name : _fileNameOf(displayUrl);
  return FileSaver.save(fileName, Uint8List.fromList(data));
}
