part of 'board_file.dart';

mat.Matrix _cameraAfter(mat.Matrix? origin, mat.Matrix delta) {
  final out = mat.Matrix.fromBuffer(origin?.writeToBuffer() ?? const <int>[])
    ..clearEventTime();
  final values = Float32List.fromList(
    _mul(
      Float32List.fromList(_matrix(delta)),
      Float32List.fromList(_matrix(origin)),
    ),
  );
  // Matrix.proto fields 2..10 are the row-major floats. Android omits zero defaults.
  for (var i = 0; i < values.length; i++) {
    if (values[i] == 0) {
      out.clearField(i + 2);
    } else {
      out.setField(i + 2, values[i]);
    }
  }
  return out;
}

extension BlackboardCamera on BlackboardPage {
  bool get canRecordCamera {
    if (!canRecordCursor) return false;
    final config = _pageHeader().moveConfig;
    return config.isEnable &&
        config.maxWidthTimes > 0 &&
        config.maxHeightTimes > 0 &&
        (config.horizontalTranslate ||
            config.verticalTranslate ||
            config.scale);
  }
}

/// Native SeeAction keeps each transform relative to the camera at pointer-down.
class PageCameraGesture {
  PageCameraGesture(
    this.owner,
    this.anchor,
    this.startTime, {
    this.writing = false,
  }) : config = owner._pageHeader().moveConfig,
       origin = mat.Matrix.fromBuffer(owner.doc.cameraMatrix.writeToBuffer()),
       original = owner.camera {
    if (!owner.doc.hasCameraMatrix())
      origin
        ..scaleX = 1
        ..scaleY = 1
        ..perSp2 = 1;
    final w = owner.size.width * config.maxWidthTimes;
    final h = owner.size.height * config.maxHeightTimes;
    final corners = [
      Offset.zero,
      Offset(w, 0),
      Offset(w, h),
      Offset(0, h),
    ].map((p) => _project(original, p)).toList();
    area = Rect.fromLTRB(
      corners.map((p) => p.dx).reduce(math.min),
      corners.map((p) => p.dy).reduce(math.min),
      corners.map((p) => p.dx).reduce(math.max),
      corners.map((p) => p.dy).reduce(math.max),
    );
  }

  final BlackboardPage owner;
  final int startTime;
  final bool writing;
  final header.MoveConfig config;
  final mat.Matrix origin;
  final List<double> original;
  late final Rect area;
  Offset anchor;
  double? span;
  final samples = <mat.Matrix>[];
  BoardFrame? preview;

  void beginPinch(Offset center, double distance) {
    anchor = center;
    span = distance;
  }

  void move(Offset center, double? distance, int time) {
    if (!center.isFinite ||
        time < startTime ||
        (samples.isNotEmpty && time < samples.last.eventTime.toInt()))
      return;
    final size = owner.size;
    double factor = 1;
    final first = span;
    if (!writing &&
        config.scale &&
        first != null &&
        first > 0 &&
        distance != null &&
        distance.isFinite) {
      final minimum = math.min(
        size.width / area.width,
        size.height / area.height,
      );
      factor = math.max(minimum, distance / first);
    }
    // Scale about the first midpoint, then clamp the midpoint displacement
    // against the transformed logical page, just as SeeAction does.
    double shift(double change, double low, double high) {
      if (writing && low >= high) return 0;
      return low > high ? (low + high) / 2 : change.clamp(low, high).toDouble();
    }

    double x = (1 - factor) * anchor.dx, y = (1 - factor) * anchor.dy;
    if (config.horizontalTranslate) {
      x += shift(
        center.dx - anchor.dx,
        size.width - (factor * area.right + x),
        -(factor * area.left + x),
      );
    }
    if (config.verticalTranslate) {
      y += shift(
        center.dy - anchor.dy,
        size.height - (factor * area.bottom + y),
        -(factor * area.top + y),
      );
    }
    final delta = mat.Matrix(
      scaleX: factor,
      scaleY: factor,
      transX: x == 0 ? null : x,
      transY: y == 0 ? null : y,
      perSp2: 1,
      eventTime: Int64(time),
    );
    // Flutter delivers the contacts of one browser touch event separately.
    // The Android recorder reads both coordinates in a single MotionEvent.
    if (samples.isNotEmpty && samples.last.eventTime == delta.eventTime) {
      samples.last = delta;
    } else {
      samples.add(delta);
    }
    final scene = BlackboardPage._(
      owner.bundle,
      owner.name,
      page.PageSnapshot(
        graphSnapshot: owner.doc.graphSnapshot,
        cameraMatrix: _cameraAfter(origin, delta),
      ),
      size,
      Uint8List(0),
    )..refresh();
    preview = BoardFrame(
      scene.strokes,
      scene.background,
      scene.artwork,
      paperLines: scene.paperLines,
      paperCamera: scene.camera,
      cameraInkLayer: (
        strokes: owner.strokes,
        artwork: owner.artwork,
        delta: _matrix(delta),
      ),
    );
  }

  bool save() {
    if (samples.isEmpty ||
        !samples.any((m) => m.transX != 0 || m.transY != 0 || m.scaleX != 1))
      return false;
    final timeline = owner.replay;
    final audio = owner.pageAudio;
    final start = [
      audio.durationMs,
      audio._commandEnd,
      timeline._clockEnd,
      timeline._lastGate,
    ].reduce(math.max);
    final duration = math.max(
      1,
      samples.last.eventTime.toInt() - samples.first.eventTime.toInt(),
    );
    // The native camera worker must commit its final transform before the
    // scheduler finishes the page or starts another asynchronous camera.
    const settleMs = 192;
    final meta = owner._pageHeader()
      ..duration = Int64(start + duration + settleMs);
    final routerPath = '${owner.dir}router.bin';
    final refs = router.RouterRecord.fromBuffer(owner.bundle.read(routerPath));
    final shard = owner._nextName('matrix');
    final last = _cameraAfter(origin, samples.last);
    final command = cmd.CommandSource_CommandInfo_CameraMatrix(
      sourceFileName: shard,
      originMatrix: mat.Matrix.fromBuffer(origin.writeToBuffer())
        ..eventTime = Int64(startTime),
      lastMatrix: last,
    );
    owner._writeRecord(
      shard,
      src.MatrixSource(
        matrixInfo: [src.MatrixSource_MatrixInfo(matrix: samples)],
      ),
      refs.matrixSourceRecord,
    );
    owner._writeRecord(
      owner._nextName('command'),
      cmd.CommandSource(
        commandInfo: [
          cmd.CommandSource_CommandInfo(
            commandEnum: ce.CommandEnum.ACTION_CAMERA_MATRIX,
            isPlay: true,
            delayTime: Int64(start - timeline._clockEnd),
            duration: Int64(duration),
            data: command.writeToBuffer(),
          ),
          cmd.CommandSource_CommandInfo(
            commandEnum: ce.CommandEnum.ACTION_RECORD_STOP,
            isPlay: true,
            delayTime: Int64(settleMs),
          ),
        ],
      ),
      refs.commandRecord,
    );
    owner.bundle.changed[routerPath] = refs.writeToBuffer();
    owner.bundle.changed['${owner.dir}header.bin'] = meta.writeToBuffer();
    owner.doc.cameraMatrix = last;
    owner.dirty = true;
    owner._audioTrack = null;
    owner.refresh();
    return true;
  }
}
