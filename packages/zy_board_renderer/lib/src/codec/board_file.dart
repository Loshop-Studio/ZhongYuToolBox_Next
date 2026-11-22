import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';
import 'cloud_mdb.dart';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'generated/board/GraphSnapshot.pb.dart' as page;
import 'generated/board/Header.pb.dart' as header;
import 'generated/board/enums/BackgroundLineTypeEnum.pbenum.dart' as line;
import 'generated/board/PageRouter.pb.dart' as pages;
import 'generated/board/PageHeader.pb.dart' as pagehead;
import 'generated/board/RouterRecord.pb.dart' as router;
import 'generated/board/Command.pb.dart' as cmd;
import 'generated/board/enums/CommandEnum.pbenum.dart' as ce;
import 'generated/board/enums/GraphEnum.pbenum.dart' as ge;
import 'generated/board/enums/GeometryEnum.pbenum.dart' as geom;
import 'generated/board/utils/Paint.pb.dart' as paint;
import 'generated/board/utils/Matrix.pb.dart' as mat;
import 'generated/board/utils/RectF.pb.dart' as rect;
import 'generated/board/utils/PointF.pb.dart' as pf;
import 'package:fixnum/fixnum.dart';
import 'package:image/image.dart' as raster;
import 'package:protobuf/protobuf.dart';
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart';
import 'generated/sketch/DrawBoard.pb.dart' as sk;
import 'generated/sketch/SketchGraphSnapshot.pb.dart' as snapshot;
import 'generated/simple/SimpleBoardData.pb.dart' as simple;
import 'generated/board/Source.pb.dart' as src;
import 'generated/board/utils/TouchEvent.pb.dart' as touch;

part 'board_archive.dart';
part 'simple_erase.dart';
part 'cloud_page_index.dart';
part 'page_edit.dart';
part 'page_paper.dart';
part 'page_audio.dart';
part 'page_replay.dart';
part 'cloud_ink.dart';
part 'page_cursor.dart';
part 'page_camera.dart';
part 'page_create.dart';
part 'sketch_timeline.dart';
part 'sketch_space.dart';
part 'sketch_legacy_touch.dart';
part 'sketch_image.dart';
part 'sketch_presentation.dart';

typedef CameraInkLayer = ({
  List<Ink> strokes,
  List<PageArtwork> artwork,
  List<double> delta,
});

class BoardFrame {
  BoardFrame(
    this.strokes,
    this.background,
    this.artwork, {
    this.sketchDrawArea,
    this.paperLines,
    this.paperCamera,
    this.cameraInkLayer,
    this.cursor,
  });
  final List<Ink> strokes;
  final int background;
  final List<PageArtwork> artwork;
  final Rect? sketchDrawArea;
  final header.BackgroundLineConfig? paperLines;
  final List<double>? paperCamera;
  final CameraInkLayer? cameraInkLayer;
  final PageCursor? cursor;
}

enum PenShape { free, line, rectangle, ellipse }

sealed class _SketchLayer {}

class Ink implements _SketchLayer {
  Ink(
    this.points,
    this.argb,
    this.width, {
    this.erase = false,
    this.dashed = false,
    this.unfinishedPath = false,
    this.eventTimes,
    this.boardPaint,
    this.shape = PenShape.free,
  });
  final List<Offset> points;
  final List<int>? eventTimes;
  final int argb;
  final double width;
  final bool erase, dashed, unfinishedPath;
  final paint.Paint? boardPaint;
  final PenShape shape;

  List<Offset> _sketchPoints() {
    if (erase || shape == PenShape.free || shape == PenShape.line)
      return points;
    final bounds = Rect.fromPoints(points.first, points.last);
    if (bounds.isEmpty) {
      return points.first == points.last
          ? [points.first]
          : [points.first, points.last];
    }
    if (shape == PenShape.rectangle) {
      // Native WritingAction smooths consecutive samples through their midpoint.
      // Duplicate corners. A point equal to the first starts a new native
      // subpath, so finish half a pixel past the start on the same edge.
      return [
        bounds.topCenter,
        for (final p in [
          bounds.topRight,
          bounds.bottomRight,
          bounds.bottomLeft,
          bounds.topLeft,
        ]) ...[p, p],
        bounds.topCenter + Offset(math.min(0.5, bounds.width / 8), 0),
      ];
    }
    final rx = bounds.width / 2, ry = bounds.height / 2;
    final quarters = (math.pi / 4 * math.sqrt(math.max(rx, ry) / 0.25))
        .ceil()
        .clamp(4, 512);
    final cardinal = [
      bounds.centerRight,
      bounds.bottomCenter,
      bounds.centerLeft,
      bounds.topCenter,
    ];
    return [
      for (var i = 0; i < 4 * quarters; i++)
        if (i % quarters == 0)
          cardinal[i ~/ quarters]
        else
          bounds.center +
              Offset(
                rx * math.cos(i * math.pi / (2 * quarters)),
                ry * math.sin(i * math.pi / (2 * quarters)),
              ),
      bounds.center +
          Offset(
            rx * math.cos(math.pi / (8 * quarters)),
            ry * math.sin(math.pi / (8 * quarters)),
          ),
    ];
  }
}

