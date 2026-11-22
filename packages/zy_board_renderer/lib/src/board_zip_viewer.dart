import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide Ink;
import 'package:media_kit/media_kit.dart';

import 'codec/board_file.dart';
import 'codec/generated/board/Header.pb.dart' as wire;

/// Loads and displays one static or recorded board page from a ZIP archive.
///
/// This is intentionally a read-only surface: gestures are reserved for canvas
/// pan/zoom, with no drawing, editing, page selection, or export controls.
class BoardZipViewer extends StatefulWidget {
  const BoardZipViewer({super.key, required this.url, required this.loadBytes});

  final String url;
  final Future<Uint8List> Function(String url) loadBytes;

  @override
  State<BoardZipViewer> createState() => _BoardZipViewerState();
}

class _BoardZipViewerState extends State<BoardZipViewer> {
  late Future<BoardArchive> _archive;

  @override
  void initState() {
    super.initState();
    _archive = _load();
  }

  @override
  void didUpdateWidget(covariant BoardZipViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) _archive = _load();
  }

  Future<BoardArchive> _load() async {
    final bytes = await widget.loadBytes(widget.url);
    if (bytes.length > 64 * 1024 * 1024) {
      throw const FormatException('画板压缩包超过 64 MiB');
    }
    return BoardArchive.open('answer.zip', bytes);
  }

  void _retry() {
    setState(() {
      _archive = _load();
    });
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<BoardArchive>(
    future: _archive,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError || !snapshot.hasData) {
        return _BoardLoadError(
          message: snapshot.error?.toString() ?? '画板内容无法读取',
          onRetry: _retry,
        );
      }
      return _BoardReplayView(
        key: ObjectKey(snapshot.data!),
        archive: snapshot.data!,
      );
    },
  );
}

class _BoardLoadError extends StatelessWidget {
  const _BoardLoadError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.broken_image_outlined),
        const SizedBox(height: 8),
        const Text('画板加载失败'),
        const SizedBox(height: 4),
        Text(
          message,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('重试'),
        ),
      ],
    ),
  );
}

class _BoardReplayView extends StatefulWidget {
  const _BoardReplayView({
    super.key,
    required this.archive,
    this.initialPosition = 0,
    this.initialPlaying = false,
    this.fullscreen = false,
    this.onExitPosition,
  });
  final BoardArchive archive;
  final int initialPosition;
  final bool initialPlaying;
  final bool fullscreen;
  final ValueChanged<int>? onExitPosition;

  @override
  State<_BoardReplayView> createState() => _BoardReplayViewState();
}

class _AudioSyncRequest {
  const _AudioSyncRequest({
    required this.clip,
    required this.position,
    required this.shouldPlay,
    required this.seek,
  });

  final RecordingClip? clip;
  final int position;
  final bool shouldPlay;
  final bool seek;
}

class _BoardReplayViewState extends State<_BoardReplayView> {
  final Stopwatch _clock = Stopwatch();
  final Set<RecordingClip> _unplayableAudioClips = <RecordingClip>{};
  Timer? _timer;
  late int _position;
  BoardFrame? _frame;
  Player? _audioPlayer;
  Media? _activeMedia;
  RecordingClip? _activeAudioClip;
  _AudioSyncRequest? _pendingAudioSync;
  Future<void>? _audioSyncWorker;
  bool _audioIsPlaying = false;
  bool _audioNeedsSeek = false;
  bool _audioReady = false;
  bool _disposed = false;
  int _lastAudioDriftCheckMs = 0;

