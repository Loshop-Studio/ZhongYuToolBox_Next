import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';

import '../storage/app_file_store.dart';
import 'plugin_models.dart';
import 'plugin_source_models.dart';
import 'plugin_source_service.dart';

class PluginManager extends ChangeNotifier {
  PluginManager._();

  static final PluginManager instance = PluginManager._();

  final List<InstalledPlugin> _plugins = <InstalledPlugin>[];
  final Set<String> _disabledIds = <String>{};
  final List<PluginIndexSource> _sources = <PluginIndexSource>[];
  final List<PluginIndexEntry> _catalog = <PluginIndexEntry>[];
  final Map<String, String> _catalogErrors = <String, String>{};
  final Map<String, String> _catalogDetailErrors = <String, String>{};
  final Set<String> _catalogDetailLoading = <String>{};
  final Map<String, PluginIndexDetail?> _catalogDetails =
      <String, PluginIndexDetail?>{};
  final Set<String> _resolvedCatalogDetails = <String>{};
  final Map<String, Future<PluginIndexDetail?>> _catalogDetailRequests =
      <String, Future<PluginIndexDetail?>>{};
  final Map<String, String> _sourceByPlugin = <String, String>{};
  final Set<String> _installingIds = <String>{};
  final PluginSourceService _sourceService = PluginSourceService.instance;
  bool _initialized = false;
  bool _catalogRefreshing = false;
  bool _catalogRefreshQueued = false;
  int _catalogGeneration = 0;
  Future<int>? _automaticUpdateTask;
  Directory? _pluginsDirectory;

  List<InstalledPlugin> get plugins => List.unmodifiable(_plugins);
  List<PluginIndexSource> get sources => List.unmodifiable(_sources);
  List<PluginIndexEntry> get catalog => List.unmodifiable(_catalog);
  Map<String, String> get catalogErrors => Map.unmodifiable(_catalogErrors);
  Map<String, String> get catalogDetailErrors {
    final errors = <String, String>{};
    for (final entry in _catalog) {
      final error = _catalogDetailErrors[_detailKey(entry)];
      if (error != null) errors[entry.uuid.toLowerCase()] = error;
    }
    return Map.unmodifiable(errors);
  }

  bool get isRefreshing => _catalogRefreshing;

  bool isCatalogDetailLoading(PluginIndexEntry entry) {
    final suffix = '\u0000${entry.uuid.toLowerCase()}\u0001$_catalogGeneration';
    return _catalogDetailLoading.any((key) => key.endsWith(suffix));
  }

  String? catalogDetailError(PluginIndexEntry entry) =>
      _catalogDetailErrors[_detailKey(entry)];

