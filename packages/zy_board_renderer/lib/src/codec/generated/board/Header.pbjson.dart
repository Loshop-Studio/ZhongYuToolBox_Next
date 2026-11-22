// This is a generated file - do not edit.
//
// Generated from Header.proto.

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

@$core.Deprecated('Use headerDescriptor instead')
const Header$json = {
  '1': 'Header',
  '2': [
    {'1': 'version', '3': 1, '4': 1, '5': 5, '10': 'version'},
    {'1': 'width', '3': 2, '4': 1, '5': 5, '10': 'width'},
    {'1': 'height', '3': 3, '4': 1, '5': 5, '10': 'height'},
    {'1': 'createDate', '3': 4, '4': 1, '5': 3, '10': 'createDate'},
    {'1': 'updateDate', '3': 5, '4': 1, '5': 3, '10': 'updateDate'},
    {'1': 'duration', '3': 6, '4': 1, '5': 3, '10': 'duration'},
    {'1': 'author', '3': 7, '4': 1, '5': 11, '6': '.Author', '10': 'author'},
    {'1': 'convertUrl', '3': 8, '4': 1, '5': 9, '10': 'convertUrl'},
    {
      '1': 'provider',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.Author',
      '10': 'provider'
    },
    {
      '1': 'defaultBackgroundColor',
      '3': 10,
      '4': 1,
      '5': 5,
      '10': 'defaultBackgroundColor'
    },
    {
      '1': 'lastBackgroundColor',
      '3': 11,
      '4': 1,
      '5': 5,
      '10': 'lastBackgroundColor'
    },
    {
      '1': 'moveConfig',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.MoveConfig',
      '10': 'moveConfig'
    },
    {
      '1': 'defaultBackgroundLineConfig',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.BackgroundLineConfig',
      '10': 'defaultBackgroundLineConfig'
    },
    {
      '1': 'lastBackgroundLineConfig',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.BackgroundLineConfig',
      '10': 'lastBackgroundLineConfig'
    },
  ],
};

/// Descriptor for `Header`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List headerDescriptor = $convert.base64Decode(
    'CgZIZWFkZXISGAoHdmVyc2lvbhgBIAEoBVIHdmVyc2lvbhIUCgV3aWR0aBgCIAEoBVIFd2lkdG'
    'gSFgoGaGVpZ2h0GAMgASgFUgZoZWlnaHQSHgoKY3JlYXRlRGF0ZRgEIAEoA1IKY3JlYXRlRGF0'
    'ZRIeCgp1cGRhdGVEYXRlGAUgASgDUgp1cGRhdGVEYXRlEhoKCGR1cmF0aW9uGAYgASgDUghkdX'
    'JhdGlvbhIfCgZhdXRob3IYByABKAsyBy5BdXRob3JSBmF1dGhvchIeCgpjb252ZXJ0VXJsGAgg'
    'ASgJUgpjb252ZXJ0VXJsEiMKCHByb3ZpZGVyGAkgAygLMgcuQXV0aG9yUghwcm92aWRlchI2Ch'
    'ZkZWZhdWx0QmFja2dyb3VuZENvbG9yGAogASgFUhZkZWZhdWx0QmFja2dyb3VuZENvbG9yEjAK'
    'E2xhc3RCYWNrZ3JvdW5kQ29sb3IYCyABKAVSE2xhc3RCYWNrZ3JvdW5kQ29sb3ISKwoKbW92ZU'
    'NvbmZpZxgMIAEoCzILLk1vdmVDb25maWdSCm1vdmVDb25maWcSVwobZGVmYXVsdEJhY2tncm91'
    'bmRMaW5lQ29uZmlnGA0gASgLMhUuQmFja2dyb3VuZExpbmVDb25maWdSG2RlZmF1bHRCYWNrZ3'
    'JvdW5kTGluZUNvbmZpZxJRChhsYXN0QmFja2dyb3VuZExpbmVDb25maWcYDiABKAsyFS5CYWNr'
    'Z3JvdW5kTGluZUNvbmZpZ1IYbGFzdEJhY2tncm91bmRMaW5lQ29uZmln');

