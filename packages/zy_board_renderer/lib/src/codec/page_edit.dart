part of 'board_file.dart';

extension BlackboardArtworkEditing on BlackboardPage {
  String get _noteHeader =>
      '${_dir(dir.endsWith('/') ? dir.substring(0, dir.length - 1) : dir)}header.bin';
  bool get supportsArtworkEditing {
    final local = '${dir}header.bin';
    if (bundle._hasFullPageHeader(local)) {
      return header.Header.fromBuffer(bundle.read(local)).version == 6;
    }
    return bundle.has(_noteHeader) &&
        header.Header.fromBuffer(bundle.read(_noteHeader)).version == 6;
  }

  /// Keep original source chunks immutable so earlier playback commands still see
  /// the old resources. New values live in the current snapshot and command log.
  bool editArtwork(
    PageArtwork art, {
    String? content,
    int? argb,
    double? size,
    int? style,
    Size? extent,
    List<Offset>? vertices,
    Offset move = Offset.zero,
  }) {
    if (!supportsArtworkEditing ||
        !artwork.any((a) => identical(a, art)) ||
        !art.editable ||
        art.image != null) {
      throw StateError('当前页面没有可编辑的对应图元');
    }
    final g = art._graph!, parent = art._parent!, isText = art.text != null;
    bool valid(double n) => n.isFinite && n.abs() <= 3.4e38;
    if (!valid(move.dx) ||
        !valid(move.dy) ||
        (content != null && !isText) ||
        (size != null && (!valid(size) || size < 0 || (isText && size == 0))) ||
        (style != null && (style < 0 || style > 2)) ||
        (extent != null &&
            (!valid(extent.width) ||
                !valid(extent.height) ||
                extent.isEmpty)) ||
        (vertices != null &&
            (isText ||
                art.oval ||
                vertices.length < 3 ||
                vertices.any((p) => !valid(p.dx) || !valid(p.dy))))) {
      throw const FormatException('图元的尺寸、位移或顶点无效');
    }
    final editText = content != null && content != art.text;
    final editPaint =
        (argb != null && argb.toSigned(32) != art.style.color) ||
        (size != null &&
            size != (isText ? art.style.textSize : art.style.width)) ||
        (style != null && style != art.style.style);
    final editBounds = extent != null && extent != art.bounds.size;
    final editPoints =
        vertices != null &&
        (vertices.length != art.polygon!.length ||
            Iterable<int>.generate(
              vertices.length,
            ).any((i) => vertices[i] != art.polygon![i]));
    if (!editText &&
        !editPaint &&
        !editBounds &&
        !editPoints &&
        move == Offset.zero)
      return false;
    final routerPath = '${dir}router.bin';
    final refs = bundle.has(routerPath)
        ? router.RouterRecord.fromBuffer(bundle.read(routerPath))
        : router.RouterRecord();
    final commands = <cmd.CommandSource_CommandInfo>[];
    void record(ce.CommandEnum kind, GeneratedMessage data) => commands.add(
      cmd.CommandSource_CommandInfo(
        commandEnum: kind,
        isPlay: false,
        data: data.writeToBuffer(),
      ),
    );

    // Older/sparse pages sometimes keep these values only in their resource
    // chunk. GraphUtils reads snapshot fields directly when recreating a graph.
    final sourcePaint = !g.hasPaint() && art.style.writeToBuffer().isNotEmpty;
    final sourceText = isText && g.content.isEmpty && art.text!.isNotEmpty;
    final sourcePoints =
        !isText && !art.oval && g.pointList.isEmpty && art.polygon!.isNotEmpty;
    if (editText ||
        editPaint ||
        editBounds ||
        editPoints ||
        sourcePaint ||
        sourceText ||
        sourcePoints) {
      final change = cmd.CommandSource_CommandInfo_GraphChange(
        graphId: g.id,
        graphEnum: g.graphEnum,
      );
      if (editPaint || sourcePaint) {
        final next = paint.Paint.fromBuffer(art.style.writeToBuffer());
        if (argb != null) next.color = argb.toSigned(32);
        if (style != null) next.style = style;
        if (size != null) {
          if (isText) {
            next.textSize = size;
          } else {
            next.width = size;
          }
        }
        g.paint = change.paint = next;
      }
      if (sourceText && !editText) g.content = change.content = art.text!;
      if (sourcePoints && !editPoints && !editBounds) {
        final points = art.polygon!
            .map((v) => pf.PointF(x: v.dx, y: v.dy))
            .toList();
        g.pointList.addAll(points);
        change.points.addAll(points);
      }
      if (editText) {
        g.content = change.content = content;
        if (content.isEmpty) {
          // Proto3 can omit the empty string. Preserve the pre-edit source for
          // earlier frames and make an explicit empty source for snapshot readers.
          final filename = _nextName('text');
          _writeRecord(
            filename,
            src.TextSource(
              textInfo: [
                src.TextSource_TextInfo(
                  content: content,
                  paint: g.hasPaint() ? g.paint : art.style,
                ),
              ],
            ),
            refs.textSourceRecord,
          );
          g.sourceFileName = filename;
          g.sourceId = 0;
        }
      }
      if (editBounds) {
        final box = rect.RectF.fromBuffer(g.outRect.writeToBuffer())
          ..right = art.bounds.left + extent.width
          ..bottom = art.bounds.top + extent.height;
        g.outRect = change.outRect = box;
      }
      if (editPoints ||
          (editBounds && !isText && !art.oval && !art.bounds.isEmpty)) {
        final points = editPoints
            ? vertices
            : art.polygon!
                  .map(
                    (p) => Offset(
                      art.bounds.left +
                          (p.dx - art.bounds.left) *
                              extent!.width /
                              art.bounds.width,
                      art.bounds.top +
                          (p.dy - art.bounds.top) *
                              extent.height /
                              art.bounds.height,
                    ),
                  )
                  .toList();
        // Native hit testing also uses outRect. Keep the original bounds for
        // in-bounds edits and include vertices that extend outside that box.
        if (editPoints && !editBounds) {
          var box = art.bounds;
          final minX = points.map((p) => p.dx).reduce(math.min);
          final minY = points.map((p) => p.dy).reduce(math.min);
          final maxX = points.map((p) => p.dx).reduce(math.max);
          final maxY = points.map((p) => p.dy).reduce(math.max);
          final verticesBox = Rect.fromLTRB(minX, minY, maxX, maxY);
          box = box.isEmpty ? verticesBox : box.expandToInclude(verticesBox);
          if (box != art.bounds) {
            final next = rect.RectF.fromBuffer(g.outRect.writeToBuffer())
              ..left = box.left
              ..top = box.top
              ..right = box.right
              ..bottom = box.bottom;
            g.outRect = change.outRect = next;
          }
        }
        final mapped = points.map((p) => pf.PointF(x: p.dx, y: p.dy)).toList();
        g.pointList
          ..clear()
          ..addAll(mapped);
        change.points.addAll(mapped);
      }
      // GraphChangeExecute visits direct text/geometry children and ignores
      // blank strings. RebuildExecute restores a full graph in those other cases.
      if (!identical(parent, doc.graphSnapshot) ||
          (editText && content.trim().isEmpty)) {
        // REBUILD reads the entire tree, including siblings from sparse pages.
        for (final sibling in artwork.where(
          (a) => a.editable && a.image == null && !identical(a, art),
        )) {
          final node = sibling._graph!;
          if (!node.hasPaint())
            node.paint = paint.Paint.fromBuffer(sibling.style.writeToBuffer());
          if (node.content.isEmpty && sibling.text?.isNotEmpty == true)
            node.content = sibling.text!;
          if (!sibling.oval &&
              node.pointList.isEmpty &&
              sibling.polygon != null) {
            node.pointList.addAll(
              sibling.polygon!.map((v) => pf.PointF(x: v.dx, y: v.dy)),
            );
          }
        }
        final h = _pageHeader();
        record(
          ce.CommandEnum.ACTION_REBUILD,
          cmd.CommandSource_CommandInfo_REBUILD(
            snapshot: doc.graphSnapshot,
            backgroundColor: background.toSigned(32),
            backgroundLineConfig: h.hasLastBackgroundLineConfig()
                ? h.lastBackgroundLineConfig
                : h.defaultBackgroundLineConfig,
          ),
        );
      } else {
        record(ce.CommandEnum.ACTION_GRAPH_CHANGE, change);
      }
    }
    if (move != Offset.zero) {
      record(
        ce.CommandEnum.ACTION_GRAPH_MATRIX,
        _translateArtwork(g, parent, refs, move),
      );
    }
    _writeRecord(
      _nextName('command'),
      cmd.CommandSource(commandInfo: commands),
      refs.commandRecord,
    );
    bundle.changed[routerPath] = refs.writeToBuffer();
    dirty = true;
    refresh();
    return true;
  }

