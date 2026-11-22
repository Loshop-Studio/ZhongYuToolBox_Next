// This is a generated file - do not edit.
//
// Generated from enums/PositionEnum.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class PositionEnum extends $pb.ProtobufEnum {
  static const PositionEnum TOP_LEFT =
      PositionEnum._(0, _omitEnumNames ? '' : 'TOP_LEFT');
  static const PositionEnum TOP_CENTER =
      PositionEnum._(1, _omitEnumNames ? '' : 'TOP_CENTER');
  static const PositionEnum TOP_RIGHT =
      PositionEnum._(2, _omitEnumNames ? '' : 'TOP_RIGHT');
  static const PositionEnum CENTER_LEFT =
      PositionEnum._(3, _omitEnumNames ? '' : 'CENTER_LEFT');
  static const PositionEnum CENTER =
      PositionEnum._(4, _omitEnumNames ? '' : 'CENTER');
  static const PositionEnum CENTER_RIGHT =
      PositionEnum._(5, _omitEnumNames ? '' : 'CENTER_RIGHT');
  static const PositionEnum BOTTOM_LEFT =
      PositionEnum._(6, _omitEnumNames ? '' : 'BOTTOM_LEFT');
  static const PositionEnum BOTTOM_CENTER =
      PositionEnum._(7, _omitEnumNames ? '' : 'BOTTOM_CENTER');
  static const PositionEnum BOTTOM_RIGHT =
      PositionEnum._(8, _omitEnumNames ? '' : 'BOTTOM_RIGHT');

  static const $core.List<PositionEnum> values = <PositionEnum>[
    TOP_LEFT,
    TOP_CENTER,
    TOP_RIGHT,
    CENTER_LEFT,
    CENTER,
    CENTER_RIGHT,
    BOTTOM_LEFT,
    BOTTOM_CENTER,
    BOTTOM_RIGHT,
  ];

  static final $core.List<PositionEnum?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 8);
  static PositionEnum? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PositionEnum._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
