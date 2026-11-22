part of 'board_file.dart';

String _dir(String path) =>
    path.contains('/') ? path.substring(0, path.lastIndexOf('/') + 1) : '';
String _leaf(String path) => path.split('/').last;

Uint8List? _archiveFileBytes(ArchiveFile? file) {
  if (file == null) return null;
  final content = file.content;
  if (content is Uint8List) return content;
  if (content is List<int>) return Uint8List.fromList(content);
  return null;
}

/// A ZIP is a transport for an original board folder. Keep every unedited member.
class BoardArchive {
  BoardArchive._(this.name, this.arch, this._original);
  final String name;
  final Archive arch;
  // A selected folder has no original transport bytes until its first export.
  Uint8List? _original;
  Uint8List get original => _original ??= _zip(const {});
  // Largest 32-bit float, used in both directions by the native unbounded root.
  static const _rootLimit = 3.4028234663852886e38;
  static const maxMembers = 10000;
  static const maxMemberBytes = 256 * 1024 * 1024;
  final entries = <String>[];
  final changed = <String, Uint8List>{};
  final pendingPreviews = <String>{};
  // An undo revision keeps the original JPEG plus any unbaked actions. A
  // freshly imported export already includes every action in its JPEG.
  final thumbnailActionCounts = <String, int>{};
  final sizes = <String, Size>{};
  final _imageCache = <String, Uint8List>{};
  final _completeNotes = <String, String>{};
  int index = 0;
  String? _backgroundFor;
  Uint8List? _background;
  late BoardFile current;
  factory BoardArchive.blankBlackboard() {
    final meta = header.Header(
      version: 6,
      width: 1200,
      height: 900,
      createDate: Int64(DateTime.now().millisecondsSinceEpoch),
      defaultBackgroundColor: -1,
      lastBackgroundColor: -1,
    );
    final bundle = BoardArchive._('新笔记.zip', Archive(), null);
    const root = 'lesson/';
    bundle.changed['${root}header.bin'] = meta.writeToBuffer();
    bundle._appendBlackboardPage(root, meta, pages.PageRouter());
    return bundle;
  }

  bool get canAddBlackboardPage =>
      current is BlackboardPage &&
      (current as BlackboardPage).supportsArtworkEditing &&
      _completeNotes.containsKey(entries[index]);

  void addBlackboardPage() {
    if (!canAddBlackboardPage) throw StateError('需要完整的 Blackboard V6 笔记');
    final root = _completeNotes[entries[index]]!;
    final rootHeader = '${root}header.bin';
    final page = current as BlackboardPage;
    final meta = _hasFullPageHeader('${page.dir}header.bin') || !has(rootHeader)
        ? page._pageHeader()
        : header.Header.fromBuffer(read(rootHeader));
    final indexFile = pages.PageRouter.fromBuffer(
      read('${root}page_router.bin'),
    );
    commit();
    _appendBlackboardPage(root, meta, indexFile);
  }

