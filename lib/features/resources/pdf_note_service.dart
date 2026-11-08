import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:pdfx/pdfx.dart';
import 'package:pointycastle/export.dart' as pc;

import '../../core/crypto/zy_aes.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/session_manager.dart';
import '../../data/api/oss_api.dart';

/// PDF 导入云笔记（复刻旧项目 src/api/pdfNote.ts）
///
/// 流程：PDFium 逐页渲染成 2880×1800 画布 → 按页生成 8 个模板资源 + 1 张图
/// → 直传 OSS → Resources/AddOrUpdate → Notes/AddOrUpdate。
class PdfNoteService {
  PdfNoteService._();

  static const String _assetBase = 'assets/note_template/';
  static const String _uuid = 'a888b5fb-e65d-4611-a3af-1f80a0fb6ced';
  static const List<String> _templateFiles = [
    'page_router.bin',
    '$_uuid/059848e4-1971-47fb-9e47-517266cdef05_matrix.bin',
    '$_uuid/a2b4fb47-3623-45be-9fe9-57fc62e66651_file.bin',
    '$_uuid/e339e39b-64d9-4de0-bfaa-dace2a3f8e7d_command.bin',
    '$_uuid/header.bin',
    '$_uuid/router.bin',
    '$_uuid/screenshot.png',
    '$_uuid/snapshot.bin',
  ];
  static const String _descriptor =
      '$_uuid/a2b4fb47-3623-45be-9fe9-57fc62e66651_file.bin';
  static const String _router = '$_uuid/router.bin';
  static const String _imgFilename =
      'B466246B6F67160E63431159941CD9A9screenCaptureb59d24b6-00fa-4f53-bc4f-1df255a5101a.webp';
  static const int _canvasWidth = 2880;
  static const int _canvasHeight = 1800;