@$core.Deprecated('Use moveConfigDescriptor instead')
const MoveConfig$json = {
  '1': 'MoveConfig',
  '2': [
    {'1': 'isEnable', '3': 1, '4': 1, '5': 8, '10': 'isEnable'},
    {
      '1': 'verticalTranslate',
      '3': 2,
      '4': 1,
      '5': 8,
      '10': 'verticalTranslate'
    },
    {
      '1': 'horizontalTranslate',
      '3': 3,
      '4': 1,
      '5': 8,
      '10': 'horizontalTranslate'
    },
    {'1': 'scale', '3': 4, '4': 1, '5': 8, '10': 'scale'},
    {'1': 'rotate', '3': 5, '4': 1, '5': 8, '10': 'rotate'},
    {'1': 'maxHeightTimes', '3': 6, '4': 1, '5': 5, '10': 'maxHeightTimes'},
    {'1': 'maxWidthTimes', '3': 7, '4': 1, '5': 5, '10': 'maxWidthTimes'},
  ],
};

/// Descriptor for `MoveConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List moveConfigDescriptor = $convert.base64Decode(
    'CgpNb3ZlQ29uZmlnEhoKCGlzRW5hYmxlGAEgASgIUghpc0VuYWJsZRIsChF2ZXJ0aWNhbFRyYW'
    '5zbGF0ZRgCIAEoCFIRdmVydGljYWxUcmFuc2xhdGUSMAoTaG9yaXpvbnRhbFRyYW5zbGF0ZRgD'
    'IAEoCFITaG9yaXpvbnRhbFRyYW5zbGF0ZRIUCgVzY2FsZRgEIAEoCFIFc2NhbGUSFgoGcm90YX'
    'RlGAUgASgIUgZyb3RhdGUSJgoObWF4SGVpZ2h0VGltZXMYBiABKAVSDm1heEhlaWdodFRpbWVz'
    'EiQKDW1heFdpZHRoVGltZXMYByABKAVSDW1heFdpZHRoVGltZXM=');

@$core.Deprecated('Use backgroundLineConfigDescriptor instead')
const BackgroundLineConfig$json = {
  '1': 'BackgroundLineConfig',
  '2': [
    {'1': 'lineColor', '3': 1, '4': 1, '5': 5, '10': 'lineColor'},
    {'1': 'lineSpace', '3': 2, '4': 1, '5': 2, '10': 'lineSpace'},
    {
      '1': 'lineType',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.BackgroundLineTypeEnum',
      '10': 'lineType'
    },
    {'1': 'lineWidth', '3': 4, '4': 1, '5': 2, '10': 'lineWidth'},
  ],
};

/// Descriptor for `BackgroundLineConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List backgroundLineConfigDescriptor = $convert.base64Decode(
    'ChRCYWNrZ3JvdW5kTGluZUNvbmZpZxIcCglsaW5lQ29sb3IYASABKAVSCWxpbmVDb2xvchIcCg'
    'lsaW5lU3BhY2UYAiABKAJSCWxpbmVTcGFjZRIzCghsaW5lVHlwZRgDIAEoDjIXLkJhY2tncm91'
    'bmRMaW5lVHlwZUVudW1SCGxpbmVUeXBlEhwKCWxpbmVXaWR0aBgEIAEoAlIJbGluZVdpZHRo');

@$core.Deprecated('Use authorDescriptor instead')
const Author$json = {
  '1': 'Author',
  '2': [
    {'1': 'authorName', '3': 1, '4': 1, '5': 9, '10': 'authorName'},
    {'1': 'schoolId', '3': 2, '4': 1, '5': 9, '10': 'schoolId'},
    {'1': 'authorId', '3': 3, '4': 1, '5': 9, '10': 'authorId'},
    {'1': 'url', '3': 4, '4': 1, '5': 9, '10': 'url'},
    {'1': 'startTime', '3': 5, '4': 1, '5': 3, '10': 'startTime'},
    {'1': 'duration', '3': 6, '4': 1, '5': 3, '10': 'duration'},
  ],
};

/// Descriptor for `Author`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authorDescriptor = $convert.base64Decode(
    'CgZBdXRob3ISHgoKYXV0aG9yTmFtZRgBIAEoCVIKYXV0aG9yTmFtZRIaCghzY2hvb2xJZBgCIA'
    'EoCVIIc2Nob29sSWQSGgoIYXV0aG9ySWQYAyABKAlSCGF1dGhvcklkEhAKA3VybBgEIAEoCVID'
    'dXJsEhwKCXN0YXJ0VGltZRgFIAEoA1IJc3RhcnRUaW1lEhoKCGR1cmF0aW9uGAYgASgDUghkdX'
    'JhdGlvbg==');
