// This is a generated file - do not edit.
//
// Generated from enums/CommandEnum.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class CommandEnum extends $pb.ProtobufEnum {
  static const CommandEnum ACTION_DEFAULT =
      CommandEnum._(0, _omitEnumNames ? '' : 'ACTION_DEFAULT');
  static const CommandEnum ACTION_GRAPH_ADD =
      CommandEnum._(1, _omitEnumNames ? '' : 'ACTION_GRAPH_ADD');
  static const CommandEnum ACTION_GRAPH_REMOVE =
      CommandEnum._(2, _omitEnumNames ? '' : 'ACTION_GRAPH_REMOVE');
  static const CommandEnum ACTION_GRAPH_MATRIX =
      CommandEnum._(3, _omitEnumNames ? '' : 'ACTION_GRAPH_MATRIX');
  static const CommandEnum ACTION_GRAPH_CHANGE =
      CommandEnum._(4, _omitEnumNames ? '' : 'ACTION_GRAPH_CHANGE');
  static const CommandEnum ACTION_GRAPH_CUSTOM =
      CommandEnum._(5, _omitEnumNames ? '' : 'ACTION_GRAPH_CUSTOM');
  static const CommandEnum ACTION_AUDIO_START =
      CommandEnum._(6, _omitEnumNames ? '' : 'ACTION_AUDIO_START');
  static const CommandEnum ACTION_CAMERA =
      CommandEnum._(7, _omitEnumNames ? '' : 'ACTION_CAMERA');
  static const CommandEnum ACTION_CAMERA_MATRIX =
      CommandEnum._(8, _omitEnumNames ? '' : 'ACTION_CAMERA_MATRIX');
  static const CommandEnum ACTION_CONFIG =
      CommandEnum._(9, _omitEnumNames ? '' : 'ACTION_CONFIG');
  static const CommandEnum ACTION_RECORD_STOP =
      CommandEnum._(10, _omitEnumNames ? '' : 'ACTION_RECORD_STOP');
  static const CommandEnum ACTION_CURSOR_MOVE =
      CommandEnum._(11, _omitEnumNames ? '' : 'ACTION_CURSOR_MOVE');
  static const CommandEnum ACTION_REBUILD =
      CommandEnum._(12, _omitEnumNames ? '' : 'ACTION_REBUILD');

  static const $core.List<CommandEnum> values = <CommandEnum>[
    ACTION_DEFAULT,
    ACTION_GRAPH_ADD,
    ACTION_GRAPH_REMOVE,
    ACTION_GRAPH_MATRIX,
    ACTION_GRAPH_CHANGE,
    ACTION_GRAPH_CUSTOM,
    ACTION_AUDIO_START,
    ACTION_CAMERA,
    ACTION_CAMERA_MATRIX,
    ACTION_CONFIG,
    ACTION_RECORD_STOP,
    ACTION_CURSOR_MOVE,
    ACTION_REBUILD,
  ];

  static final $core.List<CommandEnum?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 12);
  static CommandEnum? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CommandEnum._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