  void _appendBlackboardPage(
    String root,
    header.Header meta,
    pages.PageRouter indexFile,
  ) {
    final listed = indexFile.pageInfo;
    final pageIndex =
        listed.fold(-1, (int last, info) => math.max(last, info.pageIndex)) + 1;
    if (pageIndex > 2147483647) throw const FormatException('页面索引已满');
    final occupied = <String>{
      ...arch.files.map((e) => e.name),
      ...changed.keys,
    };
    var n = listed.length + 1;
    String name;
    do {
      name = 'p${n++}';
    } while (listed.any((p) => p.name == name) ||
        occupied.any((p) => p == root + name || p.startsWith('$root$name/')));
    final prefix = '$root$name/';
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final id = 'web-root-$name-$stamp';
    // BasePageControl.addRootGraph uses float extrema as an unbounded canvas.
    const limit = _rootLimit;
    final box = rect.RectF(
      left: -limit,
      top: -limit,
      right: limit,
      bottom: limit,
    );
    final identity = mat.Matrix(scaleX: 1, scaleY: 1, perSp2: 1);
    final color = meta.hasLastBackgroundColor()
        ? meta.lastBackgroundColor
        : meta.hasDefaultBackgroundColor()
        ? meta.defaultBackgroundColor
        : -1;
    final snapshot = page.PageSnapshot(
      cameraMatrix: identity,
      graphSnapshot: page.PageSnapshot_GraphSnapshot(
        id: id,
        graphEnum: ge.GraphEnum.BOUNDED_CONTAINER_GRAPH,
        outRect: box,
        matrix: identity,
        backgroundColor: color,
      ),
    );
    final addRoot = cmd.CommandSource(
      commandInfo: [
        cmd.CommandSource_CommandInfo(
          commandEnum: ce.CommandEnum.ACTION_GRAPH_ADD,
          isPlay: false,
          data: cmd.CommandSource_CommandInfo_GraphData(
            graphId: id,
            parentGraphId: '',
            graphEnum: ge.GraphEnum.BOUNDED_CONTAINER_GRAPH,
            outRect: box,
          ).writeToBuffer(),
        ),
      ],
    ).writeToBuffer();
    final commandName = '${stamp}_command.bin';
    final path = '${prefix}snapshot.bin';
    final size = (meta.width > 0 && meta.height > 0)
        ? Size(meta.width.toDouble(), meta.height.toDouble())
        : (entries.isEmpty ? const Size(1200, 900) : current.size);
    if (!size.width.isFinite ||
        !size.height.isFinite ||
        size.width > 2147483647 ||
        size.height > 2147483647) {
      throw const FormatException('原笔记没有可用的页面尺寸');
    }
    if (meta.width <= 0 || meta.height <= 0) {
      meta
        ..width = size.width.round()
        ..height = size.height.round();
      changed['${root}header.bin'] = meta.writeToBuffer();
    }
    final newPageHeader = header.Header.fromBuffer(meta.writeToBuffer())
      ..clearDuration();
    if (!has('${root}header.bin')) {
      newPageHeader
        ..createDate = Int64(stamp)
        ..updateDate = Int64(stamp);
    }
    listed.add(pages.PageRouter_PageInfo(name: name, pageIndex: pageIndex));
    changed.addAll({
      '${root}page_router.bin': indexFile.writeToBuffer(),
      '${prefix}header.bin': newPageHeader.writeToBuffer(),
      '${prefix}router.bin': router.RouterRecord(
        commandRecord: [
          router.RouterRecord_SourceCommandRecord(
            fileName: commandName,
            validate: BlackboardPage._signature(addRoot),
          ),
        ],
      ).writeToBuffer(),
      prefix + commandName: addRoot,
      path: snapshot.writeToBuffer(),
    });
    final last = entries.lastIndexWhere((e) => _completeNotes[e] == root);
    entries.insert(last + 1, path);
    _completeNotes[path] = root;
    sizes[path] = size;
    pendingPreviews.add(path);
    _select(last + 1);
  }

  factory BoardArchive.fromSketch(BoardFile board) {
    final bytes = board.bytes();
    final container = Archive()
      ..addFile(ArchiveFile('actions.bin', bytes.length, bytes));
    final stem = _leaf(
      board.name,
    ).replaceFirst(RegExp(r'\.bin$', caseSensitive: false), '');
    return BoardArchive.open(
      '$stem.zip',
      Uint8List.fromList(ZipEncoder().encode(container)!),
    );
  }
  static BoardArchive open(
    String name,
    Uint8List bytes, {
    int pageIndex = 0,
    Map<String, int> thumbnailActionCounts = const {},
  }) {
    return fromArchive(
      name,
      ZipDecoder().decodeBytes(bytes),
      bytes,
      pageIndex,
      thumbnailActionCounts,
    );
  }

  static BoardArchive fromDirectory(
    String folder,
    Map<String, Uint8List> files,
  ) {
    return fromArchive('$folder.zip', directoryMembers(files), null, 0);
  }

  static Archive directoryMembers(Map<String, Uint8List> files) {
    final archive = Archive();
    for (final e in files.entries) {
      archive.addFile(ArchiveFile(e.key, e.value.length, e.value));
    }
    return archive;
  }

  static List<String> memberNames(Archive zip) {
    if (zip.length > maxMembers ||
        zip.fold<int>(0, (sum, f) => sum + f.size) > maxMemberBytes)
      throw const FormatException('画板包展开后过大');
    final names = zip.files.where((f) => f.isFile).map((f) => f.name).toList();
    if (names.toSet().length != names.length)
      throw const FormatException('ZIP 包含重复文件名');
    return names;
  }