  cmd.CommandSource_CommandInfo_GraphMatrix _translateArtwork(
    page.PageSnapshot_GraphSnapshot g,
    page.PageSnapshot_GraphSnapshot parent,
    router.RouterRecord refs,
    Offset move,
  ) {
    final delta = mat.Matrix(
      scaleX: 1,
      scaleY: 1,
      perSp2: 1,
      transX: move.dx,
      transY: move.dy,
    );
    return _applyArtworkMatrix(g, parent, refs, delta);
  }

  /// Native V6 selects the centre in displayed coordinates, then conjugates the
  /// gesture by the camera before applying it to the graph's page-space matrix.
  bool transformImage(
    PageArtwork art, {
    Offset move = Offset.zero,
    double scale = 1,
    double degrees = 0,
  }) {
    if (!supportsArtworkEditing ||
        art.image == null ||
        !artwork.any((item) => identical(item, art))) {
      throw StateError('当前页面没有可编辑的对应图片');
    }
    if (!scale.isFinite ||
        scale <= 0 ||
        !degrees.isFinite ||
        !move.dx.isFinite ||
        !move.dy.isFinite) {
      throw const FormatException('缩放比例须大于零，角度和位移须为有效数字');
    }
    final angle = degrees.remainder(360);
    if (scale == 1 && angle == 0 && move == Offset.zero) return false;
    final center = _project(art.transform, art.bounds.center);
    final radians = angle * math.pi / 180;
    final a = scale * math.cos(radians), b = scale * math.sin(radians);
    final gesture = [
      a,
      -b,
      move.dx + center.dx - a * center.dx + b * center.dy,
      b,
      a,
      move.dy + center.dy - b * center.dx - a * center.dy,
      0.0,
      0.0,
      1.0,
    ];
    final camera = _matrix(doc.hasCameraMatrix() ? doc.cameraMatrix : null);
    final values = Float32List.fromList(
      _mul(_inverse(camera), _mul(gesture, camera)),
    );
    final graph = art._graph!;
    final composed = _mul(
      values,
      _matrix(graph.hasMatrix() ? graph.matrix : null),
    );
    if (Float32List.fromList([scale]).first == 0 ||
        [...values, ...composed].any((n) => !n.isFinite || n.abs() > 3.4e38)) {
      throw const FormatException('图片变换超出原生矩阵范围');
    }
    final delta = mat.Matrix(
      scaleX: values[0],
      skewX: values[1],
      transX: values[2],
      skewY: values[3],
      scaleY: values[4],
      transY: values[5],
      perSp0: values[6],
      perSp1: values[7],
      perSp2: values[8],
    );
    final routerPath = '${dir}router.bin';
    final refs = bundle.has(routerPath)
        ? router.RouterRecord.fromBuffer(bundle.read(routerPath))
        : router.RouterRecord();
    final payload = _applyArtworkMatrix(graph, art._parent!, refs, delta);
    _writeRecord(
      _nextName('command'),
      cmd.CommandSource(
        commandInfo: [
          cmd.CommandSource_CommandInfo(
            commandEnum: ce.CommandEnum.ACTION_GRAPH_MATRIX,
            isPlay: false,
            data: payload.writeToBuffer(),
          ),
        ],
      ),
      refs.commandRecord,
    );
    bundle.changed[routerPath] = refs.writeToBuffer();
    dirty = true;
    refresh();
    return true;
  }