enum BoardFormat { sketch, legacy, simple, touchSource, pageSnapshot }

/// Original protobufs own the serialized state. Preview strokes are derived data.
class BoardFile {
  BoardFile._(this.name, this.format, this.message, this.size, this.original);
  final String name;
  final BoardFormat format;
  final GeneratedMessage message;
  Size size;
  final Uint8List? original;
  bool dirty = false;
  final strokes = <Ink>[];
  final artwork = <PageArtwork>[];
  final _pathRadii = Expando<double>();
  final _simpleHitBounds = <Rect>[];
  double simpleCreationRadius = SimpleBoardEraser.defaultRadius;
  Uint8List? Function(String)? _readSketchResource;
  SketchBitmap? _thumbnailLayer;
  int? _bakedActionCount;
  final unrendered = <String>{};
  SketchTimeline? timeline;
  Rect? sketchDrawArea, sketchPreviewClip;
  // Older recorder builds open the stored JPEG itself as the editable image.
  bool get sketchUsesThumbnailAsSource =>
      format == BoardFormat.legacy ||
      (format == BoardFormat.sketch &&
          (message as sk.DrawBoard).boardHead.createDate < Int64(1546272000));
  sk.GraphResetData? _terminalReset;
  _V2Scene? _v2Scene;
  int _lastTime = 0;
  int background = 0xffffffff;

  factory BoardFile.blank() => BoardFile._(
    'actions.bin',
    BoardFormat.sketch,
    sk.DrawBoard(
      boardHead: sk.BoardHead(version: 5, width: 1200, height: 900, type: 1),
      boardBody: sk.BoardBody(),
    ),
    const Size(1200, 900),
    null,
  );

  static BoardFile open(
    String name,
    Uint8List data, {
    bool allowEmptySimple = false,
    Uint8List? Function(String)? sketchImage,
    Uint8List? Function()? sketchThumbnail,
    int? bakedActionCount,
  }) {
    final base = name.split('/').last.toLowerCase();
    if (data.length > 64 * 1024 * 1024)
      throw const FormatException('单文件超过 64 MiB');
    if (RegExp(
      r'(header|router|snapshot|_command|_matrix|_geometry|_file|_text|_audio)\.bin$',
    ).hasMatch(base)) {
      throw const FormatException('这是页面索引、快照或资源分片。请打开 actions.bin 或笔迹分片。');
    }
    if ((allowEmptySimple || base == 'remote_draft.bin') &&
        data.isEmpty &&
        base != 'actions.bin' &&
        !base.endsWith('_touch.bin'))
      return BoardFile._(
        name,
        BoardFormat.simple,
        simple.SimpleBoardData(),
        const Size(320, 240),
        data,
      );
    if (base.endsWith('_touch.bin')) {
      final doc = src.TouchSource.fromBuffer(data);
      if (data.isNotEmpty && doc.touchInfo.isEmpty)
        throw const FormatException('触摸分片中缺少记录');
      final result = BoardFile._(
        name,
        BoardFormat.touchSource,
        doc,
        _extent(
          doc.touchInfo.expand(
            (i) => i.touchEvent.map((e) => Offset(e.x, e.y)),
          ),
        ),
        data,
      );
      result.refresh();
      return result;
    }
    // Read just the board head before decoding the version-dependent body.
    // A V1 Any has a string in field 1 where a V2+ ActionContent has an enum.
    sk.BoardHead? head;
    try {
      final input = CodedBufferReader(data);
      while (!input.isAtEnd()) {
        final tag = input.readTag();
        if (tag == 10) {
          head = sk.BoardHead.fromBuffer(input.readBytes());
          break;
        }
        input.skipField(tag);
      }
    } on Exception {
      head = null;
    }
    if (head != null &&
        head.hasVersion() &&
        head.version >= 1 &&
        head.version <= 5 &&
        head.width > 0 &&
        head.height > 0) {
      final legacy = head.version == 1;
      final GeneratedMessage doc = legacy
          ? sk.DrawBoardV1.fromBuffer(data)
          : sk.DrawBoard.fromBuffer(data);
      final result = BoardFile._(
        name,
        legacy ? BoardFormat.legacy : BoardFormat.sketch,
        doc,
        Size(head.width.toDouble(), head.height.toDouble()),
        data,
      );
      result._readSketchResource = sketchImage;
      if (head.type != 2 && result.sketchUsesThumbnailAsSource) {
        final jpeg = sketchThumbnail?.call();
        if (jpeg != null) {
          final info = raster.JpegDecoder().startDecode(jpeg);
          if (info != null && info.width > 0 && info.height > 0) {
            result._thumbnailLayer = SketchBitmap.backing(
              jpeg,
              info.width,
              info.height,
              result.size,
            );
            result._bakedActionCount =
                bakedActionCount ?? result._actions.length;
          }
        }
      }
      result.refresh();
      return result;
    }
    if (base == 'actions.bin') throw const FormatException('画板版本或分辨率无法识别');
    final doc = simple.SimpleBoardData.fromBuffer(data);
    if (doc.path.isEmpty ||
        doc.path.any(
          (p) =>
              p.point.isEmpty ||
              p.point.any(
                (q) =>
                    q.value.length < 2 ||
                    !q.value[0].isFinite ||
                    !q.value[1].isFinite,
              ),
        )) {
      throw const FormatException('无法识别笔迹格式');
    }
    final result = BoardFile._(
      name,
      BoardFormat.simple,
      doc,
      _extent(
        doc.path.expand(
          (p) => p.point.map((q) => Offset(q.value[0], q.value[1])),
        ),
      ),
      data,
    );
    result.refresh();
    return result;
  }

