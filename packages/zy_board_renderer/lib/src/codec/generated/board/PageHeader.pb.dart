// This is a generated file - do not edit.
//
// Generated from PageHeader.proto.

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

/// Page的信息
class PageHeader extends $pb.GeneratedMessage {
  factory PageHeader({
    $fixnum.Int64? duration,
  }) {
    final result = PageHeader._();
    if (duration != null) result.duration = duration;
    return result;
  }

  PageHeader._();

  factory PageHeader.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PageHeader()..mergeFromBuffer(data, registry);
  factory PageHeader.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PageHeader()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PageHeader',
      createEmptyInstance: PageHeader.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'duration')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PageHeader clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PageHeader copyWith(void Function(PageHeader) updates) =>
      super.copyWith((message) => updates(message as PageHeader)) as PageHeader;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PageHeader() / PageHeader.new instead')
  static PageHeader create() => PageHeader._();
  static $pb.GeneratedMessage $_createMessage() => PageHeader._();
  @$core.override
  PageHeader createEmptyInstance() => PageHeader._();
  @$core.pragma('dart2js:noInline')
  static PageHeader getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PageHeader>(PageHeader.$_createMessage);
  static PageHeader? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get duration => $_getI64(0);
  @$pb.TagNumber(1)
  set duration($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDuration() => $_has(0);
  @$pb.TagNumber(1)
  void clearDuration() => $_clearField(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