  static BoardArchive fromArchive(
    String name,
    Archive zip,
    Uint8List? bytes,
    int pageIndex, [
    Map<String, int> thumbnailActionCounts = const {},
  ]) {
    final names = memberNames(zip);
    final board = BoardArchive._(name, zip, bytes)
      ..thumbnailActionCounts.addAll(thumbnailActionCounts);
    for (final path in names.where((n) => _leaf(n) == 'page_router.bin')) {
      final base = _dir(path);
      final idx = pages.PageRouter.fromBuffer(board.read(path));
      final rootHeader = '${base}header.bin';
      final info = board.has(rootHeader)
          ? header.Header.fromBuffer(board.read(rootHeader))
          : null;
      final listed = idx.pageInfo.toList()
        ..sort((a, b) => a.pageIndex.compareTo(b.pageIndex));
      final complete =
          listed.isNotEmpty &&
          listed.every(
            (p) =>
                zip.findFile('$base${p.name}/router.bin') != null &&
                zip.findFile('$base${p.name}/snapshot.bin') != null &&
                (info != null ||
                    board._hasFullPageHeader('$base${p.name}/header.bin')),
          );
      for (final e in listed) {
        final file = '$base${e.name}/snapshot.bin';
        if (zip.findFile(file) == null) continue;
        board.entries.add(file);
        if (complete) board._completeNotes[file] = base;
        if (info != null && info.width > 0 && info.height > 0)
          board.sizes[file] = Size(
            info.width.toDouble(),
            info.height.toDouble(),
          );
      }
    }
    for (final path in names.where(
      (n) => _leaf(n) == 'actions.bin' || _leaf(n) == 'snapshot.bin',
    )) {
      if (!board.entries.contains(path)) board.entries.add(path);
    }
    final bins = names
        .where((name) => name.toLowerCase().endsWith('.bin'))
        .toList();
    final backgrounds = names
        .where((name) => name.toLowerCase().endsWith('.webp'))
        .map(_dir)
        .toSet();
    final hasIndexedPage = board.entries.isNotEmpty;
    for (final path in bins) {
      // SimpleBoard saves its BIN and WebP together, including inside larger
      // note folders that may also contain a Sketch or Blackboard page.
      final paired = backgrounds.contains(_dir(path));
      final isDraft = _leaf(path).toLowerCase() == 'remote_draft.bin';
      if (hasIndexedPage && !isDraft && !paired) continue;
      if (board.entries.contains(path)) continue;
      try {
        final file = BoardFile.open(
          path,
          board.read(path),
          allowEmptySimple: bins.length == 1 || paired || isDraft,
        );
        if (file.format == BoardFormat.simple) board.entries.add(path);
      } on Exception {
        continue;
      }
    }
    _applyCloudPageIndexes(board, names);
    if (board.entries.isEmpty) throw const FormatException('ZIP 中没有可编辑的画板页');
    board._select(pageIndex.clamp(0, board.entries.length - 1));
    return board;
  }

  Uint8List read(String path) {
    final file = changed[path] ?? _archiveFileBytes(arch.findFile(path));
    if (file == null) throw FormatException('缺少画板成员 $path');
    return file;
  }

  bool has(String path) =>
      changed.containsKey(path) || arch.findFile(path) != null;
  void _select(int i) {
    index = i;
    final entry = entries[i];
    current = _openBoard(entry);
    if (backgroundImage case final Uint8List data) {
      final originalSize = _webpSize(data);
      if (originalSize != null) current.size = sizes[entry] ?? originalSize;
    }
  }

  BoardFile _openBoard(String entry) {
    if (_leaf(entry) == 'snapshot.bin') return BlackboardPage.load(this, entry);
    final thumbnail = '${_dir(entry)}thumbnail.jpg';
    final file = BoardFile.open(
      entry,
      read(entry),
      allowEmptySimple: _leaf(entry) != 'actions.bin',
      sketchThumbnail: () => has(thumbnail) ? read(thumbnail) : null,
      bakedActionCount: thumbnailActionCounts[entry],
      sketchImage: (name) {
        final path = '${_dir(entry)}res/$name';
        return has(path)
            ? _imageCache.putIfAbsent(path, () => read(path))
            : null;
      },
    );
    if (file._bakedActionCount case final count?)
      thumbnailActionCounts[entry] = count;
    return file;
  }

  Uint8List? get backgroundImage {
    if (current.format != BoardFormat.simple) return null;
    final folder = _dir(entries[index]);
    if (_backgroundFor != folder) {
      _backgroundFor = folder;
      final file = arch.files
          .where(
            (f) =>
                _dir(f.name) == folder &&
                f.name.toLowerCase().endsWith('.webp'),
          )
          .firstOrNull;
      _background = _archiveFileBytes(file);
    }
    return _background;
  }

  Uint8List? sketchAudio(String filename) {
    final path = '${_dir(entries[index])}res/audio/$filename';
    return filename.isNotEmpty && has(path) ? read(path) : null;
  }

  String insertSketchImage(
    String name,
    Uint8List bytes,
    int width,
    int height,
    int position,
  ) {
    if (!current.canInsertSketchImage || width < 1 || height < 1) {
      throw StateError('当前画板或图片尺寸无效');
    }
    final base = '${_dir(entries[index])}res/';
    final filename = _uniqueResourceName(base, name);
    changed[base + filename] = bytes;
    current._appendImage(filename, width, height, position);
    return filename;
  }

  String _uniqueResourceName(String base, String name) {
    final leaf = _leaf(name.replaceAll('\\', '/'));
    final dot = leaf.lastIndexOf('.');
    final stem = dot > 0 ? leaf.substring(0, dot) : leaf;
    final extension = dot > 0 ? leaf.substring(dot) : '';
    var filename = leaf;
    for (int n = 2; has(base + filename); n++) {
      filename = '$stem-$n$extension';
    }
    if (leaf.isEmpty || leaf == '.' || leaf == '..')
      throw const FormatException('资源文件名无效');
    return filename;
  }