  static Size _extent(Iterable<Offset> points) {
    double width = 0, height = 0;
    for (final p in points) {
      if (!p.dx.isFinite || !p.dy.isFinite)
        throw const FormatException('坐标不是有限数值');
      width = math.max(width, p.dx);
      height = math.max(height, p.dy);
    }
    return Size(math.max(320, width + 24), math.max(240, height + 24));
  }

  List<Any> get _actions => format == BoardFormat.legacy
      ? (message as sk.DrawBoardV1).boardBodyV1.actionContent
      : (message as sk.DrawBoard).boardBody.actionContent
            .map((e) => e.action)
            .toList();

  void refresh() {
    strokes.clear();
    artwork.clear();
    _terminalReset = null;
    unrendered.clear();
    _lastTime = 0;
    background = 0xffffffff;
    if (format == BoardFormat.simple) {
      _simpleHitBounds.clear();
      for (final path in (message as simple.SimpleBoardData).path) {
        final points = path.point
            .map((q) => Offset(q.value[0], q.value[1]))
            .toList();
        final radius = _pathRadii[path] ?? SimpleBoardEraser.defaultRadius;
        _simpleHitBounds.add(_simpleBounds(points, radius));
        strokes.add(
          Ink(
            points,
            path.paint.color,
            path.paint.width,
            dashed: path.paint.isDashed,
          ),
        );
      }
      return;
    }
    if (format == BoardFormat.touchSource) {
      for (final info in (message as src.TouchSource).touchInfo) {
        strokes.add(
          Ink(
            info.touchEvent.map((q) => Offset(q.x, q.y)).toList(),
            info.paint.color,
            info.paint.width,
            boardPaint: info.paint,
          ),
        );
      }
      return;
    }
    final actions = _actions;
    timeline =
        _thumbnailLayer == null &&
            actions.any((a) => a.typeUrl.endsWith('/AudioStartAction'))
        ? SketchTimeline()
        : null;
    var color = 0xff000000, width = 3.0;
    var mode = sk.ActionModeConfig_Mode.ACTION_WRITING;
    var space = _SketchSpace(_identity, _identity);
    void moveTo(_SketchSpace next) {
      space = next;
      timeline?._view(next);
    }

    sk.DrawArea? drawArea;
    void setDrawArea(sk.DrawArea? area) {
      drawArea = area;
      sketchDrawArea = area == null
          ? null
          : Rect.fromLTRB(
              area.leftTopPoint.x,
              area.leftTopPoint.y,
              area.rightBottomPoint.x,
              area.rightBottomPoint.y,
            );
      timeline?._drawArea(sketchDrawArea);
    }

    sketchDrawArea = null;
    final version = format == BoardFormat.legacy
        ? 1
        : (message as sk.DrawBoard).boardHead.version;
    _v2Scene = version == 2 && _thumbnailLayer == null ? _V2Scene() : null;
    final scene = <_SketchLayer>[];
    void edit({_SketchLayer? add, bool Function(_SketchLayer)? remove}) {
      final changes = _StrokeEdit(add);
      if (remove != null) {
        for (var i = 0; i < scene.length; i++) {
          if (remove(scene[i])) changes.removed.add((i, scene[i]));
        }
      }
      changes.apply(scene);
      timeline?._record(changes);
    }

    final wrapped = format == BoardFormat.sketch
        ? (message as sk.DrawBoard).boardBody.actionContent
        : null;
    void restoreSnapshot(sk.ActionContent record) {
      _v2Scene?.restore(record.graphSnapshot);
      final wipe = _StrokeEdit(null);
      for (var i = 0; i < scene.length; i++) {
        wipe.removed.add((i, scene[i]));
      }
      wipe.apply(scene);
      timeline?._record(wipe);
      moveTo(
        _SketchSpace(
          _snapshotMatrix(record.graphSnapshot.matrix),
          _snapshotMatrix(record.graphSnapshot.childExtendMatrix),
        ),
      );
      for (final restored in _snapshotLayers(
        record.graphSnapshot,
        unrendered,
        _readSketchResource,
      )) {
        final append = _StrokeEdit(restored);
        append.apply(scene);
        timeline?._record(append);
      }
      if (record.hasResetData()) {
        final reset = record.resetData;
        mode = reset.modeConfig;
        setDrawArea(reset.hasDrawArea() ? reset.drawArea : null);
        width = reset.graphConfig.width;
        color = reset.graphConfig.color;
        if (reset.backgroundColor != 0) {
          timeline?._paper(background, reset.backgroundColor);
          background = reset.backgroundColor;
        }
      }
    }

    var firstAction = 0;
    if (_thumbnailLayer case final image?) {
      // The older recorder opens this single bitmap and returns without
      // replaying the old BIN. Only actions added since this JPEG was opened
      // are separate editable layers until the next export.
      scene.add(image);
      firstAction = _bakedActionCount!;
      _time(
        format == BoardFormat.legacy
            ? (message as sk.DrawBoardV1).boardHead.updateDate
            : (message as sk.DrawBoard).boardHead.updateDate,
      );
    } else if (wrapped != null &&
        timeline == null &&
        !sketchUsesThumbnailAsSource) {
      final head = (message as sk.DrawBoard).boardHead;
      if (head.type == 1) {
        // The recorder can compact even an ordinary touch into a full scene.
        // executeActionContent restores the last such tree and runs its tail.
        final snapshotIndex = wrapped.lastIndexWhere(
          (record) => record.hasGraphSnapshot(),
        );
        if (snapshotIndex >= 0) {
          restoreSnapshot(wrapped[snapshotIndex]);
          _time(head.updateDate);
          firstAction = snapshotIndex + 1;
        }
      }
    }
    for (var i = firstAction; i < actions.length; i++) {
      final a = actions[i];
      final record = wrapped?[i];
      final type = a.typeUrl.split('/').last;
      switch (type) {
        case 'AudioStartAction':
          final e = sk.AudioStartAction.fromBuffer(a.value);
          _lastTime = math.max(_lastTime, e.startTime.toInt());
          timeline?._begin(e.fileName, e.startTime.toInt());
          if (record != null && version >= 3) restoreSnapshot(record);
          break;
        case 'AudioStopAction':
          final e = sk.AudioStopAction.fromBuffer(a.value);
          _lastTime = math.max(_lastTime, e.startTime.toInt());
          timeline?._end(e.startTime.toInt());
          if (record != null && (version == 3 || version == 5)) {
            restoreSnapshot(record);
          }
          break;
        case 'ActionGraphConfig':
          final e = sk.ActionGraphConfig.fromBuffer(a.value);
          color = e.config.color;
          width = e.config.width;
          _time(e.startTime);
          break;
        case 'ActionModeConfig':
          final e = sk.ActionModeConfig.fromBuffer(a.value);
          mode = e.mode;
          _time(e.startTime);
          break;
        case 'ActionDrawConfig':
          final e = sk.ActionDrawConfig.fromBuffer(a.value);
          _time(e.startTime);
          if (e.hasDrawArea()) setDrawArea(e.drawArea);
          if (e.hasBackgroundColor()) {
            timeline?._paper(background, e.backgroundColor);
            background = e.backgroundColor;
          }
          break;
        case 'ActionZoom':
          final e = sk.ActionZoom.fromBuffer(a.value);
          _time(e.startTime);
          if (version >= 4) {
            moveTo(space.zoom(e));
          } else if (version == 3 && record != null) {
            restoreSnapshot(record);
          }
          break;
        case 'ActionTranslation':
          final e = sk.ActionTranslation.fromBuffer(a.value);
          _time(e.startTime);
          if (version == 5) moveTo(space.translate(e));
          break;
        case 'ActionResetMatrix':
          // GraphTaskParseVersion5 never schedules this recorder-side action.
          _lastTime = math.max(
            _lastTime,
            sk.ActionResetMatrix.fromBuffer(a.value).startTime.toInt(),
          );
          break;
        case 'ActionTouchEvent':
          final e = sk.ActionTouchEvent.fromBuffer(a.value);
          _lastTime = math.max(_lastTime, e.startTime.toInt());
          if (version == 3 &&
              _thumbnailLayer == null &&
              e.touchEvent.length > 1) {
            // V3 initialises its drawing strategy from this touch's resetData on DOWN.
            final reset = record!.resetData;
            mode = reset.modeConfig;
            width = reset.graphConfig.width;
            color = reset.graphConfig.color;
            setDrawArea(reset.hasDrawArea() ? reset.drawArea : null);
            if (reset.backgroundColor != 0) {
              timeline?._paper(background, reset.backgroundColor);
              background = reset.backgroundColor;
            }
          }
          var points = <Offset>[], pointTimes = <int>[];
          final mobile =
              mode == sk.ActionModeConfig_Mode.ACTION_WRITING_MOVE ||
              mode == sk.ActionModeConfig_Mode.ACTION_WRITING_MOVE_VERTICAL;
          final writing =
              mobile || mode == sk.ActionModeConfig_Mode.ACTION_WRITING;
          Offset? mid;
          _SketchSpace? drag;
          var cancelled = false;
          for (final t in e.touchEvent) {
            _time(t.eventTime);
            // The shipped action factories have no handlers for these two modes.
            if (mode == sk.ActionModeConfig_Mode.ACTION_SHAPE_RECT ||
                mode == sk.ActionModeConfig_Mode.ACTION_SHAPE_CIRCLE)
              continue;
            if (t.action == 0) {
              points = [];
              pointTimes = [];
              cancelled = false;
              mid = null;
              drag = null;
            }
            if (mobile &&
                (t.action == 5 ||
                    t.action == 6 ||
                    (t.pointerCount > 1 && t.action == 2))) {
              if (t.pointerCoords.length < 2) {
                unrendered.add('双指坐标不全');
                continue;
              }
              final first = t.pointerCoords[0], second = t.pointerCoords[1];
              final center = Offset(
                (first.x + second.x) / 2,
                (first.y + second.y) / 2,
              );
              if (t.action == 5) {
                timeline?._gesture(Ink(points, color, width), pointTimes);
                points = [];
                pointTimes = [];
                cancelled = true;
                mid = center;
                drag = space;
              } else if (t.action == 6) {
                mid = null;
                drag = null;
              } else if (drag != null && mid != null) {
                final delta = center - mid;
                moveTo(
                  drag.pan(
                    mode ==
                            sk
                                .ActionModeConfig_Mode
                                .ACTION_WRITING_MOVE_VERTICAL
                        ? 0
                        : delta.dx,
                    delta.dy,
                  ),
                );
              }
              continue;
            }
            if (cancelled) continue;
            if (t.pointerCount > 1) {
              unrendered.add('多指手势');
              continue;
            }
            final xy = t.pointerCoords.firstOrNull;
            if (!writing || t.action == 0 || t.action == 2) {
              // Ink gets a point on DOWN and MOVE. UP commits the pending native path.
              final at = writing
                  ? Offset(t.x, t.y)
                  : Offset(xy?.x ?? t.x, xy?.y ?? t.y);
              points.add(space.local(at));
              if (timeline != null) pointTimes.add(timeline!.durationMs);
            }
            if (t.action == 1 || identical(t, e.touchEvent.last)) {
              if (points.isEmpty) continue;
              if (mode == sk.ActionModeConfig_Mode.ACTION_ERASER_WRITING) {
                edit(
                  remove: (s) =>
                      s is Ink &&
                      s.points.any(
                        (p) => points.any(
                          (q) =>
                              (space.screen(p) - space.screen(q)).distance <=
                              math.max(9, width),
                        ),
                      ),
                );
              } else if ([
                sk.ActionModeConfig_Mode.ACTION_WRITING,
                sk.ActionModeConfig_Mode.ACTION_WRITING_MOVE,
                sk.ActionModeConfig_Mode.ACTION_WRITING_MOVE_VERTICAL,
                sk.ActionModeConfig_Mode.ACTION_ERASER_VIEW,
              ].contains(mode)) {
                edit(
                  add: Ink(
                    List.of(points),
                    color,
                    width,
                    erase: mode == sk.ActionModeConfig_Mode.ACTION_ERASER_VIEW,
                  ),
                );
              } else {
                unrendered.add(mode.name);
              }
              if (timeline != null &&
                  (mode == sk.ActionModeConfig_Mode.ACTION_WRITING ||
                      mode == sk.ActionModeConfig_Mode.ACTION_WRITING_MOVE ||
                      mode ==
                          sk
                              .ActionModeConfig_Mode
                              .ACTION_WRITING_MOVE_VERTICAL ||
                      mode == sk.ActionModeConfig_Mode.ACTION_ERASER_VIEW)) {
                final finished = scene.last as Ink;
                timeline!._gesture(
                  Ink(
                    points,
                    color,
                    width,
                    erase: finished.erase,
                    shape: finished.shape,
                  ),
                  pointTimes,
                );
              }
              points = [];
              pointTimes = [];
            }
          }
          if (e.touchEvent.isNotEmpty &&
              _thumbnailLayer == null &&
              record != null &&
              (version == 2 ||
                  (version == 3 &&
                      record.hasGraphSnapshot() &&
                      (i % 50 == 0 || i == actions.length - 1)))) {
            restoreSnapshot(record);
          }
          break;
        case 'ActionWebViewConfig':
          final e = sk.ActionWebViewConfig.fromBuffer(a.value);
          _time(e.startTime);
          // V2 replays the WebView action even when the same record has a snapshot.
          if (version == 3) {
            restoreSnapshot(record ?? sk.ActionContent());
          } else {
            final deck = SketchPresentation.action(
              e,
              'action-$i',
              _readSketchResource,
            );
            _v2Scene?.addDeck(e, deck);
            if (!deck.hasHtml) unrendered.add(deck.missingLabel);
            edit(add: deck);
          }
          break;
        case 'ActionImageConfig':
          final e = sk.ActionImageConfig.fromBuffer(a.value);
          _time(e.startTime);
          if (version < 4) {
            restoreSnapshot(record ?? sk.ActionContent());
          } else {
            final bytes = _readSketchResource?.call(e.path);
            if (bytes == null) {
              unrendered.add('缺少图片 res/${e.path}');
            } else {
              edit(add: SketchBitmap.fromAction(e, bytes, space));
            }
          }
          break;
        case 'ActionClearBoard':
          _time(sk.ActionClearBoard.fromBuffer(a.value).startTime);
          edit(remove: (_) => true);
          break;
        case 'ActionPrevAction':
          _time(sk.ActionPrevAction.fromBuffer(a.value).startTime);
          restoreSnapshot(record ?? sk.ActionContent());
          break;
        case 'ActionNextAction':
          _time(sk.ActionNextAction.fromBuffer(a.value).startTime);
          restoreSnapshot(record ?? sk.ActionContent());
          break;
        default:
          final time = switch (type) {
            'ActionFitterConfig' => sk.ActionFitterConfig.fromBuffer(
              a.value,
            ).startTime,
            _ => null,
          };
          if (time != null) _time(time);
          unrendered.add(type.isEmpty ? '未知操作' : type);
      }
    }
    // RecordControl.thumbnail clips the mapped bounding rectangle after
    // painting the paper. It uses the root matrix, without its child extension.
    sketchPreviewClip = null;
    if (drawArea case final area?) {
      final left = area.leftTopPoint.x, top = area.leftTopPoint.y;
      final right = area.rightBottomPoint.x, bottom = area.rightBottomPoint.y;
      final corners = [
        for (final x in [left, right])
          for (final y in [top, bottom]) _sketchPoint(space.root, Offset(x, y)),
      ];
      sketchPreviewClip = Rect.fromLTRB(
        corners.map((p) => p.dx).reduce(math.min),
        corners.map((p) => p.dy).reduce(math.min),
        corners.map((p) => p.dx).reduce(math.max),
        corners.map((p) => p.dy).reduce(math.max),
      );
    }
    final finalFrame = _sketchFrame(scene, space, background);
    strokes.addAll(finalFrame.strokes);
    artwork.addAll(finalFrame.artwork);
    final last = wrapped?.lastOrNull;
    if (_thumbnailLayer == null &&
        version == 5 &&
        last != null &&
        last.type == sk.ActionEnum.ACTION_AUDIO_STOP &&
        !last.hasResetData()) {
      // After replacing the root graph, the native action factory may still
      // point to a detached writing group. Supply its effective settings when
      // the user adds the first edit after this snapshot.
      _terminalReset = sk.GraphResetData(
        modeConfig: mode,
        graphConfig: sk.ActionGraphConfig_GraphConfig(
          color: color.toSigned(32),
          width: width,
        ),
        backgroundColor: background.toSigned(32),
        drawArea: drawArea,
        action: sk.GraphResetData_ActionFactory(),
      );
    }
  }

