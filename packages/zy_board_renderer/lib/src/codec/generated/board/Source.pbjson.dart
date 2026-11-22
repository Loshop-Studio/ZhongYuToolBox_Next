// This is a generated file - do not edit.
//
// Generated from Source.proto.

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

@$core.Deprecated('Use touchSourceDescriptor instead')
const TouchSource$json = {
  '1': 'TouchSource',
  '2': [
    {
      '1': 'touchInfo',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.TouchSource.TouchInfo',
      '10': 'touchInfo'
    },
  ],
  '3': [TouchSource_TouchInfo$json],
};

@$core.Deprecated('Use touchSourceDescriptor instead')
const TouchSource_TouchInfo$json = {
  '1': 'TouchInfo',
  '2': [
    {
      '1': 'touchEvent',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.TouchEvent',
      '10': 'touchEvent'
    },
    {'1': 'paint', '3': 2, '4': 1, '5': 11, '6': '.Paint', '10': 'paint'},
  ],
};

/// Descriptor for `TouchSource`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List touchSourceDescriptor = $convert.base64Decode(
    'CgtUb3VjaFNvdXJjZRI0Cgl0b3VjaEluZm8YASADKAsyFi5Ub3VjaFNvdXJjZS5Ub3VjaEluZm'
    '9SCXRvdWNoSW5mbxpWCglUb3VjaEluZm8SKwoKdG91Y2hFdmVudBgBIAMoCzILLlRvdWNoRXZl'
    'bnRSCnRvdWNoRXZlbnQSHAoFcGFpbnQYAiABKAsyBi5QYWludFIFcGFpbnQ=');

@$core.Deprecated('Use matrixSourceDescriptor instead')
const MatrixSource$json = {
  '1': 'MatrixSource',
  '2': [
    {
      '1': 'matrixInfo',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.MatrixSource.MatrixInfo',
      '10': 'matrixInfo'
    },
  ],
  '3': [MatrixSource_MatrixInfo$json],
};

@$core.Deprecated('Use matrixSourceDescriptor instead')
const MatrixSource_MatrixInfo$json = {
  '1': 'MatrixInfo',
  '2': [
    {'1': 'matrix', '3': 1, '4': 3, '5': 11, '6': '.Matrix', '10': 'matrix'},
  ],
};

/// Descriptor for `MatrixSource`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matrixSourceDescriptor = $convert.base64Decode(
    'CgxNYXRyaXhTb3VyY2USOAoKbWF0cml4SW5mbxgBIAMoCzIYLk1hdHJpeFNvdXJjZS5NYXRyaX'
    'hJbmZvUgptYXRyaXhJbmZvGi0KCk1hdHJpeEluZm8SHwoGbWF0cml4GAEgAygLMgcuTWF0cml4'
    'UgZtYXRyaXg=');

@$core.Deprecated('Use fileSourceDescriptor instead')
const FileSource$json = {
  '1': 'FileSource',
  '2': [
    {
      '1': 'fileInfo',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.FileSource.FileInfo',
      '10': 'fileInfo'
    },
  ],
  '3': [FileSource_FileInfo$json],
};

@$core.Deprecated('Use fileSourceDescriptor instead')
const FileSource_FileInfo$json = {
  '1': 'FileInfo',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'width', '3': 2, '4': 1, '5': 5, '10': 'width'},
    {'1': 'height', '3': 3, '4': 1, '5': 5, '10': 'height'},
    {'1': 'validate', '3': 4, '4': 1, '5': 9, '10': 'validate'},
  ],
};

/// Descriptor for `FileSource`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileSourceDescriptor = $convert.base64Decode(
    'CgpGaWxlU291cmNlEjAKCGZpbGVJbmZvGAEgAygLMhQuRmlsZVNvdXJjZS5GaWxlSW5mb1IIZm'
    'lsZUluZm8aaAoIRmlsZUluZm8SEgoEbmFtZRgBIAEoCVIEbmFtZRIUCgV3aWR0aBgCIAEoBVIF'
    'd2lkdGgSFgoGaGVpZ2h0GAMgASgFUgZoZWlnaHQSGgoIdmFsaWRhdGUYBCABKAlSCHZhbGlkYX'
    'Rl');

