part of 'board_file.dart';

/// The Android player draws each cursor sample on its own temporary layer.
class PageCursor {
  PageCursor(this.local, this.camera, this.brush);
  final Offset local;
  final List<double> camera;
  final paint.Paint brush;
  Offset get center => _project(camera, local);

  // Matrix.mapRadius takes the geometric mean of the lengths of its two
  // mapped radius vectors. ActiveView then transforms the circular path.
  double get localRadius {
    final inv = _tryInverse(camera), radius = brush.width / 2;
    if (inv == null) return radius;
    final origin = _project(inv, Offset.zero);
    final x = _project(inv, Offset(radius, 0)) - origin;
    final y = _project(inv, Offset(0, radius)) - origin;
    return math.sqrt(x.distance * y.distance);
  }
}

extension BlackboardCursor on BlackboardPage {
  bool get canRecordCursor =>
      supportsArtworkEditing &&
      _tryInverse(camera) != null &&
      replay._anchored &&
      replay.issue == null &&
      pageAudio.issue == null;

  PageCursor cursorAt(Offset point, int color, double width) => PageCursor(
    _project(_inverse(camera), point),
    camera,
    paint.Paint(color: color.toSigned(32), width: width, itemLength: 1),
  );

  /// Append a timed cursor gesture without modifying the saved graph or preview.
  void appendCursor(
    List<Offset> points,
    List<int> times,
    int color,
    double width,
  ) {
    if (!canRecordCursor ||
        points.length < 2 ||
        points.length != times.length ||
        !width.isFinite ||
        width <= 0 ||
        points.any((p) => !p.isFinite)) {
      throw const FormatException('当前页面或光标轨迹无效');
    }
    for (var i = 1; i < times.length; i++) {
      if (times[i] < times[i - 1]) throw const FormatException('光标采样时间须按顺序排列');
    }
    final timeline = replay;
    final start = [
      pageAudio.durationMs,
      pageAudio._commandEnd,
      timeline._clockEnd,
      timeline._lastGate,
    ].reduce(math.max);
    final duration = math.max(1, times.last - times.first);
    // Give the original asynchronous cursor thread time to clear the last dot
    // before the page player stops its children. Its normal clock ticks at 16 ms.
    const clearInterval = 64;
    final stop = cmd.CommandSource_CommandInfo(
      commandEnum: ce.CommandEnum.ACTION_RECORD_STOP,
      isPlay: true,
      delayTime: Int64(clearInterval),
    );
    final meta = _pageHeader()
      ..duration = Int64(start + duration + clearInterval);
    final route = '${dir}router.bin';
    final refs = router.RouterRecord.fromBuffer(bundle.read(route));
    final pointer = cursorAt(points.first, color, width);
    final inverse = _inverse(pointer.camera);
    final info = src.TouchSource_TouchInfo(paint: pointer.brush);
    for (var i = 0; i < points.length; i++) {
      final local = _project(inverse, points[i]);
      info.touchEvent.add(
        touch.TouchEvent(x: local.dx, y: local.dy, eventTime: Int64(times[i])),
      );
    }
    final shard = _nextName('touch');
    final gesture = cmd.CommandSource_CommandInfo_CursorMove(
      sourceFileName: shard,
    );
    final command = cmd.CommandSource_CommandInfo(
      commandEnum: ce.CommandEnum.ACTION_CURSOR_MOVE,
      isPlay: true,
      delayTime: Int64(start - timeline._clockEnd),
      duration: Int64(duration),
      data: gesture.writeToBuffer(),
    );
    _writeRecord(
      shard,
      src.TouchSource(touchInfo: [info]),
      refs.touchSourceRecord,
    );
    _writeRecord(
      _nextName('command'),
      cmd.CommandSource(commandInfo: [command, stop]),
      refs.commandRecord,
    );
    bundle.changed[route] = refs.writeToBuffer();
    bundle.changed['${dir}header.bin'] = meta.writeToBuffer();
    _replay = null;
    _audioTrack = null;
  }
}
