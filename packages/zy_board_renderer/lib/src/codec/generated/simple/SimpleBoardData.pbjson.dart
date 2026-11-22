// This is a generated file - do not edit.
//
// Generated from SimpleBoardData.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use simpleBoardDataDescriptor instead')
const SimpleBoardData$json = {
  '1': 'SimpleBoardData',
  '2': [
    {'1': 'path', '3': 1, '4': 3, '5': 11, '6': '.Path', '10': 'path'},
  ],
};

/// Descriptor for `SimpleBoardData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List simpleBoardDataDescriptor = $convert.base64Decode(
    'Cg9TaW1wbGVCb2FyZERhdGESGQoEcGF0aBgBIAMoCzIFLlBhdGhSBHBhdGg=');

@$core.Deprecated('Use pointFDescriptor instead')
const PointF$json = {
  '1': 'PointF',
  '2': [
    {'1': 'value', '3': 1, '4': 3, '5': 2, '10': 'value'},
  ],
};

/// Descriptor for `PointF`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pointFDescriptor =
    $convert.base64Decode('CgZQb2ludEYSFAoFdmFsdWUYASADKAJSBXZhbHVl');

@$core.Deprecated('Use paintDescriptor instead')
const Paint$json = {
  '1': 'Paint',
  '2': [
    {'1': 'width', '3': 1, '4': 1, '5': 2, '10': 'width'},
    {'1': 'color', '3': 2, '4': 1, '5': 5, '10': 'color'},
    {'1': 'isDashed', '3': 3, '4': 1, '5': 8, '10': 'isDashed'},
  ],
};

/// Descriptor for `Paint`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List paintDescriptor = $convert.base64Decode(
    'CgVQYWludBIUCgV3aWR0aBgBIAEoAlIFd2lkdGgSFAoFY29sb3IYAiABKAVSBWNvbG9yEhoKCG'
    'lzRGFzaGVkGAMgASgIUghpc0Rhc2hlZA==');

@$core.Deprecated('Use pathDescriptor instead')
const Path$json = {
  '1': 'Path',
  '2': [
    {'1': 'point', '3': 1, '4': 3, '5': 11, '6': '.PointF', '10': 'point'},
    {'1': 'paint', '3': 2, '4': 1, '5': 11, '6': '.Paint', '10': 'paint'},
  ],
};

/// Descriptor for `Path`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pathDescriptor = $convert.base64Decode(
    'CgRQYXRoEh0KBXBvaW50GAEgAygLMgcuUG9pbnRGUgVwb2ludBIcCgVwYWludBgCIAEoCzIGLl'
    'BhaW50UgVwYWludA==');
