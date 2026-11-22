// This is a generated file - do not edit.
//
// Generated from utils/Paint.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Paint extends $pb.GeneratedMessage {
  factory Paint({
    $core.double? width,
    $core.int? color,
    $core.double? spacing,
    $core.double? itemLength,
    $core.int? style,
    $core.double? textSize,
  }) {
    final result = Paint._();
    if (width != null) result.width = width;
    if (color != null) result.color = color;
    if (spacing != null) result.spacing = spacing;
    if (itemLength != null) result.itemLength = itemLength;
    if (style != null) result.style = style;
    if (textSize != null) result.textSize = textSize;
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
    ..aD(3, _omitFieldNames ? '' : 'spacing', fieldType: $pb.PbFieldType.OF)
    ..aD(4, _omitFieldNames ? '' : 'itemLength',
        protoName: 'itemLength', fieldType: $pb.PbFieldType.OF)
    ..aI(5, _omitFieldNames ? '' : 'style')
    ..aD(6, _omitFieldNames ? '' : 'textSize',
        protoName: 'textSize', fieldType: $pb.PbFieldType.OF)
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
  $core.double get spacing => $_getN(2);
  @$pb.TagNumber(3)
  set spacing($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSpacing() => $_has(2);
  @$pb.TagNumber(3)
  void clearSpacing() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get itemLength => $_getN(3);
  @$pb.TagNumber(4)
  set itemLength($core.double value) => $_setFloat(3, value);
  @$pb.TagNumber(4)
  $core.bool hasItemLength() => $_has(3);
  @$pb.TagNumber(4)
  void clearItemLength() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get style => $_getIZ(4);
  @$pb.TagNumber(5)
  set style($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStyle() => $_has(4);
  @$pb.TagNumber(5)
  void clearStyle() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get textSize => $_getN(5);
  @$pb.TagNumber(6)
  set textSize($core.double value) => $_setFloat(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTextSize() => $_has(5);
  @$pb.TagNumber(6)
  void clearTextSize() => $_clearField(6);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