  void setSimpleWidth(double width) {
    if (current.format != BoardFormat.simple || !width.isFinite || width <= 0)
      return;
    current.size = Size(width, width / current.size.aspectRatio);
    sizes[entries[index]] = current.size;
  }

  void select(int i) {
    commit();
    _select(i);
  }

  void commit() {
    if (!current.dirty) return;
    final path = entries[index];
    changed[path] = current.bytes();
    if (current case final BlackboardPage page
        when page.supportsArtworkEditing) {
      pendingPreviews.add(path);
    } else if (_leaf(path) == 'actions.bin' &&
        (has('${_dir(path)}thumbnail.jpg') || has('${_dir(path)}header.bin'))) {
      pendingPreviews.add(path);
    }
  }

  // The two historical page headers use the same wire type for field 1.
  // With only that field and the notebook version as its value, keep a native
  // version-only header. Legacy durations with a distinct value are unambiguous.
  static Int64? _shortHeaderDuration(Uint8List data, int noteVersion) {
    final full = header.Header.fromBuffer(data);
    final version = full.version;
    full.clearVersion();
    if (full.writeToBuffer().isNotEmpty ||
        (version != 0 && version == noteVersion)) {
      return null;
    }
    return pagehead.PageHeader.fromBuffer(data).duration;
  }

  // A standalone PageHeader uses field 1 for duration. Dimensions distinguish
  // an original full page header when there is no notebook header to refer to.
  bool _hasFullPageHeader(String path) {
    if (!has(path)) return false;
    final page = header.Header.fromBuffer(read(path));
    return page.version > 0 && page.width > 0 && page.height > 0;
  }

  bool get canExportCloudNote => _completeNotes.containsKey(entries[index]);

  Map<String, Uint8List> _cloudUpdates(String root) {
    final updates = Map.of(changed);
    // The original recorder also writes notebooks containing only full per-page
    // headers. The cloud reader consumes those files as they are.
    if (!has('${root}header.bin')) {
      return updates;
    }
    final source = header.Header.fromBuffer(read('${root}header.bin'));
    final listed = pages.PageRouter.fromBuffer(
      read('${root}page_router.bin'),
    ).pageInfo;
    for (final entry in listed) {
      final path = '$root${entry.name}/header.bin';
      // Cloud Note reads a full EzyHeader.Header per page. A PageHeader uses
      // just field 1 for duration. Preserve full and extended header messages.
      final info = header.Header.fromBuffer(source.writeToBuffer());
      if (has(path)) {
        final bytes = read(path);
        final duration = _shortHeaderDuration(bytes, source.version);
        if (duration == null) continue;
        info.duration = duration;
      } else if (listed.length > 1) {
        info.clearDuration();
      }
      updates[path] = info.writeToBuffer();
    }
    return updates;
  }

  String get _cloudRoot =>
      _completeNotes[entries[index]] ?? (throw StateError('所选画板缺少完整页面索引'));

  Uint8List cloudNoteBytes() {
    commit();
    final root = _cloudRoot;
    // An existing page_mdb makes the native loader skip its BIN importer.
    return _zip(_cloudUpdates(root), omitDirectory: '${root}page_mdb');
  }

  Future<({Uint8List bytes, List<String> skipped})> export({
    required bool cloudCopy,
    required Future<Uint8List> Function(BlackboardPage) renderPreview,
    Future<Uint8List> Function(BoardFile, Uint8List?)? renderSketchThumbnail,
  }) async {
    commit();
    if (pendingPreviews.isEmpty) {
      return (
        bytes: cloudCopy ? cloudNoteBytes() : bytes(),
        skipped: <String>[],
      );
    }
    final root = cloudCopy ? _cloudRoot : null;
    // Rendering may yield to another edit. Freeze the selected export before
    // the first frame, including the resources used by all changed pages.
    final frozen = BoardArchive._(name, arch, _original)
      ..changed.addAll(root == null ? changed : _cloudUpdates(root))
      ..thumbnailActionCounts.addAll(thumbnailActionCounts)
      ..sizes.addAll(sizes);
    final skipped = <String>[];
    for (final path in pendingPreviews.toList()) {
      try {
        if (_leaf(path) == 'actions.bin') {
          if (renderSketchThumbnail == null)
            throw StateError('缺少 Sketch 预览绘制器');
          final dest = '${_dir(path)}thumbnail.jpg';
          frozen.changed[dest] = await renderSketchThumbnail(
            frozen._openBoard(path),
            frozen.has(dest) ? frozen.read(dest) : null,
          );
        } else {
          final page = BlackboardPage.load(frozen, path);
          frozen.changed['${page.dir}screenshot.png'] = await renderPreview(
            page,
          );
        }
      } catch (e) {
        skipped.add('$path ($e)');
      }
    }
    return (
      bytes: frozen._zip(
        frozen.changed,
        omitDirectory: root == null ? null : '${root}page_mdb',
      ),
      skipped: skipped,
    );
  }

