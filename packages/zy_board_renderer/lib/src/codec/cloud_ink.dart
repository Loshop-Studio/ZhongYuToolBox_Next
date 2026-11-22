part of 'board_file.dart';

typedef _ScalarEdit = ({int offset, int before, int after});

/// Project the current MDB page through the same graph and ink renderer used
/// for Blackboard. The generated protobufs are transient resource views.
class CloudInkDocument {
  CloudInkDocument(Uint8List bytes, {this.member = '', this.archive})
    : store = CloudMdbStore.read(bytes);
  final CloudMdbStore store;
  final String member;
  final Archive? archive;
  final _undo = <List<_ScalarEdit>>[], _redo = <List<_ScalarEdit>>[];
  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;
  List<MdbRow> get pages => store.rows['PageEntity']!.values.toList();
  final sources = <(String, int), MdbRow>{};
  late BlackboardPage board;
  String? notice;

  Iterable<MdbRow> _records(String type, int record) => record == 0
      ? const []
      : (store.rows[type]?.values ?? const <MdbRow>[]).where(
          (r) => r.long('recordId') == record,
        );

  void openPage(int index) {
    final pageRow = pages[index];
    final pageName = pageRow.string('dirName') ?? '';
    final path = member.endsWith('page_mdb/data.mdb')
        ? member.substring(0, member.length - 'page_mdb/data.mdb'.length)
        : '';
    final snapshot = pageName.isEmpty
        ? null
        : archive?.findFile('$path$pageName/snapshot.bin');
    final info = store.rows['HeaderEntity']?[pageRow.long('headerEntityId')];
    final width = info?.int32('width') ?? 0,
        height = info?.int32('height') ?? 0;
    final size = Size(
      width > 0 ? width.toDouble() : 1200,
      height > 0 ? height.toDouble() : 900,
    );
    final bundle = BoardArchive._(member, Archive(), null);
    final meta = header.Header(
      version: 6,
      width: size.width.toInt(),
      height: size.height.toInt(),
      lastBackgroundColor: info?.int32('lastBackgroundColor') ?? -1,
    );
    bundle.changed['p/header.bin'] = meta.writeToBuffer();
    final record = pageRow.long('recordEntityId');
    sources.clear();
    notice = null;
    final groups = <String, List<MdbRow>>{};
    for (final chunk in _records('TouchRecordEntity', record)) {
      final name = chunk.string('fileName');
      if (name == null || name.isEmpty) continue;
      final events = store.children(chunk, 'TouchEventEntity');
      groups[name] = events;
      final touchSource = src.TouchSource();
      for (final event in events) {
        sources[(name, touchSource.touchInfo.length)] = event;
        touchSource.touchInfo.add(
          src.TouchSource_TouchInfo(
            paint: paint.Paint(
              color: event.int32('color'),
              width: event.real('width'),
              style: event.int32('style'),
              spacing: event.real('spacing'),
              itemLength: event.real('itemLength'),
              textSize: event.real('textSize'),
            ),
            touchEvent: store
                .children(event, 'TouchInfoEntity')
                .map(
                  (p) => touch.TouchEvent(
                    x: p.real('x'),
                    y: p.real('y'),
                    eventTime: Int64(p.long('eventTime')),
                  ),
                ),
          ),
        );
      }
      bundle.changed['p/$name'] = touchSource.writeToBuffer();
    }
    final doc = page.PageSnapshot(
      graphSnapshot: _Graph(id: '', graphEnum: ge.GraphEnum.GROUP_GRAPH),
    );
    board = BlackboardPage._(bundle, 'p/snapshot.bin', doc, size, Uint8List(0));
    bool restored = false;
    if (snapshot != null && snapshot.size > 0) {
      try {
        final saved = page.PageSnapshot.fromBuffer(snapshot.content);
        final m = _matrix(saved.cameraMatrix);
        // BasePageControl.show replays an empty graph or an unusable camera.
        if (saved.graphSnapshot.childGraph.isNotEmpty &&
            m.every((x) => x.isFinite) &&
            m[8].abs() >= 0.0001 &&
            m[0] * m[0] + m[3] * m[3] >= 1e-8 &&
            m[1] * m[1] + m[4] * m[4] >= 1e-8 &&
            _tryInverse(m) != null) {
          doc.mergeFromMessage(saved);
          restored = true;
        }
      } on InvalidProtocolBufferException {
        notice = '页面快照无法读取，已从 MDB 命令恢复';
      }
    }
    if (!restored || pageRow.flag('isChange')) {
      for (final chunk in _records('MatrixRecordEntity', record)) {
        final filename = chunk.string('fileName');
        if (filename == null) continue;
        final matrixSource = src.MatrixSource(
          matrixInfo: store
              .children(chunk, 'MatrixEventEntity')
              .map(
                (event) => src.MatrixSource_MatrixInfo(
                  matrix: store
                      .children(event, 'MatrixInfoEntity')
                      .map(
                        (p) => mat.Matrix(
                          scaleX: p.real('scaleX'),
                          scaleY: p.real('scaleY'),
                          skewX: p.real('skewX'),
                          skewY: p.real('skewY'),
                          transX: p.real('transX'),
                          transY: p.real('transY'),
                          perSp0: p.real('perSp0'),
                          perSp1: p.real('perSp1'),
                          perSp2: p.real('perSp2'),
                          eventTime: Int64(p.long('eventTime')),
                        ),
                      ),
                ),
              ),
        );
        bundle.changed['p/$filename'] = matrixSource.writeToBuffer();
      }
      final player = BlackboardReplay._(board);
      bool graphHistory = restored, hasCommands = false;
      bool waitingForCursor = restored;
      for (final chunk in _records('CommandRecordEntity', record)) {
        var first = 0;
        if (waitingForCursor) {
          if (chunk.string('fileName') != pageRow.string('commandFileName'))
            continue;
          first = math.max(0, pageRow.int32('commandIndex'));
          waitingForCursor = false;
        }
        for (final entry
            in store.children(chunk, 'CommandInfoEntity').skip(first)) {
          hasCommands = true;
          final kind = ce.CommandEnum.valueOf(entry.int32('commandEnum'));
          if (kind == null) continue;
          final visual = _decodeVisual(kind, entry.blob('data'));
          if (visual == null) continue;
          if (visual is cmd.CommandSource_CommandInfo_GraphData) {
            // Some imported pages start at the first stroke, with an implicit root.
            if (!graphHistory && visual.parentGraphId.isNotEmpty)
              doc.graphSnapshot.id = visual.parentGraphId;
            graphHistory = true;
          }
          if (visual is cmd.CommandSource_CommandInfo_REBUILD ||
              visual is cmd.CommandSource_CommandInfo_GraphRemove)
            graphHistory = true;
          player._apply(board, visual);
        }
      }
      if (!restored && !hasCommands && groups.isNotEmpty) {
        notice = '缺少页面图元记录，显示库内保存的采样笔迹';
        for (final group in groups.entries) {
          for (var i = 0; i < group.value.length; i++) {
            doc.graphSnapshot.childGraph.add(
              _Graph(
                graphEnum: ge.GraphEnum.STROKE_GRAPH,
                sourceFileName: group.key,
                sourceId: i,
              ),
            );
          }
        }
      }
    }
    board.refresh();
  }