@$core.Deprecated('Use audioSourceDescriptor instead')
const AudioSource$json = {
  '1': 'AudioSource',
  '2': [
    {
      '1': 'audioInfo',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.AudioSource.AudioInfo',
      '10': 'audioInfo'
    },
  ],
  '3': [AudioSource_AudioInfo$json],
};

@$core.Deprecated('Use audioSourceDescriptor instead')
const AudioSource_AudioInfo$json = {
  '1': 'AudioInfo',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'duration', '3': 2, '4': 1, '5': 3, '10': 'duration'},
    {'1': 'validate', '3': 3, '4': 1, '5': 9, '10': 'validate'},
  ],
};

/// Descriptor for `AudioSource`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List audioSourceDescriptor = $convert.base64Decode(
    'CgtBdWRpb1NvdXJjZRI0CglhdWRpb0luZm8YASADKAsyFi5BdWRpb1NvdXJjZS5BdWRpb0luZm'
    '9SCWF1ZGlvSW5mbxpXCglBdWRpb0luZm8SEgoEbmFtZRgBIAEoCVIEbmFtZRIaCghkdXJhdGlv'
    'bhgCIAEoA1IIZHVyYXRpb24SGgoIdmFsaWRhdGUYAyABKAlSCHZhbGlkYXRl');

@$core.Deprecated('Use textSourceDescriptor instead')
const TextSource$json = {
  '1': 'TextSource',
  '2': [
    {
      '1': 'textInfo',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.TextSource.TextInfo',
      '10': 'textInfo'
    },
  ],
  '3': [TextSource_TextInfo$json],
};

@$core.Deprecated('Use textSourceDescriptor instead')
const TextSource_TextInfo$json = {
  '1': 'TextInfo',
  '2': [
    {'1': 'content', '3': 1, '4': 1, '5': 9, '10': 'content'},
    {'1': 'paint', '3': 2, '4': 1, '5': 11, '6': '.Paint', '10': 'paint'},
  ],
};

/// Descriptor for `TextSource`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List textSourceDescriptor = $convert.base64Decode(
    'CgpUZXh0U291cmNlEjAKCHRleHRJbmZvGAEgAygLMhQuVGV4dFNvdXJjZS5UZXh0SW5mb1IIdG'
    'V4dEluZm8aQgoIVGV4dEluZm8SGAoHY29udGVudBgBIAEoCVIHY29udGVudBIcCgVwYWludBgC'
    'IAEoCzIGLlBhaW50UgVwYWludA==');

@$core.Deprecated('Use geometrySourceDescriptor instead')
const GeometrySource$json = {
  '1': 'GeometrySource',
  '2': [
    {
      '1': 'geometryInfo',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.GeometrySource.GeometryInfo',
      '10': 'geometryInfo'
    },
  ],
  '3': [GeometrySource_GeometryInfo$json],
};

@$core.Deprecated('Use geometrySourceDescriptor instead')
const GeometrySource_GeometryInfo$json = {
  '1': 'GeometryInfo',
  '2': [
    {
      '1': 'geometryType',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.GeometryEnum',
      '10': 'geometryType'
    },
    {'1': 'points', '3': 2, '4': 3, '5': 11, '6': '.PointF', '10': 'points'},
    {'1': 'paint', '3': 3, '4': 1, '5': 11, '6': '.Paint', '10': 'paint'},
  ],
};

/// Descriptor for `GeometrySource`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List geometrySourceDescriptor = $convert.base64Decode(
    'Cg5HZW9tZXRyeVNvdXJjZRJACgxnZW9tZXRyeUluZm8YASADKAsyHC5HZW9tZXRyeVNvdXJjZS'
    '5HZW9tZXRyeUluZm9SDGdlb21ldHJ5SW5mbxqAAQoMR2VvbWV0cnlJbmZvEjEKDGdlb21ldHJ5'
    'VHlwZRgBIAEoDjINLkdlb21ldHJ5RW51bVIMZ2VvbWV0cnlUeXBlEh8KBnBvaW50cxgCIAMoCz'
    'IHLlBvaW50RlIGcG9pbnRzEhwKBXBhaW50GAMgASgLMgYuUGFpbnRSBXBhaW50');
