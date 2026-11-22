// This is a generated file - do not edit.
//
// Generated from SketchHeader.proto.

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

/// 画板
class Header extends $pb.GeneratedMessage {
  factory Header({
    $core.int? version,
    $core.int? width,
    $core.int? height,
    $fixnum.Int64? createDate,
    $fixnum.Int64? updateDate,
    $core.String? author,
    $core.int? type,
  }) {
    final result = Header._();
    if (version != null) result.version = version;
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    if (createDate != null) result.createDate = createDate;
    if (updateDate != null) result.updateDate = updateDate;
    if (author != null) result.author = author;
    if (type != null) result.type = type;
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
    ..aOS(6, _omitFieldNames ? '' : 'author')
    ..aI(7, _omitFieldNames ? '' : 'type')
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
  $core.String get author => $_getSZ(5);
  @$pb.TagNumber(6)
  set author($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAuthor() => $_has(5);
  @$pb.TagNumber(6)
  void clearAuthor() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get type => $_getIZ(6);
  @$pb.TagNumber(7)
  set type($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasType() => $_has(6);
  @$pb.TagNumber(7)
  void clearType() => $_clearField(7);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