  MdbRow eventAt(int stroke) {
    final graph = board._graphs[stroke].$1;
    return sources[(graph.sourceFileName, graph.sourceId)]!;
  }

  // Smooth inside the original stroke's convex hull. This retains its native
  // bounding rectangle, endpoints, timing, source index and graph transforms.
  void edit(
    int stroke, {
    int? color,
    double? width,
    bool smooth = false,
    (int, Offset)? movePoint,
  }) {
    final event = eventAt(stroke);
    if (store.shared('TouchRecordEntity', event))
      throw const FormatException('这笔数据被多个记录引用，无法单独修改');

    final data = ByteData.sublistView(store.bytes);
    final edits = <int, _ScalarEdit>{};
    void change(MdbRow row, String field, int bits) {
      if (row.type == 'TouchInfoEntity' &&
          store.shared('TouchEventEntity', row))
        throw const FormatException('此采样点被多笔共用，无法单独移动');
      final offset = row.scalarOffset(field);
      final before = data.getUint32(offset, Endian.little);
      if (before != bits)
        edits[offset] = (offset: offset, before: before, after: bits);
    }

    int floatBits(double n) => (ByteData(
      4,
    )..setFloat32(0, n, Endian.little)).getUint32(0, Endian.little);
    if (color != null) change(event, 'color', color.toUnsigned(32));
    if (width != null && width.isFinite && width > 0)
      change(event, 'width', floatBits(width));
    if (smooth) {
      final points = store.children(event, 'TouchInfoEntity');
      for (int i = 1; i + 1 < points.length; i++) {
        for (final axis in ['x', 'y']) {
          final n =
              (points[i - 1].real(axis) +
                  2 * points[i].real(axis) +
                  points[i + 1].real(axis)) /
              4;
          change(points[i], axis, floatBits(n));
        }
      }
    }
    if (movePoint != null) {
      final points = store.children(event, 'TouchInfoEntity');
      final graph = board._graphs[stroke].$1;
      final transform = _mul(
        board.camera,
        _matrix(graph.hasMatrix() ? graph.matrix : null),
      );
      final raw = _project(_inverse(transform), movePoint.$2);
      final x = points[movePoint.$1];
      final r = graph.outRect;
      final bounds =
          graph.hasOutRect() && r.right >= r.left && r.bottom >= r.top
          ? Rect.fromLTRB(r.left, r.top, r.right, r.bottom)
          : points
                .map((p) => Offset(p.real('x'), p.real('y')))
                .map((p) => Rect.fromPoints(p, p))
                .reduce((a, b) => a.expandToInclude(b));
      change(x, 'x', floatBits(raw.dx.clamp(bounds.left, bounds.right)));
      change(x, 'y', floatBits(raw.dy.clamp(bounds.top, bounds.bottom)));
    }
    if (edits.isEmpty) return;
    final batch = edits.values.toList();
    _write(batch, true);
    _redo.clear();
    _undo.add(batch);
  }

  void _write(List<_ScalarEdit> batch, bool forward) {
    final data = ByteData.sublistView(store.bytes);
    for (final e in batch) {
      data.setUint32(e.offset, forward ? e.after : e.before, Endian.little);
    }
  }

  void undo() {
    if (!canUndo) return;
    final batch = _undo.removeLast();
    _write(batch, false);
    _redo.add(batch);
  }

  void redo() {
    if (!canRedo) return;
    final batch = _redo.removeLast();
    _write(batch, true);
    _undo.add(batch);
  }
}
