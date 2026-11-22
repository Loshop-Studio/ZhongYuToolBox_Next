// This is a generated file - do not edit.
//
// Generated from enums/ModeEnum.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ModeEnum extends $pb.ProtobufEnum {
  static const ModeEnum ACTION_SELECT =
      ModeEnum._(0, _omitEnumNames ? '' : 'ACTION_SELECT');
  static const ModeEnum ACTION_WRITING =
      ModeEnum._(1, _omitEnumNames ? '' : 'ACTION_WRITING');
  static const ModeEnum ACTION_WRITING_MOVE =
      ModeEnum._(2, _omitEnumNames ? '' : 'ACTION_WRITING_MOVE');
  static const ModeEnum ACTION_WRITING_BEELINE =
      ModeEnum._(3, _omitEnumNames ? '' : 'ACTION_WRITING_BEELINE');
  static const ModeEnum ACTION_ERASER_WRITING =
      ModeEnum._(4, _omitEnumNames ? '' : 'ACTION_ERASER_WRITING');
  static const ModeEnum ACTION_DELETE =
      ModeEnum._(5, _omitEnumNames ? '' : 'ACTION_DELETE');
  static const ModeEnum ACTION_SEE =
      ModeEnum._(6, _omitEnumNames ? '' : 'ACTION_SEE');
  static const ModeEnum ACTION_TEXT =
      ModeEnum._(7, _omitEnumNames ? '' : 'ACTION_TEXT');
  static const ModeEnum ACTION_CURSOR =
      ModeEnum._(8, _omitEnumNames ? '' : 'ACTION_CURSOR');
  static const ModeEnum ACTION_NEW_SELECT =
      ModeEnum._(9, _omitEnumNames ? '' : 'ACTION_NEW_SELECT');
  static const ModeEnum ACTION_GEOMETRY =
      ModeEnum._(10, _omitEnumNames ? '' : 'ACTION_GEOMETRY');

  static const $core.List<ModeEnum> values = <ModeEnum>[
    ACTION_SELECT,
    ACTION_WRITING,
    ACTION_WRITING_MOVE,
    ACTION_WRITING_BEELINE,
    ACTION_ERASER_WRITING,
    ACTION_DELETE,
    ACTION_SEE,
    ACTION_TEXT,
    ACTION_CURSOR,
    ACTION_NEW_SELECT,
    ACTION_GEOMETRY,
  ];

  static final $core.List<ModeEnum?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 10);
  static ModeEnum? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ModeEnum._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