  BoardFile get _page => widget.archive.current;
  BlackboardPage? get _blackboard =>
      _page is BlackboardPage ? _page as BlackboardPage : null;
  int get _duration =>
      _page.timeline?.durationMs ?? _blackboard?.pageAudio.durationMs ?? 0;
  RecordingTrack? get _recordingTrack =>
      _page.timeline ?? _blackboard?.pageAudio;
  bool get _canReplay =>
      (_page.timeline?.durationMs ?? 0) > 0 ||
      (_blackboard?.replay.available ?? false);

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition.clamp(0, _duration).toInt();
    if (_position > 0) _frame = _frameAt(_position, direct: true);
    if (widget.initialPlaying) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _togglePlayback();
      });
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _clock.stop();
    _pendingAudioSync = null;
    unawaited(_audioPlayer?.dispose() ?? Future<void>.value());
    if (widget.fullscreen) widget.onExitPosition?.call(_position);
    super.dispose();
  }

  void _showAt(int value, {bool direct = false}) {
    final position = value.clamp(0, _duration).toInt();
    try {
      final frame = _frameAt(position, direct: direct);
      setState(() {
        _position = position;
        _frame = frame;
      });
      _syncAudio(position, shouldPlay: _clock.isRunning, seek: direct);
    } on Exception catch (error) {
      _stop();
      setState(() => _frame = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('录制内容无法播放：$error')));
    }
  }

  BoardFrame? _frameAt(int position, {bool direct = false}) =>
      _page.timeline?.seek(position) ??
      (_blackboard?.replay.available == true
          ? _blackboard!.replay.seek(position, direct: direct)
          : null);

  RecordingClip? _audioClipAt(int position) =>
      _recordingTrack?.clipAt(position);

  Uint8List? _audioBytes(RecordingClip clip) => _page.timeline != null
      ? widget.archive.sketchAudio(clip.filename)
      : _blackboard?.audioBytes(clip.filename);

  String _audioMimeType(RecordingClip clip, Uint8List bytes) {
    final extension = clip.filename.split('.').last.toLowerCase();
    return switch (extension) {
      'wav' => 'audio/wav',
      'mp3' => 'audio/mpeg',
      'm4a' => 'audio/mp4',
      'aac' => 'audio/aac',
      'ogg' || 'opus' => 'audio/ogg',
      'amr' => 'audio/amr',
      _
          when bytes.length >= 12 &&
              String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' =>
        'audio/wav',
      _
          when bytes.length >= 4 &&
              String.fromCharCodes(bytes.sublist(0, 4)) == 'OggS' =>
        'audio/ogg',
      _ => 'application/octet-stream',
    };
  }

  void _syncAudio(int position, {required bool shouldPlay, bool seek = false}) {
    final clip = _audioClipAt(position);
    if (clip != null && _unplayableAudioClips.contains(clip)) {
      if (_activeAudioClip == null &&
          !_audioIsPlaying &&
          _pendingAudioSync == null &&
          _audioSyncWorker == null) {
        return;
      }
      _pendingAudioSync = _AudioSyncRequest(
        clip: null,
        position: position,
        shouldPlay: false,
        seek: false,
      );
      _audioSyncWorker ??= _drainAudioSync();
      return;
    }
    final playAudio = shouldPlay && clip != null;
    if (!playAudio || seek || clip != _activeAudioClip) {
      _lastAudioDriftCheckMs = position;
    }
    if (playAudio &&
        clip == _activeAudioClip &&
        _audioIsPlaying &&
        _audioReady &&
        !seek &&
        position - _lastAudioDriftCheckMs >= 750) {
      _lastAudioDriftCheckMs = position;
      final actual = _audioPlayer?.state.position.inMilliseconds;
      final expected = math.max(0, position - clip.startMs);
      if (actual != null && (actual - expected).abs() >= 200) {
        seek = true;
      }
    }
    if (clip == _activeAudioClip &&
        !seek &&
        playAudio == _audioIsPlaying &&
        _pendingAudioSync == null &&
        _audioSyncWorker == null &&
        (clip == null || _audioReady || _unplayableAudioClips.contains(clip))) {
      return;
    }
    final previousRequest = _pendingAudioSync;
    final wasPendingSeek =
        previousRequest != null &&
        previousRequest.clip == clip &&
        previousRequest.seek;
    _pendingAudioSync = _AudioSyncRequest(
      clip: clip,
      position: position,
      shouldPlay: playAudio,
      seek: seek || wasPendingSeek,
    );
    _audioSyncWorker ??= _drainAudioSync();
  }

  Future<void> _drainAudioSync() async {
    try {
      while (!_disposed && _pendingAudioSync != null) {
        final request = _pendingAudioSync!;
        _pendingAudioSync = null;
        try {
          await _applyAudioSync(request);
        } catch (error) {
          final clip = request.clip;
          if (clip != null) {
            _unplayableAudioClips.add(clip);
            _activeAudioClip = clip;
          }
          _audioReady = false;
          _audioIsPlaying = false;
          try {
            await _audioPlayer?.pause();
          } catch (_) {}
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('录制音频无法播放，将继续显示画面：$error')));
          }
        }
      }
    } finally {
      _audioSyncWorker = null;
      if (!_disposed && _pendingAudioSync != null) {
        _audioSyncWorker = _drainAudioSync();
      }
    }
  }

  Future<void> _applyAudioSync(_AudioSyncRequest request) async {
    final clip = request.clip;
    final existingPlayer = _audioPlayer;
    if (clip == null) {
      if (existingPlayer != null && _audioIsPlaying) {
        await existingPlayer.pause();
      }
      _activeAudioClip = null;
      _audioIsPlaying = false;
      _audioNeedsSeek = false;
      _audioReady = false;
      _activeMedia = null;
      return;
    }
    if (_unplayableAudioClips.contains(clip)) {
      if (existingPlayer != null && _audioIsPlaying) {
        await existingPlayer.pause();
      }
      _activeAudioClip = clip;
      _audioIsPlaying = false;
      return;
    }

    final player = _audioPlayer ??= Player();
    final needsOpen =
        !identical(_activeAudioClip, clip) ||
        !_audioReady ||
        _activeMedia == null;
    if (needsOpen) {
      final bytes = _audioBytes(clip);
      if (bytes == null || bytes.isEmpty) {
        throw const FormatException('录制音频文件缺失');
      }
      await player.pause();
      final media = await Media.memory(
        bytes,
        type: _audioMimeType(clip, bytes),
      );
      if (_disposed) return;
      await player.open(media, play: false);
      _activeMedia = media;
      _activeAudioClip = clip;
      _audioReady = true;
      _audioNeedsSeek = true;
    }

    if (_disposed) return;
    final pending = _pendingAudioSync;
    if (pending != null && !identical(pending.clip, clip)) {
      await player.pause();
      _audioIsPlaying = false;
      return;
    }
    final target = pending ?? request;
    if (request.seek || target.seek || _audioNeedsSeek) {
      final localMs = (target.position - clip.startMs)
          .clamp(0, math.max(0, clip.endMs - clip.startMs))
          .toInt();
      await player.seek(Duration(milliseconds: localMs));
      _audioNeedsSeek = false;
    }
    if (target.shouldPlay) {
      await player.play();
      _audioIsPlaying = true;
    } else {
      await player.pause();
      _audioIsPlaying = false;
    }
  }

  Future<void> _openFullscreen() async {
    final resumeAfterFullscreen = _clock.isRunning;
    if (resumeAfterFullscreen) {
      _timer?.cancel();
      _timer = null;
      _clock.stop();
      _syncAudio(_position, shouldPlay: false);
      setState(() {});
    }
    var exitPosition = _position;
    final position = await Navigator.of(context).push<int>(
      MaterialPageRoute<int>(
        fullscreenDialog: true,
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: _BoardReplayView(
              archive: widget.archive,
              initialPosition: _position,
              initialPlaying: resumeAfterFullscreen,
              fullscreen: true,
              onExitPosition: (position) {
                exitPosition = position;
              },
            ),
          ),
        ),
      ),
    );
    if (!mounted) return;
    _showAt(position ?? exitPosition, direct: true);
    if (resumeAfterFullscreen && _position < _duration) _togglePlayback();
  }

  void _closeFullscreen() => Navigator.of(context).pop(_position);

  void _togglePlayback() {
    if (_clock.isRunning) {
      _timer?.cancel();
      _timer = null;
      _clock.stop();
      _syncAudio(_position, shouldPlay: false);
      setState(() {});
      return;
    }
    if (!_canReplay || _duration <= 0) return;
    final origin = _position >= _duration ? 0 : _position;
    _clock
      ..reset()
      ..start();
    _showAt(origin, direct: true);
    _timer = Timer.periodic(const Duration(milliseconds: 33), (_) {
      final next = origin + _clock.elapsedMilliseconds;
      if (next >= _duration) {
        _showAt(_duration);
        _stop();
      } else {
        _showAt(next);
      }
    });
    setState(() {});
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    _clock
      ..stop()
      ..reset();
    _syncAudio(_position, shouldPlay: false);
    if (mounted) setState(() {});
  }

  void _showStatic() {
    _stop();
    setState(() {
      _position = 0;
      _frame = null;
    });
  }

  String _stamp(int ms) =>
      '${ms ~/ 60000}:${((ms ~/ 1000) % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final page = _page;
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: _BoardCanvas(
                  archive: widget.archive,
                  page: page,
                  frame: _frame,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: widget.fullscreen ? '退出全屏' : '全屏',
                    color: Colors.white,
                    onPressed: widget.fullscreen
                        ? _closeFullscreen
                        : _openFullscreen,
                    icon: Icon(
                      widget.fullscreen
                          ? Icons.close_fullscreen
                          : Icons.fullscreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_canReplay && _duration > 0)
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                children: [
                  IconButton(
                    tooltip: _clock.isRunning ? '暂停录制' : '播放录制',
                    onPressed: _togglePlayback,
                    icon: Icon(
                      _clock.isRunning ? Icons.pause : Icons.play_arrow,
                    ),
                  ),
                  Text('${_stamp(_position)} / ${_stamp(_duration)}'),
                  Expanded(
                    child: Slider(
                      min: 0,
                      max: _duration.toDouble(),
                      value: _position.clamp(0, _duration).toDouble(),
                      onChanged: (value) {
                        if (_clock.isRunning) {
                          _timer?.cancel();
                          _timer = null;
                          _clock.stop();
                        }
                        _showAt(value.round(), direct: true);
                      },
                    ),
                  ),
                  IconButton(
                    tooltip: '显示静态画面',
                    onPressed: _frame == null ? null : _showStatic,
                    icon: const Icon(Icons.stop),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _BoardCanvas extends StatefulWidget {
  const _BoardCanvas({
    required this.archive,
    required this.page,
    required this.frame,
  });
  final BoardArchive archive;
  final BoardFile page;
  final BoardFrame? frame;

  @override
  State<_BoardCanvas> createState() => _BoardCanvasState();
}

class _BoardCanvasState extends State<_BoardCanvas> {
  final TransformationController _transform = TransformationController();
  Size? _lastViewport;
  Size? _lastBoard;

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  Size _renderSize(Size source) {
    if (!source.width.isFinite ||
        !source.height.isFinite ||
        source.width <= 0 ||
        source.height <= 0) {
      return const Size(1200, 900);
    }
    const maxDimension = 4096.0;
    final factor = math.min(
      1.0,
      maxDimension / math.max(source.width, source.height),
    );
    return Size(source.width * factor, source.height * factor);
  }

  void _fit(Size viewport, Size board) {
    if (_lastViewport == viewport && _lastBoard == board) return;
    _lastViewport = viewport;
    _lastBoard = board;
    final scale = math
        .min(viewport.width / board.width, viewport.height / board.height)
        .clamp(0.01, 1.0);
    final x = (viewport.width - board.width * scale) / 2;
    final y = (viewport.height - board.height * scale) / 2;
    _transform.value = Matrix4.identity()
      ..translateByDouble(x, y, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    final page = widget.page;
    final board = _renderSize(page.size);
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = Size(constraints.maxWidth, constraints.maxHeight);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _fit(viewport, board);
        });
        final fitScale = math
            .min(viewport.width / board.width, viewport.height / board.height)
            .clamp(0.01, 1.0);
        return InteractiveViewer(
          transformationController: _transform,
          constrained: false,
          panEnabled: true,
          scaleEnabled: true,
          minScale: fitScale,
          maxScale: fitScale * 8,
          boundaryMargin: const EdgeInsets.all(160),
          onInteractionEnd: (_) => setState(() {}),
          child: SizedBox(
            width: board.width,
            height: board.height,
            child: _BoardScene(
              archive: widget.archive,
              page: page,
              frame: widget.frame,
              size: board,
            ),
          ),
        );
      },
    );
  }
}

