// This is a generated file - do not edit.
//
// Generated from PageRouter.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Page的信息
class PageRouter_PageInfo extends $pb.GeneratedMessage {
  factory PageRouter_PageInfo({
    $core.String? name,
    $core.int? pageIndex,
  }) {
    final result = PageRouter_PageInfo._();
    if (name != null) result.name = name;
    if (pageIndex != null) result.pageIndex = pageIndex;
    return result;
  }

  PageRouter_PageInfo._();

  factory PageRouter_PageInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PageRouter_PageInfo()..mergeFromBuffer(data, registry);
  factory PageRouter_PageInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PageRouter_PageInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PageRouter.PageInfo',
      createEmptyInstance: PageRouter_PageInfo.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aI(2, _omitFieldNames ? '' : 'pageIndex', protoName: 'pageIndex')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PageRouter_PageInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PageRouter_PageInfo copyWith(void Function(PageRouter_PageInfo) updates) =>
      super.copyWith((message) => updates(message as PageRouter_PageInfo))
          as PageRouter_PageInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use PageRouter_PageInfo() / PageRouter_PageInfo.new instead')
  static PageRouter_PageInfo create() => PageRouter_PageInfo._();
  static $pb.GeneratedMessage $_createMessage() => PageRouter_PageInfo._();
  @$core.override
  PageRouter_PageInfo createEmptyInstance() => PageRouter_PageInfo._();
  @$core.pragma('dart2js:noInline')
  static PageRouter_PageInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PageRouter_PageInfo>(
          PageRouter_PageInfo.$_createMessage);
  static PageRouter_PageInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get pageIndex => $_getIZ(1);
  @$pb.TagNumber(2)
  set pageIndex($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageIndex() => $_clearField(2);
}

/// Page的信息
class PageRouter extends $pb.GeneratedMessage {
  factory PageRouter({
    $core.Iterable<PageRouter_PageInfo>? pageInfo,
  }) {
    final result = PageRouter._();
    if (pageInfo != null) result.pageInfo.addAll(pageInfo);
    return result;
  }

  PageRouter._();

  factory PageRouter.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PageRouter()..mergeFromBuffer(data, registry);
  factory PageRouter.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PageRouter()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PageRouter',
      createEmptyInstance: PageRouter.$_createMessage)
    ..pPM<PageRouter_PageInfo>(1, _omitFieldNames ? '' : 'pageInfo',
        protoName: 'pageInfo', subBuilder: PageRouter_PageInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PageRouter clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PageRouter copyWith(void Function(PageRouter) updates) =>
      super.copyWith((message) => updates(message as PageRouter)) as PageRouter;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PageRouter() / PageRouter.new instead')
  static PageRouter create() => PageRouter._();
  static $pb.GeneratedMessage $_createMessage() => PageRouter._();
  @$core.override
  PageRouter createEmptyInstance() => PageRouter._();
  @$core.pragma('dart2js:noInline')
  static PageRouter getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PageRouter>(PageRouter.$_createMessage);
  static PageRouter? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PageRouter_PageInfo> get pageInfo => $_getList(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