  Uint8List bytes() {
    commit();
    return changed.isEmpty ? original : _zip(changed);
  }

  Uint8List _zip(Map<String, Uint8List> updates, {String? omitDirectory}) {
    bool omit(String path) =>
        omitDirectory != null &&
        (path == omitDirectory || path.startsWith('$omitDirectory/'));
    final output = Archive();
    for (final file in arch.files) {
      if (omit(file.name)) continue;
      final update = updates[file.name];
      output.addFile(
        update == null ? file : ArchiveFile(file.name, update.length, update),
      );
    }
    for (final entry in updates.entries) {
      if (!omit(entry.key) && arch.findFile(entry.key) == null) {
        output.addFile(ArchiveFile(entry.key, entry.value.length, entry.value));
      }
    }
    return Uint8List.fromList(ZipEncoder().encode(output)!);
  }
}

// Android stores the nine entries in row-major order, including perspective.
List<double> _matrix(mat.Matrix? m) => m == null
    ? [1, 0, 0, 0, 1, 0, 0, 0, 1]
    : [
        m.scaleX,
        m.skewX,
        m.transX,
        m.skewY,
        m.scaleY,
        m.transY,
        m.perSp0,
        m.perSp1,
        m.perSp2,
      ];
List<double> _mul(List<double> a, List<double> b) => List.generate(9, (i) {
  final r = i ~/ 3, c = i % 3;
  return a[r * 3] * b[c] + a[r * 3 + 1] * b[3 + c] + a[r * 3 + 2] * b[6 + c];
});
Offset _project(List<double> m, Offset p) {
  final w = m[6] * p.dx + m[7] * p.dy + m[8];
  if (w.abs() < 1e-10) throw const FormatException('图元矩阵无法投影');
  return Offset(
    (m[0] * p.dx + m[1] * p.dy + m[2]) / w,
    (m[3] * p.dx + m[4] * p.dy + m[5]) / w,
  );
}

List<double> _inverse(List<double> m) =>
    _tryInverse(m) ?? (throw const FormatException('当前页矩阵不可逆'));

List<double>? _tryInverse(List<double> m) {
  final a = m[0],
      b = m[1],
      c = m[2],
      d = m[3],
      e = m[4],
      f = m[5],
      g = m[6],
      h = m[7],
      i = m[8];
  final v = [
    e * i - f * h,
    c * h - b * i,
    b * f - c * e,
    f * g - d * i,
    a * i - c * g,
    c * d - a * f,
    d * h - e * g,
    b * g - a * h,
    a * e - b * d,
  ];
  final det = a * v[0] + b * v[3] + c * v[6];
  if (!det.isFinite || det.abs() < 1e-10) return null;
  return v.map((x) => x / det).toList();
}

class BlackboardPage extends BoardFile {
  BlackboardPage._(
    this.bundle,
    String path,
    page.PageSnapshot doc,
    Size size,
    Uint8List bytes,
  ) : super._(path, BoardFormat.pageSnapshot, doc, size, bytes);
  final BoardArchive bundle;
  BlackboardAudioTrack? _audioTrack;
  BlackboardReplay? _replay;
  page.PageSnapshot get doc => message as page.PageSnapshot;
  final _graphs =
      <(page.PageSnapshot_GraphSnapshot, page.PageSnapshot_GraphSnapshot)>[];
  String get dir => _dir(name);
  header.Header get previewHeader => _pageHeader();
  late header.BackgroundLineConfig paperLines;
  List<double> get camera =>
      _matrix(doc.hasCameraMatrix() ? doc.cameraMatrix : null);

  /// Bottom of DrawControl's child-graph union in the unscrolled page. Call
  /// after refresh(applyCamera: false); the unbounded root is never included.
  double get contentBottom {
    var bottom = 0.0;
    for (final ink in strokes) {
      for (final point in ink.points) {
        bottom = math.max(bottom, point.dy + ink.width);
      }
    }
    final geometryMargins = {
      for (final item in artwork)
        if (item.polygon != null) item._graph!: item.style.width / 2,
    };
    void visit(page.PageSnapshot_GraphSnapshot node) {
      if (node.graphEnum != ge.GraphEnum.STROKE_GRAPH &&
          node.graphEnum != ge.GraphEnum.BEELINE_STROKE_GRAPH) {
        final rect = node.outRect;
        if (rect.right > rect.left && rect.bottom > rect.top) {
          final matrix = _matrix(node.hasMatrix() ? node.matrix : null);
          final margin = geometryMargins[node] ?? 0.0;
          for (final x in [rect.left, rect.right]) {
            for (final y in [rect.top, rect.bottom]) {
              bottom = math.max(
                bottom,
                _project(matrix, Offset(x, y)).dy + margin,
              );
            }
          }
        }
      }
      node.childGraph.forEach(visit);
    }

    doc.graphSnapshot.childGraph.forEach(visit);
    return bottom;
  }

