import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';

import '../storage/app_file_store.dart';
import 'plugin_models.dart';

class PluginManager extends ChangeNotifier {
  PluginManager._();

  static final PluginManager instance = PluginManager._();

  final List<InstalledPlugin> _plugins = <InstalledPlugin>[];
  final Set<String> _disabledIds = <String>{};
  bool _initialized = false;
  Directory? _pluginsDirectory;

  List<InstalledPlugin> get plugins => List.unmodifiable(_plugins);

  Future<Directory> _rootDirectory() async {
    final cached = _pluginsDirectory;
    if (cached != null) return cached;

    final appData = await AppFileStore.instance.directory();
    final legacy = Directory('${appData.path}${Platform.pathSeparator}plugins');

    if (Platform.isWindows) {
      final softwareDirectory = File(Platform.resolvedExecutable).parent;
      final preferred = Directory(
        '${softwareDirectory.path}${Platform.pathSeparator}plugins',
      );
      try {
        await _ensureWritable(preferred);
        await _copyLegacyPlugins(legacy, preferred);
        _pluginsDirectory = preferred;
        return preferred;
      } catch (error) {
        debugPrint('[PluginManager] 软件目录不可写，回退到应用数据目录：$error');
      }
    }

    if (!await legacy.exists()) await legacy.create(recursive: true);
    _pluginsDirectory = legacy;
    return legacy;
  }

  Future<void> _ensureWritable(Directory directory) async {
    if (!await directory.exists()) await directory.create(recursive: true);
    final probe = File(
      '${directory.path}${Platform.pathSeparator}.write-test-$pid',
    );
    await probe.writeAsString('ok', flush: true);
    await probe.delete();
  }