class _BoardScene extends StatelessWidget {
  const _BoardScene({
    required this.archive,
    required this.page,
    required this.frame,
    required this.size,
  });
  final BoardArchive archive;
  final BoardFile page;
  final BoardFrame? frame;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final background = frame?.background ?? page.background;
    final wire.BackgroundLineConfig? lines =
        frame?.paperLines ??
        (page is BlackboardPage ? (page as BlackboardPage).paperLines : null);
    final camera =
        frame?.paperCamera ??
        (page is BlackboardPage ? (page as BlackboardPage).camera : null);
    final layer = frame?.cameraInkLayer;
    final artwork = layer?.artwork ?? frame?.artwork ?? page.artwork;
    final strokes = layer?.strokes ?? frame?.strokes ?? page.strokes;
    final drawArea = frame?.sketchDrawArea;
    final drawing = _boardLayers(page, strokes, artwork, size);
    final drawingWidget = layer == null
        ? Stack(fit: StackFit.expand, children: drawing)
        : Transform(
            alignment: Alignment.topLeft,
            transform: _cameraInkTransform(
              layer.delta,
              size.width / page.size.width,
            ),
            child: Stack(fit: StackFit.expand, children: drawing),
          );
    final children = <Widget>[
      if (page is BlackboardPage && lines != null && camera != null)
        Positioned.fill(
          child: CustomPaint(
            painter: _BoardPaperPainter(
              lines,
              camera,
              size.width / page.size.width,
            ),
          ),
        ),
      if (archive.backgroundImage case final Uint8List image)
        Positioned.fill(child: Image.memory(image, fit: BoxFit.fill)),
      Positioned.fill(child: drawingWidget),
    ];
    final color = page is BlackboardPage
        ? Color.alphaBlend(Color(background), Colors.white)
        : Color(background);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRect(
        clipper: drawArea != null && !drawArea.isEmpty
            ? _SketchAreaClipper(drawArea, size.width / page.size.width)
            : null,
        child: Stack(fit: StackFit.expand, children: children),
      ),
    );
  }
}

