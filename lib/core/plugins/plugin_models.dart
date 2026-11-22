import 'package:flutter/material.dart';

/// Flutter/EVC 插件可挂载的宿主位置。
abstract final class PluginPositions {
  static const String homepageMenu = 'Homepage:Menu';
  static const String homepageUserCard = 'Homepage:UserCard';
  static const String notePlusBtn = 'Note:PlusBtn';
  static const String noteDetail = 'Note:Detail';
  static const String galleryAdd = 'Gallery:Add';
  static const String galleryDetail = 'Gallery:Detail';
  static const String exerciseHome = 'Exercise:Home';
  static const String exerciseDetail = 'Exercise:Detail';
  static const String studyHome = 'Study:Home';
  static const String columnDetail = 'Column:Detail';
  static const String columnAttachmentDetail = 'Column:AttachmentDetail';
  static const String askPlusBtn = 'Ask:PlusBtn';
  static const String askDetail = 'Ask:Detail';

  static const Set<String> all = {
    homepageMenu,
    homepageUserCard,
    notePlusBtn,
    noteDetail,
    galleryAdd,
    galleryDetail,
    exerciseHome,
    exerciseDetail,
    studyHome,
    columnDetail,
    columnAttachmentDetail,
    askPlusBtn,
    askDetail,
  };
}

class PluginManifest {
  const PluginManifest({
    required this.id,
    required this.name,
    required this.version,
    required this.pages,
    required this.actions,
    this.bytecode = 'plugin.evc',
    this.runtime = 'flutter',
    this.entry = '',
    this.description = '',
    this.author = '',
  });

  final String id;
  final String name;
  final String version;

  /// Renderer ABI. Only `flutter`/`evc` are supported; web pages are rejected.
  final String runtime;
  final String entry;
  final String description;
  final String author;
  final String bytecode;
  final List<PluginPageDefinition> pages;
  final List<PluginActionDefinition> actions;

  factory PluginManifest.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? '').toString().trim();
    final name = (json['name'] ?? '').toString().trim();
    final version = (json['version'] ?? '').toString().trim();
    final declared = (json['runtime'] ?? '').toString().trim().toLowerCase();
    if (declared == 'web' || declared == 'html' || declared == 'webview') {
      throw const FormatException('不支持 WebView/HTML 插件，插件必须使用 Flutter/EVC');
    }
    if (declared.isNotEmpty && declared != 'flutter' && declared != 'evc') {
      throw FormatException('不支持的插件 runtime：$declared');
    }
    const runtime = 'flutter';
    final bytecode = (json['bytecode'] ?? 'plugin.evc').toString().trim();
    if (!RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9._-]{1,79}$').hasMatch(id)) {
      throw const FormatException('插件 id 只能包含字母、数字、点、下划线和短横线（2-80 字符）');
    }
    if (name.isEmpty) throw const FormatException('插件 name 不能为空');
    if (version.isEmpty) throw const FormatException('插件 version 不能为空');
    if (!_isSafeRelativePath(bytecode)) {
      throw const FormatException('bytecode 必须是插件包内的相对路径');
    }

    final pagesRaw = json['pages'];
    if (pagesRaw is! List || pagesRaw.isEmpty) {
      throw const FormatException('插件至少需要注册一个 page');
    }
    final pages = pagesRaw
        .whereType<Map>()
        .map((e) => PluginPageDefinition.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
    if (pages.length != pagesRaw.length) {
      throw const FormatException('pages 中存在无效项');
    }
    final pageIds = <String>{};
    for (final page in pages) {
      if (!pageIds.add(page.id)) throw FormatException('page id 重复：${page.id}');
    }

    final actionsRaw = json['actions'];
    final actions = actionsRaw is List
        ? actionsRaw
              .whereType<Map>()
              .map(
                (e) => PluginActionDefinition.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList(growable: false)
        : const <PluginActionDefinition>[];
    if (actionsRaw is List && actions.length != actionsRaw.length) {
      throw const FormatException('actions 中存在无效项');
    }
    final actionIds = <String>{};
    for (final action in actions) {
      if (!actionIds.add(action.id)) {
        throw FormatException('action id 重复：${action.id}');
      }
      if (!PluginPositions.all.contains(action.posId)) {
        throw FormatException('未知 posId：${action.posId}');
      }
      if (!pageIds.contains(action.pageId)) {
        throw FormatException(
          'action ${action.id} 指向不存在的 page：${action.pageId}',
        );
      }
    }
    return PluginManifest(
      id: id,
      name: name,
      version: version,
      runtime: runtime,
      entry: '',
      bytecode: bytecode,
      pages: pages,
      actions: actions,
      description: (json['description'] ?? '').toString(),
      author: (json['author'] ?? '').toString(),
    );
  }

  static bool _isSafeRelativePath(String value) {
    if (value.isEmpty || value.startsWith('/') || value.startsWith('\\')) {
      return false;
    }
    if (RegExp(r'^[a-zA-Z]:').hasMatch(value)) return false;
    final segments = value.replaceAll('\\', '/').split('/');
    return !segments.any((part) => part.isEmpty || part == '..');
  }
}

