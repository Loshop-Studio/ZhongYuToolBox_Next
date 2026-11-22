part of 'board_file.dart';

typedef _Graph = page.PageSnapshot_GraphSnapshot;

class _VisualCommand {
  _VisualCommand(this.start, this.seekGate, this.end, this.data);
  final int start, seekGate, end;
  final GeneratedMessage data;
}

GeneratedMessage? _decodeVisual(
  ce.CommandEnum kind,
  List<int> bytes,
) => switch (kind) {
  ce.CommandEnum.ACTION_GRAPH_ADD =>
    cmd.CommandSource_CommandInfo_GraphData.fromBuffer(bytes),
  ce.CommandEnum.ACTION_GRAPH_REMOVE =>
    cmd.CommandSource_CommandInfo_GraphRemove.fromBuffer(bytes),
  ce.CommandEnum.ACTION_GRAPH_CHANGE =>
    cmd.CommandSource_CommandInfo_GraphChange.fromBuffer(bytes),
  ce.CommandEnum.ACTION_GRAPH_MATRIX =>
    cmd.CommandSource_CommandInfo_GraphMatrix.fromBuffer(bytes),
  ce.CommandEnum.ACTION_CAMERA =>
    cmd.CommandSource_CommandInfo_Camera.fromBuffer(bytes),
  ce.CommandEnum.ACTION_CAMERA_MATRIX =>
    cmd.CommandSource_CommandInfo_CameraMatrix.fromBuffer(bytes),
  ce.CommandEnum.ACTION_CONFIG =>
    cmd.CommandSource_CommandInfo_Config.fromBuffer(bytes),
  ce.CommandEnum.ACTION_REBUILD =>
    cmd.CommandSource_CommandInfo_REBUILD.fromBuffer(bytes),
  ce.CommandEnum.ACTION_CURSOR_MOVE =>
    cmd.CommandSource_CommandInfo_CursorMove.fromBuffer(bytes),
  _ =>
    null, // RECORD_STOP and the custom command have no persisted graph effect.
};

extension BlackboardRecording on BlackboardPage {
  BlackboardReplay get replay => _replay ??= BlackboardReplay._(this);
}

/// Replays the V6 drawing stream into a private graph tree. The editable
/// snapshot and the audio stream have separate native lifetimes.
class BlackboardReplay {
  BlackboardReplay._(this.owner) {
    try {
      _load();
    } on Exception catch (e) {
      issue = '画面回放无法读取 · $e';
    }
  }
  final BlackboardPage owner;
  final _commands = <_VisualCommand>[];
  String? issue;
  bool _anchored = false, _timed = false;
  int _clockEnd = 0, _lastGate = 0;
  bool get available =>
      owner.pageAudio.durationMs > 0 && _anchored && _timed && issue == null;
  late BlackboardPage _scene;
  int _index = 0, _last = -1, _paper = -1;
  late header.BackgroundLineConfig _lines;
  late List<double> _paperCamera;
  bool? _seekMode;
  BoardFrame? _base;
  final _touch = <String, src.TouchSource>{};
  final _matrices = <String, src.MatrixSource>{};

  void _load() {
    if (!owner.supportsArtworkEditing) return;
    final path = '${owner.dir}router.bin';
    if (!owner.bundle.has(path)) return;
    final refs = router.RouterRecord.fromBuffer(owner.bundle.read(path));
    int clock = 0, lastGate = 0;
    for (final ref in refs.commandRecord) {
      final chunk = cmd.CommandSource.fromBuffer(
        owner.bundle.read(owner.dir + ref.fileName),
      );
      for (final command in chunk.commandInfo) {
        final delay = command.delayTime.toInt(),
            duration = command.duration.toInt();
        final start = clock + (command.isPlay ? delay : 0);
        final seekGate = math.max(lastGate, clock + delay);
        if (command.isPlay && (delay < 0 || duration < 0)) {
          issue = '画面命令含重叠时间，当前显示页面快照';
          return;
        }
        lastGate = seekGate;
        final end = start + (command.isPlay ? duration : 0);
        if (command.isPlay) clock = end;
        _clockEnd = clock;
        _lastGate = lastGate;
        final data = _decodeVisual(command.commandEnum, command.data);
        if (data == null) continue;
        if (_commands.isEmpty || !_anchored) {
          if (data is cmd.CommandSource_CommandInfo_REBUILD ||
              (data is cmd.CommandSource_CommandInfo_GraphData &&
                  data.parentGraphId.trim().isEmpty)) {
            _anchored = true;
          } else if (data is! cmd.CommandSource_CommandInfo_Config &&
              data is! cmd.CommandSource_CommandInfo_Camera) {
            issue = '缺少回放起始图元，当前显示页面快照';
            return;
          }
        }
        if (start > 0 || end > 0 || seekGate > 0) _timed = true;
        _commands.add(_VisualCommand(start, seekGate, end, data));
      }
    }
  }

