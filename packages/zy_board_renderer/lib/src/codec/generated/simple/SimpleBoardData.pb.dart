// This is a generated file - do not edit.
//
// Generated from SimpleBoardData.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class SimpleBoardData extends $pb.GeneratedMessage {
  factory SimpleBoardData({
    $core.Iterable<Path>? path,
  }) {
    final result = SimpleBoardData._();
    if (path != null) result.path.addAll(path);
    return result;
  }

  SimpleBoardData._();

  factory SimpleBoardData.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SimpleBoardData()..mergeFromBuffer(data, registry);
  factory SimpleBoardData.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SimpleBoardData()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SimpleBoardData',
      createEmptyInstance: SimpleBoardData.$_createMessage)
    ..pPM<Path>(1, _omitFieldNames ? '' : 'path',
        subBuilder: Path.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SimpleBoardData clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SimpleBoardData copyWith(void Function(SimpleBoardData) updates) =>
      super.copyWith((message) => updates(message as SimpleBoardData))
          as SimpleBoardData;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SimpleBoardData() / SimpleBoardData.new instead')
  static SimpleBoardData create() => SimpleBoardData._();
  static $pb.GeneratedMessage $_createMessage() => SimpleBoardData._();
  @$core.override
  SimpleBoardData createEmptyInstance() => SimpleBoardData._();
  @$core.pragma('dart2js:noInline')
  static SimpleBoardData getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SimpleBoardData>(
          SimpleBoardData.$_createMessage);
  static SimpleBoardData? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Path> get path => $_getList(0);
}

class PointF extends $pb.GeneratedMessage {
  factory PointF({
    $core.Iterable<$core.double>? value,
  }) {
    final result = PointF._();
    if (value != null) result.value.addAll(value);
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
    ..p<$core.double>(1, _omitFieldNames ? '' : 'value', $pb.PbFieldType.KF)
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
  $pb.PbList<$core.double> get value => $_getList(0);
}

class Paint extends $pb.GeneratedMessage {
  factory Paint({
    $core.double? width,
    $core.int? color,
    $core.bool? isDashed,
  }) {
    final result = Paint._();
    if (width != null) result.width = width;
    if (color != null) result.color = color;
    if (isDashed != null) result.isDashed = isDashed;
    return result;
  }

  Paint._();

  factory Paint.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Paint()..mergeFromBuffer(data, registry);
  factory Paint.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Paint()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Paint',
      createEmptyInstance: Paint.$_createMessage)
    ..aD(1, _omitFieldNames ? '' : 'width', fieldType: $pb.PbFieldType.OF)
    ..aI(2, _omitFieldNames ? '' : 'color')
    ..aOB(3, _omitFieldNames ? '' : 'isDashed', protoName: 'isDashed')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Paint clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Paint copyWith(void Function(Paint) updates) =>
      super.copyWith((message) => updates(message as Paint)) as Paint;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Paint() / Paint.new instead')
  static Paint create() => Paint._();
  static $pb.GeneratedMessage $_createMessage() => Paint._();
  @$core.override
  Paint createEmptyInstance() => Paint._();
  @$core.pragma('dart2js:noInline')
  static Paint getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Paint>(Paint.$_createMessage);
  static Paint? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get width => $_getN(0);
  @$pb.TagNumber(1)
  set width($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWidth() => $_has(0);
  @$pb.TagNumber(1)
  void clearWidth() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get color => $_getIZ(1);
  @$pb.TagNumber(2)
  set color($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasColor() => $_has(1);
  @$pb.TagNumber(2)
  void clearColor() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isDashed => $_getBF(2);
  @$pb.TagNumber(3)
  set isDashed($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsDashed() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsDashed() => $_clearField(3);
}

class Path extends $pb.GeneratedMessage {
  factory Path({
    $core.Iterable<PointF>? point,
    Paint? paint,
  }) {
    final result = Path._();
    if (point != null) result.point.addAll(point);
    if (paint != null) result.paint = paint;
    return result;
  }

  Path._();

  factory Path.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Path()..mergeFromBuffer(data, registry);
  factory Path.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Path()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Path',
      createEmptyInstance: Path.$_createMessage)
    ..pPM<PointF>(1, _omitFieldNames ? '' : 'point',
        subBuilder: PointF.$_createMessage)
    ..aOM<Paint>(2, _omitFieldNames ? '' : 'paint',
        subBuilder: Paint.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Path clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Path copyWith(void Function(Path) updates) =>
      super.copyWith((message) => updates(message as Path)) as Path;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Path() / Path.new instead')
  static Path create() => Path._();
  static $pb.GeneratedMessage $_createMessage() => Path._();
  @$core.override
  Path createEmptyInstance() => Path._();
  @$core.pragma('dart2js:noInline')
  static Path getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Path>(Path.$_createMessage);
  static Path? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PointF> get point => $_getList(0);

  @$pb.TagNumber(2)
  Paint get paint => $_getN(1);
  @$pb.TagNumber(2)
  set paint(Paint value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPaint() => $_has(1);
  @$pb.TagNumber(2)
  void clearPaint() => $_clearField(2);
  @$pb.TagNumber(2)
  Paint ensurePaint() => $_ensure(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