class PluginPageDefinition {
  const PluginPageDefinition({
    required this.id,
    required this.title,
    required this.library,
    required this.function,
  });

  final String id;
  final String title;
  final String library;
  final String function;

  factory PluginPageDefinition.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? '').toString().trim();
    final title = (json['title'] ?? '').toString().trim();
    final library = (json['library'] ?? '').toString().trim();
    final function = (json['function'] ?? '').toString().trim();
    if (!RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9._-]{0,79}$').hasMatch(id)) {
      throw FormatException('无效 page id：$id');
    }
    if (library.isEmpty || function.isEmpty) {
      throw FormatException('page $id 缺少 library/function');
    }
    return PluginPageDefinition(
      id: id,
      title: title.isEmpty ? id : title,
      library: library,
      function: function,
    );
  }
}

class PluginActionDefinition {
  const PluginActionDefinition({
    required this.id,
    required this.posId,
    required this.label,
    required this.pageId,
    this.icon = 'extension',
    this.order = 0,
    this.replacesNative = false,
  });

  final String id;
  final String posId;
  final String label;
  final String icon;
  final String pageId;
  final int order;
  final bool replacesNative;

  factory PluginActionDefinition.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? '').toString().trim();
    final posId = (json['posId'] ?? '').toString().trim();
    final label = (json['label'] ?? '').toString().trim();
    final pageId = (json['pageId'] ?? '').toString().trim();
    if (id.isEmpty || posId.isEmpty || label.isEmpty || pageId.isEmpty) {
      throw const FormatException('action 缺少 id/posId/label/pageId');
    }
    return PluginActionDefinition(
      id: id,
      posId: posId,
      label: label,
      pageId: pageId,
      icon: (json['icon'] ?? 'extension').toString(),
      order: (json['order'] as num?)?.toInt() ?? 0,
      replacesNative: json['replacesNative'] == true,
    );
  }
}

class InstalledPlugin {
  const InstalledPlugin({
    required this.manifest,
    required this.directoryPath,
    required this.enabled,
  });

  final PluginManifest manifest;
  final String directoryPath;
  final bool enabled;

  bool get isFlutter => true;
  bool get isWeb => false;
  bool get isLegacy => false;

  String get bytecodePath {
    final separator = directoryPath.contains('\\') ? '\\' : '/';
    final relative = manifest.bytecode.replaceAll(RegExp(r'[\\/]+'), separator);
    return '$directoryPath$separator$relative';
  }

  InstalledPlugin copyWith({bool? enabled}) => InstalledPlugin(
    manifest: manifest,
    directoryPath: directoryPath,
    enabled: enabled ?? this.enabled,
  );
}

class RegisteredPluginAction {
  const RegisteredPluginAction({required this.plugin, required this.action});

  final InstalledPlugin plugin;
  final PluginActionDefinition action;

  String get value => '${plugin.manifest.id}:${action.id}';
}

IconData pluginIcon(String name) {
  return switch (name.trim().toLowerCase()) {
    'add' => Icons.add,
    'article' => Icons.article_outlined,
    'book' || 'menu_book' => Icons.menu_book_outlined,
    'build' => Icons.build_outlined,
    'camera' => Icons.camera_alt_outlined,
    'cloud' => Icons.cloud_outlined,
    'code' => Icons.code,
    'download' => Icons.download_outlined,
    'edit' => Icons.edit_outlined,
    'fact_check' => Icons.fact_check_outlined,
    'file' => Icons.insert_drive_file_outlined,
    'folder' => Icons.folder_outlined,
    'forum' => Icons.forum_outlined,
    'image' || 'photo' => Icons.image_outlined,
    'info' => Icons.info_outline,
    'link' => Icons.link,
    'note' => Icons.note_outlined,
    'open_in_new' => Icons.open_in_new,
    'person' => Icons.person_outline,
    'school' => Icons.school_outlined,
    'search' => Icons.search,
    'send' => Icons.send_outlined,
    'settings' => Icons.settings_outlined,
    'share' => Icons.share_outlined,
    'star' => Icons.star_outline,
    'upload' => Icons.upload_file_outlined,
    'web' => Icons.public,
    _ => Icons.extension_outlined,
  };
}
