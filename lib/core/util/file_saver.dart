import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

/// 保存文件（复刻 saveBlobFile 的桌面/移动两路）
class FileSaver {
  FileSaver._();

  /// 返回保存后的路径（失败返回 null）
  static Future<String?> save(String fileName, Uint8List bytes) async {
    final safeName = _sanitize(fileName);
    String? picked;
    try {
      picked = await FilePicker.platform.saveFile(
        dialogTitle: '保存文件',
        fileName: safeName,
        bytes: bytes,
        type: FileType.custom,
        allowedExtensions: _extensionsOf(safeName),
      );
    } catch (_) {
      picked = null;
    }

    if (picked != null && picked.isNotEmpty) {
      // 关键：桌面端 file_picker 只返回用户选的路径，不会写文件，必须自己落盘；
      // Android/iOS 返回的是 content:// URI，插件已写入，不能再按路径写。
      if (!Platform.isAndroid && !Platform.isIOS) {
        try {
          await File(picked).writeAsBytes(bytes, flush: true);
          return picked;
        } catch (_) {
          return _saveToDocuments(safeName, bytes);
        }
      }
      return picked;
    }

    return _saveToDocuments(safeName, bytes);
  }

  /// Windows 不允许文件名包含这些字符，避免保存失败
  static String _sanitize(String fileName) {
    final trimmed = fileName.trim();
    if (trimmed.isEmpty) return 'file';
    final cleaned = trimmed.replaceAll(RegExp(r'[\\/:*?"<>|\r\n]'), '_');
    return cleaned.isEmpty ? 'file' : cleaned;
  }

  static List<String> _extensionsOf(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return const <String>[];
    return <String>[fileName.substring(dot + 1).toLowerCase()];
  }

  static Future<String?> _saveToDocuments(String fileName, Uint8List bytes) async {
    try {
      Directory dir;
      try {
        dir = await getApplicationDocumentsDirectory();
      } catch (_) {
        dir = await getTemporaryDirectory();
      }
      final target = File('${dir.path}${Platform.pathSeparator}$fileName');
      await target.writeAsBytes(bytes, flush: true);
      return target.path;
    } catch (_) {
      return null;
    }
  }
}