  String? sourceForPlugin(String pluginId) =>
      _sourceByPlugin[pluginId.toLowerCase()];

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
    _restoreSources(state['sources']);
    final sourceByPlugin = state['sourceByPlugin'];
    if (sourceByPlugin is Map) {
      for (final entry in sourceByPlugin.entries) {
        final pluginId = entry.key.toString().trim().toLowerCase();
        try {
          final sourceUrl = _normalizeSourceUrl(entry.value.toString());
          if (pluginId.isNotEmpty) _sourceByPlugin[pluginId] = sourceUrl;
        } catch (error) {
          debugPrint('[PluginManager] 忽略无效插件来源映射：$error');
        }
      }
    }
    await reload();
    _initialized = true;
    if (_sources.any((source) => source.autoUpdate)) {
      unawaited(checkAutomaticUpdates());
    }
  }

  void _restoreSources(Object? rawSources) {
    final restoredSources = <PluginIndexSource>[];
    if (rawSources is List) {
      for (final raw in rawSources) {
        if (raw is! Map) continue;
        try {
          final restoredSource = PluginIndexSource.fromJson(
            Map<String, dynamic>.from(raw),
          );
          final source = PluginIndexSource(
            url: _normalizeSourceUrl(restoredSource.url),
            autoUpdate: restoredSource.autoUpdate,
            displayName: restoredSource.displayName,
          );
          if (restoredSources.any((item) => item.url == source.url)) continue;
          restoredSources.add(source);
        } catch (error) {
          debugPrint('[PluginManager] 忽略无效插件索引源：$error');
        }
      }
    }

    final official = restoredSources
        .where((source) => source.isOfficial)
        .firstOrNull;
    _sources
      ..clear()
      ..add(official ?? const PluginIndexSource(url: officialPluginIndexUrl))
      ..addAll(restoredSources.where((source) => !source.isOfficial));
  }

  Future<void> addSource(String url) async {
    final normalized = _normalizeSourceUrl(url);
    if (normalized == officialPluginIndexUrl ||
        _sources.any((source) => source.url == normalized)) {
      throw const FormatException('该插件索引源已存在');
    }
    _sources.add(PluginIndexSource(url: normalized));
    await _saveState();
    notifyListeners();
  }

  Future<void> removeSource(String url) async {
    final normalized = _normalizeSourceUrl(url);
    final source = _sources.where((item) => item.url == normalized).firstOrNull;
    if (source == null) return;
    if (source.isOfficial) throw StateError('官方插件索引源不能删除');
    _sources.remove(source);
    _sourceByPlugin.removeWhere((_, sourceUrl) => sourceUrl == normalized);
    _catalogErrors.remove(normalized);
    await _saveState();
    _catalog.removeWhere((entry) => entry.sourceUrl == normalized);
    notifyListeners();
    await refreshCatalog();
  }

  Future<void> setSourceAutoUpdate(String url, bool enabled) async {
    final normalized = _normalizeSourceUrl(url);
    final index = _sourceIndex(normalized);
    // A switch callback can outlive the source row (for example when a
    // refresh or removal rebuilds the page while its confirmation dialog is
    // open). Treat that stale callback as a no-op instead of surfacing a
    // misleading error or restoring a source that was intentionally removed.
    if (index < 0) {
      debugPrint(
        '[PluginManager] 忽略已过期的插件索引源开关：$normalized；'
        '当前源：${_sources.map((source) => source.url).join(', ')}',
      );
      notifyListeners();
      return;
    }
    if (_sources[index].url != normalized) {
      final source = _sources[index];
      _sources[index] = PluginIndexSource(
        url: normalized,
        autoUpdate: source.autoUpdate,
        displayName: source.displayName,
      );
    }
    _sources[index] = _sources[index].copyWith(autoUpdate: enabled);
    await _saveState();
    notifyListeners();
    if (enabled) unawaited(checkAutomaticUpdates());
  }

  int _sourceIndex(String normalizedUrl) => _sources.indexWhere(
    (source) => _sameSourceUrl(source.url, normalizedUrl),
  );

  Future<void> refreshCatalog() async {
    if (_catalogRefreshing) {
      _catalogRefreshQueued = true;
      return;
    }
    _catalogRefreshing = true;
    notifyListeners();
    try {
      do {
        _catalogRefreshQueued = false;
        await _refreshCatalogOnce();
      } while (_catalogRefreshQueued);
    } finally {
      _catalogRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> _refreshCatalogOnce() async {
    final sources = List<PluginIndexSource>.of(_sources);
    final results = await Future.wait(
      sources.indexed.map((item) async {
        final (index, source) = item;
        try {
          final document = await _sourceService.fetchIndex(
            source,
            sourceOrder: index,
          );
          final issue = document.issues.isEmpty
              ? null
              : '索引中有 ${document.issues.length} 行格式无效：'
                    '${document.issues.take(3).join('；')}';
          return _IndexFetchResult(document: document, error: issue);
        } catch (error) {
          return _IndexFetchResult(error: error.toString());
        }
      }),
    );
    final documents = <PluginIndexDocument>[];
    _catalogErrors.clear();
    for (var index = 0; index < results.length; index++) {
      final result = results[index];
      if (result.document != null) documents.add(result.document!);
      final error = result.error;
      if (error != null) _catalogErrors[sources[index].url] = error;
    }
    final generation = ++_catalogGeneration;
    _catalogDetails.clear();
    _resolvedCatalogDetails.clear();
    _catalogDetailErrors.clear();
    _catalog
      ..clear()
      ..addAll(mergePluginIndexDocuments(documents));
    if (documents.isNotEmpty) {
      unawaited(_resolveCatalogDetails(documents, generation));
    }
  }

  /// Fetches optional detail.txt metadata. Index rows are already visible while
  /// this request runs; a missing or failed detail file does not invalidate the
  /// catalog entry.
  Future<PluginIndexDetail?> fetchCatalogDetail(PluginIndexEntry entry) async {
    final key = _detailKey(entry);
    if (entry.detail != null) return entry.detail;
    if (_resolvedCatalogDetails.contains(key)) return _catalogDetails[key];
    final requestKey = _detailRequestKey(entry);
    final pending = _catalogDetailRequests[requestKey];
    if (pending != null) return pending;

    final request = _fetchCatalogDetail(entry, key, requestKey);
    _catalogDetailRequests[requestKey] = request;
    return request;
  }

  Future<PluginIndexDetail?> _fetchCatalogDetail(
    PluginIndexEntry entry,
    String key,
    String requestKey,
  ) async {
    final generation = _catalogGeneration;
    _catalogDetailLoading.add(requestKey);
    notifyListeners();
    try {
      final detail = await _sourceService.fetchDetail(entry);
      if (generation == _catalogGeneration) {
        _catalogDetails[key] = detail;
        _resolvedCatalogDetails.add(key);
        _catalogDetailErrors.remove(key);
        _replaceCatalogDetail(entry, detail);
      }
      return detail;
    } catch (error) {
      if (generation == _catalogGeneration && _catalogContains(entry)) {
        _catalogDetailErrors[key] = error.toString();
      }
      rethrow;
    } finally {
      _catalogDetailRequests.remove(requestKey);
      _catalogDetailLoading.remove(requestKey);
      notifyListeners();
    }
  }

  Future<void> _resolveCatalogDetails(
    List<PluginIndexDocument> documents,
    int generation,
  ) async {
    final entries = documents.expand((document) => document.entries).toList();
    for (var start = 0; start < entries.length; start += 8) {
      final batch = entries.skip(start).take(8);
      await Future.wait(
        batch.map((entry) async {
          try {
            await fetchCatalogDetail(entry);
          } catch (_) {
            // Optional metadata must never prevent index browsing.
          }
        }),
      );
      if (generation != _catalogGeneration) return;
    }
    if (generation != _catalogGeneration) return;

    final detailedDocuments = documents.map((document) {
      return PluginIndexDocument(
        source: document.source,
        sourceOrder: document.sourceOrder,
        issues: document.issues,
        entries: document.entries
            .map((entry) {
              final detail = _catalogDetails[_detailKey(entry)];
              return detail == null ? entry : entry.copyWith(detail: detail);
            })
            .toList(growable: false),
      );
    });
    _catalog
      ..clear()
      ..addAll(mergePluginIndexDocuments(detailedDocuments));
    notifyListeners();
  }

  void _replaceCatalogDetail(
    PluginIndexEntry requestedEntry,
    PluginIndexDetail? detail,
  ) {
    final index = _catalog.indexWhere(
      (entry) =>
          entry.uuid.toLowerCase() == requestedEntry.uuid.toLowerCase() &&
          entry.sourceUrl == requestedEntry.sourceUrl,
    );
    if (index < 0 || detail == null) return;
    _catalog[index] = _catalog[index].copyWith(detail: detail);
    notifyListeners();
  }

  bool _catalogContains(PluginIndexEntry entry) => _catalog.any(
    (candidate) =>
        candidate.uuid.toLowerCase() == entry.uuid.toLowerCase() &&
        candidate.sourceUrl == entry.sourceUrl,
  );

  String _detailKey(PluginIndexEntry entry) =>
      '${entry.sourceUrl}\u0000${entry.uuid.toLowerCase()}';

  String _detailRequestKey(PluginIndexEntry entry) =>
      '${_detailKey(entry)}\u0001$_catalogGeneration';

  /// Downloads a catalog package and validates the index identity before the
  /// UI asks the user to trust and install it.
  Future<Uint8List> downloadCatalogPlugin(PluginIndexEntry entry) async {
    var resolvedEntry = entry;
    if (entry.detail == null &&
        !_resolvedCatalogDetails.contains(_detailKey(entry))) {
      try {
        final detail = await fetchCatalogDetail(entry);
        if (detail != null) resolvedEntry = entry.copyWith(detail: detail);
      } catch (_) {
        // Index metadata remains sufficient when optional detail is offline.
      }
    }
    resolvedEntry = resolvedEntry.copyWith(
      detail: resolvedEntry.detail ?? _catalogDetails[_detailKey(entry)],
    );
    final bytes = await _sourceService.downloadPlugin(resolvedEntry);
    final manifest = inspectPackage(bytes);
    if (manifest.id.toLowerCase() != resolvedEntry.uuid.toLowerCase()) {
      throw FormatException(
        '下载包插件 ID 与索引不一致：${manifest.id} != ${resolvedEntry.uuid}',
      );
    }
    if (resolvedEntry.version != null &&
        manifest.version != resolvedEntry.version) {
      throw FormatException(
        '下载包版本与索引不一致：${manifest.version} != ${resolvedEntry.version}',
      );
    }
    return bytes;
  }

  /// Checks only explicitly auto-updating sources, and updates a plugin only
  /// when its recorded source is still enabled. Candidate versions are then
  /// resolved across all enabled sources, using configured source order for
  /// equal versions.
  Future<int> checkAutomaticUpdates() {
    final running = _automaticUpdateTask;
    if (running != null) return running;
    final task = _checkAutomaticUpdates();
    _automaticUpdateTask = task;
    return task.whenComplete(() {
      if (identical(_automaticUpdateTask, task)) _automaticUpdateTask = null;
    });
  }

  Future<int> _checkAutomaticUpdates() async {
    final enabledSources = _sources
        .where((source) => source.autoUpdate)
        .toList(growable: false);
    if (enabledSources.isEmpty) return 0;

    final results = await Future.wait(
      enabledSources.map((source) async {
        try {
          final document = await _sourceService.fetchIndex(
            source,
            sourceOrder: _sources.indexOf(source),
          );
          return _IndexFetchResult(document: document);
        } catch (error) {
          return _IndexFetchResult(error: error.toString());
        }
      }),
    );
    final documents = <PluginIndexDocument>[];
    _catalogErrors.removeWhere(
      (url, _) => enabledSources.any((source) => source.url == url),
    );
    for (var index = 0; index < results.length; index++) {
      final result = results[index];
      final source = enabledSources[index];
      if (result.document != null) {
        documents.add(result.document!);
        if (result.document!.issues.isNotEmpty) {
          _catalogErrors[source.url] =
              '索引中有 ${result.document!.issues.length} 行格式无效';
        }
      } else if (result.error != null) {
        _catalogErrors[source.url] = result.error!;
      }
    }
    notifyListeners();

    var updated = 0;
    final pluginSnapshot = List<InstalledPlugin>.from(_plugins);
    for (final plugin in pluginSnapshot) {
      final installedSourceUrl =
          _sourceByPlugin[plugin.manifest.id.toLowerCase()];
      if (installedSourceUrl == null ||
          !enabledSources.any((source) => source.url == installedSourceUrl)) {
        continue;
      }
      final matchingEntries = documents
          .map((document) {
            final entries = document.entries
                .where(
                  (entry) =>
                      entry.uuid.toLowerCase() ==
                      plugin.manifest.id.toLowerCase(),
                )
                .toList(growable: false);
            return PluginIndexDocument(
              source: document.source,
              sourceOrder: document.sourceOrder,
              issues: document.issues,
              entries: entries,
            );
          })
          .where((document) => document.entries.isNotEmpty)
          .toList(growable: false);
      if (matchingEntries.isEmpty) continue;

      final detailedCandidates = <PluginIndexDocument>[];
      for (final document in matchingEntries) {
        final entries = await Future.wait(
          document.entries.map((entry) async {
            if (entry.version != null) return entry;
            try {
              final detail = await fetchCatalogDetail(entry);
              return detail == null ? entry : entry.copyWith(detail: detail);
            } catch (error) {
              _catalogErrors[entry.sourceUrl] = error.toString();
              return entry;
            }
          }),
        );
        detailedCandidates.add(
          PluginIndexDocument(
            source: document.source,
            sourceOrder: document.sourceOrder,
            issues: document.issues,
            entries: entries,
          ),
        );
      }
      final entry = mergePluginIndexDocuments(detailedCandidates).firstOrNull;
      if (entry == null) continue;

      try {
        final installedVersion = PluginVersion.tryParse(
          plugin.manifest.version,
        );
        final catalogVersion = entry.effectiveParsedVersion;
        if (catalogVersion != null &&
            installedVersion != null &&
            catalogVersion.compareTo(installedVersion) <= 0) {
          continue;
        }
        if (catalogVersion != null && installedVersion == null) {
          _catalogErrors[entry.sourceUrl] =
              '插件 ${plugin.manifest.name} 当前版本不是三段式，已跳过自动更新';
          continue;
        }

        final bytes = await downloadCatalogPlugin(entry);
        final candidate = inspectPackage(bytes);
        final candidateVersion = PluginVersion.tryParse(candidate.version);
        if (candidateVersion == null || installedVersion == null) {
          _catalogErrors[entry.sourceUrl] =
              '插件 ${plugin.manifest.name} 的包版本不是三段式，已跳过自动更新';
          continue;
        }
        if (candidateVersion.compareTo(installedVersion) <= 0) continue;
        await installPackage(bytes, sourceUrl: entry.sourceUrl);
        updated++;
      } catch (error) {
        _catalogErrors[entry.sourceUrl] = error.toString();
      }
    }
    notifyListeners();
    return updated;
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
        if (await _hasRequiredFiles(plugin)) loaded.add(plugin);
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

  Future<void> installPackage(Uint8List bytes, {String? sourceUrl}) async {
    final manifest = inspectPackage(bytes);
    final pluginKey = manifest.id.toLowerCase();
    if (!_installingIds.add(pluginKey)) {
      throw StateError('插件 ${manifest.name} 正在安装或更新');
    }
    try {
      await _installPackage(bytes, manifest, sourceUrl: sourceUrl);
    } finally {
      _installingIds.remove(pluginKey);
    }
  }

  Future<void> _installPackage(
    Uint8List bytes,
    PluginManifest manifest, {
    String? sourceUrl,
  }) async {
    final archive = ZipDecoder().decodeBytes(bytes, verify: true);
    final root = await _rootDirectory();
    final target = Directory(
      '${root.path}${Platform.pathSeparator}${manifest.id}',
    );
    final staging = Directory(
      '${root.path}${Platform.pathSeparator}.${manifest.id}.installing',
    );
    final backup = Directory(
      '${root.path}${Platform.pathSeparator}.${manifest.id}.backup-$pid-${DateTime.now().microsecondsSinceEpoch}',
    );
    var movedOld = false;
    var activated = false;
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
        await target.rename(backup.path);
        movedOld = true;
      }
      await staging.rename(target.path);
      activated = true;
      if (!movedOld) _disabledIds.remove(manifest.id);
      final previousSource = _sourceByPlugin[manifest.id.toLowerCase()];
      if (sourceUrl == null) {
        _sourceByPlugin.remove(manifest.id.toLowerCase());
      } else {
        _sourceByPlugin[manifest.id.toLowerCase()] = _normalizeSourceUrl(
          sourceUrl,
        );
      }
      try {
        await _saveState();
      } catch (_) {
        if (previousSource == null) {
          _sourceByPlugin.remove(manifest.id.toLowerCase());
        } else {
          _sourceByPlugin[manifest.id.toLowerCase()] = previousSource;
        }
        if (await target.exists()) await target.delete(recursive: true);
        if (movedOld && await backup.exists()) {
          await backup.rename(target.path);
          movedOld = false;
        }
        rethrow;
      }
      if (movedOld && await backup.exists()) {
        try {
          await backup.delete(recursive: true);
          movedOld = false;
        } catch (error) {
          debugPrint('[PluginManager] 清理旧插件备份失败：$error');
        }
      }
      await reload();
    } catch (_) {
      if (await staging.exists()) await staging.delete(recursive: true);
      if (movedOld && !await target.exists() && await backup.exists()) {
        await backup.rename(target.path);
      } else if (activated && await backup.exists()) {
        // Keep the active replacement and leave its recoverable backup if a
        // later cleanup step failed.
        debugPrint('[PluginManager] 保留插件更新备份：${backup.path}');
      }
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
    _sourceByPlugin.remove(pluginId.toLowerCase());
    await _saveState();
    await reload();
  }

  Future<void> _saveState() {
    return AppFileStore.instance.writeJson('plugins_state.json', {
      'disabled': _disabledIds.toList()..sort(),
      'sources': _sources.map((source) => source.toJson()).toList(),
      'sourceByPlugin': Map<String, String>.from(_sourceByPlugin),
    });
  }

  String _normalizeSourceUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      throw const FormatException('插件索引源必须是有效的 HTTP/HTTPS URL');
    }
    return canonicalPluginSourceUrl(uri.toString());
  }

  bool _sameSourceUrl(String left, String right) {
    try {
      return _normalizeSourceUrl(left) == _normalizeSourceUrl(right);
    } catch (_) {
      return left.trim() == right.trim();
    }
  }

  Future<bool> _hasRequiredFiles(InstalledPlugin plugin) {
    return File(plugin.bytecodePath).exists();
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

class _IndexFetchResult {
  const _IndexFetchResult({this.document, this.error});

  final PluginIndexDocument? document;
  final String? error;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
