// This is a generated file - do not edit.
//
// Generated from SketchGraphSnapshot.proto.

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

@$core.Deprecated('Use graphTypeDescriptor instead')
const GraphType$json = {
  '1': 'GraphType',
  '2': [
    {'1': 'UNBOUNDED_CONTAINER_GRAPH', '2': 0},
    {'1': 'BOUNDED_CONTAINER_GRAPH', '2': 1},
    {'1': 'IMAGE_GRAPH', '2': 2},
    {'1': 'WEB_VIEW_GRAPH', '2': 3},
    {'1': 'WRITING_GROUP_GRAPH', '2': 4},
    {'1': 'STROKE_GRAPH', '2': 5},
    {'1': 'SHAPE_GRAPH', '2': 6},
  ],
};

/// Descriptor for `GraphType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List graphTypeDescriptor = $convert.base64Decode(
    'CglHcmFwaFR5cGUSHQoZVU5CT1VOREVEX0NPTlRBSU5FUl9HUkFQSBAAEhsKF0JPVU5ERURfQ0'
    '9OVEFJTkVSX0dSQVBIEAESDwoLSU1BR0VfR1JBUEgQAhISCg5XRUJfVklFV19HUkFQSBADEhcK'
    'E1dSSVRJTkdfR1JPVVBfR1JBUEgQBBIQCgxTVFJPS0VfR1JBUEgQBRIPCgtTSEFQRV9HUkFQSB'
    'AG');

@$core.Deprecated('Use graphDataDescriptor instead')
const GraphData$json = {
  '1': 'GraphData',
  '2': [
    {
      '1': 'graphType',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.GraphType',
      '10': 'graphType'
    },
    {
      '1': 'childGraph',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.GraphData',
      '10': 'childGraph'
    },
    {'1': 'matrix', '3': 3, '4': 3, '5': 2, '10': 'matrix'},
    {
      '1': 'childExtendMatrix',
      '3': 4,
      '4': 3,
      '5': 2,
      '10': 'childExtendMatrix'
    },
    {'1': 'width', '3': 6, '4': 1, '5': 2, '10': 'width'},
    {'1': 'color', '3': 7, '4': 1, '5': 5, '10': 'color'},
    {'1': 'isSelect', '3': 8, '4': 1, '5': 8, '10': 'isSelect'},
    {'1': 'showDelete', '3': 9, '4': 1, '5': 8, '10': 'showDelete'},
    {
      '1': 'extra',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Any',
      '10': 'extra'
    },
    {'1': 'name', '3': 11, '4': 1, '5': 9, '10': 'name'},
    {'1': 'outRect', '3': 12, '4': 1, '5': 11, '6': '.RectF', '10': 'outRect'},
  ],
};

/// Descriptor for `GraphData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List graphDataDescriptor = $convert.base64Decode(
    'CglHcmFwaERhdGESKAoJZ3JhcGhUeXBlGAEgASgOMgouR3JhcGhUeXBlUglncmFwaFR5cGUSKg'
    'oKY2hpbGRHcmFwaBgCIAMoCzIKLkdyYXBoRGF0YVIKY2hpbGRHcmFwaBIWCgZtYXRyaXgYAyAD'
    'KAJSBm1hdHJpeBIsChFjaGlsZEV4dGVuZE1hdHJpeBgEIAMoAlIRY2hpbGRFeHRlbmRNYXRyaX'
    'gSFAoFd2lkdGgYBiABKAJSBXdpZHRoEhQKBWNvbG9yGAcgASgFUgVjb2xvchIaCghpc1NlbGVj'
    'dBgIIAEoCFIIaXNTZWxlY3QSHgoKc2hvd0RlbGV0ZRgJIAEoCFIKc2hvd0RlbGV0ZRIqCgVleH'
    'RyYRgKIAEoCzIULmdvb2dsZS5wcm90b2J1Zi5BbnlSBWV4dHJhEhIKBG5hbWUYCyABKAlSBG5h'
    'bWUSIAoHb3V0UmVjdBgMIAEoCzIGLlJlY3RGUgdvdXRSZWN0');

@$core.Deprecated('Use pointFDescriptor instead')
const PointF$json = {
  '1': 'PointF',
  '2': [
    {'1': 'x', '3': 1, '4': 1, '5': 2, '10': 'x'},
    {'1': 'y', '3': 2, '4': 1, '5': 2, '10': 'y'},
  ],
};

/// Descriptor for `PointF`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pointFDescriptor =
    $convert.base64Decode('CgZQb2ludEYSDAoBeBgBIAEoAlIBeBIMCgF5GAIgASgCUgF5');

@$core.Deprecated('Use touchDescriptor instead')
const Touch$json = {
  '1': 'Touch',
  '2': [
    {'1': 'pointF', '3': 1, '4': 3, '5': 11, '6': '.PointF', '10': 'pointF'},
  ],
};

/// Descriptor for `Touch`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List touchDescriptor = $convert
    .base64Decode('CgVUb3VjaBIfCgZwb2ludEYYASADKAsyBy5Qb2ludEZSBnBvaW50Rg==');

@$core.Deprecated('Use fileDescriptor instead')
const File$json = {
  '1': 'File',
  '2': [
    {'1': 'fileName', '3': 1, '4': 1, '5': 9, '10': 'fileName'},
    {'1': 'width', '3': 2, '4': 1, '5': 5, '10': 'width'},
    {'1': 'height', '3': 3, '4': 1, '5': 5, '10': 'height'},
    {'1': 'viewWidth', '3': 4, '4': 1, '5': 5, '10': 'viewWidth'},
    {'1': 'viewHeight', '3': 5, '4': 1, '5': 5, '10': 'viewHeight'},
    {'1': 'positionFlag', '3': 6, '4': 1, '5': 5, '10': 'positionFlag'},
  ],
};

/// Descriptor for `File`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileDescriptor = $convert.base64Decode(
    'CgRGaWxlEhoKCGZpbGVOYW1lGAEgASgJUghmaWxlTmFtZRIUCgV3aWR0aBgCIAEoBVIFd2lkdG'
    'gSFgoGaGVpZ2h0GAMgASgFUgZoZWlnaHQSHAoJdmlld1dpZHRoGAQgASgFUgl2aWV3V2lkdGgS'
    'HgoKdmlld0hlaWdodBgFIAEoBVIKdmlld0hlaWdodBIiCgxwb3NpdGlvbkZsYWcYBiABKAVSDH'
    'Bvc2l0aW9uRmxhZw==');

@$core.Deprecated('Use rectFDescriptor instead')
const RectF$json = {
  '1': 'RectF',
  '2': [
    {'1': 'left', '3': 1, '4': 1, '5': 2, '10': 'left'},
    {'1': 'top', '3': 2, '4': 1, '5': 2, '10': 'top'},
    {'1': 'right', '3': 3, '4': 1, '5': 2, '10': 'right'},
    {'1': 'bottom', '3': 4, '4': 1, '5': 2, '10': 'bottom'},
  ],
};

/// Descriptor for `RectF`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rectFDescriptor = $convert.base64Decode(
    'CgVSZWN0RhISCgRsZWZ0GAEgASgCUgRsZWZ0EhAKA3RvcBgCIAEoAlIDdG9wEhQKBXJpZ2h0GA'
    'MgASgCUgVyaWdodBIWCgZib3R0b20YBCABKAJSBmJvdHRvbQ==');