  void _reset() {
    _scene = BlackboardPage._(
      owner.bundle,
      owner.name,
      page.PageSnapshot(),
      owner.size,
      Uint8List(0),
    );
    _index = 0;
    final header = owner._pageHeader();
    // BasePlayPageControl.show sets the paper grid to the snapshot camera.
    // seekTo resets the ink camera, while CameraExecute redraws only the ink.
    _paperCamera = owner.camera;
    _lines = header.defaultBackgroundLineConfig;
    _paper = header.defaultBackgroundColor;
    _base = null;
  }

  _Graph? _find(_Graph node, String id) {
    if (node.id == id) return node;
    for (final child in node.childGraph) {
      final match = _find(child, id);
      if (match != null) return match;
    }
    return null;
  }

  void _remove(_Graph from, Set<String> ids) {
    from.childGraph.removeWhere((g) => ids.contains(g.id));
    for (final child in from.childGraph) {
      _remove(child, ids);
    }
  }

  src.TouchSource_TouchInfo? _points(String file, int id) {
    if (file.isEmpty || !owner.bundle.has(owner.dir + file)) return null;
    final rows = _touch
        .putIfAbsent(
          file,
          () => src.TouchSource.fromBuffer(owner.bundle.read(owner.dir + file)),
        )
        .touchInfo;
    return id >= 0 && id < rows.length ? rows[id] : null;
  }

  List<mat.Matrix> _matrixEvents(String file, int id) {
    if (file.isEmpty || !owner.bundle.has(owner.dir + file)) return [];
    final rows = _matrices
        .putIfAbsent(
          file,
          () =>
              src.MatrixSource.fromBuffer(owner.bundle.read(owner.dir + file)),
        )
        .matrixInfo;
    return id >= 0 && id < rows.length ? rows[id].matrix : [];
  }

  void _apply(BlackboardPage scene, GeneratedMessage data) {
    final doc = scene.doc, root = scene.doc.graphSnapshot;
    switch (data) {
      case cmd.CommandSource_CommandInfo_GraphData():
        final node = _Graph(
          id: data.graphId,
          graphEnum: data.graphEnum,
          outRect: data.outRect,
          sourceFileName: data.sourceFileName,
          sourceId: data.sourceId,
        );
        if (data.parentGraphId.trim().isEmpty) {
          doc.graphSnapshot = node;
        } else if (data.graphEnum == ge.GraphEnum.IMAGE_GRAPH &&
            data.extras.contains('imageBackground')) {
          final index = root.childGraph.lastIndexWhere(
            (g) => g.graphEnum == ge.GraphEnum.IMAGE_GRAPH,
          );
          root.childGraph.insert(index < 0 ? 0 : index, node);
        } else {
          _find(root, data.parentGraphId)?.childGraph.add(node);
        }
      case cmd.CommandSource_CommandInfo_GraphRemove():
        _remove(root, data.graphData.map((g) => g.graphId).toSet());
      case cmd.CommandSource_CommandInfo_GraphChange():
        final node = root.childGraph
            .where((g) => g.id == data.graphId)
            .firstOrNull;
        if (node == null) return;
        final kind = node.graphEnum;
        if (data.hasOutRect() &&
            [
              ge.GraphEnum.TEXT_GRAPH,
              ge.GraphEnum.GEOMETRY_GRAPH,
              ge.GraphEnum.IMAGE_GRAPH,
            ].contains(kind))
          node.outRect = data.outRect;
        if (kind == ge.GraphEnum.TEXT_GRAPH && data.content.trim().isNotEmpty)
          node.content = data.content;
        if ((kind == ge.GraphEnum.TEXT_GRAPH ||
                kind == ge.GraphEnum.GEOMETRY_GRAPH) &&
            data.hasPaint())
          node.paint = data.paint;
        if (kind == ge.GraphEnum.GEOMETRY_GRAPH && data.points.isNotEmpty)
          node.pointList
            ..clear()
            ..addAll(data.points);
        if (kind == ge.GraphEnum.IMAGE_GRAPH) {
          if (data.hasRenderMatrix()) node.matrix = data.renderMatrix;
          if (data.filePath.trim().isNotEmpty) node.filePath = data.filePath;
        }
      case cmd.CommandSource_CommandInfo_GraphMatrix():
        final delta = _matrixEvents(
          data.sourceFileName,
          data.sourceId,
        ).lastOrNull;
        if (delta != null) _move(root, data, delta);
      case cmd.CommandSource_CommandInfo_Camera():
        doc.cameraMatrix = data.lastMatrix;
      case cmd.CommandSource_CommandInfo_CameraMatrix():
        doc.cameraMatrix = data.lastMatrix;
        if (_seekMode == false) _paperCamera = _matrix(data.lastMatrix);
      case cmd.CommandSource_CommandInfo_Config():
        _paper = data.lastBackground;
        _lines = data.lastBackgroundLineConfig;
      case cmd.CommandSource_CommandInfo_REBUILD():
        doc.graphSnapshot = page.PageSnapshot_GraphSnapshot.fromBuffer(
          data.snapshot.writeToBuffer(),
        );
        _paper = data.backgroundColor;
        _lines = data.backgroundLineConfig;
    }
  }

