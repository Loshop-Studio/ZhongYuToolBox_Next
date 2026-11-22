// This is a generated file - do not edit.
//
// Generated from SketchGraphSnapshot.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart' as $0;

import 'SketchGraphSnapshot.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'SketchGraphSnapshot.pbenum.dart';

class GraphData extends $pb.GeneratedMessage {
  factory GraphData({
    GraphType? graphType,
    $core.Iterable<GraphData>? childGraph,
    $core.Iterable<$core.double>? matrix,
    $core.Iterable<$core.double>? childExtendMatrix,
    $core.double? width,
    $core.int? color,
    $core.bool? isSelect,
    $core.bool? showDelete,
    $0.Any? extra,
    $core.String? name,
    RectF? outRect,
  }) {
    final result = GraphData._();
    if (graphType != null) result.graphType = graphType;
    if (childGraph != null) result.childGraph.addAll(childGraph);
    if (matrix != null) result.matrix.addAll(matrix);
    if (childExtendMatrix != null)
      result.childExtendMatrix.addAll(childExtendMatrix);
    if (width != null) result.width = width;
    if (color != null) result.color = color;
    if (isSelect != null) result.isSelect = isSelect;
    if (showDelete != null) result.showDelete = showDelete;
    if (extra != null) result.extra = extra;
    if (name != null) result.name = name;
    if (outRect != null) result.outRect = outRect;
    return result;
  }

  GraphData._();