  static BlackboardPage load(BoardArchive bundle, String path) {
    final bytes = bundle.read(path), doc = page.PageSnapshot.fromBuffer(bytes);
    if (!doc.hasGraphSnapshot()) throw const FormatException('空快照没有根图元');
    final r = doc.graphSnapshot.outRect;
    final unbounded =
        r.left == -BoardArchive._rootLimit ||
        r.top == -BoardArchive._rootLimit ||
        r.right == BoardArchive._rootLimit ||
        r.bottom == BoardArchive._rootLimit;
    var size =
        bundle.sizes[path] ??
        (unbounded
            ? const Size(1200, 900)
            : Size(
                math.max(320, r.right - r.left),
                math.max(240, r.bottom - r.top),
              ));
    final pageHeader = '${_dir(path)}header.bin';
    if (bundle.has(pageHeader)) {
      final wire = header.Header.fromBuffer(bundle.read(pageHeader));
      if (wire.width > 0 && wire.height > 0) {
        size = Size(wire.width.toDouble(), wire.height.toDouble());
      }
    }
    final result = BlackboardPage._(bundle, path, doc, size, bytes);
    result.refresh();
    return result;
  }

  @override
  void refresh({bool applyCamera = true}) {
    strokes.clear();
    unrendered.clear();
    _replay = null;
    _graphs.clear();
    artwork.clear();
    final root = doc.graphSnapshot;
    background = root.hasBackgroundColor() ? root.backgroundColor : 0xffffffff;
    final meta = supportsArtworkEditing ? _pageHeader() : null;
    // SourceLoad builds a database entity with its default width (3 px).
    // Replay reads the full line config directly from each command instead.
    paperLines = header.BackgroundLineConfig.fromBuffer(
      meta?.lastBackgroundLineConfig.writeToBuffer() ?? const <int>[],
    )..lineWidth = 3;
    if (meta != null &&
        (meta.hasLastBackgroundColor() ||
            bundle._hasFullPageHeader('${dir}header.bin') ||
            (meta.width > 0 &&
                meta.height > 0 &&
                !root.hasBackgroundColor()))) {
      background = meta.lastBackgroundColor;
    }
    final camera = _matrix(
      applyCamera && doc.hasCameraMatrix() ? doc.cameraMatrix : null,
    );
    void visit(
      page.PageSnapshot_GraphSnapshot g,
      page.PageSnapshot_GraphSnapshot parent,
    ) {
      // Native concatMatrix propagates page-space changes into each child.
      final xform = _mul(camera, _matrix(g.hasMatrix() ? g.matrix : null));
      if (g.graphEnum == ge.GraphEnum.STROKE_GRAPH ||
          g.graphEnum == ge.GraphEnum.BEELINE_STROKE_GRAPH) {
        final path = dir + g.sourceFileName;
        if (!bundle.has(path)) {
          unrendered.add('缺少 ${g.sourceFileName}');
          return;
        }
        final items = src.TouchSource.fromBuffer(bundle.read(path)).touchInfo;
        if (g.sourceId < 0 || g.sourceId >= items.length) {
          unrendered.add('无效笔迹索引');
          return;
        }
        final item = items[g.sourceId];
        final points = item.touchEvent
            .map((t) => _project(xform, Offset(t.x, t.y)))
            .toList();
        // StrokeGraph transforms its Path, then draws with the original width.
        strokes.add(
          Ink(
            points,
            item.paint.color,
            item.paint.width,
            boardPaint: item.paint,
          ),
        );
        _graphs.add((g, parent));
      } else if (g.graphEnum == ge.GraphEnum.TEXT_GRAPH ||
          g.graphEnum == ge.GraphEnum.IMAGE_GRAPH ||
          g.graphEnum == ge.GraphEnum.GEOMETRY_GRAPH) {
        final artworkItem = _readArtwork(g, xform);
        if (artworkItem != null) {
          artworkItem._graph = g;
          artworkItem._parent = parent;
          artwork.add(artworkItem);
        }
      } else if (g.graphEnum != ge.GraphEnum.GROUP_GRAPH &&
          g.graphEnum != ge.GraphEnum.BOUNDED_CONTAINER_GRAPH) {
        unrendered.add(g.graphEnum.name);
      }
      for (final child in g.childGraph) {
        visit(child, g);
      }
    }

    visit(root, root);
  }

