// This is a generated file - do not edit.
//
// Generated from utils/Matrix.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Matrix extends $pb.GeneratedMessage {
  factory Matrix({
    $fixnum.Int64? eventTime,
    $core.double? scaleX,
    $core.double? skewX,
    $core.double? transX,
    $core.double? skewY,
    $core.double? scaleY,
    $core.double? transY,
    $core.double? perSp0,
    $core.double? perSp1,
    $core.double? perSp2,
  }) {
    final result = Matrix._();
    if (eventTime != null) result.eventTime = eventTime;
    if (scaleX != null) result.scaleX = scaleX;
    if (skewX != null) result.skewX = skewX;
    if (transX != null) result.transX = transX;
    if (skewY != null) result.skewY = skewY;
    if (scaleY != null) result.scaleY = scaleY;
    if (transY != null) result.transY = transY;
    if (perSp0 != null) result.perSp0 = perSp0;
    if (perSp1 != null) result.perSp1 = perSp1;
    if (perSp2 != null) result.perSp2 = perSp2;
    return result;
  }

  Matrix._();

  factory Matrix.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Matrix()..mergeFromBuffer(data, registry);
  factory Matrix.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Matrix()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Matrix',
      createEmptyInstance: Matrix.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'eventTime', protoName: 'eventTime')
    ..aD(2, _omitFieldNames ? '' : 'scaleX',
        protoName: 'scaleX', fieldType: $pb.PbFieldType.OF)
    ..aD(3, _omitFieldNames ? '' : 'skewX',
        protoName: 'skewX', fieldType: $pb.PbFieldType.OF)
    ..aD(4, _omitFieldNames ? '' : 'transX',
        protoName: 'transX', fieldType: $pb.PbFieldType.OF)
    ..aD(5, _omitFieldNames ? '' : 'skewY',
        protoName: 'skewY', fieldType: $pb.PbFieldType.OF)
    ..aD(6, _omitFieldNames ? '' : 'scaleY',
        protoName: 'scaleY', fieldType: $pb.PbFieldType.OF)
    ..aD(7, _omitFieldNames ? '' : 'transY',
        protoName: 'transY', fieldType: $pb.PbFieldType.OF)
    ..aD(8, _omitFieldNames ? '' : 'perSp0',
        protoName: 'perSp0', fieldType: $pb.PbFieldType.OF)
    ..aD(9, _omitFieldNames ? '' : 'perSp1',
        protoName: 'perSp1', fieldType: $pb.PbFieldType.OF)
    ..aD(10, _omitFieldNames ? '' : 'perSp2',
        protoName: 'perSp2', fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Matrix clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Matrix copyWith(void Function(Matrix) updates) =>
      super.copyWith((message) => updates(message as Matrix)) as Matrix;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Matrix() / Matrix.new instead')
  static Matrix create() => Matrix._();
  static $pb.GeneratedMessage $_createMessage() => Matrix._();
  @$core.override
  Matrix createEmptyInstance() => Matrix._();
  @$core.pragma('dart2js:noInline')
  static Matrix getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Matrix>(Matrix.$_createMessage);
  static Matrix? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get eventTime => $_getI64(0);
  @$pb.TagNumber(1)
  set eventTime($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEventTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearEventTime() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get scaleX => $_getN(1);
  @$pb.TagNumber(2)
  set scaleX($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasScaleX() => $_has(1);
  @$pb.TagNumber(2)
  void clearScaleX() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get skewX => $_getN(2);
  @$pb.TagNumber(3)
  set skewX($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSkewX() => $_has(2);
  @$pb.TagNumber(3)
  void clearSkewX() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get transX => $_getN(3);
  @$pb.TagNumber(4)
  set transX($core.double value) => $_setFloat(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTransX() => $_has(3);
  @$pb.TagNumber(4)
  void clearTransX() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get skewY => $_getN(4);
  @$pb.TagNumber(5)
  set skewY($core.double value) => $_setFloat(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSkewY() => $_has(4);
  @$pb.TagNumber(5)
  void clearSkewY() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get scaleY => $_getN(5);
  @$pb.TagNumber(6)
  set scaleY($core.double value) => $_setFloat(5, value);
  @$pb.TagNumber(6)
  $core.bool hasScaleY() => $_has(5);
  @$pb.TagNumber(6)
  void clearScaleY() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get transY => $_getN(6);
  @$pb.TagNumber(7)
  set transY($core.double value) => $_setFloat(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTransY() => $_has(6);
  @$pb.TagNumber(7)
  void clearTransY() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get perSp0 => $_getN(7);
  @$pb.TagNumber(8)
  set perSp0($core.double value) => $_setFloat(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPerSp0() => $_has(7);
  @$pb.TagNumber(8)
  void clearPerSp0() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get perSp1 => $_getN(8);
  @$pb.TagNumber(9)
  set perSp1($core.double value) => $_setFloat(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPerSp1() => $_has(8);
  @$pb.TagNumber(9)
  void clearPerSp1() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get perSp2 => $_getN(9);
  @$pb.TagNumber(10)
  set perSp2($core.double value) => $_setFloat(9, value);
  @$pb.TagNumber(10)
  $core.bool hasPerSp2() => $_has(9);
  @$pb.TagNumber(10)
  void clearPerSp2() => $_clearField(10);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
