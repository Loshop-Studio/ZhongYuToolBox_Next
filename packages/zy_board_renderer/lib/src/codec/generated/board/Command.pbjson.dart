// This is a generated file - do not edit.
//
// Generated from Command.proto.

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

@$core.Deprecated('Use commandSourceDescriptor instead')
const CommandSource$json = {
  '1': 'CommandSource',
  '2': [
    {
      '1': 'commandInfo',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.CommandSource.CommandInfo',
      '10': 'commandInfo'
    },
  ],
  '3': [CommandSource_CommandInfo$json],
};

@$core.Deprecated('Use commandSourceDescriptor instead')
const CommandSource_CommandInfo$json = {
  '1': 'CommandInfo',
  '2': [
    {'1': 'delayTime', '3': 1, '4': 1, '5': 3, '10': 'delayTime'},
    {'1': 'duration', '3': 2, '4': 1, '5': 3, '10': 'duration'},
    {'1': 'isPlay', '3': 3, '4': 1, '5': 8, '10': 'isPlay'},
    {
      '1': 'commandEnum',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.CommandEnum',
      '10': 'commandEnum'
    },
    {'1': 'data', '3': 5, '4': 1, '5': 12, '10': 'data'},
  ],
  '3': [
    CommandSource_CommandInfo_GraphData$json,
    CommandSource_CommandInfo_GraphRemove$json,
    CommandSource_CommandInfo_GraphMatrix$json,
    CommandSource_CommandInfo_GraphChange$json,
    CommandSource_CommandInfo_AudioStart$json,
    CommandSource_CommandInfo_CameraMatrix$json,
    CommandSource_CommandInfo_Camera$json,
    CommandSource_CommandInfo_Config$json,
    CommandSource_CommandInfo_CursorMove$json,
    CommandSource_CommandInfo_REBUILD$json
  ],
};

@$core.Deprecated('Use commandSourceDescriptor instead')
const CommandSource_CommandInfo_GraphData$json = {
  '1': 'GraphData',
  '2': [
    {
      '1': 'graphEnum',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.GraphEnum',
      '10': 'graphEnum'
    },
    {'1': 'graphId', '3': 2, '4': 1, '5': 9, '10': 'graphId'},
    {'1': 'outRect', '3': 3, '4': 1, '5': 11, '6': '.RectF', '10': 'outRect'},
    {'1': 'parentGraphId', '3': 4, '4': 1, '5': 9, '10': 'parentGraphId'},
    {'1': 'sourceFileName', '3': 5, '4': 1, '5': 9, '10': 'sourceFileName'},
    {'1': 'sourceId', '3': 6, '4': 1, '5': 5, '10': 'sourceId'},
    {'1': 'extras', '3': 7, '4': 1, '5': 9, '10': 'extras'},
  ],
};

@$core.Deprecated('Use commandSourceDescriptor instead')
const CommandSource_CommandInfo_GraphRemove$json = {
  '1': 'GraphRemove',
  '2': [
    {
      '1': 'graphData',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.CommandSource.CommandInfo.GraphData',
      '10': 'graphData'
    },
  ],
};

@$core.Deprecated('Use commandSourceDescriptor instead')
const CommandSource_CommandInfo_GraphMatrix$json = {
  '1': 'GraphMatrix',
  '2': [
    {
      '1': 'graphData',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.CommandSource.CommandInfo.GraphData',
      '10': 'graphData'
    },
    {
      '1': 'originMatrix',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.Matrix',
      '10': 'originMatrix'
    },
    {
      '1': 'lastMatrix',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.Matrix',
      '10': 'lastMatrix'
    },
    {'1': 'sourceFileName', '3': 4, '4': 1, '5': 9, '10': 'sourceFileName'},
    {'1': 'sourceId', '3': 5, '4': 1, '5': 5, '10': 'sourceId'},
  ],
};

@$core.Deprecated('Use commandSourceDescriptor instead')
const CommandSource_CommandInfo_GraphChange$json = {
  '1': 'GraphChange',
  '2': [
    {'1': 'graphId', '3': 1, '4': 1, '5': 9, '10': 'graphId'},
    {
      '1': 'graphEnum',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.GraphEnum',
      '10': 'graphEnum'
    },
    {'1': 'outRect', '3': 3, '4': 1, '5': 11, '6': '.RectF', '10': 'outRect'},
    {'1': 'content', '3': 4, '4': 1, '5': 9, '10': 'content'},
    {'1': 'paint', '3': 5, '4': 1, '5': 11, '6': '.Paint', '10': 'paint'},
    {'1': 'points', '3': 6, '4': 3, '5': 11, '6': '.PointF', '10': 'points'},
    {
      '1': 'renderMatrix',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.Matrix',
      '10': 'renderMatrix'
    },
    {'1': 'filePath', '3': 8, '4': 1, '5': 9, '10': 'filePath'},
  ],
};

