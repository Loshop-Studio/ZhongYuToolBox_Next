// This is a generated file - do not edit.
//
// Generated from GraphSnapshot.proto.

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

@$core.Deprecated('Use pageSnapshotDescriptor instead')
const PageSnapshot$json = {
  '1': 'PageSnapshot',
  '2': [
    {
      '1': 'cameraMatrix',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.Matrix',
      '10': 'cameraMatrix'
    },
    {
      '1': 'graphSnapshot',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.PageSnapshot.GraphSnapshot',
      '10': 'graphSnapshot'
    },
  ],
  '3': [PageSnapshot_GraphSnapshot$json],
};

@$core.Deprecated('Use pageSnapshotDescriptor instead')
const PageSnapshot_GraphSnapshot$json = {
  '1': 'GraphSnapshot',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'graphEnum',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.GraphEnum',
      '10': 'graphEnum'
    },
    {'1': 'outRect', '3': 3, '4': 1, '5': 11, '6': '.RectF', '10': 'outRect'},
    {'1': 'matrix', '3': 4, '4': 1, '5': 11, '6': '.Matrix', '10': 'matrix'},
    {
      '1': 'childGraph',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.PageSnapshot.GraphSnapshot',
      '10': 'childGraph'
    },
    {'1': 'sourceFileName', '3': 6, '4': 1, '5': 9, '10': 'sourceFileName'},
    {'1': 'sourceId', '3': 7, '4': 1, '5': 5, '10': 'sourceId'},
    {'1': 'backgroundColor', '3': 8, '4': 1, '5': 5, '10': 'backgroundColor'},
    {'1': 'paint', '3': 9, '4': 1, '5': 11, '6': '.Paint', '10': 'paint'},
    {'1': 'content', '3': 10, '4': 1, '5': 9, '10': 'content'},
    {
      '1': 'pointList',
      '3': 11,
      '4': 3,
      '5': 11,
      '6': '.PointF',
      '10': 'pointList'
    },
    {'1': 'filePath', '3': 12, '4': 1, '5': 9, '10': 'filePath'},
  ],
};

/// Descriptor for `PageSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pageSnapshotDescriptor = $convert.base64Decode(
    'CgxQYWdlU25hcHNob3QSKwoMY2FtZXJhTWF0cml4GAEgASgLMgcuTWF0cml4UgxjYW1lcmFNYX'
    'RyaXgSQQoNZ3JhcGhTbmFwc2hvdBgCIAEoCzIbLlBhZ2VTbmFwc2hvdC5HcmFwaFNuYXBzaG90'
    'Ug1ncmFwaFNuYXBzaG90GrIDCg1HcmFwaFNuYXBzaG90Eg4KAmlkGAEgASgJUgJpZBIoCglncm'
    'FwaEVudW0YAiABKA4yCi5HcmFwaEVudW1SCWdyYXBoRW51bRIgCgdvdXRSZWN0GAMgASgLMgYu'
    'UmVjdEZSB291dFJlY3QSHwoGbWF0cml4GAQgASgLMgcuTWF0cml4UgZtYXRyaXgSOwoKY2hpbG'
    'RHcmFwaBgFIAMoCzIbLlBhZ2VTbmFwc2hvdC5HcmFwaFNuYXBzaG90UgpjaGlsZEdyYXBoEiYK'
    'DnNvdXJjZUZpbGVOYW1lGAYgASgJUg5zb3VyY2VGaWxlTmFtZRIaCghzb3VyY2VJZBgHIAEoBV'
    'IIc291cmNlSWQSKAoPYmFja2dyb3VuZENvbG9yGAggASgFUg9iYWNrZ3JvdW5kQ29sb3ISHAoF'
    'cGFpbnQYCSABKAsyBi5QYWludFIFcGFpbnQSGAoHY29udGVudBgKIAEoCVIHY29udGVudBIlCg'
    'lwb2ludExpc3QYCyADKAsyBy5Qb2ludEZSCXBvaW50TGlzdBIaCghmaWxlUGF0aBgMIAEoCVII'
    'ZmlsZVBhdGg=');