  void _time(Int64 t) {
    _lastTime = math.max(_lastTime, t.toInt());
    timeline?._at(t.toInt());
  }

  void _append(sk.ActionEnum type, String name, GeneratedMessage data) {
    final any = Any(
      typeUrl: 'type.googleapis.com/$name',
      value: data.writeToBuffer(),
    );
    if (format == BoardFormat.legacy) {
      (message as sk.DrawBoardV1).ensureBoardBodyV1().actionContent.add(any);
    } else {
      (message as sk.DrawBoard).ensureBoardBody().actionContent.add(
        sk.ActionContent(type: type, action: any),
      );
    }
  }

  bool get canTransformSketch =>
      format == BoardFormat.sketch &&
      (message as sk.DrawBoard).boardHead.version == 5;

  bool get hasThumbnailBacking => _thumbnailLayer != null;

  bool get canInsertSketchImage =>
      format == BoardFormat.sketch &&
      (message as sk.DrawBoard).boardHead.version >= 4;

  void _appendImage(String filename, int width, int height, int position) {
    _prepareSketchEdit();
    _append(
      sk.ActionEnum.ACTION_IMAGE,
      'ActionImageConfig',
      sk.ActionImageConfig(
        startTime: Int64(_lastTime + 1),
        path: filename,
        width: width,
        height: height,
        viewWidth: size.width.round(),
        viewHeight: size.height.round(),
        positionFlag: position,
      ),
    );
    dirty = true;
    refresh();
  }

