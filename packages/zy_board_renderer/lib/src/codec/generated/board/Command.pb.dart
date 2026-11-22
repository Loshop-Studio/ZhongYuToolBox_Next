// This is a generated file - do not edit.
//
// Generated from Command.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'GraphSnapshot.pb.dart' as $5;
import 'Header.pb.dart' as $4;
import 'enums/CommandEnum.pbenum.dart' as $6;
import 'enums/GraphEnum.pbenum.dart' as $7;
import 'utils/Matrix.pb.dart' as $1;
import 'utils/Paint.pb.dart' as $2;
import 'utils/PointF.pb.dart' as $3;
import 'utils/RectF.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class CommandSource_CommandInfo_GraphData extends $pb.GeneratedMessage {
  factory CommandSource_CommandInfo_GraphData({
    $7.GraphEnum? graphEnum,
    $core.String? graphId,
    $0.RectF? outRect,
    $core.String? parentGraphId,
    $core.String? sourceFileName,
    $core.int? sourceId,
    $core.String? extras,
  }) {
    final result = CommandSource_CommandInfo_GraphData._();
    if (graphEnum != null) result.graphEnum = graphEnum;
    if (graphId != null) result.graphId = graphId;
    if (outRect != null) result.outRect = outRect;
    if (parentGraphId != null) result.parentGraphId = parentGraphId;
    if (sourceFileName != null) result.sourceFileName = sourceFileName;
    if (sourceId != null) result.sourceId = sourceId;
    if (extras != null) result.extras = extras;
    return result;
  }

  CommandSource_CommandInfo_GraphData._();

  factory CommandSource_CommandInfo_GraphData.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandSource_CommandInfo_GraphData()..mergeFromBuffer(data, registry);
  factory CommandSource_CommandInfo_GraphData.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandSource_CommandInfo_GraphData()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommandSource.CommandInfo.GraphData',
      createEmptyInstance: CommandSource_CommandInfo_GraphData.$_createMessage)
    ..aE<$7.GraphEnum>(1, _omitFieldNames ? '' : 'graphEnum',
        protoName: 'graphEnum', enumValues: $7.GraphEnum.values)
    ..aOS(2, _omitFieldNames ? '' : 'graphId', protoName: 'graphId')
    ..aOM<$0.RectF>(3, _omitFieldNames ? '' : 'outRect',
        protoName: 'outRect', subBuilder: $0.RectF.$_createMessage)
    ..aOS(4, _omitFieldNames ? '' : 'parentGraphId', protoName: 'parentGraphId')
    ..aOS(5, _omitFieldNames ? '' : 'sourceFileName',
        protoName: 'sourceFileName')
    ..aI(6, _omitFieldNames ? '' : 'sourceId', protoName: 'sourceId')
    ..aOS(7, _omitFieldNames ? '' : 'extras')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandSource_CommandInfo_GraphData clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandSource_CommandInfo_GraphData copyWith(
          void Function(CommandSource_CommandInfo_GraphData) updates) =>
      super.copyWith((message) =>
              updates(message as CommandSource_CommandInfo_GraphData))
          as CommandSource_CommandInfo_GraphData;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CommandSource_CommandInfo_GraphData() / CommandSource_CommandInfo_GraphData.new instead')
  static CommandSource_CommandInfo_GraphData create() =>
      CommandSource_CommandInfo_GraphData._();
  static $pb.GeneratedMessage $_createMessage() =>
      CommandSource_CommandInfo_GraphData._();
  @$core.override
  CommandSource_CommandInfo_GraphData createEmptyInstance() =>
      CommandSource_CommandInfo_GraphData._();
  @$core.pragma('dart2js:noInline')
  static CommandSource_CommandInfo_GraphData getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
              CommandSource_CommandInfo_GraphData>(
          CommandSource_CommandInfo_GraphData.$_createMessage);
  static CommandSource_CommandInfo_GraphData? _defaultInstance;

  @$pb.TagNumber(1)
  $7.GraphEnum get graphEnum => $_getN(0);
  @$pb.TagNumber(1)
  set graphEnum($7.GraphEnum value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasGraphEnum() => $_has(0);
  @$pb.TagNumber(1)
  void clearGraphEnum() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get graphId => $_getSZ(1);
  @$pb.TagNumber(2)
  set graphId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGraphId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGraphId() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.RectF get outRect => $_getN(2);
  @$pb.TagNumber(3)
  set outRect($0.RectF value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasOutRect() => $_has(2);
  @$pb.TagNumber(3)
  void clearOutRect() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.RectF ensureOutRect() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get parentGraphId => $_getSZ(3);
  @$pb.TagNumber(4)
  set parentGraphId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasParentGraphId() => $_has(3);
  @$pb.TagNumber(4)
  void clearParentGraphId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get sourceFileName => $_getSZ(4);
  @$pb.TagNumber(5)
  set sourceFileName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSourceFileName() => $_has(4);
  @$pb.TagNumber(5)
  void clearSourceFileName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get sourceId => $_getIZ(5);
  @$pb.TagNumber(6)
  set sourceId($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSourceId() => $_has(5);
  @$pb.TagNumber(6)
  void clearSourceId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get extras => $_getSZ(6);
  @$pb.TagNumber(7)
  set extras($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasExtras() => $_has(6);
  @$pb.TagNumber(7)
  void clearExtras() => $_clearField(7);
}

class CommandSource_CommandInfo_GraphRemove extends $pb.GeneratedMessage {
  factory CommandSource_CommandInfo_GraphRemove({
    $core.Iterable<CommandSource_CommandInfo_GraphData>? graphData,
  }) {
    final result = CommandSource_CommandInfo_GraphRemove._();
    if (graphData != null) result.graphData.addAll(graphData);
    return result;
  }

  CommandSource_CommandInfo_GraphRemove._();

  factory CommandSource_CommandInfo_GraphRemove.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandSource_CommandInfo_GraphRemove()..mergeFromBuffer(data, registry);
  factory CommandSource_CommandInfo_GraphRemove.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandSource_CommandInfo_GraphRemove()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommandSource.CommandInfo.GraphRemove',
      createEmptyInstance:
          CommandSource_CommandInfo_GraphRemove.$_createMessage)
    ..pPM<CommandSource_CommandInfo_GraphData>(
        1, _omitFieldNames ? '' : 'graphData',
        protoName: 'graphData',
        subBuilder: CommandSource_CommandInfo_GraphData.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandSource_CommandInfo_GraphRemove clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandSource_CommandInfo_GraphRemove copyWith(
          void Function(CommandSource_CommandInfo_GraphRemove) updates) =>
      super.copyWith((message) =>
              updates(message as CommandSource_CommandInfo_GraphRemove))
          as CommandSource_CommandInfo_GraphRemove;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CommandSource_CommandInfo_GraphRemove() / CommandSource_CommandInfo_GraphRemove.new instead')
  static CommandSource_CommandInfo_GraphRemove create() =>
      CommandSource_CommandInfo_GraphRemove._();
  static $pb.GeneratedMessage $_createMessage() =>
      CommandSource_CommandInfo_GraphRemove._();
  @$core.override
  CommandSource_CommandInfo_GraphRemove createEmptyInstance() =>
      CommandSource_CommandInfo_GraphRemove._();
  @$core.pragma('dart2js:noInline')
  static CommandSource_CommandInfo_GraphRemove getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
              CommandSource_CommandInfo_GraphRemove>(
          CommandSource_CommandInfo_GraphRemove.$_createMessage);
  static CommandSource_CommandInfo_GraphRemove? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<CommandSource_CommandInfo_GraphData> get graphData => $_getList(0);
}

class CommandSource_CommandInfo_GraphMatrix extends $pb.GeneratedMessage {
  factory CommandSource_CommandInfo_GraphMatrix({
    $core.Iterable<CommandSource_CommandInfo_GraphData>? graphData,
    $1.Matrix? originMatrix,
    $1.Matrix? lastMatrix,
    $core.String? sourceFileName,
    $core.int? sourceId,
  }) {
    final result = CommandSource_CommandInfo_GraphMatrix._();
    if (graphData != null) result.graphData.addAll(graphData);
    if (originMatrix != null) result.originMatrix = originMatrix;
    if (lastMatrix != null) result.lastMatrix = lastMatrix;
    if (sourceFileName != null) result.sourceFileName = sourceFileName;
    if (sourceId != null) result.sourceId = sourceId;
    return result;
  }

  CommandSource_CommandInfo_GraphMatrix._();

  factory CommandSource_CommandInfo_GraphMatrix.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandSource_CommandInfo_GraphMatrix()..mergeFromBuffer(data, registry);
  factory CommandSource_CommandInfo_GraphMatrix.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandSource_CommandInfo_GraphMatrix()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommandSource.CommandInfo.GraphMatrix',
      createEmptyInstance:
          CommandSource_CommandInfo_GraphMatrix.$_createMessage)
    ..pPM<CommandSource_CommandInfo_GraphData>(
        1, _omitFieldNames ? '' : 'graphData',
        protoName: 'graphData',
        subBuilder: CommandSource_CommandInfo_GraphData.$_createMessage)
    ..aOM<$1.Matrix>(2, _omitFieldNames ? '' : 'originMatrix',
        protoName: 'originMatrix', subBuilder: $1.Matrix.$_createMessage)
    ..aOM<$1.Matrix>(3, _omitFieldNames ? '' : 'lastMatrix',
        protoName: 'lastMatrix', subBuilder: $1.Matrix.$_createMessage)
    ..aOS(4, _omitFieldNames ? '' : 'sourceFileName',
        protoName: 'sourceFileName')
    ..aI(5, _omitFieldNames ? '' : 'sourceId', protoName: 'sourceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandSource_CommandInfo_GraphMatrix clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandSource_CommandInfo_GraphMatrix copyWith(
          void Function(CommandSource_CommandInfo_GraphMatrix) updates) =>
      super.copyWith((message) =>
              updates(message as CommandSource_CommandInfo_GraphMatrix))
          as CommandSource_CommandInfo_GraphMatrix;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CommandSource_CommandInfo_GraphMatrix() / CommandSource_CommandInfo_GraphMatrix.new instead')
  static CommandSource_CommandInfo_GraphMatrix create() =>
      CommandSource_CommandInfo_GraphMatrix._();
  static $pb.GeneratedMessage $_createMessage() =>
      CommandSource_CommandInfo_GraphMatrix._();
  @$core.override
  CommandSource_CommandInfo_GraphMatrix createEmptyInstance() =>
      CommandSource_CommandInfo_GraphMatrix._();
  @$core.pragma('dart2js:noInline')
  static CommandSource_CommandInfo_GraphMatrix getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
              CommandSource_CommandInfo_GraphMatrix>(
          CommandSource_CommandInfo_GraphMatrix.$_createMessage);
  static CommandSource_CommandInfo_GraphMatrix? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<CommandSource_CommandInfo_GraphData> get graphData => $_getList(0);

  @$pb.TagNumber(2)
  $1.Matrix get originMatrix => $_getN(1);
  @$pb.TagNumber(2)
  set originMatrix($1.Matrix value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasOriginMatrix() => $_has(1);
  @$pb.TagNumber(2)
  void clearOriginMatrix() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.Matrix ensureOriginMatrix() => $_ensure(1);

  @$pb.TagNumber(3)
  $1.Matrix get lastMatrix => $_getN(2);
  @$pb.TagNumber(3)
  set lastMatrix($1.Matrix value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasLastMatrix() => $_has(2);
  @$pb.TagNumber(3)
  void clearLastMatrix() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.Matrix ensureLastMatrix() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get sourceFileName => $_getSZ(3);
  @$pb.TagNumber(4)
  set sourceFileName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSourceFileName() => $_has(3);
  @$pb.TagNumber(4)
  void clearSourceFileName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get sourceId => $_getIZ(4);
  @$pb.TagNumber(5)
  set sourceId($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSourceId() => $_has(4);
  @$pb.TagNumber(5)
  void clearSourceId() => $_clearField(5);
}

class CommandSource_CommandInfo_GraphChange extends $pb.GeneratedMessage {
  factory CommandSource_CommandInfo_GraphChange({
    $core.String? graphId,
    $7.GraphEnum? graphEnum,
    $0.RectF? outRect,
    $core.String? content,
    $2.Paint? paint,
    $core.Iterable<$3.PointF>? points,
    $1.Matrix? renderMatrix,
    $core.String? filePath,
  }) {
    final result = CommandSource_CommandInfo_GraphChange._();
    if (graphId != null) result.graphId = graphId;
    if (graphEnum != null) result.graphEnum = graphEnum;
    if (outRect != null) result.outRect = outRect;
    if (content != null) result.content = content;
    if (paint != null) result.paint = paint;
    if (points != null) result.points.addAll(points);
    if (renderMatrix != null) result.renderMatrix = renderMatrix;
    if (filePath != null) result.filePath = filePath;
    return result;
  }

  CommandSource_CommandInfo_GraphChange._();

  factory CommandSource_CommandInfo_GraphChange.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandSource_CommandInfo_GraphChange()..mergeFromBuffer(data, registry);
  factory CommandSource_CommandInfo_GraphChange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandSource_CommandInfo_GraphChange()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommandSource.CommandInfo.GraphChange',
      createEmptyInstance:
          CommandSource_CommandInfo_GraphChange.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'graphId', protoName: 'graphId')
    ..aE<$7.GraphEnum>(2, _omitFieldNames ? '' : 'graphEnum',
        protoName: 'graphEnum', enumValues: $7.GraphEnum.values)
    ..aOM<$0.RectF>(3, _omitFieldNames ? '' : 'outRect',
        protoName: 'outRect', subBuilder: $0.RectF.$_createMessage)
    ..aOS(4, _omitFieldNames ? '' : 'content')
    ..aOM<$2.Paint>(5, _omitFieldNames ? '' : 'paint',
        subBuilder: $2.Paint.$_createMessage)
    ..pPM<$3.PointF>(6, _omitFieldNames ? '' : 'points',
        subBuilder: $3.PointF.$_createMessage)
    ..aOM<$1.Matrix>(7, _omitFieldNames ? '' : 'renderMatrix',
        protoName: 'renderMatrix', subBuilder: $1.Matrix.$_createMessage)
    ..aOS(8, _omitFieldNames ? '' : 'filePath', protoName: 'filePath')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandSource_CommandInfo_GraphChange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandSource_CommandInfo_GraphChange copyWith(
          void Function(CommandSource_CommandInfo_GraphChange) updates) =>
      super.copyWith((message) =>
              updates(message as CommandSource_CommandInfo_GraphChange))
          as CommandSource_CommandInfo_GraphChange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CommandSource_CommandInfo_GraphChange() / CommandSource_CommandInfo_GraphChange.new instead')
  static CommandSource_CommandInfo_GraphChange create() =>
      CommandSource_CommandInfo_GraphChange._();
  static $pb.GeneratedMessage $_createMessage() =>
      CommandSource_CommandInfo_GraphChange._();
  @$core.override
  CommandSource_CommandInfo_GraphChange createEmptyInstance() =>
      CommandSource_CommandInfo_GraphChange._();
  @$core.pragma('dart2js:noInline')
  static CommandSource_CommandInfo_GraphChange getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
              CommandSource_CommandInfo_GraphChange>(
          CommandSource_CommandInfo_GraphChange.$_createMessage);
  static CommandSource_CommandInfo_GraphChange? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get graphId => $_getSZ(0);
  @$pb.TagNumber(1)
  set graphId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGraphId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGraphId() => $_clearField(1);

  @$pb.TagNumber(2)
  $7.GraphEnum get graphEnum => $_getN(1);
  @$pb.TagNumber(2)
  set graphEnum($7.GraphEnum value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasGraphEnum() => $_has(1);
  @$pb.TagNumber(2)
  void clearGraphEnum() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.RectF get outRect => $_getN(2);
  @$pb.TagNumber(3)
  set outRect($0.RectF value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasOutRect() => $_has(2);
  @$pb.TagNumber(3)
  void clearOutRect() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.RectF ensureOutRect() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get content => $_getSZ(3);
  @$pb.TagNumber(4)
  set content($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasContent() => $_has(3);
  @$pb.TagNumber(4)
  void clearContent() => $_clearField(4);

  @$pb.TagNumber(5)
  $2.Paint get paint => $_getN(4);
  @$pb.TagNumber(5)
  set paint($2.Paint value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasPaint() => $_has(4);
  @$pb.TagNumber(5)
  void clearPaint() => $_clearField(5);
  @$pb.TagNumber(5)
  $2.Paint ensurePaint() => $_ensure(4);

  @$pb.TagNumber(6)
  $pb.PbList<$3.PointF> get points => $_getList(5);

  @$pb.TagNumber(7)
  $1.Matrix get renderMatrix => $_getN(6);
  @$pb.TagNumber(7)
  set renderMatrix($1.Matrix value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasRenderMatrix() => $_has(6);
  @$pb.TagNumber(7)
  void clearRenderMatrix() => $_clearField(7);
  @$pb.TagNumber(7)
  $1.Matrix ensureRenderMatrix() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.String get filePath => $_getSZ(7);
  @$pb.TagNumber(8)
  set filePath($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasFilePath() => $_has(7);
  @$pb.TagNumber(8)
  void clearFilePath() => $_clearField(8);
}

class CommandSource_CommandInfo_AudioStart extends $pb.GeneratedMessage {
  factory CommandSource_CommandInfo_AudioStart({
    $core.String? fileName,
    $fixnum.Int64? duration,
    $core.String? validate,
  }) {
    final result = CommandSource_CommandInfo_AudioStart._();
    if (fileName != null) result.fileName = fileName;
    if (duration != null) result.duration = duration;
    if (validate != null) result.validate = validate;
    return result;
  }

  CommandSource_CommandInfo_AudioStart._();

  factory CommandSource_CommandInfo_AudioStart.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandSource_CommandInfo_AudioStart()..mergeFromBuffer(data, registry);
  factory CommandSource_CommandInfo_AudioStart.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandSource_CommandInfo_AudioStart()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommandSource.CommandInfo.AudioStart',
      createEmptyInstance: CommandSource_CommandInfo_AudioStart.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'fileName', protoName: 'fileName')
    ..aInt64(2, _omitFieldNames ? '' : 'duration')
    ..aOS(3, _omitFieldNames ? '' : 'validate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandSource_CommandInfo_AudioStart clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandSource_CommandInfo_AudioStart copyWith(
          void Function(CommandSource_CommandInfo_AudioStart) updates) =>
      super.copyWith((message) =>
              updates(message as CommandSource_CommandInfo_AudioStart))
          as CommandSource_CommandInfo_AudioStart;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CommandSource_CommandInfo_AudioStart() / CommandSource_CommandInfo_AudioStart.new instead')
  static CommandSource_CommandInfo_AudioStart create() =>
      CommandSource_CommandInfo_AudioStart._();
  static $pb.GeneratedMessage $_createMessage() =>
      CommandSource_CommandInfo_AudioStart._();
  @$core.override
  CommandSource_CommandInfo_AudioStart createEmptyInstance() =>
      CommandSource_CommandInfo_AudioStart._();
  @$core.pragma('dart2js:noInline')
  static CommandSource_CommandInfo_AudioStart getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
              CommandSource_CommandInfo_AudioStart>(
          CommandSource_CommandInfo_AudioStart.$_createMessage);
  static CommandSource_CommandInfo_AudioStart? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fileName => $_getSZ(0);
  @$pb.TagNumber(1)
  set fileName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFileName() => $_has(0);
  @$pb.TagNumber(1)
  void clearFileName() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get duration => $_getI64(1);
  @$pb.TagNumber(2)
  set duration($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDuration() => $_has(1);
  @$pb.TagNumber(2)
  void clearDuration() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get validate => $_getSZ(2);
  @$pb.TagNumber(3)
  set validate($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasValidate() => $_has(2);
  @$pb.TagNumber(3)
  void clearValidate() => $_clearField(3);
}

class CommandSource_CommandInfo_CameraMatrix extends $pb.GeneratedMessage {
  factory CommandSource_CommandInfo_CameraMatrix({
    $1.Matrix? originMatrix,
    $1.Matrix? lastMatrix,
    $core.String? sourceFileName,
    $core.int? sourceId,
  }) {
    final result = CommandSource_CommandInfo_CameraMatrix._();
    if (originMatrix != null) result.originMatrix = originMatrix;
    if (lastMatrix != null) result.lastMatrix = lastMatrix;
    if (sourceFileName != null) result.sourceFileName = sourceFileName;
    if (sourceId != null) result.sourceId = sourceId;
    return result;
  }

  CommandSource_CommandInfo_CameraMatrix._();

  factory CommandSource_CommandInfo_CameraMatrix.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandSource_CommandInfo_CameraMatrix()..mergeFromBuffer(data, registry);
  factory CommandSource_CommandInfo_CameraMatrix.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandSource_CommandInfo_CameraMatrix()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommandSource.CommandInfo.CameraMatrix',
      createEmptyInstance:
          CommandSource_CommandInfo_CameraMatrix.$_createMessage)
    ..aOM<$1.Matrix>(1, _omitFieldNames ? '' : 'originMatrix',
        protoName: 'originMatrix', subBuilder: $1.Matrix.$_createMessage)
    ..aOM<$1.Matrix>(2, _omitFieldNames ? '' : 'lastMatrix',
        protoName: 'lastMatrix', subBuilder: $1.Matrix.$_createMessage)
    ..aOS(3, _omitFieldNames ? '' : 'sourceFileName',
        protoName: 'sourceFileName')
    ..aI(4, _omitFieldNames ? '' : 'sourceId', protoName: 'sourceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandSource_CommandInfo_CameraMatrix clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandSource_CommandInfo_CameraMatrix copyWith(
          void Function(CommandSource_CommandInfo_CameraMatrix) updates) =>
      super.copyWith((message) =>
              updates(message as CommandSource_CommandInfo_CameraMatrix))
          as CommandSource_CommandInfo_CameraMatrix;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CommandSource_CommandInfo_CameraMatrix() / CommandSource_CommandInfo_CameraMatrix.new instead')
  static CommandSource_CommandInfo_CameraMatrix create() =>
      CommandSource_CommandInfo_CameraMatrix._();
  static $pb.GeneratedMessage $_createMessage() =>
      CommandSource_CommandInfo_CameraMatrix._();
  @$core.override
  CommandSource_CommandInfo_CameraMatrix createEmptyInstance() =>
      CommandSource_CommandInfo_CameraMatrix._();
  @$core.pragma('dart2js:noInline')
  static CommandSource_CommandInfo_CameraMatrix getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
              CommandSource_CommandInfo_CameraMatrix>(
          CommandSource_CommandInfo_CameraMatrix.$_createMessage);
  static CommandSource_CommandInfo_CameraMatrix? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Matrix get originMatrix => $_getN(0);
  @$pb.TagNumber(1)
  set originMatrix($1.Matrix value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasOriginMatrix() => $_has(0);
  @$pb.TagNumber(1)
  void clearOriginMatrix() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Matrix ensureOriginMatrix() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.Matrix get lastMatrix => $_getN(1);
  @$pb.TagNumber(2)
  set lastMatrix($1.Matrix value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasLastMatrix() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastMatrix() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.Matrix ensureLastMatrix() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get sourceFileName => $_getSZ(2);
  @$pb.TagNumber(3)
  set sourceFileName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSourceFileName() => $_has(2);
  @$pb.TagNumber(3)
  void clearSourceFileName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get sourceId => $_getIZ(3);
  @$pb.TagNumber(4)
  set sourceId($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSourceId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSourceId() => $_clearField(4);
}

class CommandSource_CommandInfo_Camera extends $pb.GeneratedMessage {
  factory CommandSource_CommandInfo_Camera({
    $1.Matrix? originMatrix,
    $1.Matrix? lastMatrix,
  }) {
    final result = CommandSource_CommandInfo_Camera._();
    if (originMatrix != null) result.originMatrix = originMatrix;
    if (lastMatrix != null) result.lastMatrix = lastMatrix;
    return result;
  }

  CommandSource_CommandInfo_Camera._();

  factory CommandSource_CommandInfo_Camera.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandSource_CommandInfo_Camera()..mergeFromBuffer(data, registry);
  factory CommandSource_CommandInfo_Camera.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandSource_CommandInfo_Camera()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommandSource.CommandInfo.Camera',
      createEmptyInstance: CommandSource_CommandInfo_Camera.$_createMessage)
    ..aOM<$1.Matrix>(1, _omitFieldNames ? '' : 'originMatrix',
        protoName: 'originMatrix', subBuilder: $1.Matrix.$_createMessage)
    ..aOM<$1.Matrix>(2, _omitFieldNames ? '' : 'lastMatrix',
        protoName: 'lastMatrix', subBuilder: $1.Matrix.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandSource_CommandInfo_Camera clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandSource_CommandInfo_Camera copyWith(
          void Function(CommandSource_CommandInfo_Camera) updates) =>
      super.copyWith(
              (message) => updates(message as CommandSource_CommandInfo_Camera))
          as CommandSource_CommandInfo_Camera;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CommandSource_CommandInfo_Camera() / CommandSource_CommandInfo_Camera.new instead')
  static CommandSource_CommandInfo_Camera create() =>
      CommandSource_CommandInfo_Camera._();
  static $pb.GeneratedMessage $_createMessage() =>
      CommandSource_CommandInfo_Camera._();
  @$core.override
  CommandSource_CommandInfo_Camera createEmptyInstance() =>
      CommandSource_CommandInfo_Camera._();
  @$core.pragma('dart2js:noInline')
  static CommandSource_CommandInfo_Camera getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommandSource_CommandInfo_Camera>(
          CommandSource_CommandInfo_Camera.$_createMessage);
  static CommandSource_CommandInfo_Camera? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Matrix get originMatrix => $_getN(0);
  @$pb.TagNumber(1)
  set originMatrix($1.Matrix value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasOriginMatrix() => $_has(0);
  @$pb.TagNumber(1)
  void clearOriginMatrix() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Matrix ensureOriginMatrix() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.Matrix get lastMatrix => $_getN(1);
  @$pb.TagNumber(2)
  set lastMatrix($1.Matrix value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasLastMatrix() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastMatrix() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.Matrix ensureLastMatrix() => $_ensure(1);
}

class CommandSource_CommandInfo_Config extends $pb.GeneratedMessage {
  factory CommandSource_CommandInfo_Config({
    $core.int? originBackground,
    $core.int? lastBackground,
    $4.BackgroundLineConfig? originBackgroundLineConfig,
    $4.BackgroundLineConfig? lastBackgroundLineConfig,
  }) {
    final result = CommandSource_CommandInfo_Config._();
    if (originBackground != null) result.originBackground = originBackground;
    if (lastBackground != null) result.lastBackground = lastBackground;
    if (originBackgroundLineConfig != null)
      result.originBackgroundLineConfig = originBackgroundLineConfig;
    if (lastBackgroundLineConfig != null)
      result.lastBackgroundLineConfig = lastBackgroundLineConfig;
    return result;
  }

  CommandSource_CommandInfo_Config._();

  factory CommandSource_CommandInfo_Config.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandSource_CommandInfo_Config()..mergeFromBuffer(data, registry);
  factory CommandSource_CommandInfo_Config.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandSource_CommandInfo_Config()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommandSource.CommandInfo.Config',
      createEmptyInstance: CommandSource_CommandInfo_Config.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'originBackground',
        protoName: 'originBackground')
    ..aI(2, _omitFieldNames ? '' : 'lastBackground',
        protoName: 'lastBackground')
    ..aOM<$4.BackgroundLineConfig>(
        3, _omitFieldNames ? '' : 'originBackgroundLineConfig',
        protoName: 'originBackgroundLineConfig',
        subBuilder: $4.BackgroundLineConfig.$_createMessage)
    ..aOM<$4.BackgroundLineConfig>(
        4, _omitFieldNames ? '' : 'lastBackgroundLineConfig',
        protoName: 'lastBackgroundLineConfig',
        subBuilder: $4.BackgroundLineConfig.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandSource_CommandInfo_Config clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandSource_CommandInfo_Config copyWith(
          void Function(CommandSource_CommandInfo_Config) updates) =>
      super.copyWith(
              (message) => updates(message as CommandSource_CommandInfo_Config))
          as CommandSource_CommandInfo_Config;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CommandSource_CommandInfo_Config() / CommandSource_CommandInfo_Config.new instead')
  static CommandSource_CommandInfo_Config create() =>
      CommandSource_CommandInfo_Config._();
  static $pb.GeneratedMessage $_createMessage() =>
      CommandSource_CommandInfo_Config._();
  @$core.override
  CommandSource_CommandInfo_Config createEmptyInstance() =>
      CommandSource_CommandInfo_Config._();
  @$core.pragma('dart2js:noInline')
  static CommandSource_CommandInfo_Config getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommandSource_CommandInfo_Config>(
          CommandSource_CommandInfo_Config.$_createMessage);
  static CommandSource_CommandInfo_Config? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get originBackground => $_getIZ(0);
  @$pb.TagNumber(1)
  set originBackground($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOriginBackground() => $_has(0);
  @$pb.TagNumber(1)
  void clearOriginBackground() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get lastBackground => $_getIZ(1);
  @$pb.TagNumber(2)
  set lastBackground($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLastBackground() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastBackground() => $_clearField(2);

  @$pb.TagNumber(3)
  $4.BackgroundLineConfig get originBackgroundLineConfig => $_getN(2);
  @$pb.TagNumber(3)
  set originBackgroundLineConfig($4.BackgroundLineConfig value) =>
      $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasOriginBackgroundLineConfig() => $_has(2);
  @$pb.TagNumber(3)
  void clearOriginBackgroundLineConfig() => $_clearField(3);
  @$pb.TagNumber(3)
  $4.BackgroundLineConfig ensureOriginBackgroundLineConfig() => $_ensure(2);

  @$pb.TagNumber(4)
  $4.BackgroundLineConfig get lastBackgroundLineConfig => $_getN(3);
  @$pb.TagNumber(4)
  set lastBackgroundLineConfig($4.BackgroundLineConfig value) =>
      $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasLastBackgroundLineConfig() => $_has(3);
  @$pb.TagNumber(4)
  void clearLastBackgroundLineConfig() => $_clearField(4);
  @$pb.TagNumber(4)
  $4.BackgroundLineConfig ensureLastBackgroundLineConfig() => $_ensure(3);
}

class CommandSource_CommandInfo_CursorMove extends $pb.GeneratedMessage {
  factory CommandSource_CommandInfo_CursorMove({
    $core.String? sourceFileName,
    $core.int? sourceId,
  }) {
    final result = CommandSource_CommandInfo_CursorMove._();
    if (sourceFileName != null) result.sourceFileName = sourceFileName;
    if (sourceId != null) result.sourceId = sourceId;
    return result;
  }

  CommandSource_CommandInfo_CursorMove._();

  factory CommandSource_CommandInfo_CursorMove.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandSource_CommandInfo_CursorMove()..mergeFromBuffer(data, registry);
  factory CommandSource_CommandInfo_CursorMove.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandSource_CommandInfo_CursorMove()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommandSource.CommandInfo.CursorMove',
      createEmptyInstance: CommandSource_CommandInfo_CursorMove.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sourceFileName',
        protoName: 'sourceFileName')
    ..aI(2, _omitFieldNames ? '' : 'sourceId', protoName: 'sourceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandSource_CommandInfo_CursorMove clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandSource_CommandInfo_CursorMove copyWith(
          void Function(CommandSource_CommandInfo_CursorMove) updates) =>
      super.copyWith((message) =>
              updates(message as CommandSource_CommandInfo_CursorMove))
          as CommandSource_CommandInfo_CursorMove;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CommandSource_CommandInfo_CursorMove() / CommandSource_CommandInfo_CursorMove.new instead')
  static CommandSource_CommandInfo_CursorMove create() =>
      CommandSource_CommandInfo_CursorMove._();
  static $pb.GeneratedMessage $_createMessage() =>
      CommandSource_CommandInfo_CursorMove._();
  @$core.override
  CommandSource_CommandInfo_CursorMove createEmptyInstance() =>
      CommandSource_CommandInfo_CursorMove._();
  @$core.pragma('dart2js:noInline')
  static CommandSource_CommandInfo_CursorMove getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
              CommandSource_CommandInfo_CursorMove>(
          CommandSource_CommandInfo_CursorMove.$_createMessage);
  static CommandSource_CommandInfo_CursorMove? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sourceFileName => $_getSZ(0);
  @$pb.TagNumber(1)
  set sourceFileName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSourceFileName() => $_has(0);
  @$pb.TagNumber(1)
  void clearSourceFileName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get sourceId => $_getIZ(1);
  @$pb.TagNumber(2)
  set sourceId($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSourceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSourceId() => $_clearField(2);
}

class CommandSource_CommandInfo_REBUILD extends $pb.GeneratedMessage {
  factory CommandSource_CommandInfo_REBUILD({
    $5.PageSnapshot_GraphSnapshot? snapshot,
    $core.int? backgroundColor,
    $4.BackgroundLineConfig? backgroundLineConfig,
  }) {
    final result = CommandSource_CommandInfo_REBUILD._();
    if (snapshot != null) result.snapshot = snapshot;
    if (backgroundColor != null) result.backgroundColor = backgroundColor;
    if (backgroundLineConfig != null)
      result.backgroundLineConfig = backgroundLineConfig;
    return result;
  }

  CommandSource_CommandInfo_REBUILD._();

  factory CommandSource_CommandInfo_REBUILD.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandSource_CommandInfo_REBUILD()..mergeFromBuffer(data, registry);
  factory CommandSource_CommandInfo_REBUILD.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandSource_CommandInfo_REBUILD()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommandSource.CommandInfo.REBUILD',
      createEmptyInstance: CommandSource_CommandInfo_REBUILD.$_createMessage)
    ..aOM<$5.PageSnapshot_GraphSnapshot>(1, _omitFieldNames ? '' : 'snapshot',
        subBuilder: $5.PageSnapshot_GraphSnapshot.$_createMessage)
    ..aI(2, _omitFieldNames ? '' : 'backgroundColor',
        protoName: 'backgroundColor')
    ..aOM<$4.BackgroundLineConfig>(
        3, _omitFieldNames ? '' : 'backgroundLineConfig',
        protoName: 'backgroundLineConfig',
        subBuilder: $4.BackgroundLineConfig.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandSource_CommandInfo_REBUILD clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandSource_CommandInfo_REBUILD copyWith(
          void Function(CommandSource_CommandInfo_REBUILD) updates) =>
      super.copyWith((message) =>
              updates(message as CommandSource_CommandInfo_REBUILD))
          as CommandSource_CommandInfo_REBUILD;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CommandSource_CommandInfo_REBUILD() / CommandSource_CommandInfo_REBUILD.new instead')
  static CommandSource_CommandInfo_REBUILD create() =>
      CommandSource_CommandInfo_REBUILD._();
  static $pb.GeneratedMessage $_createMessage() =>
      CommandSource_CommandInfo_REBUILD._();
  @$core.override
  CommandSource_CommandInfo_REBUILD createEmptyInstance() =>
      CommandSource_CommandInfo_REBUILD._();
  @$core.pragma('dart2js:noInline')
  static CommandSource_CommandInfo_REBUILD getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommandSource_CommandInfo_REBUILD>(
          CommandSource_CommandInfo_REBUILD.$_createMessage);
  static CommandSource_CommandInfo_REBUILD? _defaultInstance;

  /// 新的快照
  @$pb.TagNumber(1)
  $5.PageSnapshot_GraphSnapshot get snapshot => $_getN(0);
  @$pb.TagNumber(1)
  set snapshot($5.PageSnapshot_GraphSnapshot value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSnapshot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSnapshot() => $_clearField(1);
  @$pb.TagNumber(1)
  $5.PageSnapshot_GraphSnapshot ensureSnapshot() => $_ensure(0);

  /// 背景色
  @$pb.TagNumber(2)
  $core.int get backgroundColor => $_getIZ(1);
  @$pb.TagNumber(2)
  set backgroundColor($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBackgroundColor() => $_has(1);
  @$pb.TagNumber(2)
  void clearBackgroundColor() => $_clearField(2);

  /// 背景线条配置
  @$pb.TagNumber(3)
  $4.BackgroundLineConfig get backgroundLineConfig => $_getN(2);
  @$pb.TagNumber(3)
  set backgroundLineConfig($4.BackgroundLineConfig value) =>
      $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasBackgroundLineConfig() => $_has(2);
  @$pb.TagNumber(3)
  void clearBackgroundLineConfig() => $_clearField(3);
  @$pb.TagNumber(3)
  $4.BackgroundLineConfig ensureBackgroundLineConfig() => $_ensure(2);
}

class CommandSource_CommandInfo extends $pb.GeneratedMessage {
  factory CommandSource_CommandInfo({
    $fixnum.Int64? delayTime,
    $fixnum.Int64? duration,
    $core.bool? isPlay,
    $6.CommandEnum? commandEnum,
    $core.List<$core.int>? data,
  }) {
    final result = CommandSource_CommandInfo._();
    if (delayTime != null) result.delayTime = delayTime;
    if (duration != null) result.duration = duration;
    if (isPlay != null) result.isPlay = isPlay;
    if (commandEnum != null) result.commandEnum = commandEnum;
    if (data != null) result.data = data;
    return result;
  }

  CommandSource_CommandInfo._();

  factory CommandSource_CommandInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandSource_CommandInfo()..mergeFromBuffer(data, registry);
  factory CommandSource_CommandInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandSource_CommandInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommandSource.CommandInfo',
      createEmptyInstance: CommandSource_CommandInfo.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'delayTime', protoName: 'delayTime')
    ..aInt64(2, _omitFieldNames ? '' : 'duration')
    ..aOB(3, _omitFieldNames ? '' : 'isPlay', protoName: 'isPlay')
    ..aE<$6.CommandEnum>(4, _omitFieldNames ? '' : 'commandEnum',
        protoName: 'commandEnum', enumValues: $6.CommandEnum.values)
    ..a<$core.List<$core.int>>(
        5, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandSource_CommandInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandSource_CommandInfo copyWith(
          void Function(CommandSource_CommandInfo) updates) =>
      super.copyWith((message) => updates(message as CommandSource_CommandInfo))
          as CommandSource_CommandInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use CommandSource_CommandInfo() / CommandSource_CommandInfo.new instead')
  static CommandSource_CommandInfo create() => CommandSource_CommandInfo._();
  static $pb.GeneratedMessage $_createMessage() =>
      CommandSource_CommandInfo._();
  @$core.override
  CommandSource_CommandInfo createEmptyInstance() =>
      CommandSource_CommandInfo._();
  @$core.pragma('dart2js:noInline')
  static CommandSource_CommandInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommandSource_CommandInfo>(
          CommandSource_CommandInfo.$_createMessage);
  static CommandSource_CommandInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get delayTime => $_getI64(0);
  @$pb.TagNumber(1)
  set delayTime($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDelayTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearDelayTime() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get duration => $_getI64(1);
  @$pb.TagNumber(2)
  set duration($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDuration() => $_has(1);
  @$pb.TagNumber(2)
  void clearDuration() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isPlay => $_getBF(2);
  @$pb.TagNumber(3)
  set isPlay($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsPlay() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsPlay() => $_clearField(3);

  @$pb.TagNumber(4)
  $6.CommandEnum get commandEnum => $_getN(3);
  @$pb.TagNumber(4)
  set commandEnum($6.CommandEnum value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCommandEnum() => $_has(3);
  @$pb.TagNumber(4)
  void clearCommandEnum() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.int> get data => $_getN(4);
  @$pb.TagNumber(5)
  set data($core.List<$core.int> value) => $_setBytes(4, value);
  @$pb.TagNumber(5)
  $core.bool hasData() => $_has(4);
  @$pb.TagNumber(5)
  void clearData() => $_clearField(5);
}

/// / 命令集合
class CommandSource extends $pb.GeneratedMessage {
  factory CommandSource({
    $core.Iterable<CommandSource_CommandInfo>? commandInfo,
  }) {
    final result = CommandSource._();
    if (commandInfo != null) result.commandInfo.addAll(commandInfo);
    return result;
  }

  CommandSource._();

  factory CommandSource.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandSource()..mergeFromBuffer(data, registry);
  factory CommandSource.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommandSource()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommandSource',
      createEmptyInstance: CommandSource.$_createMessage)
    ..pPM<CommandSource_CommandInfo>(1, _omitFieldNames ? '' : 'commandInfo',
        protoName: 'commandInfo',
        subBuilder: CommandSource_CommandInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandSource clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommandSource copyWith(void Function(CommandSource) updates) =>
      super.copyWith((message) => updates(message as CommandSource))
          as CommandSource;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CommandSource() / CommandSource.new instead')
  static CommandSource create() => CommandSource._();
  static $pb.GeneratedMessage $_createMessage() => CommandSource._();
  @$core.override
  CommandSource createEmptyInstance() => CommandSource._();
  @$core.pragma('dart2js:noInline')
  static CommandSource getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CommandSource>(
          CommandSource.$_createMessage);
  static CommandSource? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<CommandSource_CommandInfo> get commandInfo => $_getList(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