  cmd.CommandSource_CommandInfo_GraphMatrix _applyArtworkMatrix(
    page.PageSnapshot_GraphSnapshot g,
    page.PageSnapshot_GraphSnapshot parent,
    router.RouterRecord refs,
    mat.Matrix delta,
  ) {
    final filename = _nextName('matrix');
    _writeRecord(
      filename,
      src.MatrixSource(
        matrixInfo: [
          src.MatrixSource_MatrixInfo(matrix: [delta]),
        ],
      ),
      refs.matrixSourceRecord,
    );
    // Android Matrix and the wire format both store floats. Round at each edit
    // so the in-memory snapshot and playback of successive commands stay in sync.
    _transformGraph(g, delta);
    return cmd.CommandSource_CommandInfo_GraphMatrix(
      graphData: [
        cmd.CommandSource_CommandInfo_GraphData(
          graphId: g.id,
          parentGraphId: parent.id,
          graphEnum: g.graphEnum,
        ),
      ],
      sourceFileName: filename,
      sourceId: 0,
    );
  }
}

void _transformGraph(page.PageSnapshot_GraphSnapshot g, mat.Matrix delta) {
  final nativeDelta = Float32List.fromList(_matrix(delta));
  void transform(page.PageSnapshot_GraphSnapshot node) {
    final m = Float32List.fromList(
      _mul(
        nativeDelta,
        Float32List.fromList(_matrix(node.hasMatrix() ? node.matrix : null)),
      ),
    );
    final next = mat.Matrix.fromBuffer(node.matrix.writeToBuffer())
      ..scaleX = m[0]
      ..skewX = m[1]
      ..transX = m[2]
      ..skewY = m[3]
      ..scaleY = m[4]
      ..transY = m[5]
      ..perSp0 = m[6]
      ..perSp1 = m[7]
      ..perSp2 = m[8];
    node.matrix = next;
    for (final child in node.childGraph) {
      transform(child);
    }
  }

  transform(g);
}