  void _prepareSketchEdit() {
    if (_terminalReset case final reset?) {
      (message as sk.DrawBoard).boardBody.actionContent.last.resetData = reset;
    }
  }

  void moveSketch(Offset delta) {
    if (!canTransformSketch || delta == Offset.zero) return;
    _prepareSketchEdit();
    final action = sk.ActionTranslation(
      startTime: Int64(_lastTime + 1),
      keep: true,
    );
    action.ensureTransX().value = delta.dx;
    action.ensureTransY().value = delta.dy;
    _append(sk.ActionEnum.ACTION_TRANS, 'ActionTranslation', action);
    dirty = true;
    refresh();
  }

  void zoomSketch(double factor, Offset center) {
    if (!canTransformSketch || !factor.isFinite || factor <= 0 || factor == 1)
      return;
    _prepareSketchEdit();
    _append(
      sk.ActionEnum.ACTION_ZOOM,
      'ActionZoom',
      sk.ActionZoom(
        startTime: Int64(_lastTime + 1),
        keep: true,
        scaleX: factor,
        scaleY: factor,
        centerX: center.dx,
        centerY: center.dy,
      ),
    );
    dirty = true;
    refresh();
  }

  void draw(Ink ink) {
    if (ink.points.isEmpty) return;
    if (format == BoardFormat.touchSource)
      throw StateError('分片索引由页面命令引用。只允许修改已有笔迹。');
    if (format == BoardFormat.simple) {
      final paths = (message as simple.SimpleBoardData).path;
      if (ink.erase) {
        for (final point in ink.points) {
          eraseSimpleAt(point, ink.width);
        }
        return;
      }
      final path = simple.Path(
        point: ink.points.map((p) => simple.PointF(value: [p.dx, p.dy])),
        paint: simple.Paint(
          width: ink.width,
          color: ink.argb.toSigned(32),
          isDashed: ink.dashed,
        ),
      );
      _pathRadii[path] = simpleCreationRadius;
      paths.add(path);
    } else {
      _prepareSketchEdit();
      final start = Int64(_lastTime + 1);
      _append(
        sk.ActionEnum.ACTION_MODE,
        'ActionModeConfig',
        sk.ActionModeConfig(
          startTime: start,
          mode: ink.erase
              ? sk.ActionModeConfig_Mode.ACTION_ERASER_WRITING
              : sk.ActionModeConfig_Mode.ACTION_WRITING,
        ),
      );
      _append(
        sk.ActionEnum.ACTION_GRAPH,
        'ActionGraphConfig',
        sk.ActionGraphConfig(
          startTime: start,
          config: sk.ActionGraphConfig_GraphConfig(
            width: ink.width,
            color: ink.argb.toSigned(32),
          ),
        ),
      );
      final points = [...ink._sketchPoints()];
      // UP commits the native stroke without adding its own coordinate.
      if (points.length == 1 || !ink.erase) points.add(points.last);
      final events = <sk.ActionTouchEvent_TouchEvent>[];
      for (var i = 0; i < points.length; i++) {
        final p = points[i];
        events.add(
          sk.ActionTouchEvent_TouchEvent(
            eventTime: start + Int64(i * 8),
            action: i == 0
                ? 0
                : i == points.length - 1
                ? 1
                : 2,
            pointerCount: 1,
            x: p.dx,
            y: p.dy,
            pointerCoords: [
              sk.ActionTouchEvent_TouchEvent_PointerCoords(x: p.dx, y: p.dy),
            ],
            pointerProperties: [
              sk.ActionTouchEvent_TouchEvent_PointerProperties(
                id: 0,
                toolType: 2,
              ),
            ],
          ),
        );
      }
      _append(
        sk.ActionEnum.ACTION_TOUCH,
        'ActionTouchEvent',
        sk.ActionTouchEvent(
          startTime: start,
          endTime: events.last.eventTime,
          touchEvent: events,
        ),
      );
      if (message case sk.DrawBoard board) {
        final touch = board.boardBody.actionContent.last;
        if (_v2Scene case final state?) {
          touch.graphSnapshot = state.after(
            ink,
            points.take(points.length - 1),
            start,
          );
        } else if (board.boardHead.version == 3 && _thumbnailLayer == null) {
          touch.resetData = sk.GraphResetData(
            modeConfig: ink.erase
                ? sk.ActionModeConfig_Mode.ACTION_ERASER_WRITING
                : sk.ActionModeConfig_Mode.ACTION_WRITING,
            graphConfig: sk.ActionGraphConfig_GraphConfig(
              width: ink.width,
              color: ink.argb.toSigned(32),
            ),
            backgroundColor: background.toSigned(32),
            action: sk.GraphResetData_ActionFactory(),
          );
          final area = sketchDrawArea;
          if (area != null) {
            final clip = touch.resetData.ensureDrawArea();
            clip.ensureLeftTopPoint()
              ..x = area.left
              ..y = area.top;
            clip.ensureRightBottomPoint()
              ..x = area.right
              ..y = area.bottom;
          }
        }
      }
    }
    dirty = true;
    refresh();
  }