  static String _hex(List<int> bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  static String _sha256Hex(Uint8List bytes) =>
      _hex(pc.Digest('SHA-256').process(bytes));

  static String _md5Upper(Uint8List bytes) =>
      _hex(pc.Digest('MD5').process(bytes)).toUpperCase();

  static Future<Uint8List> _asset(String rel) async {
    final data = await rootBundle.load('$_assetBase$rel');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  static Future<Map<String, Uint8List>> _loadTemplates() async {
    final result = <String, Uint8List>{};
    for (final rel in _templateFiles) {
      result[rel] = await _asset(rel);
    }
    return result;
  }

  /// 模板 bin 是 ASCII 文本，把其中唯一的 64 位摘要换成新值
  static Uint8List _replaceDigest(
    Uint8List bytes,
    String digest, {
    String? expected,
  }) {
    final text = latin1.decode(bytes);
    final pattern = RegExp(
      expected != null ? RegExp.escape(expected) : r'[0-9a-f]{64}',
    );
    final matches = pattern.allMatches(text).toList();
    if (matches.length != 1) {
      throw ApiException('笔记模板中的资源摘要结构无效');
    }
    final updated = text.replaceRange(
      matches.first.start,
      matches.first.end,
      digest,
    );
    return Uint8List.fromList(latin1.encode(updated));
  }

  static Map<String, Uint8List> _preparePageTemplates(
    Map<String, Uint8List> templates,
    Uint8List image,
  ) {
    final original = templates[_descriptor]!;
    final originalHash = _sha256Hex(original);
    final descriptor = _replaceDigest(original, _sha256Hex(image));
    final router = _replaceDigest(
      templates[_router]!,
      _sha256Hex(descriptor),
      expected: originalHash,
    );
    return <String, Uint8List>{
      ...templates,
      _descriptor: descriptor,
      _router: router,
    };
  }

  /// 按 NOTE_CANVAS 等比缩放并白边居中，复刻 fitPageToCanvas
  static Future<Uint8List> _renderPage(PdfPage page) async {
    final scale = min(_canvasWidth / page.width, _canvasHeight / page.height);
    final width = (page.width * scale).round().clamp(1, _canvasWidth);
    final height = (page.height * scale).round().clamp(1, _canvasHeight);
    final shot = await page.render(
      width: width.toDouble(),
      height: height.toDouble(),
      format: PdfPageImageFormat.jpeg,
      quality: 90,
      backgroundColor: '#FFFFFF',
    );
    if (shot == null) throw ApiException('PDF 页面渲染失败');

    final decoded = img.decodeImage(shot.bytes);
    if (decoded == null) throw ApiException('PDF 页面图片解码失败');
    final canvas = img.Image(width: _canvasWidth, height: _canvasHeight);
    img.fill(canvas, color: img.ColorRgb8(255, 255, 255));
    img.compositeImage(
      canvas,
      decoded,
      dstX: (_canvasWidth - width) ~/ 2,
      dstY: (_canvasHeight - height) ~/ 2,
    );
    return Uint8List.fromList(img.encodeJpg(canvas, quality: 90));
  }

  static String _timestamp() {
    final n = DateTime.now();
    String p(int v) => v.toString().padLeft(2, '0');
    return '${n.year}-${p(n.month)}-${p(n.day)} '
        '${p(n.hour)}:${p(n.minute)}:${p(n.second)}';
  }

  static void _ensureOk(dynamic data, String message) {
    if (data is Map) {
      final code = data['code'];
      final ok =
          code == null ||
          (code is num ? code.toInt() == 0 : code.toString() == '0');
      if (!ok) throw ApiException('$message：${data['msg'] ?? code}');
    }
  }

  /// 生成自定义 fileId（须 33 位小写字母数字，且含 g-z）
  static String _generateFileId() {
    const chars = '0123456789abcdefghijklmnopqrstuvwxyz';
    final random = Random.secure();
    for (var attempt = 0; attempt < 50; attempt++) {
      final buffer = StringBuffer('h');
      for (var i = 0; i < 32; i++) {
        buffer.write(chars[random.nextInt(chars.length)]);
      }
      final value = buffer.toString();
      if (RegExp(r'[g-z]').hasMatch(value)) return value;
    }
    return 'h${DateTime.now().microsecondsSinceEpoch}'
        .substring(0, 33)
        .padRight(33, '0');
  }

  static Future<void> importPdf({
    required Uint8List pdfBytes,
    required String noteName,
    required String parentId,
    required void Function(int percent, String text) onProgress,
  }) async {
    final session = SessionManager.instance.session;
    final userId = session.userId;
    if (userId.isEmpty) throw ApiException('无法获取当前用户 ID');
    if (noteName.trim().isEmpty) throw ApiException('请输入笔记名称');

    onProgress(1, '正在加载笔记模板…');
    final templates = await _loadTemplates();

    onProgress(5, '正在解析 PDF…');
    final document = await PdfDocument.openData(pdfBytes);
    final pageCount = document.pagesCount;
    if (pageCount <= 0) {
      await document.close();
      throw ApiException('PDF 中没有页面');
    }

    final fileId = _generateFileId();
    final timestamp = _timestamp();
    final resourceList = <Map<String, dynamic>>[];
    var noteRoot = '';
    var nextPageHash = DateTime.now().millisecondsSinceEpoch;

    try {
      for (var index = 0; index < pageCount; index++) {
        final page = await document.getPage(index + 1);
        late final Uint8List imageBytes;
        try {
          imageBytes = await _renderPage(page);
        } finally {
          await page.close();
        }

        final pageHash = (nextPageHash++).toString();
        final pageBase =
            '/storage/emulated/0/Android/data/com.friday.cloudsnote/userNote/'
            '$userId/note/$fileId/$pageHash';
        final pageTemplates = _preparePageTemplates(templates, imageBytes);

        final resources = <({String rel, Uint8List bytes, int type})>[
          for (final rel in _templateFiles)
            (
              rel: rel,
              bytes: pageTemplates[rel]!,
              type: rel.endsWith('.png') ? 2 : 1,
            ),
          (rel: 'res/image/$_imgFilename', bytes: imageBytes, type: 0),
        ];

        for (var i = 0; i < resources.length; i++) {
          final resource = resources[i];
          final remoteName = resource.type == 0 ? _imgFilename : resource.rel;
          final url = await OssApi.uploadBytes(
            bytes: resource.bytes,
            fileName: '$pageHash/$remoteName',
            userId: userId,
            fc: 'note_v2',
            mime: resource.type == 0
                ? 'image/webp'
                : (resource.rel.endsWith('.png')
                      ? 'image/png'
                      : 'application/octet-stream'),
            nonceInput: fileId,
          );
          if (noteRoot.isEmpty) {
            final suffix = '$pageHash/$remoteName';
            if (!url.endsWith(suffix)) {
              throw ApiException('上传返回的资源路径无法解析');
            }
            noteRoot = url.substring(0, url.length - suffix.length);
          }
          resourceList.add(<String, dynamic>{
            'id': '$pageBase/${resource.rel}',
            'fileId': fileId,
            'pageName': pageBase,
            'pageIndex': index,
            'md5': _md5Upper(resource.bytes),
            'resourceType': resource.type,
            'ossImageUrl': url,
            'createTimeStamp': timestamp,
            'updateTimeStamp': timestamp,
            'toBeUploaded': false,
            'wasDeleted': false,
          });
          final percent =
              5 +
              (((index + (i + 1) / resources.length) / pageCount) * 85).round();
          onProgress(
            percent.clamp(0, 92),
            '上传第 ${index + 1}/$pageCount 页 · 资源 ${i + 1}/${resources.length}',
          );
        }
      }
    } finally {
      await document.close();
    }

    if (noteRoot.isEmpty) throw ApiException('没有可上传的页面');

    onProgress(93, '正在保存资源…');
    final resourcesResult = await ApiClient.instance.request(
      '/CloudNotes/api/Resources/AddOrUpdate',
      method: 'POST',
      data: ZyAes.encrypt(jsonEncode(resourceList)),
    );
    _ensureOk(resourcesResult, '保存资源失败');

    onProgress(97, '正在保存笔记…');
    final noteResult = await ApiClient.instance.request(
      '/CloudNotes/api/Notes/AddOrUpdate',
      method: 'POST',
      data: ZyAes.encrypt(
        jsonEncode(<String, dynamic>{
          'fileId': fileId,
          'fileName': noteName.trim(),
          'parentId': parentId.isEmpty ? '0' : parentId,
          'type': '12',
          'fileUrl': noteRoot,
        }),
      ),
    );
    _ensureOk(noteResult, '保存笔记失败');

    onProgress(100, '导入完成，共 $pageCount 页');
  }
}
