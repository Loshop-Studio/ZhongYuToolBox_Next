// This is a generated file - do not edit.
//
// Generated from GraphSnapshot.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'enums/GraphEnum.pbenum.dart' as $4;
import 'utils/Matrix.pb.dart' as $0;
import 'utils/Paint.pb.dart' as $2;
import 'utils/PointF.pb.dart' as $3;
import 'utils/RectF.pb.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class PageSnapshot_GraphSnapshot extends $pb.GeneratedMessage {
  factory PageSnapshot_GraphSnapshot({
    $core.String? id,
    $4.GraphEnum? graphEnum,
    $1.RectF? outRect,
    $0.Matrix? matrix,
    $core.Iterable<PageSnapshot_GraphSnapshot>? childGraph,
    $core.String? sourceFileName,
    $core.int? sourceId,
    $core.int? backgroundColor,
    $2.Paint? paint,
    $core.String? content,
    $core.Iterable<$3.PointF>? pointList,
    $core.String? filePath,
  }) {
    final result = PageSnapshot_GraphSnapshot._();
    if (id != null) result.id = id;
    if (graphEnum != null) result.graphEnum = graphEnum;
    if (outRect != null) result.outRect = outRect;
    if (matrix != null) result.matrix = matrix;
    if (childGraph != null) result.childGraph.addAll(childGraph);
    if (sourceFileName != null) result.sourceFileName = sourceFileName;
    if (sourceId != null) result.sourceId = sourceId;
    if (backgroundColor != null) result.backgroundColor = backgroundColor;
    if (paint != null) result.paint = paint;
    if (content != null) result.content = content;
    if (pointList != null) result.pointList.addAll(pointList);
    if (filePath != null) result.filePath = filePath;
    return result;
  }

  PageSnapshot_GraphSnapshot._();

  factory PageSnapshot_GraphSnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PageSnapshot_GraphSnapshot()..mergeFromBuffer(data, registry);
  factory PageSnapshot_GraphSnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PageSnapshot_GraphSnapshot()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PageSnapshot.GraphSnapshot',
      createEmptyInstance: PageSnapshot_GraphSnapshot.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aE<$4.GraphEnum>(2, _omitFieldNames ? '' : 'graphEnum',
        protoName: 'graphEnum', enumValues: $4.GraphEnum.values)
    ..aOM<$1.RectF>(3, _omitFieldNames ? '' : 'outRect',
        protoName: 'outRect', subBuilder: $1.RectF.$_createMessage)
    ..aOM<$0.Matrix>(4, _omitFieldNames ? '' : 'matrix',
        subBuilder: $0.Matrix.$_createMessage)
    ..pPM<PageSnapshot_GraphSnapshot>(5, _omitFieldNames ? '' : 'childGraph',
        protoName: 'childGraph',
        subBuilder: PageSnapshot_GraphSnapshot.$_createMessage)
    ..aOS(6, _omitFieldNames ? '' : 'sourceFileName',
        protoName: 'sourceFileName')
    ..aI(7, _omitFieldNames ? '' : 'sourceId', protoName: 'sourceId')
    ..aI(8, _omitFieldNames ? '' : 'backgroundColor',
        protoName: 'backgroundColor')
    ..aOM<$2.Paint>(9, _omitFieldNames ? '' : 'paint',
        subBuilder: $2.Paint.$_createMessage)
    ..aOS(10, _omitFieldNames ? '' : 'content')
    ..pPM<$3.PointF>(11, _omitFieldNames ? '' : 'pointList',
        protoName: 'pointList', subBuilder: $3.PointF.$_createMessage)
    ..aOS(12, _omitFieldNames ? '' : 'filePath', protoName: 'filePath')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PageSnapshot_GraphSnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PageSnapshot_GraphSnapshot copyWith(
          void Function(PageSnapshot_GraphSnapshot) updates) =>
      super.copyWith(
              (message) => updates(message as PageSnapshot_GraphSnapshot))
          as PageSnapshot_GraphSnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use PageSnapshot_GraphSnapshot() / PageSnapshot_GraphSnapshot.new instead')
  static PageSnapshot_GraphSnapshot create() => PageSnapshot_GraphSnapshot._();
  static $pb.GeneratedMessage $_createMessage() =>
      PageSnapshot_GraphSnapshot._();
  @$core.override
  PageSnapshot_GraphSnapshot createEmptyInstance() =>
      PageSnapshot_GraphSnapshot._();
  @$core.pragma('dart2js:noInline')
  static PageSnapshot_GraphSnapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PageSnapshot_GraphSnapshot>(
          PageSnapshot_GraphSnapshot.$_createMessage);
  static PageSnapshot_GraphSnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $4.GraphEnum get graphEnum => $_getN(1);
  @$pb.TagNumber(2)
  set graphEnum($4.GraphEnum value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasGraphEnum() => $_has(1);
  @$pb.TagNumber(2)
  void clearGraphEnum() => $_clearField(2);

  @$pb.TagNumber(3)
  $1.RectF get outRect => $_getN(2);
  @$pb.TagNumber(3)
  set outRect($1.RectF value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasOutRect() => $_has(2);
  @$pb.TagNumber(3)
  void clearOutRect() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.RectF ensureOutRect() => $_ensure(2);

  @$pb.TagNumber(4)
  $0.Matrix get matrix => $_getN(3);
  @$pb.TagNumber(4)
  set matrix($0.Matrix value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasMatrix() => $_has(3);
  @$pb.TagNumber(4)
  void clearMatrix() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Matrix ensureMatrix() => $_ensure(3);

  @$pb.TagNumber(5)
  $pb.PbList<PageSnapshot_GraphSnapshot> get childGraph => $_getList(4);

  @$pb.TagNumber(6)
  $core.String get sourceFileName => $_getSZ(5);
  @$pb.TagNumber(6)
  set sourceFileName($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSourceFileName() => $_has(5);
  @$pb.TagNumber(6)
  void clearSourceFileName() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get sourceId => $_getIZ(6);
  @$pb.TagNumber(7)
  set sourceId($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSourceId() => $_has(6);
  @$pb.TagNumber(7)
  void clearSourceId() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get backgroundColor => $_getIZ(7);
  @$pb.TagNumber(8)
  set backgroundColor($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasBackgroundColor() => $_has(7);
  @$pb.TagNumber(8)
  void clearBackgroundColor() => $_clearField(8);

  @$pb.TagNumber(9)
  $2.Paint get paint => $_getN(8);
  @$pb.TagNumber(9)
  set paint($2.Paint value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasPaint() => $_has(8);
  @$pb.TagNumber(9)
  void clearPaint() => $_clearField(9);
  @$pb.TagNumber(9)
  $2.Paint ensurePaint() => $_ensure(8);

  @$pb.TagNumber(10)
  $core.String get content => $_getSZ(9);
  @$pb.TagNumber(10)
  set content($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasContent() => $_has(9);
  @$pb.TagNumber(10)
  void clearContent() => $_clearField(10);

  @$pb.TagNumber(11)
  $pb.PbList<$3.PointF> get pointList => $_getList(10);

  @$pb.TagNumber(12)
  $core.String get filePath => $_getSZ(11);
  @$pb.TagNumber(12)
  set filePath($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasFilePath() => $_has(11);
  @$pb.TagNumber(12)
  void clearFilePath() => $_clearField(12);
}

class PageSnapshot extends $pb.GeneratedMessage {
  factory PageSnapshot({
    $0.Matrix? cameraMatrix,
    PageSnapshot_GraphSnapshot? graphSnapshot,
  }) {
    final result = PageSnapshot._();
    if (cameraMatrix != null) result.cameraMatrix = cameraMatrix;
    if (graphSnapshot != null) result.graphSnapshot = graphSnapshot;
    return result;
  }

  PageSnapshot._();

  factory PageSnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PageSnapshot()..mergeFromBuffer(data, registry);
  factory PageSnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PageSnapshot()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PageSnapshot',
      createEmptyInstance: PageSnapshot.$_createMessage)
    ..aOM<$0.Matrix>(1, _omitFieldNames ? '' : 'cameraMatrix',
        protoName: 'cameraMatrix', subBuilder: $0.Matrix.$_createMessage)
    ..aOM<PageSnapshot_GraphSnapshot>(2, _omitFieldNames ? '' : 'graphSnapshot',
        protoName: 'graphSnapshot',
        subBuilder: PageSnapshot_GraphSnapshot.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PageSnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PageSnapshot copyWith(void Function(PageSnapshot) updates) =>
      super.copyWith((message) => updates(message as PageSnapshot))
          as PageSnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PageSnapshot() / PageSnapshot.new instead')
  static PageSnapshot create() => PageSnapshot._();
  static $pb.GeneratedMessage $_createMessage() => PageSnapshot._();
  @$core.override
  PageSnapshot createEmptyInstance() => PageSnapshot._();
  @$core.pragma('dart2js:noInline')
  static PageSnapshot getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PageSnapshot>(
          PageSnapshot.$_createMessage);
  static PageSnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Matrix get cameraMatrix => $_getN(0);
  @$pb.TagNumber(1)
  set cameraMatrix($0.Matrix value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCameraMatrix() => $_has(0);
  @$pb.TagNumber(1)
  void clearCameraMatrix() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Matrix ensureCameraMatrix() => $_ensure(0);

  @$pb.TagNumber(2)
  PageSnapshot_GraphSnapshot get graphSnapshot => $_getN(1);
  @$pb.TagNumber(2)
  set graphSnapshot(PageSnapshot_GraphSnapshot value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasGraphSnapshot() => $_has(1);
  @$pb.TagNumber(2)
  void clearGraphSnapshot() => $_clearField(2);
  @$pb.TagNumber(2)
  PageSnapshot_GraphSnapshot ensureGraphSnapshot() => $_ensure(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
