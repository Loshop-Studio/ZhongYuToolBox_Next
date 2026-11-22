// This is a generated file - do not edit.
//
// Generated from Header.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'enums/BackgroundLineTypeEnum.pbenum.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// 画板
class Header extends $pb.GeneratedMessage {
  factory Header({
    $core.int? version,
    $core.int? width,
    $core.int? height,
    $fixnum.Int64? createDate,
    $fixnum.Int64? updateDate,
    $fixnum.Int64? duration,
    Author? author,
    $core.String? convertUrl,
    $core.Iterable<Author>? provider,
    $core.int? defaultBackgroundColor,
    $core.int? lastBackgroundColor,
    MoveConfig? moveConfig,
    BackgroundLineConfig? defaultBackgroundLineConfig,
    BackgroundLineConfig? lastBackgroundLineConfig,
  }) {
    final result = Header._();
    if (version != null) result.version = version;
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    if (createDate != null) result.createDate = createDate;
    if (updateDate != null) result.updateDate = updateDate;
    if (duration != null) result.duration = duration;
    if (author != null) result.author = author;
    if (convertUrl != null) result.convertUrl = convertUrl;
    if (provider != null) result.provider.addAll(provider);
    if (defaultBackgroundColor != null)
      result.defaultBackgroundColor = defaultBackgroundColor;
    if (lastBackgroundColor != null)
      result.lastBackgroundColor = lastBackgroundColor;
    if (moveConfig != null) result.moveConfig = moveConfig;
    if (defaultBackgroundLineConfig != null)
      result.defaultBackgroundLineConfig = defaultBackgroundLineConfig;
    if (lastBackgroundLineConfig != null)
      result.lastBackgroundLineConfig = lastBackgroundLineConfig;
    return result;
  }

  Header._();

