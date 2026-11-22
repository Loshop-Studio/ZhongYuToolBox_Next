// This is a generated file - do not edit.
//
// Generated from utils/TouchEvent.proto.

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

class TouchEvent_PointerProperties extends $pb.GeneratedMessage {
  factory TouchEvent_PointerProperties({
    $core.int? id,
    $core.int? toolType,
  }) {
    final result = TouchEvent_PointerProperties._();
    if (id != null) result.id = id;
    if (toolType != null) result.toolType = toolType;
    return result;
  }

  TouchEvent_PointerProperties._();

  factory TouchEvent_PointerProperties.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TouchEvent_PointerProperties()..mergeFromBuffer(data, registry);
  factory TouchEvent_PointerProperties.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TouchEvent_PointerProperties()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TouchEvent.PointerProperties',
      createEmptyInstance: TouchEvent_PointerProperties.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aI(2, _omitFieldNames ? '' : 'toolType', protoName: 'toolType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TouchEvent_PointerProperties clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TouchEvent_PointerProperties copyWith(
          void Function(TouchEvent_PointerProperties) updates) =>
      super.copyWith(
              (message) => updates(message as TouchEvent_PointerProperties))
          as TouchEvent_PointerProperties;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TouchEvent_PointerProperties() / TouchEvent_PointerProperties.new instead')
  static TouchEvent_PointerProperties create() =>
      TouchEvent_PointerProperties._();
  static $pb.GeneratedMessage $_createMessage() =>
      TouchEvent_PointerProperties._();
  @$core.override
  TouchEvent_PointerProperties createEmptyInstance() =>
      TouchEvent_PointerProperties._();
  @$core.pragma('dart2js:noInline')
  static TouchEvent_PointerProperties getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TouchEvent_PointerProperties>(
          TouchEvent_PointerProperties.$_createMessage);
  static TouchEvent_PointerProperties? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get toolType => $_getIZ(1);
  @$pb.TagNumber(2)
  set toolType($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasToolType() => $_has(1);
  @$pb.TagNumber(2)
  void clearToolType() => $_clearField(2);
}

class TouchEvent_PointerCoords extends $pb.GeneratedMessage {
  factory TouchEvent_PointerCoords({
    $core.double? x,
    $core.double? y,
  }) {
    final result = TouchEvent_PointerCoords._();
    if (x != null) result.x = x;
    if (y != null) result.y = y;
    return result;
  }

  TouchEvent_PointerCoords._();

  factory TouchEvent_PointerCoords.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TouchEvent_PointerCoords()..mergeFromBuffer(data, registry);
  factory TouchEvent_PointerCoords.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TouchEvent_PointerCoords()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TouchEvent.PointerCoords',
      createEmptyInstance: TouchEvent_PointerCoords.$_createMessage)
    ..aD(1, _omitFieldNames ? '' : 'x', fieldType: $pb.PbFieldType.OF)
    ..aD(2, _omitFieldNames ? '' : 'y', fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TouchEvent_PointerCoords clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TouchEvent_PointerCoords copyWith(
          void Function(TouchEvent_PointerCoords) updates) =>
      super.copyWith((message) => updates(message as TouchEvent_PointerCoords))
          as TouchEvent_PointerCoords;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TouchEvent_PointerCoords() / TouchEvent_PointerCoords.new instead')
  static TouchEvent_PointerCoords create() => TouchEvent_PointerCoords._();
  static $pb.GeneratedMessage $_createMessage() => TouchEvent_PointerCoords._();
  @$core.override
  TouchEvent_PointerCoords createEmptyInstance() =>
      TouchEvent_PointerCoords._();
  @$core.pragma('dart2js:noInline')
  static TouchEvent_PointerCoords getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TouchEvent_PointerCoords>(
          TouchEvent_PointerCoords.$_createMessage);
  static TouchEvent_PointerCoords? _defaultInstance;

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

class TouchEvent extends $pb.GeneratedMessage {
  factory TouchEvent({
    $fixnum.Int64? eventTime,
    $core.int? action,
    $core.double? x,
    $core.double? y,
    $core.int? pointerCount,
    $core.Iterable<TouchEvent_PointerProperties>? pointerProperties,
    $core.Iterable<TouchEvent_PointerCoords>? pointerCoords,
  }) {
    final result = TouchEvent._();
    if (eventTime != null) result.eventTime = eventTime;
    if (action != null) result.action = action;
    if (x != null) result.x = x;
    if (y != null) result.y = y;
    if (pointerCount != null) result.pointerCount = pointerCount;
    if (pointerProperties != null)
      result.pointerProperties.addAll(pointerProperties);
    if (pointerCoords != null) result.pointerCoords.addAll(pointerCoords);
    return result;
  }

  TouchEvent._();

  factory TouchEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TouchEvent()..mergeFromBuffer(data, registry);
  factory TouchEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TouchEvent()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TouchEvent',
      createEmptyInstance: TouchEvent.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'eventTime', protoName: 'eventTime')
    ..aI(2, _omitFieldNames ? '' : 'action')
    ..aD(3, _omitFieldNames ? '' : 'x', fieldType: $pb.PbFieldType.OF)
    ..aD(4, _omitFieldNames ? '' : 'y', fieldType: $pb.PbFieldType.OF)
    ..aI(5, _omitFieldNames ? '' : 'pointerCount', protoName: 'pointerCount')
    ..pPM<TouchEvent_PointerProperties>(
        6, _omitFieldNames ? '' : 'pointerProperties',
        protoName: 'pointerProperties',
        subBuilder: TouchEvent_PointerProperties.$_createMessage)
    ..pPM<TouchEvent_PointerCoords>(7, _omitFieldNames ? '' : 'pointerCoords',
        protoName: 'pointerCoords',
        subBuilder: TouchEvent_PointerCoords.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TouchEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TouchEvent copyWith(void Function(TouchEvent) updates) =>
      super.copyWith((message) => updates(message as TouchEvent)) as TouchEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TouchEvent() / TouchEvent.new instead')
  static TouchEvent create() => TouchEvent._();
  static $pb.GeneratedMessage $_createMessage() => TouchEvent._();
  @$core.override
  TouchEvent createEmptyInstance() => TouchEvent._();
  @$core.pragma('dart2js:noInline')
  static TouchEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TouchEvent>(TouchEvent.$_createMessage);
  static TouchEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get eventTime => $_getI64(0);
  @$pb.TagNumber(1)
  set eventTime($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEventTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearEventTime() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get action => $_getIZ(1);
  @$pb.TagNumber(2)
  set action($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAction() => $_has(1);
  @$pb.TagNumber(2)
  void clearAction() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get x => $_getN(2);
  @$pb.TagNumber(3)
  set x($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasX() => $_has(2);
  @$pb.TagNumber(3)
  void clearX() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get y => $_getN(3);
  @$pb.TagNumber(4)
  set y($core.double value) => $_setFloat(3, value);
  @$pb.TagNumber(4)
  $core.bool hasY() => $_has(3);
  @$pb.TagNumber(4)
  void clearY() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get pointerCount => $_getIZ(4);
  @$pb.TagNumber(5)
  set pointerCount($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPointerCount() => $_has(4);
  @$pb.TagNumber(5)
  void clearPointerCount() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<TouchEvent_PointerProperties> get pointerProperties =>
      $_getList(5);

  @$pb.TagNumber(7)
  $pb.PbList<TouchEvent_PointerCoords> get pointerCoords => $_getList(6);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
