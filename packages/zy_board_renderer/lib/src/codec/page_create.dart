part of 'board_file.dart';

enum ArtworkKind {
  text('文字'),
  oval('椭圆'),
  rectangle('矩形'),
  triangle('三角形'),
  image('图片');

  const ArtworkKind(this.label);
  final String label;
}

extension BlackboardArtworkCreation on BlackboardPage {
  /// Native v6 builders create a graph at its local origin. Its position on the
  /// page is a separate matrix command which is replayed after GRAPH_ADD.
  String createArtwork(
    ArtworkKind kind, {
    required Rect area,
    required int argb,
    double penSize = 3,
    String content = '',
    String imageName = '',
    Uint8List? imageBytes,
  }) {
    if (!supportsArtworkEditing) throw StateError('需要第 6 版 Blackboard 页面');
    if (area.isEmpty ||
        ![
          area.left,
          area.top,
          area.width,
          area.height,
          penSize,
        ].every((v) => v.isFinite && v.abs() <= 2147483647) ||
        penSize <= 0) {
      throw const FormatException('坐标、尺寸或画笔大小无效');
    }
    if (kind == ArtworkKind.text && content.trim().isEmpty) {
      throw const FormatException('请输入文字');
    }
    final routerPath = '${dir}router.bin';
    final refs = bundle.has(routerPath)
        ? router.RouterRecord.fromBuffer(bundle.read(routerPath))
        : router.RouterRecord();
    final root = doc.graphSnapshot;
    final graph = page.PageSnapshot_GraphSnapshot(
      outRect: rect.RectF(right: area.width, bottom: area.height),
      matrix: mat.Matrix(scaleX: 1, scaleY: 1, perSp2: 1),
      sourceId: 0,
    );
    final style = paint.Paint(color: argb.toSigned(32));
    late final GeneratedMessage source;
    late final List<router.RouterRecord_SourceCommandRecord> records;
    late final String suffix;
    switch (kind) {
      case ArtworkKind.text:
        suffix = 'text';
        records = refs.textSourceRecord;
        style.textSize = penSize;
        graph
          ..graphEnum = ge.GraphEnum.TEXT_GRAPH
          ..content = content
          ..paint = style;
        source = src.TextSource(
          textInfo: [src.TextSource_TextInfo(content: content, paint: style)],
        );
      case ArtworkKind.image:
        if (imageBytes == null ||
            imageBytes.isEmpty ||
            area.width < 1 ||
            area.height < 1) {
          throw const FormatException('图片内容或显示尺寸无效');
        }
        suffix = 'file';
        records = refs.fileSourceRecord;
        final base = '${_dir(_noteHeader)}res/image/';
        final name = bundle._uniqueResourceName(base, imageName);
        final w = area.width.round(), h = area.height.round();
        graph
          ..graphEnum = ge.GraphEnum.IMAGE_GRAPH
          ..filePath = name;
        graph.outRect
          ..right = w.toDouble()
          ..bottom = h.toDouble();
        source = src.FileSource(
          fileInfo: [
            src.FileSource_FileInfo(
              name: name,
              width: w,
              height: h,
              validate: BlackboardPage._signature(imageBytes),
            ),
          ],
        );
        bundle.changed[base + name] = imageBytes;
      case ArtworkKind.oval:
      case ArtworkKind.rectangle:
      case ArtworkKind.triangle:
        suffix = 'geometry';
        records = refs.geometrySourceRecord;
        style
          ..width = penSize
          ..style = 1;
        graph
          ..graphEnum = ge.GraphEnum.GEOMETRY_GRAPH
          ..paint = style;
        final w = area.width, h = area.height;
        final points = switch (kind) {
          ArtworkKind.triangle => [
            Offset(w / 2, 0),
            Offset(w, h),
            Offset(0, h),
          ],
          ArtworkKind.rectangle => [
            Offset.zero,
            Offset(w, 0),
            Offset(w, h),
            Offset(0, h),
          ],
          _ => <Offset>[],
        };
        graph.pointList.addAll(points.map((p) => pf.PointF(x: p.dx, y: p.dy)));
        source = src.GeometrySource(
          geometryInfo: [
            src.GeometrySource_GeometryInfo(
              geometryType: kind == ArtworkKind.oval
                  ? geom.GeometryEnum.OVAL
                  : geom.GeometryEnum.POLYGON,
              points: graph.pointList,
              paint: style,
            ),
          ],
        );
    }
    final filename = _nextName(suffix);
    final idBase = 'web-${kind.name}-${filename.split('_').first}';
    final ids = <String>{};
    void readIds(page.PageSnapshot_GraphSnapshot node) {
      ids.add(node.id);
      node.childGraph.forEach(readIds);
    }

    readIds(root);
    var id = idBase;
    for (var n = 2; ids.contains(id); n++) {
      id = '$idBase-$n';
    }
    graph
      ..id = id
      ..sourceFileName = filename;
    _writeRecord(filename, source, records);
    final add = cmd.CommandSource_CommandInfo_GraphData(
      graphId: id,
      graphEnum: graph.graphEnum,
      parentGraphId: root.id,
      outRect: graph.outRect,
      sourceFileName: filename,
      sourceId: 0,
    );
    final commands = cmd.CommandSource(
      commandInfo: [
        cmd.CommandSource_CommandInfo(
          commandEnum: ce.CommandEnum.ACTION_GRAPH_ADD,
          isPlay: false,
          data: add.writeToBuffer(),
        ),
        if (area.topLeft != Offset.zero)
          cmd.CommandSource_CommandInfo(
            commandEnum: ce.CommandEnum.ACTION_GRAPH_MATRIX,
            isPlay: false,
            data: _translateArtwork(
              graph,
              root,
              refs,
              area.topLeft,
            ).writeToBuffer(),
          ),
      ],
    );
    root.childGraph.add(graph);
    _writeRecord(_nextName('command'), commands, refs.commandRecord);
    bundle.changed[routerPath] = refs.writeToBuffer();
    dirty = true;
    refresh();
    return id;
  }
}