  PageArtwork? _readArtwork(
    page.PageSnapshot_GraphSnapshot g,
    List<double> matrix,
  ) {
    final r = g.outRect;
    final bounds = Rect.fromLTRB(r.left, r.top, r.right, r.bottom);
    final chunkPath = dir + g.sourceFileName;
    final chunk = g.sourceFileName.isNotEmpty && bundle.has(chunkPath)
        ? bundle.read(chunkPath)
        : null;
    final result = PageArtwork(strokes.length, matrix, bounds, g.paint);
    T? item<T>(List<T> items) =>
        g.sourceId >= 0 && g.sourceId < items.length ? items[g.sourceId] : null;
    if (g.graphEnum == ge.GraphEnum.TEXT_GRAPH) {
      final info = chunk == null
          ? null
          : item(src.TextSource.fromBuffer(chunk).textInfo);
      result.text = g.content.isNotEmpty ? g.content : info?.content;
      if (!g.hasPaint() && info != null) result.style = info.paint;
      if (result.text != null) return result;
    } else if (g.graphEnum == ge.GraphEnum.IMAGE_GRAPH) {
      final info = chunk == null
          ? null
          : item(src.FileSource.fromBuffer(chunk).fileInfo);
      final filename = g.filePath.isNotEmpty ? g.filePath : info?.name;
      if (filename != null) {
        final root = dir.isEmpty ? '' : _dir(dir.substring(0, dir.length - 1));
        final path = '${root}res/image/$filename';
        if (bundle.has(path)) {
          result.imageName = filename;
          result.image = bundle.read(path);
          return result;
        }
      }
    } else {
      final info = chunk == null
          ? null
          : item(src.GeometrySource.fromBuffer(chunk).geometryInfo);
      if (info != null) {
        if (!g.hasPaint()) result.style = info.paint;
        final points = g.pointList.isEmpty ? info.points : g.pointList;
        result.oval = info.geometryType.value == 0;
        result.polygon = points.map((p) => Offset(p.x, p.y)).toList();
        return result;
      }
    }
    unrendered.add('缺少 ${g.graphEnum.name} 资源');
    return null;
  }

  /// Native FileValidateUtils uses positive BigInteger hex padded to a minimum of 32.
  void _writeRecord<T extends GeneratedMessage>(
    String filename,
    T record,
    List<router.RouterRecord_SourceCommandRecord> refs,
  ) {
    final bytes = record.writeToBuffer();
    bundle.changed[dir + filename] = bytes;
    final ref =
        refs.where((r) => r.fileName == filename).firstOrNull ??
        router.RouterRecord_SourceCommandRecord(fileName: filename);
    ref.validate = _signature(bytes);
    if (!refs.contains(ref)) refs.add(ref);
  }

  static String _signature(Uint8List bytes) => sha256
      .convert(bytes)
      .toString()
      .replaceFirst(RegExp('^0+'), '')
      .padLeft(32, '0');

  String _nextName(String suffix) {
    var stamp = DateTime.now().millisecondsSinceEpoch;
    while (bundle.has('$dir${stamp}_$suffix.bin')) {
      stamp++;
    }
    return '${stamp}_$suffix.bin';
  }

  @override
  void draw(Ink ink) {
    if (ink.points.isEmpty) return;
    final root = doc.graphSnapshot;
    final routerPath = '${dir}router.bin';
    final refs = bundle.has(routerPath)
        ? router.RouterRecord.fromBuffer(bundle.read(routerPath))
        : router.RouterRecord();
    // Native V6 records the pen interval even when editing outside playback.
    // Only strokes created during a recording consume time on its timeline.
    final v6 = supportsArtworkEditing;
    final command = cmd.CommandSource_CommandInfo(isPlay: !v6);
    if (ink.erase) {
      final removed = cmd.CommandSource_CommandInfo_GraphRemove();
      for (var i = strokes.length - 1; i >= 0; i--) {
        if (!ink.points.any(
          (p) => strokes[i].points.any((q) => (p - q).distance <= ink.width),
        ))
          continue;
        final (g, parent) = _graphs[i];
        removed.graphData.add(
          cmd.CommandSource_CommandInfo_GraphData(
            graphId: g.id,
            parentGraphId: parent.id,
            graphEnum: g.graphEnum,
            outRect: g.outRect,
            sourceFileName: g.sourceFileName,
            sourceId: g.sourceId,
          ),
        );
        parent.childGraph.remove(g);
      }
      if (removed.graphData.isEmpty) return;
      command
        ..commandEnum = ce.CommandEnum.ACTION_GRAPH_REMOVE
        ..data = removed.writeToBuffer();
    } else {
      final inv = _inverse(
        _matrix(doc.hasCameraMatrix() ? doc.cameraMatrix : null),
      );
      final local = ink.points.map((p) => _project(inv, p)).toList();
      if (local.length == 1) local.add(local.first);
      final bounds = rect.RectF(
        left: local.map((p) => p.dx).reduce(math.min),
        top: local.map((p) => p.dy).reduce(math.min),
        right: local.map((p) => p.dx).reduce(math.max),
        bottom: local.map((p) => p.dy).reduce(math.max),
      );
      final filename = _nextName('touch');
      final info = src.TouchSource_TouchInfo(
        paint: paint.Paint(
          width: ink.width,
          color: ink.argb.toSigned(32),
          style: 1,
        ),
      );
      final timestamps = ink.eventTimes;
      final clock = timestamps != null && timestamps.length == ink.points.length
          ? timestamps
          : null;
      int timeAt(int index) =>
          clock == null ? index * 8 : clock[math.min(index, clock.length - 1)];
      for (var i = 0; i < local.length; i++) {
        final p = local[i];
        if (v6) {
          info.touchEvent.add(
            touch.TouchEvent(eventTime: Int64(timeAt(i)), x: p.dx, y: p.dy),
          );
          continue;
        }
        info.touchEvent.add(
          touch.TouchEvent(
            eventTime: Int64(timeAt(i)),
            action: i == 0
                ? 0
                : i == local.length - 1
                ? 1
                : 2,
            x: p.dx,
            y: p.dy,
            pointerCount: 1,
            pointerProperties: [
              touch.TouchEvent_PointerProperties(id: 0, toolType: 2),
            ],
            pointerCoords: [touch.TouchEvent_PointerCoords(x: p.dx, y: p.dy)],
          ),
        );
      }
      _writeRecord(
        filename,
        src.TouchSource(touchInfo: [info]),
        refs.touchSourceRecord,
      );
      final graph = page.PageSnapshot_GraphSnapshot(
        id: 'web-${filename.split("_").first}',
        graphEnum: ge.GraphEnum.STROKE_GRAPH,
        outRect: bounds,
        matrix: mat.Matrix(scaleX: 1, scaleY: 1, perSp2: 1),
        sourceFileName: filename,
        sourceId: 0,
      );
      root.childGraph.add(graph);
      command
        ..commandEnum = ce.CommandEnum.ACTION_GRAPH_ADD
        ..duration = Int64(timeAt(local.length - 1) - timeAt(0))
        ..data = cmd.CommandSource_CommandInfo_GraphData(
          graphId: graph.id,
          graphEnum: graph.graphEnum,
          parentGraphId: root.id,
          outRect: bounds,
          sourceFileName: filename,
          sourceId: 0,
        ).writeToBuffer();
    }
    _writeRecord(
      _nextName('command'),
      cmd.CommandSource(commandInfo: [command]),
      refs.commandRecord,
    );
    bundle.changed[routerPath] = refs.writeToBuffer();
    dirty = true;
    refresh();
  }
}