  factory Header.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Header()..mergeFromBuffer(data, registry);
  factory Header.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Header()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Header',
      createEmptyInstance: Header.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'version')
    ..aI(2, _omitFieldNames ? '' : 'width')
    ..aI(3, _omitFieldNames ? '' : 'height')
    ..aInt64(4, _omitFieldNames ? '' : 'createDate', protoName: 'createDate')
    ..aInt64(5, _omitFieldNames ? '' : 'updateDate', protoName: 'updateDate')
    ..aInt64(6, _omitFieldNames ? '' : 'duration')
    ..aOM<Author>(7, _omitFieldNames ? '' : 'author',
        subBuilder: Author.$_createMessage)
    ..aOS(8, _omitFieldNames ? '' : 'convertUrl', protoName: 'convertUrl')
    ..pPM<Author>(9, _omitFieldNames ? '' : 'provider',
        subBuilder: Author.$_createMessage)
    ..aI(10, _omitFieldNames ? '' : 'defaultBackgroundColor',
        protoName: 'defaultBackgroundColor')
    ..aI(11, _omitFieldNames ? '' : 'lastBackgroundColor',
        protoName: 'lastBackgroundColor')
    ..aOM<MoveConfig>(12, _omitFieldNames ? '' : 'moveConfig',
        protoName: 'moveConfig', subBuilder: MoveConfig.$_createMessage)
    ..aOM<BackgroundLineConfig>(
        13, _omitFieldNames ? '' : 'defaultBackgroundLineConfig',
        protoName: 'defaultBackgroundLineConfig',
        subBuilder: BackgroundLineConfig.$_createMessage)
    ..aOM<BackgroundLineConfig>(
        14, _omitFieldNames ? '' : 'lastBackgroundLineConfig',
        protoName: 'lastBackgroundLineConfig',
        subBuilder: BackgroundLineConfig.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Header clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Header copyWith(void Function(Header) updates) =>
      super.copyWith((message) => updates(message as Header)) as Header;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Header() / Header.new instead')
  static Header create() => Header._();
  static $pb.GeneratedMessage $_createMessage() => Header._();
  @$core.override
  Header createEmptyInstance() => Header._();
  @$core.pragma('dart2js:noInline')
  static Header getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Header>(Header.$_createMessage);
  static Header? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get version => $_getIZ(0);
  @$pb.TagNumber(1)
  set version($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => $_clearField(1);

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
  $fixnum.Int64 get createDate => $_getI64(3);
  @$pb.TagNumber(4)
  set createDate($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCreateDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreateDate() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get updateDate => $_getI64(4);
  @$pb.TagNumber(5)
  set updateDate($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUpdateDate() => $_has(4);
  @$pb.TagNumber(5)
  void clearUpdateDate() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get duration => $_getI64(5);
  @$pb.TagNumber(6)
  set duration($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDuration() => $_has(5);
  @$pb.TagNumber(6)
  void clearDuration() => $_clearField(6);

  @$pb.TagNumber(7)
  Author get author => $_getN(6);
  @$pb.TagNumber(7)
  set author(Author value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasAuthor() => $_has(6);
  @$pb.TagNumber(7)
  void clearAuthor() => $_clearField(7);
  @$pb.TagNumber(7)
  Author ensureAuthor() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.String get convertUrl => $_getSZ(7);
  @$pb.TagNumber(8)
  set convertUrl($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasConvertUrl() => $_has(7);
  @$pb.TagNumber(8)
  void clearConvertUrl() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbList<Author> get provider => $_getList(8);

  @$pb.TagNumber(10)
  $core.int get defaultBackgroundColor => $_getIZ(9);
  @$pb.TagNumber(10)
  set defaultBackgroundColor($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasDefaultBackgroundColor() => $_has(9);
  @$pb.TagNumber(10)
  void clearDefaultBackgroundColor() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get lastBackgroundColor => $_getIZ(10);
  @$pb.TagNumber(11)
  set lastBackgroundColor($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasLastBackgroundColor() => $_has(10);
  @$pb.TagNumber(11)
  void clearLastBackgroundColor() => $_clearField(11);

  @$pb.TagNumber(12)
  MoveConfig get moveConfig => $_getN(11);
  @$pb.TagNumber(12)
  set moveConfig(MoveConfig value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasMoveConfig() => $_has(11);
  @$pb.TagNumber(12)
  void clearMoveConfig() => $_clearField(12);
  @$pb.TagNumber(12)
  MoveConfig ensureMoveConfig() => $_ensure(11);

  @$pb.TagNumber(13)
  BackgroundLineConfig get defaultBackgroundLineConfig => $_getN(12);
  @$pb.TagNumber(13)
  set defaultBackgroundLineConfig(BackgroundLineConfig value) =>
      $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasDefaultBackgroundLineConfig() => $_has(12);
  @$pb.TagNumber(13)
  void clearDefaultBackgroundLineConfig() => $_clearField(13);
  @$pb.TagNumber(13)
  BackgroundLineConfig ensureDefaultBackgroundLineConfig() => $_ensure(12);

  @$pb.TagNumber(14)
  BackgroundLineConfig get lastBackgroundLineConfig => $_getN(13);
  @$pb.TagNumber(14)
  set lastBackgroundLineConfig(BackgroundLineConfig value) =>
      $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasLastBackgroundLineConfig() => $_has(13);
  @$pb.TagNumber(14)
  void clearLastBackgroundLineConfig() => $_clearField(14);
  @$pb.TagNumber(14)
  BackgroundLineConfig ensureLastBackgroundLineConfig() => $_ensure(13);
}

class MoveConfig extends $pb.GeneratedMessage {
  factory MoveConfig({
    $core.bool? isEnable,
    $core.bool? verticalTranslate,
    $core.bool? horizontalTranslate,
    $core.bool? scale,
    $core.bool? rotate,
    $core.int? maxHeightTimes,
    $core.int? maxWidthTimes,
  }) {
    final result = MoveConfig._();
    if (isEnable != null) result.isEnable = isEnable;
    if (verticalTranslate != null) result.verticalTranslate = verticalTranslate;
    if (horizontalTranslate != null)
      result.horizontalTranslate = horizontalTranslate;
    if (scale != null) result.scale = scale;
    if (rotate != null) result.rotate = rotate;
    if (maxHeightTimes != null) result.maxHeightTimes = maxHeightTimes;
    if (maxWidthTimes != null) result.maxWidthTimes = maxWidthTimes;
    return result;
  }

  MoveConfig._();

  factory MoveConfig.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MoveConfig()..mergeFromBuffer(data, registry);
  factory MoveConfig.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MoveConfig()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MoveConfig',
      createEmptyInstance: MoveConfig.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'isEnable', protoName: 'isEnable')
    ..aOB(2, _omitFieldNames ? '' : 'verticalTranslate',
        protoName: 'verticalTranslate')
    ..aOB(3, _omitFieldNames ? '' : 'horizontalTranslate',
        protoName: 'horizontalTranslate')
    ..aOB(4, _omitFieldNames ? '' : 'scale')
    ..aOB(5, _omitFieldNames ? '' : 'rotate')
    ..aI(6, _omitFieldNames ? '' : 'maxHeightTimes',
        protoName: 'maxHeightTimes')
    ..aI(7, _omitFieldNames ? '' : 'maxWidthTimes', protoName: 'maxWidthTimes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MoveConfig clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MoveConfig copyWith(void Function(MoveConfig) updates) =>
      super.copyWith((message) => updates(message as MoveConfig)) as MoveConfig;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MoveConfig() / MoveConfig.new instead')
  static MoveConfig create() => MoveConfig._();
  static $pb.GeneratedMessage $_createMessage() => MoveConfig._();
  @$core.override
  MoveConfig createEmptyInstance() => MoveConfig._();
  @$core.pragma('dart2js:noInline')
  static MoveConfig getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MoveConfig>(MoveConfig.$_createMessage);
  static MoveConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get isEnable => $_getBF(0);
  @$pb.TagNumber(1)
  set isEnable($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIsEnable() => $_has(0);
  @$pb.TagNumber(1)
  void clearIsEnable() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get verticalTranslate => $_getBF(1);
  @$pb.TagNumber(2)
  set verticalTranslate($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVerticalTranslate() => $_has(1);
  @$pb.TagNumber(2)
  void clearVerticalTranslate() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get horizontalTranslate => $_getBF(2);
  @$pb.TagNumber(3)
  set horizontalTranslate($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHorizontalTranslate() => $_has(2);
  @$pb.TagNumber(3)
  void clearHorizontalTranslate() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get scale => $_getBF(3);
  @$pb.TagNumber(4)
  set scale($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasScale() => $_has(3);
  @$pb.TagNumber(4)
  void clearScale() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get rotate => $_getBF(4);
  @$pb.TagNumber(5)
  set rotate($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRotate() => $_has(4);
  @$pb.TagNumber(5)
  void clearRotate() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get maxHeightTimes => $_getIZ(5);
  @$pb.TagNumber(6)
  set maxHeightTimes($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMaxHeightTimes() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxHeightTimes() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get maxWidthTimes => $_getIZ(6);
  @$pb.TagNumber(7)
  set maxWidthTimes($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMaxWidthTimes() => $_has(6);
  @$pb.TagNumber(7)
  void clearMaxWidthTimes() => $_clearField(7);
}

class BackgroundLineConfig extends $pb.GeneratedMessage {
  factory BackgroundLineConfig({
    $core.int? lineColor,
    $core.double? lineSpace,
    $0.BackgroundLineTypeEnum? lineType,
    $core.double? lineWidth,
  }) {
    final result = BackgroundLineConfig._();
    if (lineColor != null) result.lineColor = lineColor;
    if (lineSpace != null) result.lineSpace = lineSpace;
    if (lineType != null) result.lineType = lineType;
    if (lineWidth != null) result.lineWidth = lineWidth;
    return result;
  }

  BackgroundLineConfig._();

  factory BackgroundLineConfig.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BackgroundLineConfig()..mergeFromBuffer(data, registry);
  factory BackgroundLineConfig.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BackgroundLineConfig()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BackgroundLineConfig',
      createEmptyInstance: BackgroundLineConfig.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'lineColor', protoName: 'lineColor')
    ..aD(2, _omitFieldNames ? '' : 'lineSpace',
        protoName: 'lineSpace', fieldType: $pb.PbFieldType.OF)
    ..aE<$0.BackgroundLineTypeEnum>(3, _omitFieldNames ? '' : 'lineType',
        protoName: 'lineType', enumValues: $0.BackgroundLineTypeEnum.values)
    ..aD(4, _omitFieldNames ? '' : 'lineWidth',
        protoName: 'lineWidth', fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BackgroundLineConfig clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BackgroundLineConfig copyWith(void Function(BackgroundLineConfig) updates) =>
      super.copyWith((message) => updates(message as BackgroundLineConfig))
          as BackgroundLineConfig;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use BackgroundLineConfig() / BackgroundLineConfig.new instead')
  static BackgroundLineConfig create() => BackgroundLineConfig._();
  static $pb.GeneratedMessage $_createMessage() => BackgroundLineConfig._();
  @$core.override
  BackgroundLineConfig createEmptyInstance() => BackgroundLineConfig._();
  @$core.pragma('dart2js:noInline')
  static BackgroundLineConfig getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BackgroundLineConfig>(
          BackgroundLineConfig.$_createMessage);
  static BackgroundLineConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get lineColor => $_getIZ(0);
  @$pb.TagNumber(1)
  set lineColor($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLineColor() => $_has(0);
  @$pb.TagNumber(1)
  void clearLineColor() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get lineSpace => $_getN(1);
  @$pb.TagNumber(2)
  set lineSpace($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLineSpace() => $_has(1);
  @$pb.TagNumber(2)
  void clearLineSpace() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.BackgroundLineTypeEnum get lineType => $_getN(2);
  @$pb.TagNumber(3)
  set lineType($0.BackgroundLineTypeEnum value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasLineType() => $_has(2);
  @$pb.TagNumber(3)
  void clearLineType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get lineWidth => $_getN(3);
  @$pb.TagNumber(4)
  set lineWidth($core.double value) => $_setFloat(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLineWidth() => $_has(3);
  @$pb.TagNumber(4)
  void clearLineWidth() => $_clearField(4);
}

class Author extends $pb.GeneratedMessage {
  factory Author({
    $core.String? authorName,
    $core.String? schoolId,
    $core.String? authorId,
    $core.String? url,
    $fixnum.Int64? startTime,
    $fixnum.Int64? duration,
  }) {
    final result = Author._();
    if (authorName != null) result.authorName = authorName;
    if (schoolId != null) result.schoolId = schoolId;
    if (authorId != null) result.authorId = authorId;
    if (url != null) result.url = url;
    if (startTime != null) result.startTime = startTime;
    if (duration != null) result.duration = duration;
    return result;
  }

  Author._();

  factory Author.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Author()..mergeFromBuffer(data, registry);
  factory Author.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Author()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Author',
      createEmptyInstance: Author.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'authorName', protoName: 'authorName')
    ..aOS(2, _omitFieldNames ? '' : 'schoolId', protoName: 'schoolId')
    ..aOS(3, _omitFieldNames ? '' : 'authorId', protoName: 'authorId')
    ..aOS(4, _omitFieldNames ? '' : 'url')
    ..aInt64(5, _omitFieldNames ? '' : 'startTime', protoName: 'startTime')
    ..aInt64(6, _omitFieldNames ? '' : 'duration')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Author clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Author copyWith(void Function(Author) updates) =>
      super.copyWith((message) => updates(message as Author)) as Author;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Author() / Author.new instead')
  static Author create() => Author._();
  static $pb.GeneratedMessage $_createMessage() => Author._();
  @$core.override
  Author createEmptyInstance() => Author._();
  @$core.pragma('dart2js:noInline')
  static Author getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Author>(Author.$_createMessage);
  static Author? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get authorName => $_getSZ(0);
  @$pb.TagNumber(1)
  set authorName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAuthorName() => $_has(0);
  @$pb.TagNumber(1)
  void clearAuthorName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get schoolId => $_getSZ(1);
  @$pb.TagNumber(2)
  set schoolId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSchoolId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSchoolId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get authorId => $_getSZ(2);
  @$pb.TagNumber(3)
  set authorId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAuthorId() => $_has(2);
  @$pb.TagNumber(3)
  void clearAuthorId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get url => $_getSZ(3);
  @$pb.TagNumber(4)
  set url($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUrl() => $_has(3);
  @$pb.TagNumber(4)
  void clearUrl() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get startTime => $_getI64(4);
  @$pb.TagNumber(5)
  set startTime($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStartTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearStartTime() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get duration => $_getI64(5);
  @$pb.TagNumber(6)
  set duration($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDuration() => $_has(5);
  @$pb.TagNumber(6)
  void clearDuration() => $_clearField(6);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