  /// Preserve native source indices when replacing a touch stroke.
  void replaceTouch(int index, Ink ink) {
    final info = (message as src.TouchSource).touchInfo[index];
    final start = info.touchEvent.isEmpty
        ? Int64.ZERO
        : info.touchEvent.first.eventTime;
    final points = ink.points.length == 1
        ? [ink.points.first, ink.points.first]
        : ink.points;
    if (points.isEmpty) return;
    final events = <touch.TouchEvent>[];
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      events.add(
        touch.TouchEvent(
          eventTime: start + Int64(i * 8),
          action: i == 0
              ? 0
              : i == points.length - 1
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
    info.touchEvent
      ..clear()
      ..addAll(events);
    info.ensurePaint()
      ..width = ink.width
      ..color = ink.argb.toSigned(32);
    dirty = true;
    refresh();
  }

  Uint8List bytes() =>
      !dirty && original != null ? original! : message.writeToBuffer();
}

// Save reversible edits so seeking backwards can restore removed strokes.
class _StrokeEdit {
  _StrokeEdit(this.added);
  final _SketchLayer? added;
  final removed = <(int, _SketchLayer)>[];

  void apply(List<_SketchLayer> layers) {
    for (final (index, _) in removed.reversed) {
      layers.removeAt(index);
    }
    if (added case final _SketchLayer layer) layers.add(layer);
  }

  void undo(List<_SketchLayer> layers) {
    if (added != null) layers.removeLast();
    for (final (index, ink) in removed) {
      layers.insert(index, ink);
    }
  }
}