  Future<void> _copyLegacyPlugins(
    Directory legacy,
    Directory destination,
  ) async {
    if (!await legacy.exists() || legacy.path == destination.path) return;
    await for (final entity in legacy.list(followLinks: false)) {
      if (entity is! Directory) continue;
      final name = entity.path.substring(legacy.path.length + 1);
      if (name.startsWith('.')) continue;
      final target = Directory(
        '${destination.path}${Platform.pathSeparator}$name',
      );
      if (await target.exists()) continue;
      final staging = Directory(
        '${destination.path}${Platform.pathSeparator}.$name.migrating',
      );
      try {
        if (await staging.exists()) await staging.delete(recursive: true);
        await _copyDirectory(entity, staging);
        await staging.rename(target.path);
      } catch (error) {
        if (await staging.exists()) await staging.delete(recursive: true);
        debugPrint('[PluginManager] 迁移旧插件 $name 失败：$error');
      }
    }
  }

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await destination.create(recursive: true);
    await for (final entity in source.list(followLinks: false)) {
      final name = entity.path.substring(source.path.length + 1);
      final targetPath = '${destination.path}${Platform.pathSeparator}$name';
      if (entity is File) {
        await entity.copy(targetPath);
      } else if (entity is Directory) {
        await _copyDirectory(entity, Directory(targetPath));
      }
    }
  }

  Future<void> init() async {
    if (_initialized) return;
    final state = await AppFileStore.instance.readJson('plugins_state.json');
    final disabled = state['disabled'];
    if (disabled is List) {
      _disabledIds.addAll(disabled.map((e) => e.toString()));
    }
    await reload();
    _initialized = true;
  }

  Future<void> reload() async {
    final root = await _rootDirectory();
    final loaded = <InstalledPlugin>[];
    await for (final entity in root.list(followLinks: false)) {
      if (entity is! Directory) continue;
      final manifestFile = File(
        '${entity.path}${Platform.pathSeparator}manifest.json',
      );
      if (!await manifestFile.exists()) continue;
      try {
        final decoded = jsonDecode(await manifestFile.readAsString());
        if (decoded is! Map) continue;
        final manifest = PluginManifest.fromJson(
          Map<String, dynamic>.from(decoded),
        );
        final plugin = InstalledPlugin(
          manifest: manifest,
          directoryPath: entity.path,
          enabled: !_disabledIds.contains(manifest.id),
        );
        if (await File(plugin.bytecodePath).exists()) loaded.add(plugin);
      } catch (e) {
        debugPrint('[PluginManager] 忽略损坏插件 ${entity.path}: $e');
      }
    }
    loaded.sort((a, b) => a.manifest.name.compareTo(b.manifest.name));
    _plugins
      ..clear()
      ..addAll(loaded);
    notifyListeners();
  }

  List<RegisteredPluginAction> actionsFor(String posId) {
    final actions = <RegisteredPluginAction>[];
    for (final plugin in _plugins) {
      if (!plugin.enabled) continue;
      for (final action in plugin.manifest.actions) {
        if (action.posId == posId) {
          actions.add(RegisteredPluginAction(plugin: plugin, action: action));
        }
      }
    }
    actions.sort((a, b) {
      final byOrder = a.action.order.compareTo(b.action.order);
      if (byOrder != 0) return byOrder;
      return a.action.label.compareTo(b.action.label);
    });
    return actions;
  }

  InstalledPlugin? findPlugin(String pluginId) {
    for (final plugin in _plugins) {
      if (plugin.manifest.id == pluginId && plugin.enabled) return plugin;
    }
    return null;
  }

  PluginPageDefinition? findPage(InstalledPlugin plugin, String pageId) {
    for (final page in plugin.manifest.pages) {
      if (page.id == pageId) return page;
    }
    return null;
  }

  PluginManifest inspectPackage(Uint8List bytes) {
    final archive = ZipDecoder().decodeBytes(bytes, verify: true);
    final entry = archive.files.where((file) {
      return file.isFile && _normalized(file.name) == 'manifest.json';
    }).firstOrNull;
    if (entry == null) throw const FormatException('插件包缺少根目录 manifest.json');
    final decoded = jsonDecode(utf8.decode(_entryBytes(entry)));
    if (decoded is! Map) throw const FormatException('manifest.json 格式错误');
    final manifest = PluginManifest.fromJson(
      Map<String, dynamic>.from(decoded),
    );
    final bytecode = _normalized(manifest.bytecode);
    if (!archive.files.any(
      (file) => file.isFile && _normalized(file.name) == bytecode,
    )) {
      throw FormatException('插件包缺少字节码文件：${manifest.bytecode}');
    }
    return manifest;
  }

  Future<void> installPackage(Uint8List bytes) async {
    final manifest = inspectPackage(bytes);
    final archive = ZipDecoder().decodeBytes(bytes, verify: true);
    final root = await _rootDirectory();
    final target = Directory(
      '${root.path}${Platform.pathSeparator}${manifest.id}',
    );
    final staging = Directory(
      '${root.path}${Platform.pathSeparator}.${manifest.id}.installing',
    );
    if (await staging.exists()) await staging.delete(recursive: true);
    await staging.create(recursive: true);
    try {
      for (final entry in archive.files) {
        final relative = _normalized(entry.name);
        if (relative.isEmpty || !_safeArchivePath(relative)) continue;
        final outputPath = relative
            .split('/')
            .fold<String>(
              staging.path,
              (path, part) => '$path${Platform.pathSeparator}$part',
            );
        if (entry.isFile) {
          final file = File(outputPath);
          await file.parent.create(recursive: true);
          await file.writeAsBytes(_entryBytes(entry), flush: true);
        } else {
          await Directory(outputPath).create(recursive: true);
        }
      }
      if (await target.exists()) {
        await target.delete(recursive: true);
      }
      await staging.rename(target.path);
      _disabledIds.remove(manifest.id);
      await _saveState();
      await reload();
    } catch (_) {
      if (await staging.exists()) await staging.delete(recursive: true);
      rethrow;
    }
  }

  Future<void> setEnabled(String pluginId, bool enabled) async {
    if (enabled) {
      _disabledIds.remove(pluginId);
    } else {
      _disabledIds.add(pluginId);
    }
    await _saveState();
    final index = _plugins.indexWhere((e) => e.manifest.id == pluginId);
    if (index >= 0) {
      _plugins[index] = _plugins[index].copyWith(enabled: enabled);
    }
    notifyListeners();
  }

  Future<void> remove(String pluginId) async {
    final plugin = _plugins.where((e) => e.manifest.id == pluginId).firstOrNull;
    if (plugin == null) return;
    final target = Directory(plugin.directoryPath);
    if (await target.exists()) await target.delete(recursive: true);
    _disabledIds.remove(pluginId);
    await _saveState();
    await reload();
  }

  Future<void> _saveState() {
    return AppFileStore.instance.writeJson('plugins_state.json', {
      'disabled': _disabledIds.toList()..sort(),
    });
  }

  static String _normalized(String path) =>
      path.replaceAll('\\', '/').replaceAll(RegExp(r'^\./+'), '');

  static bool _safeArchivePath(String path) {
    if (path.startsWith('/') || RegExp(r'^[a-zA-Z]:').hasMatch(path)) {
      return false;
    }
    return !path.split('/').any((part) => part.isEmpty || part == '..');
  }

  static Uint8List _entryBytes(ArchiveFile entry) {
    final content = entry.content;
    if (content is Uint8List) return content;
    if (content is List<int>) return Uint8List.fromList(content);
    throw FormatException('无法读取插件包文件：${entry.name}');
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
