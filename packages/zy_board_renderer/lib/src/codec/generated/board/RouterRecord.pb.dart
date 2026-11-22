// This is a generated file - do not edit.
//
// Generated from RouterRecord.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class RouterRecord_SourceCommandRecord extends $pb.GeneratedMessage {
  factory RouterRecord_SourceCommandRecord({
    $core.String? fileName,
    $core.String? validate,
  }) {
    final result = RouterRecord_SourceCommandRecord._();
    if (fileName != null) result.fileName = fileName;
    if (validate != null) result.validate = validate;
    return result;
  }

  RouterRecord_SourceCommandRecord._();

  factory RouterRecord_SourceCommandRecord.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RouterRecord_SourceCommandRecord()..mergeFromBuffer(data, registry);
  factory RouterRecord_SourceCommandRecord.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RouterRecord_SourceCommandRecord()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RouterRecord.SourceCommandRecord',
      createEmptyInstance: RouterRecord_SourceCommandRecord.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'fileName', protoName: 'fileName')
    ..aOS(2, _omitFieldNames ? '' : 'validate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RouterRecord_SourceCommandRecord clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RouterRecord_SourceCommandRecord copyWith(
          void Function(RouterRecord_SourceCommandRecord) updates) =>
      super.copyWith(
              (message) => updates(message as RouterRecord_SourceCommandRecord))
          as RouterRecord_SourceCommandRecord;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use RouterRecord_SourceCommandRecord() / RouterRecord_SourceCommandRecord.new instead')
  static RouterRecord_SourceCommandRecord create() =>
      RouterRecord_SourceCommandRecord._();
  static $pb.GeneratedMessage $_createMessage() =>
      RouterRecord_SourceCommandRecord._();
  @$core.override
  RouterRecord_SourceCommandRecord createEmptyInstance() =>
      RouterRecord_SourceCommandRecord._();
  @$core.pragma('dart2js:noInline')
  static RouterRecord_SourceCommandRecord getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RouterRecord_SourceCommandRecord>(
          RouterRecord_SourceCommandRecord.$_createMessage);
  static RouterRecord_SourceCommandRecord? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fileName => $_getSZ(0);
  @$pb.TagNumber(1)
  set fileName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFileName() => $_has(0);
  @$pb.TagNumber(1)
  void clearFileName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get validate => $_getSZ(1);
  @$pb.TagNumber(2)
  set validate($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValidate() => $_has(1);
  @$pb.TagNumber(2)
  void clearValidate() => $_clearField(2);
}

/// /记录文件，用于校验文件完整性
/// / commandRecord 记录命令文件
/// / SourceAudioRecord 记录音频文件
/// / touchSourceRecord，matrixSourceRecord，audioSourceRecord 记录的是每条命令可能使用到的数据，
/// / 但记录的仅仅是这类数据存放的文件名，用于最后的完整性校验。
/// / 如果命令中使用到了数据，该命令中会说明去哪个文件中找
class RouterRecord extends $pb.GeneratedMessage {
  factory RouterRecord({
    $core.Iterable<RouterRecord_SourceCommandRecord>? commandRecord,
    $core.Iterable<RouterRecord_SourceCommandRecord>? audioRecord,
    $core.Iterable<RouterRecord_SourceCommandRecord>? touchSourceRecord,
    $core.Iterable<RouterRecord_SourceCommandRecord>? matrixSourceRecord,
    $core.Iterable<RouterRecord_SourceCommandRecord>? fileSourceRecord,
    $core.Iterable<RouterRecord_SourceCommandRecord>? textSourceRecord,
    $core.Iterable<RouterRecord_SourceCommandRecord>? geometrySourceRecord,
  }) {
    final result = RouterRecord._();
    if (commandRecord != null) result.commandRecord.addAll(commandRecord);
    if (audioRecord != null) result.audioRecord.addAll(audioRecord);
    if (touchSourceRecord != null)
      result.touchSourceRecord.addAll(touchSourceRecord);
    if (matrixSourceRecord != null)
      result.matrixSourceRecord.addAll(matrixSourceRecord);
    if (fileSourceRecord != null)
      result.fileSourceRecord.addAll(fileSourceRecord);
    if (textSourceRecord != null)
      result.textSourceRecord.addAll(textSourceRecord);
    if (geometrySourceRecord != null)
      result.geometrySourceRecord.addAll(geometrySourceRecord);
    return result;
  }

  RouterRecord._();

  factory RouterRecord.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RouterRecord()..mergeFromBuffer(data, registry);
  factory RouterRecord.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RouterRecord()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RouterRecord',
      createEmptyInstance: RouterRecord.$_createMessage)
    ..pPM<RouterRecord_SourceCommandRecord>(
        1, _omitFieldNames ? '' : 'commandRecord',
        protoName: 'commandRecord',
        subBuilder: RouterRecord_SourceCommandRecord.$_createMessage)
    ..pPM<RouterRecord_SourceCommandRecord>(
        2, _omitFieldNames ? '' : 'audioRecord',
        protoName: 'audioRecord',
        subBuilder: RouterRecord_SourceCommandRecord.$_createMessage)
    ..pPM<RouterRecord_SourceCommandRecord>(
        3, _omitFieldNames ? '' : 'touchSourceRecord',
        protoName: 'touchSourceRecord',
        subBuilder: RouterRecord_SourceCommandRecord.$_createMessage)
    ..pPM<RouterRecord_SourceCommandRecord>(
        4, _omitFieldNames ? '' : 'matrixSourceRecord',
        protoName: 'matrixSourceRecord',
        subBuilder: RouterRecord_SourceCommandRecord.$_createMessage)
    ..pPM<RouterRecord_SourceCommandRecord>(
        5, _omitFieldNames ? '' : 'fileSourceRecord',
        protoName: 'fileSourceRecord',
        subBuilder: RouterRecord_SourceCommandRecord.$_createMessage)
    ..pPM<RouterRecord_SourceCommandRecord>(
        6, _omitFieldNames ? '' : 'textSourceRecord',
        protoName: 'textSourceRecord',
        subBuilder: RouterRecord_SourceCommandRecord.$_createMessage)
    ..pPM<RouterRecord_SourceCommandRecord>(
        7, _omitFieldNames ? '' : 'geometrySourceRecord',
        protoName: 'geometrySourceRecord',
        subBuilder: RouterRecord_SourceCommandRecord.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RouterRecord clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RouterRecord copyWith(void Function(RouterRecord) updates) =>
      super.copyWith((message) => updates(message as RouterRecord))
          as RouterRecord;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RouterRecord() / RouterRecord.new instead')
  static RouterRecord create() => RouterRecord._();
  static $pb.GeneratedMessage $_createMessage() => RouterRecord._();
  @$core.override
  RouterRecord createEmptyInstance() => RouterRecord._();
  @$core.pragma('dart2js:noInline')
  static RouterRecord getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RouterRecord>(
          RouterRecord.$_createMessage);
  static RouterRecord? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<RouterRecord_SourceCommandRecord> get commandRecord =>
      $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<RouterRecord_SourceCommandRecord> get audioRecord => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<RouterRecord_SourceCommandRecord> get touchSourceRecord =>
      $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<RouterRecord_SourceCommandRecord> get matrixSourceRecord =>
      $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<RouterRecord_SourceCommandRecord> get fileSourceRecord =>
      $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<RouterRecord_SourceCommandRecord> get textSourceRecord =>
      $_getList(5);

  @$pb.TagNumber(7)
  $pb.PbList<RouterRecord_SourceCommandRecord> get geometrySourceRecord =>
      $_getList(6);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