@$core.Deprecated('Use commandSourceDescriptor instead')
const CommandSource_CommandInfo_AudioStart$json = {
  '1': 'AudioStart',
  '2': [
    {'1': 'fileName', '3': 1, '4': 1, '5': 9, '10': 'fileName'},
    {'1': 'duration', '3': 2, '4': 1, '5': 3, '10': 'duration'},
    {'1': 'validate', '3': 3, '4': 1, '5': 9, '10': 'validate'},
  ],
};

@$core.Deprecated('Use commandSourceDescriptor instead')
const CommandSource_CommandInfo_CameraMatrix$json = {
  '1': 'CameraMatrix',
  '2': [
    {
      '1': 'originMatrix',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.Matrix',
      '10': 'originMatrix'
    },
    {
      '1': 'lastMatrix',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.Matrix',
      '10': 'lastMatrix'
    },
    {'1': 'sourceFileName', '3': 3, '4': 1, '5': 9, '10': 'sourceFileName'},
    {'1': 'sourceId', '3': 4, '4': 1, '5': 5, '10': 'sourceId'},
  ],
};

@$core.Deprecated('Use commandSourceDescriptor instead')
const CommandSource_CommandInfo_Camera$json = {
  '1': 'Camera',
  '2': [
    {
      '1': 'originMatrix',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.Matrix',
      '10': 'originMatrix'
    },
    {
      '1': 'lastMatrix',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.Matrix',
      '10': 'lastMatrix'
    },
  ],
};

@$core.Deprecated('Use commandSourceDescriptor instead')
const CommandSource_CommandInfo_Config$json = {
  '1': 'Config',
  '2': [
    {'1': 'originBackground', '3': 1, '4': 1, '5': 5, '10': 'originBackground'},
    {'1': 'lastBackground', '3': 2, '4': 1, '5': 5, '10': 'lastBackground'},
    {
      '1': 'originBackgroundLineConfig',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.BackgroundLineConfig',
      '10': 'originBackgroundLineConfig'
    },
    {
      '1': 'lastBackgroundLineConfig',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.BackgroundLineConfig',
      '10': 'lastBackgroundLineConfig'
    },
  ],
};

@$core.Deprecated('Use commandSourceDescriptor instead')
const CommandSource_CommandInfo_CursorMove$json = {
  '1': 'CursorMove',
  '2': [
    {'1': 'sourceFileName', '3': 1, '4': 1, '5': 9, '10': 'sourceFileName'},
    {'1': 'sourceId', '3': 2, '4': 1, '5': 5, '10': 'sourceId'},
  ],
};

@$core.Deprecated('Use commandSourceDescriptor instead')
const CommandSource_CommandInfo_REBUILD$json = {
  '1': 'REBUILD',
  '2': [
    {
      '1': 'snapshot',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.PageSnapshot.GraphSnapshot',
      '10': 'snapshot'
    },
    {'1': 'backgroundColor', '3': 2, '4': 1, '5': 5, '10': 'backgroundColor'},
    {
      '1': 'backgroundLineConfig',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.BackgroundLineConfig',
      '10': 'backgroundLineConfig'
    },
  ],
};