  void _move(
    _Graph root,
    cmd.CommandSource_CommandInfo_GraphMatrix data,
    mat.Matrix delta,
  ) {
    for (final ref in data.graphData) {
      final node = _find(root, ref.graphId);
      if (node != null) _transformGraph(node, delta);
    }
  }

  BoardFrame _frame(
    BlackboardPage scene, {
    List<double>? paperCamera,
    CameraInkLayer? cameraInkLayer,
  }) {
    scene.refresh();
    return BoardFrame(
      List.of(scene.strokes),
      _paper,
      List.of(scene.artwork),
      paperLines: _lines,
      paperCamera: paperCamera ?? _paperCamera,
      cameraInkLayer: cameraInkLayer,
    );
  }

  BoardFrame seek(int ms, {bool direct = true}) {
    if (!available) throw StateError(issue ?? '页面没有可回放的画面命令');
    if (_last < 0 || ms < _last || direct != _seekMode) _reset();
    _last = ms;
    _seekMode = direct;
    while (_index < _commands.length) {
      final command = _commands[_index];
      final data = command.data;
      if (ms < (direct ? command.seekGate : command.start)) break;
      if (ms < command.end &&
          (data is cmd.CommandSource_CommandInfo_GraphData ||
              data is cmd.CommandSource_CommandInfo_CursorMove ||
              data is cmd.CommandSource_CommandInfo_GraphMatrix ||
              data is cmd.CommandSource_CommandInfo_CameraMatrix)) {
        return _partial(data, ms - command.start);
      }
      _apply(_scene, data);
      _base = null;
      _index++;
    }
    return _base ??= _frame(_scene);
  }

  BoardFrame _partial(GeneratedMessage data, int time) {
    final base = _base ??= _frame(_scene);
    if (data is cmd.CommandSource_CommandInfo_GraphData ||
        data is cmd.CommandSource_CommandInfo_CursorMove) {
      final cursor = data is cmd.CommandSource_CommandInfo_CursorMove;
      final info = cursor
          ? _points(data.sourceFileName, data.sourceId)
          : _points(
              (data as cmd.CommandSource_CommandInfo_GraphData).sourceFileName,
              data.sourceId,
            );
      if (info == null || info.touchEvent.isEmpty) return base;
      final first = info.touchEvent.first.eventTime.toInt();
      final points = info.touchEvent.takeWhile(
        (p) => p.eventTime.toInt() - first <= time,
      );
      if (points.isEmpty || (!cursor && points.length == 1)) return base;
      final camera = _matrix(
        _scene.doc.hasCameraMatrix() ? _scene.doc.cameraMatrix : null,
      );
      if (cursor) {
        final p = points.last;
        return BoardFrame(
          base.strokes,
          base.background,
          base.artwork,
          paperCamera: base.paperCamera,
          paperLines: base.paperLines,
          cursor: PageCursor(Offset(p.x, p.y), camera, info.paint),
        );
      }
      final ink = Ink(
        points.map((p) => _project(camera, Offset(p.x, p.y))).toList(),
        info.paint.color,
        info.paint.width,
        unfinishedPath: true,
        boardPaint: info.paint,
      );
      return BoardFrame(
        [...base.strokes, ink],
        base.background,
        base.artwork,
        paperLines: base.paperLines,
        paperCamera: base.paperCamera,
      );
    }
    final graph = data is cmd.CommandSource_CommandInfo_GraphMatrix;
    final events = graph
        ? _matrixEvents(data.sourceFileName, data.sourceId)
        : _matrixEvents(
            (data as cmd.CommandSource_CommandInfo_CameraMatrix).sourceFileName,
            data.sourceId,
          );
    if (events.isEmpty) return base;
    final reached = events
        .takeWhile(
          (m) => m.eventTime.toInt() - events.first.eventTime.toInt() <= time,
        )
        .lastOrNull;
    if (reached == null ||
        (identical(reached, events.first) && (graph || events.length > 1)))
      return base;
    final preview = BlackboardPage._(
      owner.bundle,
      owner.name,
      page.PageSnapshot.fromBuffer(_scene.doc.writeToBuffer()),
      owner.size,
      Uint8List(0),
    );
    if (graph) {
      _move(preview.doc.graphSnapshot, data, reached);
    } else {
      final camera = preview.doc.hasCameraMatrix()
          ? preview.doc.cameraMatrix
          : null;
      preview.doc.cameraMatrix = _cameraAfter(camera, reached);
    }
    return _frame(
      preview,
      paperCamera: graph ? null : preview.camera,
      cameraInkLayer: graph || identical(reached, events.last)
          ? null
          : (
              strokes: base.strokes,
              artwork: base.artwork,
              delta: _matrix(reached),
            ),
    );
  }
}
