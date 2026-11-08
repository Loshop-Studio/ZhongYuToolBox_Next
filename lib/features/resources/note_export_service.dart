import 'dart:isolate';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/network/api_exception.dart';
import '../../data/api/note_api.dart';
import 'note_renderer.dart';

/// 云笔记导出（复刻 NoteDetailView 的导出 PDF / 下载笔记）
///
/// 说明：旧版导出高清矢量 PDF 依赖 ezy-board-viewer + jsPDF；
/// Flutter 版按页截图生成位图 PDF，保证可用。
class NoteExportService {
  NoteExportService._();

  static final Dio _dio = Dio(
    BaseOptions(validateStatus: (_) => true, responseType: ResponseType.bytes),
  );

  static Future<Uint8List> _download(String url) async {
    final response = await _dio.get<dynamic>(url);
    final data = response.data;
    if (data is! List<int> || data.isEmpty) {
      throw ApiException('资源下载失败');
    }
    return Uint8List.fromList(data);
  }

  /// 下载全部资源并打包 zip
  static Future<Uint8List> buildZip(
    String fileId, {
    void Function(String message)? onProgress,
  }) async {
    final resources = await NoteApi.getResources(fileId);
    if (resources.isEmpty) throw ApiException('该笔记没有可下载的资源');
    final archive = Archive();
    var done = 0;
    for (final item in resources) {
      final url = absoluteResourceUrl(item.ossImageUrl);
      if (url.isEmpty) continue;
      onProgress?.call('正在下载 ${done + 1}/${resources.length}');
      try {
        final bytes = await _download(url);
        final path = item.ossImageUrl.isNotEmpty
            ? item.ossImageUrl.replaceAll('\\', '/')
            : 'page_${item.pageIndex + 1}';
        archive.addFile(ArchiveFile(path, bytes.length, bytes));
      } catch (_) {
        // 单个资源失败不影响整体打包
      }
      done++;
    }
    if (archive.isEmpty) throw ApiException('没有可下载的资源');
    return Uint8List.fromList(ZipEncoder().encode(archive)!);
  }

  /// 按页截图生成 PDF
  static Future<Uint8List> buildPdf(
    String fileId, {
    void Function(String message)? onProgress,
  }) async {
    final resources = await NoteApi.getResources(fileId);
    final pages = groupNotePages(
      resources,
    ).where((page) => (page.screenshotUrl ?? '').isNotEmpty).toList();
    if (pages.isEmpty) throw ApiException('该笔记没有可导出的页面截图');

    // 下载（IO）留在主 isolate，避免 UI 卡顿
    final images = <Uint8List>[];
    for (var index = 0; index < pages.length; index++) {
      onProgress?.call('正在下载页面 ${index + 1}/${pages.length}');
      images.add(await _download(pages[index].screenshotUrl!));
    }

    // 解码图片 + 压缩 PDF 是 CPU 密集操作，放到后台 isolate
    onProgress?.call('正在生成 PDF…');
    return Isolate.run(() => _buildPdfFromImages(images));
  }

  static Future<Uint8List> _buildPdfFromImages(List<Uint8List> images) async {
    final document = pw.Document();
    for (final bytes in images) {
      final image = pw.MemoryImage(bytes);
      document.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(12),
          build: (context) =>
              pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
        ),
      );
    }
    return document.save();
  }
}
