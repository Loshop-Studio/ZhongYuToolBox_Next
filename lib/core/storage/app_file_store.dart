import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// 应用数据目录里的 JSON 文件读写。
///
/// Windows: %APPDATA%\<公司>\<应用>
/// Android: /data/data/<包名>/files（getApplicationSupportDirectory）
/// iOS:     Library/Application Support
///
/// 写入采用「临时文件 + 备份 + 原子替换」，避免进程中断时把账号文件写坏。
class AppFileStore {
  AppFileStore._();

  static final AppFileStore instance = AppFileStore._();

  Directory? _directory;

  Future<Directory> directory() async {
    final cached = _directory;
    if (cached != null) return cached;
    late final Directory dir;
    try {
      dir = await getApplicationSupportDirectory();
    } catch (_) {
      dir = await getApplicationDocumentsDirectory();
    }
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _directory = dir;
    return dir;
  }

  Future<String> dataDirectoryPath() async => (await directory()).path;

  Future<File> file(String name) async {
    final dir = await directory();
    return File('${dir.path}/$name');
  }

  Future<String?> readText(String name) async {
    try {
      final target = await file(name);
      if (!await target.exists()) return null;
      return await target.readAsString(encoding: utf8);
    } catch (_) {
      return null;
    }
  }

  Future<void> writeText(String name, String content) async {
    final target = await file(name);
    final temp = File('${target.path}.tmp');
    await temp.writeAsString(content, encoding: utf8, flush: true);

    if (await target.exists()) {
      final backup = File('${target.path}.bak');
      try {
        if (await backup.exists()) await backup.delete();
        await target.copy(backup.path);
      } catch (_) {
        // 备份失败不阻塞主写入
      }
      await target.delete();
    }
    await temp.rename(target.path);
  }

  Future<void> delete(String name) async {
    try {
      final target = await file(name);
      if (await target.exists()) await target.delete();
    } catch (_) {
      // 忽略删除失败
    }
  }

  Future<Map<String, dynamic>> readJson(String name) async {
    final raw = await readText(name);
    if (raw == null || raw.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<void> writeJson(String name, Map<String, dynamic> data) async {
    await writeText(name, jsonEncode(data));
  }
}
