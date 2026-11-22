// This is a generated file - do not edit.
//
// Generated from enums/ScaleTypeEnum.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ScaleTypeEnum extends $pb.ProtobufEnum {
  static const ScaleTypeEnum MODE_MAX_WIDTH =
      ScaleTypeEnum._(0, _omitEnumNames ? '' : 'MODE_MAX_WIDTH');
  static const ScaleTypeEnum MODE_MAX_HEIGHT =
      ScaleTypeEnum._(1, _omitEnumNames ? '' : 'MODE_MAX_HEIGHT');
  static const ScaleTypeEnum MODE_MAX_VALUE =
      ScaleTypeEnum._(2, _omitEnumNames ? '' : 'MODE_MAX_VALUE');
  static const ScaleTypeEnum MODE_MIN_VALUE =
      ScaleTypeEnum._(3, _omitEnumNames ? '' : 'MODE_MIN_VALUE');
  static const ScaleTypeEnum MODE_ADAPTER =
      ScaleTypeEnum._(4, _omitEnumNames ? '' : 'MODE_ADAPTER');
  static const ScaleTypeEnum MODE_ADAPTER_8 =
      ScaleTypeEnum._(5, _omitEnumNames ? '' : 'MODE_ADAPTER_8');
  static const ScaleTypeEnum MODE_MATRIX_HEIGHT =
      ScaleTypeEnum._(6, _omitEnumNames ? '' : 'MODE_MATRIX_HEIGHT');

  static const $core.List<ScaleTypeEnum> values = <ScaleTypeEnum>[
    MODE_MAX_WIDTH,
    MODE_MAX_HEIGHT,
    MODE_MAX_VALUE,
    MODE_MIN_VALUE,
    MODE_ADAPTER,
    MODE_ADAPTER_8,
    MODE_MATRIX_HEIGHT,
  ];

  static final $core.List<ScaleTypeEnum?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static ScaleTypeEnum? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ScaleTypeEnum._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
