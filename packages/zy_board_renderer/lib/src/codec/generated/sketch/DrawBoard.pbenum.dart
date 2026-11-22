// This is a generated file - do not edit.
//
// Generated from DrawBoard.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ActionEnum extends $pb.ProtobufEnum {
  static const ActionEnum ACTION_TOUCH =
      ActionEnum._(0, _omitEnumNames ? '' : 'ACTION_TOUCH');
  static const ActionEnum ACTION_MODE =
      ActionEnum._(1, _omitEnumNames ? '' : 'ACTION_MODE');
  static const ActionEnum ACTION_GRAPH =
      ActionEnum._(2, _omitEnumNames ? '' : 'ACTION_GRAPH');
  static const ActionEnum ACTION_WEB =
      ActionEnum._(3, _omitEnumNames ? '' : 'ACTION_WEB');
  static const ActionEnum ACTION_IMAGE =
      ActionEnum._(4, _omitEnumNames ? '' : 'ACTION_IMAGE');
  static const ActionEnum ACTION_FILTER =
      ActionEnum._(5, _omitEnumNames ? '' : 'ACTION_FILTER');
  static const ActionEnum ACTION_CLEAR_BOARD =
      ActionEnum._(6, _omitEnumNames ? '' : 'ACTION_CLEAR_BOARD');
  static const ActionEnum ACTION_NEXT =
      ActionEnum._(7, _omitEnumNames ? '' : 'ACTION_NEXT');
  static const ActionEnum ACTION_PREV =
      ActionEnum._(8, _omitEnumNames ? '' : 'ACTION_PREV');
  static const ActionEnum ACTION_AUDIO_START =
      ActionEnum._(9, _omitEnumNames ? '' : 'ACTION_AUDIO_START');
  static const ActionEnum ACTION_AUDIO_STOP =
      ActionEnum._(10, _omitEnumNames ? '' : 'ACTION_AUDIO_STOP');
  static const ActionEnum ACTION_ZOOM =
      ActionEnum._(11, _omitEnumNames ? '' : 'ACTION_ZOOM');
  static const ActionEnum ACTION_TRANS =
      ActionEnum._(12, _omitEnumNames ? '' : 'ACTION_TRANS');
  static const ActionEnum ACTION_DRAW_CONFIG =
      ActionEnum._(13, _omitEnumNames ? '' : 'ACTION_DRAW_CONFIG');
  static const ActionEnum ACTION_RESET_MATRIX =
      ActionEnum._(14, _omitEnumNames ? '' : 'ACTION_RESET_MATRIX');

  static const $core.List<ActionEnum> values = <ActionEnum>[
    ACTION_TOUCH,
    ACTION_MODE,
    ACTION_GRAPH,
    ACTION_WEB,
    ACTION_IMAGE,
    ACTION_FILTER,
    ACTION_CLEAR_BOARD,
    ACTION_NEXT,
    ACTION_PREV,
    ACTION_AUDIO_START,
    ACTION_AUDIO_STOP,
    ACTION_ZOOM,
    ACTION_TRANS,
    ACTION_DRAW_CONFIG,
    ACTION_RESET_MATRIX,
  ];

  static final $core.List<ActionEnum?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 14);
  static ActionEnum? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ActionEnum._(super.value, super.name);
}

class ActionModeConfig_Mode extends $pb.ProtobufEnum {
  static const ActionModeConfig_Mode ACTION_SELECT =
      ActionModeConfig_Mode._(0, _omitEnumNames ? '' : 'ACTION_SELECT');
  static const ActionModeConfig_Mode ACTION_WRITING =
      ActionModeConfig_Mode._(1, _omitEnumNames ? '' : 'ACTION_WRITING');
  static const ActionModeConfig_Mode ACTION_SHAPE_CIRCLE =
      ActionModeConfig_Mode._(2, _omitEnumNames ? '' : 'ACTION_SHAPE_CIRCLE');
  static const ActionModeConfig_Mode ACTION_SHAPE_RECT =
      ActionModeConfig_Mode._(3, _omitEnumNames ? '' : 'ACTION_SHAPE_RECT');
  static const ActionModeConfig_Mode ACTION_ERASER_VIEW =
      ActionModeConfig_Mode._(5, _omitEnumNames ? '' : 'ACTION_ERASER_VIEW');
  static const ActionModeConfig_Mode ACTION_ERASER_WRITING =
      ActionModeConfig_Mode._(6, _omitEnumNames ? '' : 'ACTION_ERASER_WRITING');
  static const ActionModeConfig_Mode ACTION_DELETE =
      ActionModeConfig_Mode._(7, _omitEnumNames ? '' : 'ACTION_DELETE');
  static const ActionModeConfig_Mode ACTION_WRITING_MOVE =
      ActionModeConfig_Mode._(8, _omitEnumNames ? '' : 'ACTION_WRITING_MOVE');
  static const ActionModeConfig_Mode ACTION_WRITING_MOVE_VERTICAL =
      ActionModeConfig_Mode._(
          9, _omitEnumNames ? '' : 'ACTION_WRITING_MOVE_VERTICAL');

  static const $core.List<ActionModeConfig_Mode> values =
      <ActionModeConfig_Mode>[
    ACTION_SELECT,
    ACTION_WRITING,
    ACTION_SHAPE_CIRCLE,
    ACTION_SHAPE_RECT,
    ACTION_ERASER_VIEW,
    ACTION_ERASER_WRITING,
    ACTION_DELETE,
    ACTION_WRITING_MOVE,
    ACTION_WRITING_MOVE_VERTICAL,
  ];

  static final $core.List<ActionModeConfig_Mode?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 9);
  static ActionModeConfig_Mode? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ActionModeConfig_Mode._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