/// Non-stroke elements keep their native position in the graph traversal.
class PageArtwork {
  PageArtwork(this.beforeStroke, this.transform, this.bounds, this.style);
  page.PageSnapshot_GraphSnapshot? _graph, _parent;
  String get id => _graph?.id ?? '';
  bool get editable =>
      _graph != null && (text != null || polygon != null || image != null);
  String get label => text != null
      ? '文字 · ${text!.isEmpty ? id : text}'
      : image != null
      ? '图片 · $imageName'
      : '${oval ? "椭圆" : "多边形"} · $id';
  final int beforeStroke;
  final List<double> transform;
  final Rect bounds;
  paint.Paint style;
  String? text;
  String? imageName;
  Uint8List? image;
  bool containsImagePoint(Offset boardPoint) {
    if (image == null) return false;
    try {
      return bounds.contains(_project(_inverse(transform), boardPoint));
    } on FormatException {
      return false;
    }
  }

  SketchBitmap? sketchBitmap;
  SketchPresentation? presentation;
  bool oval = false;
  List<Offset>? polygon;
}

// Locate the image dimensions without decoding its pixels on each page switch.
// VP8X holds the full canvas size, including for animated WebP.
Size? _webpSize(Uint8List b) {
  if (b.length < 20 ||
      String.fromCharCodes(b.take(4)) != 'RIFF' ||
      String.fromCharCodes(b.sublist(8, 12)) != 'WEBP')
    return null;
  final input = ByteData.sublistView(b);
  int u24(int p) => b[p] | b[p + 1] << 8 | b[p + 2] << 16;
  for (int pos = 12; pos + 8 <= b.length;) {
    final type = String.fromCharCodes(b.sublist(pos, pos + 4));
    final length = input.getUint32(pos + 4, Endian.little);
    final body = pos + 8;
    if (length > b.length - body) return null;
    if (type == 'VP8X' && length >= 10)
      return Size(
        (u24(body + 4) + 1).toDouble(),
        (u24(body + 7) + 1).toDouble(),
      );
    if (type == 'VP8L' && length >= 5 && b[body] == 0x2f) {
      final dimensions = input.getUint32(body + 1, Endian.little);
      return Size(
        ((dimensions & 0x3fff) + 1).toDouble(),
        (((dimensions >> 14) & 0x3fff) + 1).toDouble(),
      );
    }
    if (type == 'VP8 ' && length >= 10 && u24(body + 3) == 0x2a019d) {
      final w = input.getUint16(body + 6, Endian.little) & 0x3fff;
      final h = input.getUint16(body + 8, Endian.little) & 0x3fff;
      if (w > 0 && h > 0) return Size(w.toDouble(), h.toDouble());
    }
    pos = body + length + length % 2;
  }
  return null;
}
