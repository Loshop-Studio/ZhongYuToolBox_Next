// This is a generated file - do not edit.
//
// Generated from Source.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'enums/GeometryEnum.pbenum.dart' as $4;
import 'utils/Matrix.pb.dart' as $2;
import 'utils/Paint.pb.dart' as $1;
import 'utils/PointF.pb.dart' as $3;
import 'utils/TouchEvent.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class TouchSource_TouchInfo extends $pb.GeneratedMessage {
  factory TouchSource_TouchInfo({
    $core.Iterable<$0.TouchEvent>? touchEvent,
    $1.Paint? paint,
  }) {
    final result = TouchSource_TouchInfo._();
    if (touchEvent != null) result.touchEvent.addAll(touchEvent);
    if (paint != null) result.paint = paint;
    return result;
  }

  TouchSource_TouchInfo._();

  factory TouchSource_TouchInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TouchSource_TouchInfo()..mergeFromBuffer(data, registry);
  factory TouchSource_TouchInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TouchSource_TouchInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TouchSource.TouchInfo',
      createEmptyInstance: TouchSource_TouchInfo.$_createMessage)
    ..pPM<$0.TouchEvent>(1, _omitFieldNames ? '' : 'touchEvent',
        protoName: 'touchEvent', subBuilder: $0.TouchEvent.$_createMessage)
    ..aOM<$1.Paint>(2, _omitFieldNames ? '' : 'paint',
        subBuilder: $1.Paint.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TouchSource_TouchInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TouchSource_TouchInfo copyWith(
          void Function(TouchSource_TouchInfo) updates) =>
      super.copyWith((message) => updates(message as TouchSource_TouchInfo))
          as TouchSource_TouchInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use TouchSource_TouchInfo() / TouchSource_TouchInfo.new instead')
  static TouchSource_TouchInfo create() => TouchSource_TouchInfo._();
  static $pb.GeneratedMessage $_createMessage() => TouchSource_TouchInfo._();
  @$core.override
  TouchSource_TouchInfo createEmptyInstance() => TouchSource_TouchInfo._();
  @$core.pragma('dart2js:noInline')
  static TouchSource_TouchInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TouchSource_TouchInfo>(
          TouchSource_TouchInfo.$_createMessage);
  static TouchSource_TouchInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$0.TouchEvent> get touchEvent => $_getList(0);

  @$pb.TagNumber(2)
  $1.Paint get paint => $_getN(1);
  @$pb.TagNumber(2)
  set paint($1.Paint value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPaint() => $_has(1);
  @$pb.TagNumber(2)
  void clearPaint() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.Paint ensurePaint() => $_ensure(1);
}

class TouchSource extends $pb.GeneratedMessage {
  factory TouchSource({
    $core.Iterable<TouchSource_TouchInfo>? touchInfo,
  }) {
    final result = TouchSource._();
    if (touchInfo != null) result.touchInfo.addAll(touchInfo);
    return result;
  }

  TouchSource._();

  factory TouchSource.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TouchSource()..mergeFromBuffer(data, registry);
  factory TouchSource.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TouchSource()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TouchSource',
      createEmptyInstance: TouchSource.$_createMessage)
    ..pPM<TouchSource_TouchInfo>(1, _omitFieldNames ? '' : 'touchInfo',
        protoName: 'touchInfo',
        subBuilder: TouchSource_TouchInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TouchSource clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TouchSource copyWith(void Function(TouchSource) updates) =>
      super.copyWith((message) => updates(message as TouchSource))
          as TouchSource;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TouchSource() / TouchSource.new instead')
  static TouchSource create() => TouchSource._();
  static $pb.GeneratedMessage $_createMessage() => TouchSource._();
  @$core.override
  TouchSource createEmptyInstance() => TouchSource._();
  @$core.pragma('dart2js:noInline')
  static TouchSource getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TouchSource>(
          TouchSource.$_createMessage);
  static TouchSource? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TouchSource_TouchInfo> get touchInfo => $_getList(0);
}

class MatrixSource_MatrixInfo extends $pb.GeneratedMessage {
  factory MatrixSource_MatrixInfo({
    $core.Iterable<$2.Matrix>? matrix,
  }) {
    final result = MatrixSource_MatrixInfo._();
    if (matrix != null) result.matrix.addAll(matrix);
    return result;
  }

  MatrixSource_MatrixInfo._();

  factory MatrixSource_MatrixInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MatrixSource_MatrixInfo()..mergeFromBuffer(data, registry);
  factory MatrixSource_MatrixInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MatrixSource_MatrixInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MatrixSource.MatrixInfo',
      createEmptyInstance: MatrixSource_MatrixInfo.$_createMessage)
    ..pPM<$2.Matrix>(1, _omitFieldNames ? '' : 'matrix',
        subBuilder: $2.Matrix.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixSource_MatrixInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixSource_MatrixInfo copyWith(
          void Function(MatrixSource_MatrixInfo) updates) =>
      super.copyWith((message) => updates(message as MatrixSource_MatrixInfo))
          as MatrixSource_MatrixInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use MatrixSource_MatrixInfo() / MatrixSource_MatrixInfo.new instead')
  static MatrixSource_MatrixInfo create() => MatrixSource_MatrixInfo._();
  static $pb.GeneratedMessage $_createMessage() => MatrixSource_MatrixInfo._();
  @$core.override
  MatrixSource_MatrixInfo createEmptyInstance() => MatrixSource_MatrixInfo._();
  @$core.pragma('dart2js:noInline')
  static MatrixSource_MatrixInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MatrixSource_MatrixInfo>(
          MatrixSource_MatrixInfo.$_createMessage);
  static MatrixSource_MatrixInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$2.Matrix> get matrix => $_getList(0);
}

class MatrixSource extends $pb.GeneratedMessage {
  factory MatrixSource({
    $core.Iterable<MatrixSource_MatrixInfo>? matrixInfo,
  }) {
    final result = MatrixSource._();
    if (matrixInfo != null) result.matrixInfo.addAll(matrixInfo);
    return result;
  }

  MatrixSource._();

  factory MatrixSource.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MatrixSource()..mergeFromBuffer(data, registry);
  factory MatrixSource.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MatrixSource()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MatrixSource',
      createEmptyInstance: MatrixSource.$_createMessage)
    ..pPM<MatrixSource_MatrixInfo>(1, _omitFieldNames ? '' : 'matrixInfo',
        protoName: 'matrixInfo',
        subBuilder: MatrixSource_MatrixInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixSource clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixSource copyWith(void Function(MatrixSource) updates) =>
      super.copyWith((message) => updates(message as MatrixSource))
          as MatrixSource;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MatrixSource() / MatrixSource.new instead')
  static MatrixSource create() => MatrixSource._();
  static $pb.GeneratedMessage $_createMessage() => MatrixSource._();
  @$core.override
  MatrixSource createEmptyInstance() => MatrixSource._();
  @$core.pragma('dart2js:noInline')
  static MatrixSource getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MatrixSource>(
          MatrixSource.$_createMessage);
  static MatrixSource? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<MatrixSource_MatrixInfo> get matrixInfo => $_getList(0);
}

class FileSource_FileInfo extends $pb.GeneratedMessage {
  factory FileSource_FileInfo({
    $core.String? name,
    $core.int? width,
    $core.int? height,
    $core.String? validate,
  }) {
    final result = FileSource_FileInfo._();
    if (name != null) result.name = name;
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    if (validate != null) result.validate = validate;
    return result;
  }

  FileSource_FileInfo._();

  factory FileSource_FileInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FileSource_FileInfo()..mergeFromBuffer(data, registry);
  factory FileSource_FileInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FileSource_FileInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FileSource.FileInfo',
      createEmptyInstance: FileSource_FileInfo.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aI(2, _omitFieldNames ? '' : 'width')
    ..aI(3, _omitFieldNames ? '' : 'height')
    ..aOS(4, _omitFieldNames ? '' : 'validate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileSource_FileInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileSource_FileInfo copyWith(void Function(FileSource_FileInfo) updates) =>
      super.copyWith((message) => updates(message as FileSource_FileInfo))
          as FileSource_FileInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use FileSource_FileInfo() / FileSource_FileInfo.new instead')
  static FileSource_FileInfo create() => FileSource_FileInfo._();
  static $pb.GeneratedMessage $_createMessage() => FileSource_FileInfo._();
  @$core.override
  FileSource_FileInfo createEmptyInstance() => FileSource_FileInfo._();
  @$core.pragma('dart2js:noInline')
  static FileSource_FileInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FileSource_FileInfo>(
          FileSource_FileInfo.$_createMessage);
  static FileSource_FileInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get width => $_getIZ(1);
  @$pb.TagNumber(2)
  set width($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWidth() => $_has(1);
  @$pb.TagNumber(2)
  void clearWidth() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get height => $_getIZ(2);
  @$pb.TagNumber(3)
  set height($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeight() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get validate => $_getSZ(3);
  @$pb.TagNumber(4)
  set validate($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasValidate() => $_has(3);
  @$pb.TagNumber(4)
  void clearValidate() => $_clearField(4);
}

class FileSource extends $pb.GeneratedMessage {
  factory FileSource({
    $core.Iterable<FileSource_FileInfo>? fileInfo,
  }) {
    final result = FileSource._();
    if (fileInfo != null) result.fileInfo.addAll(fileInfo);
    return result;
  }

  FileSource._();

  factory FileSource.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FileSource()..mergeFromBuffer(data, registry);
  factory FileSource.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FileSource()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FileSource',
      createEmptyInstance: FileSource.$_createMessage)
    ..pPM<FileSource_FileInfo>(1, _omitFieldNames ? '' : 'fileInfo',
        protoName: 'fileInfo', subBuilder: FileSource_FileInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileSource clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileSource copyWith(void Function(FileSource) updates) =>
      super.copyWith((message) => updates(message as FileSource)) as FileSource;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FileSource() / FileSource.new instead')
  static FileSource create() => FileSource._();
  static $pb.GeneratedMessage $_createMessage() => FileSource._();
  @$core.override
  FileSource createEmptyInstance() => FileSource._();
  @$core.pragma('dart2js:noInline')
  static FileSource getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FileSource>(FileSource.$_createMessage);
  static FileSource? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<FileSource_FileInfo> get fileInfo => $_getList(0);
}

class AudioSource_AudioInfo extends $pb.GeneratedMessage {
  factory AudioSource_AudioInfo({
    $core.String? name,
    $fixnum.Int64? duration,
    $core.String? validate,
  }) {
    final result = AudioSource_AudioInfo._();
    if (name != null) result.name = name;
    if (duration != null) result.duration = duration;
    if (validate != null) result.validate = validate;
    return result;
  }

  AudioSource_AudioInfo._();

  factory AudioSource_AudioInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AudioSource_AudioInfo()..mergeFromBuffer(data, registry);
  factory AudioSource_AudioInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AudioSource_AudioInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AudioSource.AudioInfo',
      createEmptyInstance: AudioSource_AudioInfo.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aInt64(2, _omitFieldNames ? '' : 'duration')
    ..aOS(3, _omitFieldNames ? '' : 'validate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AudioSource_AudioInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AudioSource_AudioInfo copyWith(
          void Function(AudioSource_AudioInfo) updates) =>
      super.copyWith((message) => updates(message as AudioSource_AudioInfo))
          as AudioSource_AudioInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use AudioSource_AudioInfo() / AudioSource_AudioInfo.new instead')
  static AudioSource_AudioInfo create() => AudioSource_AudioInfo._();
  static $pb.GeneratedMessage $_createMessage() => AudioSource_AudioInfo._();
  @$core.override
  AudioSource_AudioInfo createEmptyInstance() => AudioSource_AudioInfo._();
  @$core.pragma('dart2js:noInline')
  static AudioSource_AudioInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AudioSource_AudioInfo>(
          AudioSource_AudioInfo.$_createMessage);
  static AudioSource_AudioInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get duration => $_getI64(1);
  @$pb.TagNumber(2)
  set duration($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDuration() => $_has(1);
  @$pb.TagNumber(2)
  void clearDuration() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get validate => $_getSZ(2);
  @$pb.TagNumber(3)
  set validate($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasValidate() => $_has(2);
  @$pb.TagNumber(3)
  void clearValidate() => $_clearField(3);
}

class AudioSource extends $pb.GeneratedMessage {
  factory AudioSource({
    $core.Iterable<AudioSource_AudioInfo>? audioInfo,
  }) {
    final result = AudioSource._();
    if (audioInfo != null) result.audioInfo.addAll(audioInfo);
    return result;
  }

  AudioSource._();

  factory AudioSource.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AudioSource()..mergeFromBuffer(data, registry);
  factory AudioSource.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AudioSource()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AudioSource',
      createEmptyInstance: AudioSource.$_createMessage)
    ..pPM<AudioSource_AudioInfo>(1, _omitFieldNames ? '' : 'audioInfo',
        protoName: 'audioInfo',
        subBuilder: AudioSource_AudioInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AudioSource clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AudioSource copyWith(void Function(AudioSource) updates) =>
      super.copyWith((message) => updates(message as AudioSource))
          as AudioSource;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AudioSource() / AudioSource.new instead')
  static AudioSource create() => AudioSource._();
  static $pb.GeneratedMessage $_createMessage() => AudioSource._();
  @$core.override
  AudioSource createEmptyInstance() => AudioSource._();
  @$core.pragma('dart2js:noInline')
  static AudioSource getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AudioSource>(
          AudioSource.$_createMessage);
  static AudioSource? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<AudioSource_AudioInfo> get audioInfo => $_getList(0);
}

class TextSource_TextInfo extends $pb.GeneratedMessage {
  factory TextSource_TextInfo({
    $core.String? content,
    $1.Paint? paint,
  }) {
    final result = TextSource_TextInfo._();
    if (content != null) result.content = content;
    if (paint != null) result.paint = paint;
    return result;
  }

  TextSource_TextInfo._();

  factory TextSource_TextInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TextSource_TextInfo()..mergeFromBuffer(data, registry);
  factory TextSource_TextInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TextSource_TextInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TextSource.TextInfo',
      createEmptyInstance: TextSource_TextInfo.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'content')
    ..aOM<$1.Paint>(2, _omitFieldNames ? '' : 'paint',
        subBuilder: $1.Paint.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TextSource_TextInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TextSource_TextInfo copyWith(void Function(TextSource_TextInfo) updates) =>
      super.copyWith((message) => updates(message as TextSource_TextInfo))
          as TextSource_TextInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use TextSource_TextInfo() / TextSource_TextInfo.new instead')
  static TextSource_TextInfo create() => TextSource_TextInfo._();
  static $pb.GeneratedMessage $_createMessage() => TextSource_TextInfo._();
  @$core.override
  TextSource_TextInfo createEmptyInstance() => TextSource_TextInfo._();
  @$core.pragma('dart2js:noInline')
  static TextSource_TextInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TextSource_TextInfo>(
          TextSource_TextInfo.$_createMessage);
  static TextSource_TextInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get content => $_getSZ(0);
  @$pb.TagNumber(1)
  set content($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearContent() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.Paint get paint => $_getN(1);
  @$pb.TagNumber(2)
  set paint($1.Paint value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPaint() => $_has(1);
  @$pb.TagNumber(2)
  void clearPaint() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.Paint ensurePaint() => $_ensure(1);
}

class TextSource extends $pb.GeneratedMessage {
  factory TextSource({
    $core.Iterable<TextSource_TextInfo>? textInfo,
  }) {
    final result = TextSource._();
    if (textInfo != null) result.textInfo.addAll(textInfo);
    return result;
  }

  TextSource._();

  factory TextSource.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TextSource()..mergeFromBuffer(data, registry);
  factory TextSource.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TextSource()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TextSource',
      createEmptyInstance: TextSource.$_createMessage)
    ..pPM<TextSource_TextInfo>(1, _omitFieldNames ? '' : 'textInfo',
        protoName: 'textInfo', subBuilder: TextSource_TextInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TextSource clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TextSource copyWith(void Function(TextSource) updates) =>
      super.copyWith((message) => updates(message as TextSource)) as TextSource;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TextSource() / TextSource.new instead')
  static TextSource create() => TextSource._();
  static $pb.GeneratedMessage $_createMessage() => TextSource._();
  @$core.override
  TextSource createEmptyInstance() => TextSource._();
  @$core.pragma('dart2js:noInline')
  static TextSource getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TextSource>(TextSource.$_createMessage);
  static TextSource? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TextSource_TextInfo> get textInfo => $_getList(0);
}

class GeometrySource_GeometryInfo extends $pb.GeneratedMessage {
  factory GeometrySource_GeometryInfo({
    $4.GeometryEnum? geometryType,
    $core.Iterable<$3.PointF>? points,
    $1.Paint? paint,
  }) {
    final result = GeometrySource_GeometryInfo._();
    if (geometryType != null) result.geometryType = geometryType;
    if (points != null) result.points.addAll(points);
    if (paint != null) result.paint = paint;
    return result;
  }

  GeometrySource_GeometryInfo._();

  factory GeometrySource_GeometryInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GeometrySource_GeometryInfo()..mergeFromBuffer(data, registry);
  factory GeometrySource_GeometryInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GeometrySource_GeometryInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GeometrySource.GeometryInfo',
      createEmptyInstance: GeometrySource_GeometryInfo.$_createMessage)
    ..aE<$4.GeometryEnum>(1, _omitFieldNames ? '' : 'geometryType',
        protoName: 'geometryType', enumValues: $4.GeometryEnum.values)
    ..pPM<$3.PointF>(2, _omitFieldNames ? '' : 'points',
        subBuilder: $3.PointF.$_createMessage)
    ..aOM<$1.Paint>(3, _omitFieldNames ? '' : 'paint',
        subBuilder: $1.Paint.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GeometrySource_GeometryInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GeometrySource_GeometryInfo copyWith(
          void Function(GeometrySource_GeometryInfo) updates) =>
      super.copyWith(
              (message) => updates(message as GeometrySource_GeometryInfo))
          as GeometrySource_GeometryInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GeometrySource_GeometryInfo() / GeometrySource_GeometryInfo.new instead')
  static GeometrySource_GeometryInfo create() =>
      GeometrySource_GeometryInfo._();
  static $pb.GeneratedMessage $_createMessage() =>
      GeometrySource_GeometryInfo._();
  @$core.override
  GeometrySource_GeometryInfo createEmptyInstance() =>
      GeometrySource_GeometryInfo._();
  @$core.pragma('dart2js:noInline')
  static GeometrySource_GeometryInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GeometrySource_GeometryInfo>(
          GeometrySource_GeometryInfo.$_createMessage);
  static GeometrySource_GeometryInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $4.GeometryEnum get geometryType => $_getN(0);
  @$pb.TagNumber(1)
  set geometryType($4.GeometryEnum value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasGeometryType() => $_has(0);
  @$pb.TagNumber(1)
  void clearGeometryType() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$3.PointF> get points => $_getList(1);

  @$pb.TagNumber(3)
  $1.Paint get paint => $_getN(2);
  @$pb.TagNumber(3)
  set paint($1.Paint value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasPaint() => $_has(2);
  @$pb.TagNumber(3)
  void clearPaint() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.Paint ensurePaint() => $_ensure(2);
}

class GeometrySource extends $pb.GeneratedMessage {
  factory GeometrySource({
    $core.Iterable<GeometrySource_GeometryInfo>? geometryInfo,
  }) {
    final result = GeometrySource._();
    if (geometryInfo != null) result.geometryInfo.addAll(geometryInfo);
    return result;
  }

  GeometrySource._();

  factory GeometrySource.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GeometrySource()..mergeFromBuffer(data, registry);
  factory GeometrySource.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GeometrySource()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GeometrySource',
      createEmptyInstance: GeometrySource.$_createMessage)
    ..pPM<GeometrySource_GeometryInfo>(1, _omitFieldNames ? '' : 'geometryInfo',
        protoName: 'geometryInfo',
        subBuilder: GeometrySource_GeometryInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GeometrySource clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GeometrySource copyWith(void Function(GeometrySource) updates) =>
      super.copyWith((message) => updates(message as GeometrySource))
          as GeometrySource;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GeometrySource() / GeometrySource.new instead')
  static GeometrySource create() => GeometrySource._();
  static $pb.GeneratedMessage $_createMessage() => GeometrySource._();
  @$core.override
  GeometrySource createEmptyInstance() => GeometrySource._();
  @$core.pragma('dart2js:noInline')
  static GeometrySource getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GeometrySource>(
          GeometrySource.$_createMessage);
  static GeometrySource? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<GeometrySource_GeometryInfo> get geometryInfo => $_getList(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