/// Descriptor for `CommandSource`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commandSourceDescriptor = $convert.base64Decode(
    'Cg1Db21tYW5kU291cmNlEjwKC2NvbW1hbmRJbmZvGAEgAygLMhouQ29tbWFuZFNvdXJjZS5Db2'
    '1tYW5kSW5mb1ILY29tbWFuZEluZm8a9A4KC0NvbW1hbmRJbmZvEhwKCWRlbGF5VGltZRgBIAEo'
    'A1IJZGVsYXlUaW1lEhoKCGR1cmF0aW9uGAIgASgDUghkdXJhdGlvbhIWCgZpc1BsYXkYAyABKA'
    'hSBmlzUGxheRIuCgtjb21tYW5kRW51bRgEIAEoDjIMLkNvbW1hbmRFbnVtUgtjb21tYW5kRW51'
    'bRISCgRkYXRhGAUgASgMUgRkYXRhGvMBCglHcmFwaERhdGESKAoJZ3JhcGhFbnVtGAEgASgOMg'
    'ouR3JhcGhFbnVtUglncmFwaEVudW0SGAoHZ3JhcGhJZBgCIAEoCVIHZ3JhcGhJZBIgCgdvdXRS'
    'ZWN0GAMgASgLMgYuUmVjdEZSB291dFJlY3QSJAoNcGFyZW50R3JhcGhJZBgEIAEoCVINcGFyZW'
    '50R3JhcGhJZBImCg5zb3VyY2VGaWxlTmFtZRgFIAEoCVIOc291cmNlRmlsZU5hbWUSGgoIc291'
    'cmNlSWQYBiABKAVSCHNvdXJjZUlkEhYKBmV4dHJhcxgHIAEoCVIGZXh0cmFzGlEKC0dyYXBoUm'
    'Vtb3ZlEkIKCWdyYXBoRGF0YRgBIAMoCzIkLkNvbW1hbmRTb3VyY2UuQ29tbWFuZEluZm8uR3Jh'
    'cGhEYXRhUglncmFwaERhdGEa6wEKC0dyYXBoTWF0cml4EkIKCWdyYXBoRGF0YRgBIAMoCzIkLk'
    'NvbW1hbmRTb3VyY2UuQ29tbWFuZEluZm8uR3JhcGhEYXRhUglncmFwaERhdGESKwoMb3JpZ2lu'
    'TWF0cml4GAIgASgLMgcuTWF0cml4UgxvcmlnaW5NYXRyaXgSJwoKbGFzdE1hdHJpeBgDIAEoCz'
    'IHLk1hdHJpeFIKbGFzdE1hdHJpeBImCg5zb3VyY2VGaWxlTmFtZRgEIAEoCVIOc291cmNlRmls'
    'ZU5hbWUSGgoIc291cmNlSWQYBSABKAVSCHNvdXJjZUlkGpUCCgtHcmFwaENoYW5nZRIYCgdncm'
    'FwaElkGAEgASgJUgdncmFwaElkEigKCWdyYXBoRW51bRgCIAEoDjIKLkdyYXBoRW51bVIJZ3Jh'
    'cGhFbnVtEiAKB291dFJlY3QYAyABKAsyBi5SZWN0RlIHb3V0UmVjdBIYCgdjb250ZW50GAQgAS'
    'gJUgdjb250ZW50EhwKBXBhaW50GAUgASgLMgYuUGFpbnRSBXBhaW50Eh8KBnBvaW50cxgGIAMo'
    'CzIHLlBvaW50RlIGcG9pbnRzEisKDHJlbmRlck1hdHJpeBgHIAEoCzIHLk1hdHJpeFIMcmVuZG'
    'VyTWF0cml4EhoKCGZpbGVQYXRoGAggASgJUghmaWxlUGF0aBpgCgpBdWRpb1N0YXJ0EhoKCGZp'
    'bGVOYW1lGAEgASgJUghmaWxlTmFtZRIaCghkdXJhdGlvbhgCIAEoA1IIZHVyYXRpb24SGgoIdm'
    'FsaWRhdGUYAyABKAlSCHZhbGlkYXRlGqgBCgxDYW1lcmFNYXRyaXgSKwoMb3JpZ2luTWF0cml4'
    'GAEgASgLMgcuTWF0cml4UgxvcmlnaW5NYXRyaXgSJwoKbGFzdE1hdHJpeBgCIAEoCzIHLk1hdH'
    'JpeFIKbGFzdE1hdHJpeBImCg5zb3VyY2VGaWxlTmFtZRgDIAEoCVIOc291cmNlRmlsZU5hbWUS'
    'GgoIc291cmNlSWQYBCABKAVSCHNvdXJjZUlkGl4KBkNhbWVyYRIrCgxvcmlnaW5NYXRyaXgYAS'
    'ABKAsyBy5NYXRyaXhSDG9yaWdpbk1hdHJpeBInCgpsYXN0TWF0cml4GAIgASgLMgcuTWF0cml4'
    'UgpsYXN0TWF0cml4GoYCCgZDb25maWcSKgoQb3JpZ2luQmFja2dyb3VuZBgBIAEoBVIQb3JpZ2'
    'luQmFja2dyb3VuZBImCg5sYXN0QmFja2dyb3VuZBgCIAEoBVIObGFzdEJhY2tncm91bmQSVQoa'
    'b3JpZ2luQmFja2dyb3VuZExpbmVDb25maWcYAyABKAsyFS5CYWNrZ3JvdW5kTGluZUNvbmZpZ1'
    'Iab3JpZ2luQmFja2dyb3VuZExpbmVDb25maWcSUQoYbGFzdEJhY2tncm91bmRMaW5lQ29uZmln'
    'GAQgASgLMhUuQmFja2dyb3VuZExpbmVDb25maWdSGGxhc3RCYWNrZ3JvdW5kTGluZUNvbmZpZx'
    'pQCgpDdXJzb3JNb3ZlEiYKDnNvdXJjZUZpbGVOYW1lGAEgASgJUg5zb3VyY2VGaWxlTmFtZRIa'
    'Cghzb3VyY2VJZBgCIAEoBVIIc291cmNlSWQatwEKB1JFQlVJTEQSNwoIc25hcHNob3QYASABKA'
    'syGy5QYWdlU25hcHNob3QuR3JhcGhTbmFwc2hvdFIIc25hcHNob3QSKAoPYmFja2dyb3VuZENv'
    'bG9yGAIgASgFUg9iYWNrZ3JvdW5kQ29sb3ISSQoUYmFja2dyb3VuZExpbmVDb25maWcYAyABKA'
    'syFS5CYWNrZ3JvdW5kTGluZUNvbmZpZ1IUYmFja2dyb3VuZExpbmVDb25maWc=');