  factory GraphData.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GraphData()..mergeFromBuffer(data, registry);
  factory GraphData.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GraphData()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GraphData',
      createEmptyInstance: GraphData.$_createMessage)
    ..aE<GraphType>(1, _omitFieldNames ? '' : 'graphType',
        protoName: 'graphType', enumValues: GraphType.values)
    ..pPM<GraphData>(2, _omitFieldNames ? '' : 'childGraph',
        protoName: 'childGraph', subBuilder: GraphData.$_createMessage)
    ..p<$core.double>(3, _omitFieldNames ? '' : 'matrix', $pb.PbFieldType.KF)
    ..p<$core.double>(
        4, _omitFieldNames ? '' : 'childExtendMatrix', $pb.PbFieldType.KF,
        protoName: 'childExtendMatrix')
    ..aD(6, _omitFieldNames ? '' : 'width', fieldType: $pb.PbFieldType.OF)
    ..aI(7, _omitFieldNames ? '' : 'color')
    ..aOB(8, _omitFieldNames ? '' : 'isSelect', protoName: 'isSelect')
    ..aOB(9, _omitFieldNames ? '' : 'showDelete', protoName: 'showDelete')
    ..aOM<$0.Any>(10, _omitFieldNames ? '' : 'extra',
        subBuilder: $0.Any.$_createMessage)
    ..aOS(11, _omitFieldNames ? '' : 'name')
    ..aOM<RectF>(12, _omitFieldNames ? '' : 'outRect',
        protoName: 'outRect', subBuilder: RectF.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GraphData clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GraphData copyWith(void Function(GraphData) updates) =>
      super.copyWith((message) => updates(message as GraphData)) as GraphData;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GraphData() / GraphData.new instead')
  static GraphData create() => GraphData._();
  static $pb.GeneratedMessage $_createMessage() => GraphData._();
  @$core.override
  GraphData createEmptyInstance() => GraphData._();
  @$core.pragma('dart2js:noInline')
  static GraphData getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GraphData>(GraphData.$_createMessage);
  static GraphData? _defaultInstance;

  @$pb.TagNumber(1)
  GraphType get graphType => $_getN(0);
  @$pb.TagNumber(1)
  set graphType(GraphType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasGraphType() => $_has(0);
  @$pb.TagNumber(1)
  void clearGraphType() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<GraphData> get childGraph => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<$core.double> get matrix => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<$core.double> get childExtendMatrix => $_getList(3);

  @$pb.TagNumber(6)
  $core.double get width => $_getN(4);
  @$pb.TagNumber(6)
  set width($core.double value) => $_setFloat(4, value);
  @$pb.TagNumber(6)
  $core.bool hasWidth() => $_has(4);
  @$pb.TagNumber(6)
  void clearWidth() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get color => $_getIZ(5);
  @$pb.TagNumber(7)
  set color($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(7)
  $core.bool hasColor() => $_has(5);
  @$pb.TagNumber(7)
  void clearColor() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get isSelect => $_getBF(6);
  @$pb.TagNumber(8)
  set isSelect($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(8)
  $core.bool hasIsSelect() => $_has(6);
  @$pb.TagNumber(8)
  void clearIsSelect() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get showDelete => $_getBF(7);
  @$pb.TagNumber(9)
  set showDelete($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(9)
  $core.bool hasShowDelete() => $_has(7);
  @$pb.TagNumber(9)
  void clearShowDelete() => $_clearField(9);

  @$pb.TagNumber(10)
  $0.Any get extra => $_getN(8);
  @$pb.TagNumber(10)
  set extra($0.Any value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasExtra() => $_has(8);
  @$pb.TagNumber(10)
  void clearExtra() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Any ensureExtra() => $_ensure(8);

  @$pb.TagNumber(11)
  $core.String get name => $_getSZ(9);
  @$pb.TagNumber(11)
  set name($core.String value) => $_setString(9, value);
  @$pb.TagNumber(11)
  $core.bool hasName() => $_has(9);
  @$pb.TagNumber(11)
  void clearName() => $_clearField(11);

  @$pb.TagNumber(12)
  RectF get outRect => $_getN(10);
  @$pb.TagNumber(12)
  set outRect(RectF value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasOutRect() => $_has(10);
  @$pb.TagNumber(12)
  void clearOutRect() => $_clearField(12);
  @$pb.TagNumber(12)
  RectF ensureOutRect() => $_ensure(10);
}

class PointF extends $pb.GeneratedMessage {
  factory PointF({
    $core.double? x,
    $core.double? y,
  }) {
    final result = PointF._();
    if (x != null) result.x = x;
    if (y != null) result.y = y;
    return result;
  }

  PointF._();

  factory PointF.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PointF()..mergeFromBuffer(data, registry);
  factory PointF.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PointF()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PointF',
      createEmptyInstance: PointF.$_createMessage)
    ..aD(1, _omitFieldNames ? '' : 'x', fieldType: $pb.PbFieldType.OF)
    ..aD(2, _omitFieldNames ? '' : 'y', fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PointF clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PointF copyWith(void Function(PointF) updates) =>
      super.copyWith((message) => updates(message as PointF)) as PointF;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PointF() / PointF.new instead')
  static PointF create() => PointF._();
  static $pb.GeneratedMessage $_createMessage() => PointF._();
  @$core.override
  PointF createEmptyInstance() => PointF._();
  @$core.pragma('dart2js:noInline')
  static PointF getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PointF>(PointF.$_createMessage);
  static PointF? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get x => $_getN(0);
  @$pb.TagNumber(1)
  set x($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasX() => $_has(0);
  @$pb.TagNumber(1)
  void clearX() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get y => $_getN(1);
  @$pb.TagNumber(2)
  set y($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasY() => $_has(1);
  @$pb.TagNumber(2)
  void clearY() => $_clearField(2);
}

class Touch extends $pb.GeneratedMessage {
  factory Touch({
    $core.Iterable<PointF>? pointF,
  }) {
    final result = Touch._();
    if (pointF != null) result.pointF.addAll(pointF);
    return result;
  }

  Touch._();

  factory Touch.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Touch()..mergeFromBuffer(data, registry);
  factory Touch.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Touch()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Touch',
      createEmptyInstance: Touch.$_createMessage)
    ..pPM<PointF>(1, _omitFieldNames ? '' : 'pointF',
        protoName: 'pointF', subBuilder: PointF.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Touch clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Touch copyWith(void Function(Touch) updates) =>
      super.copyWith((message) => updates(message as Touch)) as Touch;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Touch() / Touch.new instead')
  static Touch create() => Touch._();
  static $pb.GeneratedMessage $_createMessage() => Touch._();
  @$core.override
  Touch createEmptyInstance() => Touch._();
  @$core.pragma('dart2js:noInline')
  static Touch getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Touch>(Touch.$_createMessage);
  static Touch? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PointF> get pointF => $_getList(0);
}

class File extends $pb.GeneratedMessage {
  factory File({
    $core.String? fileName,
    $core.int? width,
    $core.int? height,
    $core.int? viewWidth,
    $core.int? viewHeight,
    $core.int? positionFlag,
  }) {
    final result = File._();
    if (fileName != null) result.fileName = fileName;
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    if (viewWidth != null) result.viewWidth = viewWidth;
    if (viewHeight != null) result.viewHeight = viewHeight;
    if (positionFlag != null) result.positionFlag = positionFlag;
    return result;
  }

  File._();

  factory File.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      File()..mergeFromBuffer(data, registry);
  factory File.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      File()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'File',
      createEmptyInstance: File.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'fileName', protoName: 'fileName')
    ..aI(2, _omitFieldNames ? '' : 'width')
    ..aI(3, _omitFieldNames ? '' : 'height')
    ..aI(4, _omitFieldNames ? '' : 'viewWidth', protoName: 'viewWidth')
    ..aI(5, _omitFieldNames ? '' : 'viewHeight', protoName: 'viewHeight')
    ..aI(6, _omitFieldNames ? '' : 'positionFlag', protoName: 'positionFlag')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  File clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  File copyWith(void Function(File) updates) =>
      super.copyWith((message) => updates(message as File)) as File;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use File() / File.new instead')
  static File create() => File._();
  static $pb.GeneratedMessage $_createMessage() => File._();
  @$core.override
  File createEmptyInstance() => File._();
  @$core.pragma('dart2js:noInline')
  static File getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<File>(File.$_createMessage);
  static File? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fileName => $_getSZ(0);
  @$pb.TagNumber(1)
  set fileName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFileName() => $_has(0);
  @$pb.TagNumber(1)
  void clearFileName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get width => $_getIZ(1);
  @$pb.TagNumber(2)
  set width($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWidth() => $_has(1);
  @$pb.TagNumber(2)
  void clearWidth() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get height => $_getIZ(2);
  @$pb.TagNumber(3)
  set height($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeight() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get viewWidth => $_getIZ(3);
  @$pb.TagNumber(4)
  set viewWidth($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasViewWidth() => $_has(3);
  @$pb.TagNumber(4)
  void clearViewWidth() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get viewHeight => $_getIZ(4);
  @$pb.TagNumber(5)
  set viewHeight($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasViewHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearViewHeight() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get positionFlag => $_getIZ(5);
  @$pb.TagNumber(6)
  set positionFlag($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPositionFlag() => $_has(5);
  @$pb.TagNumber(6)
  void clearPositionFlag() => $_clearField(6);
}

class RectF extends $pb.GeneratedMessage {
  factory RectF({
    $core.double? left,
    $core.double? top,
    $core.double? right,
    $core.double? bottom,
  }) {
    final result = RectF._();
    if (left != null) result.left = left;
    if (top != null) result.top = top;
    if (right != null) result.right = right;
    if (bottom != null) result.bottom = bottom;
    return result;
  }

  RectF._();

  factory RectF.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RectF()..mergeFromBuffer(data, registry);
  factory RectF.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RectF()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RectF',
      createEmptyInstance: RectF.$_createMessage)
    ..aD(1, _omitFieldNames ? '' : 'left', fieldType: $pb.PbFieldType.OF)
    ..aD(2, _omitFieldNames ? '' : 'top', fieldType: $pb.PbFieldType.OF)
    ..aD(3, _omitFieldNames ? '' : 'right', fieldType: $pb.PbFieldType.OF)
    ..aD(4, _omitFieldNames ? '' : 'bottom', fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RectF clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RectF copyWith(void Function(RectF) updates) =>
      super.copyWith((message) => updates(message as RectF)) as RectF;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RectF() / RectF.new instead')
  static RectF create() => RectF._();
  static $pb.GeneratedMessage $_createMessage() => RectF._();
  @$core.override
  RectF createEmptyInstance() => RectF._();
  @$core.pragma('dart2js:noInline')
  static RectF getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RectF>(RectF.$_createMessage);
  static RectF? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get left => $_getN(0);
  @$pb.TagNumber(1)
  set left($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLeft() => $_has(0);
  @$pb.TagNumber(1)
  void clearLeft() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get top => $_getN(1);
  @$pb.TagNumber(2)
  set top($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTop() => $_has(1);
  @$pb.TagNumber(2)
  void clearTop() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get right => $_getN(2);
  @$pb.TagNumber(3)
  set right($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRight() => $_has(2);
  @$pb.TagNumber(3)
  void clearRight() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get bottom => $_getN(3);
  @$pb.TagNumber(4)
  set bottom($core.double value) => $_setFloat(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBottom() => $_has(3);
  @$pb.TagNumber(4)
  void clearBottom() => $_clearField(4);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
