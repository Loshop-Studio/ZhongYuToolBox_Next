import 'dart:io';
import 'dart:typed_data';

import 'cloud_note_snapshot.dart';

/// A page stored by the Android "中育云笔记" application.
///
/// The on-disk layout is intentionally kept separate from the ZIP/blackboard
/// format used by other note features:
///
/// ```text
/// <note>/
///   <timestamp>/
///     <page-id>/snapshot.bin
///     <page-id>/screenshot.png
///     page_mdb/data.mdb
///     res/image/*
/// ```
///
/// [directory] is the page-id directory. The database and shared resources
/// belong to [versionDirectory], not to the page-id directory itself.
class CloudNoteLocalPage {
  CloudNoteLocalPage({
    required this.versionDirectory,
    required this.directory,
    required this.versionId,
    required this.pageId,
  });

  /// Timestamp directory containing this page.
  final Directory versionDirectory;

  /// UUID directory containing `snapshot.bin` and `screenshot.png`.
  final Directory directory;

  /// Usually a millisecond timestamp, kept as text to preserve the filename.
  final String versionId;

  /// UUID directory name. Some exports use a non-UUID name, so this is not
  /// validated beyond being a directory name.
  final String pageId;

  File get snapshotFile => File(_join(directory.path, 'snapshot.bin'));

  File get screenshotFile => File(_join(directory.path, 'screenshot.png'));

  Directory get pageDatabaseDirectory =>
      Directory(_join(versionDirectory.path, 'page_mdb'));

  File get databaseFile => File(_join(pageDatabaseDirectory.path, 'data.mdb'));

  File get databaseLockFile =>
      File(_join(pageDatabaseDirectory.path, 'lock.mdb'));

  Directory get imageDirectory =>
      Directory(_join(_join(versionDirectory.path, 'res'), 'image'));

  bool get hasSnapshot => snapshotFile.existsSync();

  bool get hasScreenshot => screenshotFile.existsSync();

  bool get hasPageDatabase => databaseFile.existsSync();

  /// Returns the raw protobuf bytes, or null when this page has no snapshot.
  Future<Uint8List?> readSnapshot() async {
    if (!await snapshotFile.exists()) return null;
    return snapshotFile.readAsBytes();
  }

  /// Reads and decodes this page's native protobuf snapshot.
  Future<CloudNoteSnapshot?> readParsedSnapshot() async {
    final bytes = await readSnapshot();
    return bytes == null ? null : CloudNoteSnapshot.parse(bytes);
  }

  /// Returns the rendered PNG bytes, or null when this page has no screenshot.
  Future<Uint8List?> readScreenshot() async {
    if (!await screenshotFile.exists()) return null;
    return screenshotFile.readAsBytes();
  }

  /// Lists shared image resources in deterministic filename order.
  Future<List<File>> listImageFiles() async {
    if (!await imageDirectory.exists()) return const <File>[];
    final files = await imageDirectory
        .list(followLinks: false)
        .where((entity) => entity is File)
        .cast<File>()
        .toList();
    files.sort((a, b) => _fileName(a.path).compareTo(_fileName(b.path)));
    return files;
  }

  /// Resolves a `filePath` stored in GraphSnapshot to a shared image file.
  ///
  /// Snapshot values occasionally contain `/` or `\\`; both are accepted.
  /// Absolute paths and `..` segments are rejected so a malformed snapshot
  /// cannot escape the page's `res/image` directory.
  File? resolveImage(String filePath) {
    final normalized = filePath.trim().replaceAll('\\', '/');
    if (normalized.isEmpty) return null;
    if (normalized.startsWith('/') || normalized.contains(':')) return null;
    var segments = normalized
        .split('/')
        .where((part) => part.isNotEmpty)
        .toList();
    if (segments.length >= 2 &&
        segments[0].toLowerCase() == 'res' &&
        segments[1].toLowerCase() == 'image') {
      segments = segments.skip(2).toList();
    } else if (segments.first.toLowerCase() == 'image') {
      segments = segments.skip(1).toList();
    }
    final safe = <String>[];
    for (final segment in segments) {
      if (segment == '.' || segment == '..') return null;
      safe.add(segment);
    }
    if (safe.isEmpty) return null;
    return File(_join(imageDirectory.path, safe.join('/')));
  }
}

/// A locally exported 中育云笔记 document.
class CloudNoteLocalDocument {
  CloudNoteLocalDocument._({required this.root, required this.pages});

  final Directory root;
  final List<CloudNoteLocalPage> pages;

  bool get isEmpty => pages.isEmpty;

  /// Opens a note directory and discovers all timestamp/page directories.
  ///
  /// The method also accepts a page directory directly (a directory that
  /// contains `snapshot.bin`), which is useful for small one-page exports.
  static Future<CloudNoteLocalDocument> open(String path) async {
    final root = Directory(path);
    if (!await root.exists()) {
      throw FileSystemException('云笔记目录不存在', path);
    }

    final direct = await _pageFromDirectory(
      root,
      versionId: _fileName(root.path),
    );
    if (direct != null) {
      return CloudNoteLocalDocument._(root: root, pages: [direct]);
    }

    final versions = await root
        .list(followLinks: false)
        .where((entity) => entity is Directory)
        .cast<Directory>()
        .toList();
    versions.sort(_compareVersionDirectories);

    final pages = <CloudNoteLocalPage>[];
    for (final version in versions) {
      final versionId = _fileName(version.path);
      // Ignore unrelated folders (for example an accidental `tmp` folder).
      // A valid version has at least one page directory with a snapshot or
      // screenshot. Numeric timestamp names are preferred but not required
      // so that hand-exported fixtures remain loadable.
      final children = await version
          .list(followLinks: false)
          .where((entity) => entity is Directory)
          .cast<Directory>()
          .toList();
      children.sort((a, b) => _fileName(a.path).compareTo(_fileName(b.path)));
      for (final child in children) {
        final page = await _pageFromDirectory(
          child,
          versionDirectory: version,
          versionId: versionId,
        );
        if (page != null) pages.add(page);
      }
    }

    return CloudNoteLocalDocument._(root: root, pages: pages);
  }

  static Future<CloudNoteLocalPage?> _pageFromDirectory(
    Directory directory, {
    Directory? versionDirectory,
    String? versionId,
  }) async {
    final snapshot = File(_join(directory.path, 'snapshot.bin'));
    final screenshot = File(_join(directory.path, 'screenshot.png'));
    if (!await snapshot.exists() && !await screenshot.exists()) return null;
    final version = versionDirectory ?? directory;
    return CloudNoteLocalPage(
      versionDirectory: version,
      directory: directory,
      versionId: versionId ?? _fileName(version.path),
      pageId: _fileName(directory.path),
    );
  }
}

int _compareVersionDirectories(Directory a, Directory b) {
  final aName = _fileName(a.path);
  final bName = _fileName(b.path);
  final aNumber = int.tryParse(aName);
  final bNumber = int.tryParse(bName);
  if (aNumber != null && bNumber != null) return aNumber.compareTo(bNumber);
  if (aNumber != null) return -1;
  if (bNumber != null) return 1;
  return aName.compareTo(bName);
}

String _fileName(String path) {
  final normalized = path.replaceAll('\\', '/');
  final index = normalized.lastIndexOf('/');
  return index < 0 ? normalized : normalized.substring(index + 1);
}

String _join(String base, String child) {
  if (base.isEmpty) return child;
  final separator = Platform.pathSeparator;
  return '${base.endsWith(separator) ? base.substring(0, base.length - 1) : base}$separator${child.replaceAll('/', separator)}';
}