List<Widget> _boardLayers(
  BoardFile page,
  List<Ink> strokes,
  List<PageArtwork> artwork,
  Size renderSize,
) {
  final result = <Widget>[];
  var start = 0;
  for (final item in artwork) {
    final end = item.beforeStroke.clamp(start, strokes.length);
    if (end > start) {
      result.add(
        Positioned.fill(
          child: CustomPaint(
            painter: _BoardInkPainter(page, strokes, start, end),
          ),
        ),
      );
    }
    start = end;
    if (item.presentation != null) {
      result.add(
        Positioned(
          left: 0,
          top: 0,
          child: Transform(
            alignment: Alignment.topLeft,
            transform: _canvasTransform(
              item.transform,
              renderSize.width / page.size.width,
            ),
            child: Container(
              width: math.max(1, item.bounds.width),
              height: math.max(1, item.bounds.height),
              alignment: Alignment.center,
              color: const Color(0x22000000),
              child: const Text(
                '课件画面暂不支持显示',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ),
          ),
        ),
      );
    } else if (item.sketchBitmap case final bitmap?) {
      result.add(
        Positioned.fill(
          child: _SketchBitmapView(
            bitmap: bitmap,
            root: item.transform,
            scale: renderSize.width / page.size.width,
          ),
        ),
      );
    } else if (item.image case final Uint8List bytes) {
      result.add(
        Positioned(
          left: 0,
          top: 0,
          child: Transform(
            alignment: Alignment.topLeft,
            transform: _canvasTransform(
              item.transform,
              renderSize.width / page.size.width,
            ),
            child: Image.memory(
              bytes,
              width: item.bounds.width,
              fit: BoxFit.fitWidth,
              filterQuality: FilterQuality.none,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        ),
      );
    } else {
      result.add(
        Positioned.fill(
          child: CustomPaint(
            painter: _BoardArtworkPainter(
              item,
              _canvasTransform(
                item.transform,
                renderSize.width / page.size.width,
              ),
            ),
          ),
        ),
      );
    }
  }
  if (start < strokes.length) {
    result.add(
      Positioned.fill(
        child: CustomPaint(
          painter: _BoardInkPainter(page, strokes, start, strokes.length),
        ),
      ),
    );
  }
  return result;
}

class _BoardInkPainter extends CustomPainter {
  const _BoardInkPainter(this.file, this.strokes, this.start, this.end);
  final BoardFile file;
  final List<Ink> strokes;
  final int start, end;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / file.size.width);
    canvas.saveLayer(Offset.zero & file.size, Paint());
    final sketch =
        file.format == BoardFormat.sketch || file.format == BoardFormat.legacy;
    for (var i = start; i < end; i++) {
      final ink = strokes[i];
      final points = ink.points;
      if (points.isEmpty) continue;
      final pen = Paint()
        ..color = Color(ink.argb)
        ..strokeWidth = ink.width.clamp(0.25, 256).toDouble()
        ..strokeCap = sketch ? StrokeCap.butt : StrokeCap.round
        ..strokeJoin = sketch ? StrokeJoin.miter : StrokeJoin.round
        ..style = PaintingStyle.stroke;
      if (ink.erase) pen.blendMode = BlendMode.clear;
      if (points.length == 1 ||
          points.every((point) => point == points.first)) {
        if (ink.boardPaint?.style == 0 &&
            !ink.unfinishedPath &&
            points.length > 1) {
          continue;
        }
        pen.style = PaintingStyle.fill;
        if (sketch) {
          if (points.length == 1) {
            canvas.drawRect(
              Rect.fromCenter(
                center: points.first,
                width: pen.strokeWidth,
                height: pen.strokeWidth,
              ),
              pen,
            );
          }
        } else {
          canvas.drawCircle(points.first, pen.strokeWidth / 2, pen);
        }
        continue;
      }
      if (ink.shape == PenShape.rectangle || ink.shape == PenShape.ellipse) {
        final bounds = Rect.fromPoints(points.first, points.last);
        if (ink.shape == PenShape.rectangle) {
          canvas.drawRect(bounds, pen);
        } else {
          canvas.drawOval(bounds, pen);
        }
        continue;
      }
      if (ink.shape == PenShape.line && !ink.dashed) {
        canvas.drawLine(points.first, points.last, pen);
        continue;
      }
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (var i = 1; i < points.length; i++) {
        final point = points[i], previous = points[i - 1];
        if (sketch && point == points.first) {
          path
            ..moveTo(point.dx, point.dy)
            ..lineTo(point.dx, point.dy);
          continue;
        }
        if (file.format == BoardFormat.simple ||
            sketch ||
            file.format == BoardFormat.pageSnapshot ||
            file.format == BoardFormat.touchSource) {
          path.quadraticBezierTo(
            previous.dx,
            previous.dy,
            (point.dx + previous.dx) / 2,
            (point.dy + previous.dy) / 2,
          );
          if ((sketch ? point == points.last : i == points.length - 1) &&
              !ink.unfinishedPath) {
            path.lineTo(point.dx, point.dy);
          }
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      final native = ink.boardPaint;
      if (native != null && native.style != 1) {
        pen.style = PaintingStyle.fill;
        canvas.drawPath(path, pen);
        if (native.style == 0) continue;
        pen.style = PaintingStyle.stroke;
      }
      if (!ink.dashed &&
          !(native != null && native.spacing > 0 && native.itemLength > 0)) {
        canvas.drawPath(path, pen);
        continue;
      }
      final dash = native?.itemLength ?? 30.0;
      final gap = native?.spacing ?? 15.0;
      if (dash <= 0 || gap < 0) continue;
      for (final metric in path.computeMetrics()) {
        for (double offset = 0; offset < metric.length; offset += dash + gap) {
          canvas.drawPath(metric.extractPath(offset, offset + dash), pen);
        }
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BoardInkPainter oldDelegate) =>
      file != oldDelegate.file ||
      strokes != oldDelegate.strokes ||
      start != oldDelegate.start ||
      end != oldDelegate.end;
}

class _BoardPaperPainter extends CustomPainter {
  const _BoardPaperPainter(this.lines, this.camera, this.renderScale);
  final wire.BackgroundLineConfig lines;
  final List<double> camera;
  final double renderScale;

  @override
  void paint(Canvas canvas, Size viewport) {
    if (lines.lineColor == 0 || camera.isEmpty) return;
    final step = lines.lineSpace * camera[0] * renderScale;
    if (!step.isFinite || step <= 0) return;
    final origin = _transformPoint(
      _canvasTransform(camera, renderScale),
      Offset.zero,
    );
    final bounds = Rect.fromLTWH(
      origin.dx % step - step,
      origin.dy % step - step,
      viewport.width,
      viewport.height,
    );
    final path = Path();
    final nx = (bounds.width / step).truncate() + 3;
    final ny = (bounds.height / step).truncate() + 3;
    if (nx + ny > 1000000) return;
    for (var i = 0; i < ny; i++) {
      final y = bounds.top + i * step;
      path
        ..moveTo(bounds.left, y)
        ..lineTo(bounds.left + nx * step, y);
    }
    if (lines.lineType.value == 1) {
      for (var i = 0; i < nx; i++) {
        final x = bounds.left + i * step;
        path
          ..moveTo(x, bounds.top)
          ..lineTo(x, bounds.top + ny * step);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = Color(lines.lineColor)
        ..style = PaintingStyle.stroke
        ..strokeWidth = lines.lineWidth * renderScale
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_BoardPaperPainter oldDelegate) =>
      lines != oldDelegate.lines ||
      camera != oldDelegate.camera ||
      renderScale != oldDelegate.renderScale;
}

Matrix4 _canvasTransform(List<double> m, double scale) => Matrix4.fromList([
  m[0] * scale,
  m[3] * scale,
  0,
  m[6],
  m[1] * scale,
  m[4] * scale,
  0,
  m[7],
  0,
  0,
  1,
  0,
  m[2] * scale,
  m[5] * scale,
  0,
  m[8],
]);

Matrix4 _cameraInkTransform(List<double> m, double scale) =>
    _canvasTransform(m, 1)
      ..setEntry(0, 3, m[2] * scale)
      ..setEntry(1, 3, m[5] * scale)
      ..setEntry(3, 0, m[6] / scale)
      ..setEntry(3, 1, m[7] / scale);

Offset _transformPoint(Matrix4 matrix, Offset point) {
  return MatrixUtils.transformPoint(matrix, point);
}

class _SketchBitmapView extends StatelessWidget {
  const _SketchBitmapView({
    required this.bitmap,
    required this.root,
    required this.scale,
  });
  final SketchBitmap bitmap;
  final List<double> root;
  final double scale;

  Future<ui.Size> _imageSize(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    try {
      final frame = await codec.getNextFrame();
      final size = ui.Size(
        frame.image.width.toDouble(),
        frame.image.height.toDouble(),
      );
      frame.image.dispose();
      return size;
    } finally {
      codec.dispose();
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<ui.Size>(
    future: _sketchImageSizes[bitmap.bytes] ??= _imageSize(bitmap.bytes),
    builder: (context, snapshot) {
      final dimensions = snapshot.data;
      if (dimensions == null || dimensions.width <= 0) {
        return const SizedBox.shrink();
      }
      final matrix = _canvasTransform(
        bitmap.displayMatrix(root, dimensions.width),
        scale,
      );
      return Transform(
        alignment: Alignment.topLeft,
        transform: matrix,
        child: Opacity(
          opacity: bitmap.opacity,
          child: Image.memory(
            bitmap.bytes,
            width: dimensions.width,
            height: dimensions.height,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.low,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
      );
    },
  );
}

final Expando<Future<ui.Size>> _sketchImageSizes = Expando<Future<ui.Size>>();

class _SketchAreaClipper extends CustomClipper<Rect> {
  const _SketchAreaClipper(this.area, this.scale);
  final Rect area;
  final double scale;

  @override
  Rect getClip(Size viewport) {
    return Rect.fromLTRB(
      area.left * scale,
      area.top * scale,
      area.right * scale,
      area.bottom * scale,
    ).intersect(Offset.zero & viewport);
  }

  @override
  bool shouldReclip(_SketchAreaClipper oldClipper) =>
      area != oldClipper.area || scale != oldClipper.scale;
}

class _BoardArtworkPainter extends CustomPainter {
  const _BoardArtworkPainter(this.artwork, this.matrix);
  final PageArtwork artwork;
  final Matrix4 matrix;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..transform(matrix.storage);
    if (artwork.text case final String text) {
      _drawBoardText(canvas, artwork, text);
    } else if (artwork.polygon case final List<Offset> points) {
      final path = Path();
      if (artwork.oval) {
        path.addOval(artwork.bounds);
      } else if (points.isNotEmpty) {
        path.addPolygon(points, true);
      }
      final pen = Paint()
        ..color = Color(artwork.style.color)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = artwork.style.width;
      if (artwork.style.style != 1) canvas.drawPath(path, pen);
      if (artwork.style.style != 0) {
        pen.style = PaintingStyle.stroke;
        final on = artwork.style.itemLength, off = artwork.style.spacing;
        if (on > 0 && off > 0) {
          for (final segment in path.computeMetrics()) {
            for (double i = 0; i < segment.length; i += on + off) {
              canvas.drawPath(segment.extractPath(i, i + on), pen);
            }
          }
        } else {
          canvas.drawPath(path, pen);
        }
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BoardArtworkPainter oldDelegate) =>
      artwork != oldDelegate.artwork || matrix != oldDelegate.matrix;
}

void _drawBoardText(Canvas canvas, PageArtwork artwork, String content) {
  final size = artwork.style.textSize;
  final width = artwork.bounds.width;
  if (size <= 0 || width <= 0 || content.isEmpty) return;
  final style = TextStyle(
    fontFamily: 'Board Android',
    fontFamilyFallback: const ['Board Document'],
    fontSize: size,
    color: Color(artwork.style.color),
    letterSpacing: 0,
  );
  final painter = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);
  var baseline = size * 2163 / 2048;
  for (final paragraph in content.split('\n')) {
    final offsets = [0];
    for (final rune in paragraph.runes) {
      offsets.add(offsets.last + (rune > 0xffff ? 2 : 1));
    }
    for (var start = 0; start < offsets.length - 1;) {
      final remaining = offsets.length - 1 - start;
      void layout(int count) {
        painter.text = TextSpan(
          text: paragraph.substring(offsets[start], offsets[start + count]),
          style: style,
        );
        painter.layout();
      }

      var low = 1, high = 1;
      while (high < remaining) {
        layout(high);
        if (painter.width >= width) break;
        low = high;
        high = math.min(remaining, high * 2);
      }
      while (low < high) {
        final middle = (low + high + 1) ~/ 2;
        layout(middle);
        if (painter.width < width) {
          low = middle;
        } else {
          high = middle - 1;
        }
      }
      layout(low);
      painter.paint(
        canvas,
        Offset(
          0,
          baseline -
              painter.computeDistanceToActualBaseline(TextBaseline.alphabetic),
        ),
      );
      baseline += size * (2163 + 555) / 2048;
      start += low;
    }
  }
  painter.dispose();
}
