part of 'board_file.dart';

class RecordingClip {
  RecordingClip(this.filename, this.startMs);
  final String filename;
  final int startMs;
  int endMs = 0;
}

abstract class RecordingTrack {
  final clips = <RecordingClip>[];
  int get durationMs;

  RecordingClip? clipAt(int ms) {
    for (final clip in clips) {
      if (ms >= clip.startMs && ms < clip.endMs) return clip;
    }
    return null;
  }
}

typedef SketchFrame = BoardFrame;

class _TimedEdit {
  _TimedEdit(this.time, this.edit, this.beforeColor, this.afterColor);
  final int time;
  final _StrokeEdit? edit;
  final int beforeColor, afterColor;
}

class _DrawingGesture {
  _DrawingGesture(this.ink, this.times, this.endMs);
  final int endMs;
  final Ink ink;
  final List<int> times;
}

/// Native GraphTaskParse accumulates time only between audio start and stop.
/// Other changes are applied, in file order, at the previous segment boundary.
class SketchTimeline extends RecordingTrack {
  final _edits = <_TimedEdit>[];
  final _gestures = <_DrawingGesture>[];
  final _views = <(int, _SketchSpace)>[];
  final _areas = <(int, Rect?)>[];
  void _drawArea(Rect? area) => _areas.add((_clock, area));
  void _view(_SketchSpace view) => _views.add((_clock, view));
  int _completed = 0, _clock = 0, _index = 0, _color = 0xffffffff;
  int? _start;
  final _visible = <_SketchLayer>[];
  int get durationMs => _clock;

  int _at(int stamp) {
    final start = _start;
    // Native rendering consumes the queue in file order. A timestamp earlier
    // than the preceding queued event cannot make that event execute earlier.
    _clock = math.max(_clock, _completed + (start == null ? 0 : stamp - start));
    return _clock;
  }

  void _begin(String filename, int stamp) {
    _at(stamp);
    _start = stamp;
    clips.add(RecordingClip(filename, _completed));
  }

  void _end(int stamp) {
    final start = _start;
    if (start == null) return;
    _at(stamp);
    _completed += math.max(0, stamp - start);
    clips.last.endMs = _completed;
    _start = null;
  }

  void _record(_StrokeEdit edit) => _edits.add(_TimedEdit(_clock, edit, 0, 0));
  void _paper(int before, int after) =>
      _edits.add(_TimedEdit(_clock, null, before, after));
  void _gesture(Ink stroke, List<int> times) {
    if (times.isNotEmpty && times.first < _clock) {
      _gestures.add(_DrawingGesture(stroke, times, _clock));
    }
  }

  void _step(_TimedEdit e, bool advance) {
    final edit = e.edit;
    if (edit == null) {
      _color = advance ? e.afterColor : e.beforeColor;
    } else if (advance) {
      edit.apply(_visible);
    } else {
      edit.undo(_visible);
    }
  }

  SketchFrame seek(int positionMs) {
    final p = positionMs.clamp(0, durationMs);
    while (_index > 0 && _edits[_index - 1].time > p) {
      _step(_edits[--_index], false);
    }
    while (_index < _edits.length && _edits[_index].time <= p) {
      _step(_edits[_index++], true);
    }
    final visible = List<_SketchLayer>.of(_visible);
    var lo = 0, hi = _gestures.length;
    while (lo < hi) {
      final mid = (lo + hi) ~/ 2;
      if (_gestures[mid].endMs <= p) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    if (lo < _gestures.length) {
      final gesture = _gestures[lo];
      final times = gesture.times;
      if (times.first <= p) {
        var first = 0, past = times.length;
        while (first < past) {
          final mid = (first + past) ~/ 2;
          if (times[mid] <= p) {
            first = mid + 1;
          } else {
            past = mid;
          }
        }
        final ink = gesture.ink;
        visible.add(
          Ink(
            ink.points.sublist(0, first),
            ink.argb,
            ink.width,
            erase: ink.erase,
            shape: ink.shape,
            dashed: ink.dashed,
          ),
        );
      }
    }
    lo = 0;
    hi = _views.length;
    while (lo < hi) {
      final mid = (lo + hi) ~/ 2;
      if (_views[mid].$1 <= p) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return _sketchFrame(
      visible,
      lo > 0 ? _views[lo - 1].$2 : _SketchSpace(_identity, _identity),
      _color,
      drawArea: _areas.where((entry) => entry.$1 <= p).lastOrNull?.$2,
    );
  }
}

/// The snapshot stores a graph's own matrix and a separate matrix inherited by
/// its children. Android GraphExtKt.convert2WM composes both before drawing.
List<_SketchLayer> _snapshotLayers(
  snapshot.GraphData root,
  Set<String> unrendered,
  Uint8List? Function(String)? readResource,
) {
  final result = <_SketchLayer>[];
  final identity = _matrix(null);
  void visit(snapshot.GraphData g, List<double> parent) {
    final world = identical(g, root)
        ? identity
        : _mul(parent, _snapshotMatrix(g.matrix));
    switch (g.graphType) {
      case snapshot.GraphType.STROKE_GRAPH:
        if (g.extra.typeUrl.split('/').last == 'Touch') {
          final points = snapshot.Touch.fromBuffer(g.extra.value).pointF;
          result.add(
            Ink(
              points.map((p) => _sketchPoint(world, Offset(p.x, p.y))).toList(),
              g.color,
              g.width,
            ),
          );
        } else {
          unrendered.add('缺少快照笔迹数据');
        }
        break;
      case snapshot.GraphType.IMAGE_GRAPH:
        if (g.extra.typeUrl.split('/').last != 'File') {
          unrendered.add('缺少快照图片描述');
          break;
        }
        final ref = snapshot.File.fromBuffer(g.extra.value);
        final bytes = readResource?.call(ref.fileName);
        if (bytes == null) {
          unrendered.add('缺少图片 res/${ref.fileName}');
        } else {
          result.add(SketchBitmap.fromSnapshot(ref, bytes, world, g));
        }
        break;
      case snapshot.GraphType.WEB_VIEW_GRAPH:
        if (g.extra.typeUrl.split('/').last != 'File') {
          unrendered.add('缺少快照课件描述');
          break;
        }
        final ref = snapshot.File.fromBuffer(g.extra.value);
        final deck = SketchPresentation._(
          'snapshot-${g.name}-${result.length}',
          ref.fileName,
          ref.width,
          ref.height,
          (g.color >>> 24 & 255) / 255,
          world,
          readResource,
        );
        if (!deck.hasHtml) unrendered.add(deck.missingLabel);
        result.add(deck);
        break;
      case snapshot.GraphType.UNBOUNDED_CONTAINER_GRAPH:
      case snapshot.GraphType.BOUNDED_CONTAINER_GRAPH:
      case snapshot.GraphType.WRITING_GROUP_GRAPH:
        break;
      default:
        unrendered.add('快照图元 ${g.graphType.name}');
    }
    final childTransform = identical(g, root)
        ? identity
        : _mul(world, _snapshotMatrix(g.childExtendMatrix));
    for (final child in g.childGraph) {
      visit(child, childTransform);
    }
  }

  visit(root, identity);
  return result;
}
