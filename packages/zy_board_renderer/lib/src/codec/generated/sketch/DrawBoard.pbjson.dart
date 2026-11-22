// This is a generated file - do not edit.
//
// Generated from DrawBoard.proto.

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

@$core.Deprecated('Use actionEnumDescriptor instead')
const ActionEnum$json = {
  '1': 'ActionEnum',
  '2': [
    {'1': 'ACTION_TOUCH', '2': 0},
    {'1': 'ACTION_MODE', '2': 1},
    {'1': 'ACTION_GRAPH', '2': 2},
    {'1': 'ACTION_WEB', '2': 3},
    {'1': 'ACTION_IMAGE', '2': 4},
    {'1': 'ACTION_FILTER', '2': 5},
    {'1': 'ACTION_CLEAR_BOARD', '2': 6},
    {'1': 'ACTION_NEXT', '2': 7},
    {'1': 'ACTION_PREV', '2': 8},
    {'1': 'ACTION_AUDIO_START', '2': 9},
    {'1': 'ACTION_AUDIO_STOP', '2': 10},
    {'1': 'ACTION_ZOOM', '2': 11},
    {'1': 'ACTION_TRANS', '2': 12},
    {'1': 'ACTION_DRAW_CONFIG', '2': 13},
    {'1': 'ACTION_RESET_MATRIX', '2': 14},
  ],
};

/// Descriptor for `ActionEnum`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List actionEnumDescriptor = $convert.base64Decode(
    'CgpBY3Rpb25FbnVtEhAKDEFDVElPTl9UT1VDSBAAEg8KC0FDVElPTl9NT0RFEAESEAoMQUNUSU'
    '9OX0dSQVBIEAISDgoKQUNUSU9OX1dFQhADEhAKDEFDVElPTl9JTUFHRRAEEhEKDUFDVElPTl9G'
    'SUxURVIQBRIWChJBQ1RJT05fQ0xFQVJfQk9BUkQQBhIPCgtBQ1RJT05fTkVYVBAHEg8KC0FDVE'
    'lPTl9QUkVWEAgSFgoSQUNUSU9OX0FVRElPX1NUQVJUEAkSFQoRQUNUSU9OX0FVRElPX1NUT1AQ'
    'ChIPCgtBQ1RJT05fWk9PTRALEhAKDEFDVElPTl9UUkFOUxAMEhYKEkFDVElPTl9EUkFXX0NPTk'
    'ZJRxANEhcKE0FDVElPTl9SRVNFVF9NQVRSSVgQDg==');

@$core.Deprecated('Use drawBoardDescriptor instead')
const DrawBoard$json = {
  '1': 'DrawBoard',
  '2': [
    {
      '1': 'boardHead',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.BoardHead',
      '10': 'boardHead'
    },
    {
      '1': 'boardBody',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.BoardBody',
      '10': 'boardBody'
    },
  ],
};

/// Descriptor for `DrawBoard`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List drawBoardDescriptor = $convert.base64Decode(
    'CglEcmF3Qm9hcmQSKAoJYm9hcmRIZWFkGAEgASgLMgouQm9hcmRIZWFkUglib2FyZEhlYWQSKA'
    'oJYm9hcmRCb2R5GAIgASgLMgouQm9hcmRCb2R5Uglib2FyZEJvZHk=');

@$core.Deprecated('Use drawBoardV1Descriptor instead')
const DrawBoardV1$json = {
  '1': 'DrawBoardV1',
  '2': [
    {
      '1': 'boardHead',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.BoardHead',
      '10': 'boardHead'
    },
    {
      '1': 'boardBodyV1',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.BoardBodyV1',
      '10': 'boardBodyV1'
    },
  ],
};

/// Descriptor for `DrawBoardV1`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List drawBoardV1Descriptor = $convert.base64Decode(
    'CgtEcmF3Qm9hcmRWMRIoCglib2FyZEhlYWQYASABKAsyCi5Cb2FyZEhlYWRSCWJvYXJkSGVhZB'
    'IuCgtib2FyZEJvZHlWMRgCIAEoCzIMLkJvYXJkQm9keVYxUgtib2FyZEJvZHlWMQ==');

@$core.Deprecated('Use boardHeadDescriptor instead')
const BoardHead$json = {
  '1': 'BoardHead',
  '2': [
    {'1': 'version', '3': 1, '4': 1, '5': 5, '10': 'version'},
    {'1': 'width', '3': 3, '4': 1, '5': 5, '10': 'width'},
    {'1': 'height', '3': 4, '4': 1, '5': 5, '10': 'height'},
    {'1': 'createDate', '3': 5, '4': 1, '5': 3, '10': 'createDate'},
    {'1': 'updateDate', '3': 6, '4': 1, '5': 3, '10': 'updateDate'},
    {'1': 'author', '3': 7, '4': 1, '5': 9, '10': 'author'},
    {'1': 'type', '3': 8, '4': 1, '5': 5, '10': 'type'},
  ],
};

/// Descriptor for `BoardHead`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List boardHeadDescriptor = $convert.base64Decode(
    'CglCb2FyZEhlYWQSGAoHdmVyc2lvbhgBIAEoBVIHdmVyc2lvbhIUCgV3aWR0aBgDIAEoBVIFd2'
    'lkdGgSFgoGaGVpZ2h0GAQgASgFUgZoZWlnaHQSHgoKY3JlYXRlRGF0ZRgFIAEoA1IKY3JlYXRl'
    'RGF0ZRIeCgp1cGRhdGVEYXRlGAYgASgDUgp1cGRhdGVEYXRlEhYKBmF1dGhvchgHIAEoCVIGYX'
    'V0aG9yEhIKBHR5cGUYCCABKAVSBHR5cGU=');

@$core.Deprecated('Use boardBodyDescriptor instead')
const BoardBody$json = {
  '1': 'BoardBody',
  '2': [
    {
      '1': 'ActionContent',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.ActionContent',
      '10': 'ActionContent'
    },
  ],
};

/// Descriptor for `BoardBody`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List boardBodyDescriptor = $convert.base64Decode(
    'CglCb2FyZEJvZHkSNAoNQWN0aW9uQ29udGVudBgBIAMoCzIOLkFjdGlvbkNvbnRlbnRSDUFjdG'
    'lvbkNvbnRlbnQ=');

@$core.Deprecated('Use boardBodyV1Descriptor instead')
const BoardBodyV1$json = {
  '1': 'BoardBodyV1',
  '2': [
    {
      '1': 'ActionContent',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.google.protobuf.Any',
      '10': 'ActionContent'
    },
  ],
};

/// Descriptor for `BoardBodyV1`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List boardBodyV1Descriptor = $convert.base64Decode(
    'CgtCb2FyZEJvZHlWMRI6Cg1BY3Rpb25Db250ZW50GAEgAygLMhQuZ29vZ2xlLnByb3RvYnVmLk'
    'FueVINQWN0aW9uQ29udGVudA==');

@$core.Deprecated('Use actionContentDescriptor instead')
const ActionContent$json = {
  '1': 'ActionContent',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.ActionEnum', '10': 'type'},
    {
      '1': 'action',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Any',
      '10': 'action'
    },
    {
      '1': 'graphSnapshot',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.GraphData',
      '10': 'graphSnapshot'
    },
    {
      '1': 'resetData',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.GraphResetData',
      '10': 'resetData'
    },
  ],
};

/// Descriptor for `ActionContent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List actionContentDescriptor = $convert.base64Decode(
    'Cg1BY3Rpb25Db250ZW50Eh8KBHR5cGUYASABKA4yCy5BY3Rpb25FbnVtUgR0eXBlEiwKBmFjdG'
    'lvbhgCIAEoCzIULmdvb2dsZS5wcm90b2J1Zi5BbnlSBmFjdGlvbhIwCg1ncmFwaFNuYXBzaG90'
    'GAMgASgLMgouR3JhcGhEYXRhUg1ncmFwaFNuYXBzaG90Ei0KCXJlc2V0RGF0YRgFIAEoCzIPLk'
    'dyYXBoUmVzZXREYXRhUglyZXNldERhdGE=');

@$core.Deprecated('Use actionTouchEventDescriptor instead')
const ActionTouchEvent$json = {
  '1': 'ActionTouchEvent',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 5, '10': 'type'},
    {'1': 'startTime', '3': 2, '4': 1, '5': 3, '10': 'startTime'},
    {'1': 'endTime', '3': 3, '4': 1, '5': 3, '10': 'endTime'},
    {
      '1': 'touchEvent',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.ActionTouchEvent.TouchEvent',
      '10': 'touchEvent'
    },
  ],
  '3': [ActionTouchEvent_TouchEvent$json],
};

@$core.Deprecated('Use actionTouchEventDescriptor instead')
const ActionTouchEvent_TouchEvent$json = {
  '1': 'TouchEvent',
  '2': [
    {'1': 'eventTime', '3': 2, '4': 1, '5': 3, '10': 'eventTime'},
    {'1': 'action', '3': 3, '4': 1, '5': 5, '10': 'action'},
    {'1': 'pointerCount', '3': 4, '4': 1, '5': 5, '10': 'pointerCount'},
    {
      '1': 'pointerProperties',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.ActionTouchEvent.TouchEvent.PointerProperties',
      '10': 'pointerProperties'
    },
    {
      '1': 'pointerCoords',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.ActionTouchEvent.TouchEvent.PointerCoords',
      '10': 'pointerCoords'
    },
    {'1': 'x', '3': 15, '4': 1, '5': 2, '10': 'x'},
    {'1': 'y', '3': 16, '4': 1, '5': 2, '10': 'y'},
  ],
  '3': [
    ActionTouchEvent_TouchEvent_PointerProperties$json,
    ActionTouchEvent_TouchEvent_PointerCoords$json
  ],
};

@$core.Deprecated('Use actionTouchEventDescriptor instead')
const ActionTouchEvent_TouchEvent_PointerProperties$json = {
  '1': 'PointerProperties',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'toolType', '3': 2, '4': 1, '5': 5, '10': 'toolType'},
  ],
};

@$core.Deprecated('Use actionTouchEventDescriptor instead')
const ActionTouchEvent_TouchEvent_PointerCoords$json = {
  '1': 'PointerCoords',
  '2': [
    {'1': 'x', '3': 1, '4': 1, '5': 2, '10': 'x'},
    {'1': 'y', '3': 2, '4': 1, '5': 2, '10': 'y'},
  ],
};

/// Descriptor for `ActionTouchEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List actionTouchEventDescriptor = $convert.base64Decode(
    'ChBBY3Rpb25Ub3VjaEV2ZW50EhIKBHR5cGUYASABKAVSBHR5cGUSHAoJc3RhcnRUaW1lGAIgAS'
    'gDUglzdGFydFRpbWUSGAoHZW5kVGltZRgDIAEoA1IHZW5kVGltZRI8Cgp0b3VjaEV2ZW50GAQg'
    'AygLMhwuQWN0aW9uVG91Y2hFdmVudC5Ub3VjaEV2ZW50Ugp0b3VjaEV2ZW50GqADCgpUb3VjaE'
    'V2ZW50EhwKCWV2ZW50VGltZRgCIAEoA1IJZXZlbnRUaW1lEhYKBmFjdGlvbhgDIAEoBVIGYWN0'
    'aW9uEiIKDHBvaW50ZXJDb3VudBgEIAEoBVIMcG9pbnRlckNvdW50ElwKEXBvaW50ZXJQcm9wZX'
    'J0aWVzGAUgAygLMi4uQWN0aW9uVG91Y2hFdmVudC5Ub3VjaEV2ZW50LlBvaW50ZXJQcm9wZXJ0'
    'aWVzUhFwb2ludGVyUHJvcGVydGllcxJQCg1wb2ludGVyQ29vcmRzGAYgAygLMiouQWN0aW9uVG'
    '91Y2hFdmVudC5Ub3VjaEV2ZW50LlBvaW50ZXJDb29yZHNSDXBvaW50ZXJDb29yZHMSDAoBeBgP'
    'IAEoAlIBeBIMCgF5GBAgASgCUgF5Gj8KEVBvaW50ZXJQcm9wZXJ0aWVzEg4KAmlkGAEgASgFUg'
    'JpZBIaCgh0b29sVHlwZRgCIAEoBVIIdG9vbFR5cGUaKwoNUG9pbnRlckNvb3JkcxIMCgF4GAEg'
    'ASgCUgF4EgwKAXkYAiABKAJSAXk=');

@$core.Deprecated('Use actionImageConfigDescriptor instead')
const ActionImageConfig$json = {
  '1': 'ActionImageConfig',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 5, '10': 'type'},
    {'1': 'startTime', '3': 2, '4': 1, '5': 3, '10': 'startTime'},
    {'1': 'path', '3': 3, '4': 1, '5': 9, '10': 'path'},
    {'1': 'width', '3': 4, '4': 1, '5': 5, '10': 'width'},
    {'1': 'height', '3': 5, '4': 1, '5': 5, '10': 'height'},
    {'1': 'viewWidth', '3': 6, '4': 1, '5': 5, '10': 'viewWidth'},
    {'1': 'viewHeight', '3': 7, '4': 1, '5': 5, '10': 'viewHeight'},
    {'1': 'positionFlag', '3': 8, '4': 1, '5': 5, '10': 'positionFlag'},
  ],
};

/// Descriptor for `ActionImageConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List actionImageConfigDescriptor = $convert.base64Decode(
    'ChFBY3Rpb25JbWFnZUNvbmZpZxISCgR0eXBlGAEgASgFUgR0eXBlEhwKCXN0YXJ0VGltZRgCIA'
    'EoA1IJc3RhcnRUaW1lEhIKBHBhdGgYAyABKAlSBHBhdGgSFAoFd2lkdGgYBCABKAVSBXdpZHRo'
    'EhYKBmhlaWdodBgFIAEoBVIGaGVpZ2h0EhwKCXZpZXdXaWR0aBgGIAEoBVIJdmlld1dpZHRoEh'
    '4KCnZpZXdIZWlnaHQYByABKAVSCnZpZXdIZWlnaHQSIgoMcG9zaXRpb25GbGFnGAggASgFUgxw'
    'b3NpdGlvbkZsYWc=');

@$core.Deprecated('Use actionWebViewConfigDescriptor instead')
const ActionWebViewConfig$json = {
  '1': 'ActionWebViewConfig',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 5, '10': 'type'},
    {'1': 'startTime', '3': 2, '4': 1, '5': 3, '10': 'startTime'},
    {'1': 'path', '3': 3, '4': 1, '5': 9, '10': 'path'},
    {'1': 'width', '3': 4, '4': 1, '5': 5, '10': 'width'},
    {'1': 'height', '3': 5, '4': 1, '5': 5, '10': 'height'},
    {'1': 'viewWidth', '3': 6, '4': 1, '5': 5, '10': 'viewWidth'},
    {'1': 'viewHeight', '3': 7, '4': 1, '5': 5, '10': 'viewHeight'},
  ],
};

/// Descriptor for `ActionWebViewConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List actionWebViewConfigDescriptor = $convert.base64Decode(
    'ChNBY3Rpb25XZWJWaWV3Q29uZmlnEhIKBHR5cGUYASABKAVSBHR5cGUSHAoJc3RhcnRUaW1lGA'
    'IgASgDUglzdGFydFRpbWUSEgoEcGF0aBgDIAEoCVIEcGF0aBIUCgV3aWR0aBgEIAEoBVIFd2lk'
    'dGgSFgoGaGVpZ2h0GAUgASgFUgZoZWlnaHQSHAoJdmlld1dpZHRoGAYgASgFUgl2aWV3V2lkdG'
    'gSHgoKdmlld0hlaWdodBgHIAEoBVIKdmlld0hlaWdodA==');

@$core.Deprecated('Use actionGraphConfigDescriptor instead')
const ActionGraphConfig$json = {
  '1': 'ActionGraphConfig',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 5, '10': 'type'},
    {'1': 'startTime', '3': 2, '4': 1, '5': 3, '10': 'startTime'},
    {
      '1': 'config',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.ActionGraphConfig.GraphConfig',
      '10': 'config'
    },
  ],
  '3': [ActionGraphConfig_GraphConfig$json],
};

@$core.Deprecated('Use actionGraphConfigDescriptor instead')
const ActionGraphConfig_GraphConfig$json = {
  '1': 'GraphConfig',
  '2': [
    {'1': 'width', '3': 1, '4': 1, '5': 2, '10': 'width'},
    {'1': 'color', '3': 2, '4': 1, '5': 5, '10': 'color'},
  ],
};

/// Descriptor for `ActionGraphConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List actionGraphConfigDescriptor = $convert.base64Decode(
    'ChFBY3Rpb25HcmFwaENvbmZpZxISCgR0eXBlGAEgASgFUgR0eXBlEhwKCXN0YXJ0VGltZRgCIA'
    'EoA1IJc3RhcnRUaW1lEjYKBmNvbmZpZxgEIAEoCzIeLkFjdGlvbkdyYXBoQ29uZmlnLkdyYXBo'
    'Q29uZmlnUgZjb25maWcaOQoLR3JhcGhDb25maWcSFAoFd2lkdGgYASABKAJSBXdpZHRoEhQKBW'
    'NvbG9yGAIgASgFUgVjb2xvcg==');

@$core.Deprecated('Use actionDrawConfigDescriptor instead')
const ActionDrawConfig$json = {
  '1': 'ActionDrawConfig',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 5, '10': 'type'},
    {'1': 'startTime', '3': 2, '4': 1, '5': 3, '10': 'startTime'},
    {'1': 'backgroundColor', '3': 3, '4': 1, '5': 5, '10': 'backgroundColor'},
    {
      '1': 'drawArea',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.DrawArea',
      '10': 'drawArea'
    },
  ],
};

/// Descriptor for `ActionDrawConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List actionDrawConfigDescriptor = $convert.base64Decode(
    'ChBBY3Rpb25EcmF3Q29uZmlnEhIKBHR5cGUYASABKAVSBHR5cGUSHAoJc3RhcnRUaW1lGAIgAS'
    'gDUglzdGFydFRpbWUSKAoPYmFja2dyb3VuZENvbG9yGAMgASgFUg9iYWNrZ3JvdW5kQ29sb3IS'
    'JQoIZHJhd0FyZWEYBCABKAsyCS5EcmF3QXJlYVIIZHJhd0FyZWE=');

@$core.Deprecated('Use drawAreaDescriptor instead')
const DrawArea$json = {
  '1': 'DrawArea',
  '2': [
    {
      '1': 'leftTopPoint',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.PointF',
      '10': 'leftTopPoint'
    },
    {
      '1': 'rightBottomPoint',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.PointF',
      '10': 'rightBottomPoint'
    },
    {'1': 'matrix', '3': 3, '4': 3, '5': 2, '10': 'matrix'},
  ],
};

/// Descriptor for `DrawArea`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List drawAreaDescriptor = $convert.base64Decode(
    'CghEcmF3QXJlYRIrCgxsZWZ0VG9wUG9pbnQYASABKAsyBy5Qb2ludEZSDGxlZnRUb3BQb2ludB'
    'IzChByaWdodEJvdHRvbVBvaW50GAIgASgLMgcuUG9pbnRGUhByaWdodEJvdHRvbVBvaW50EhYK'
    'Bm1hdHJpeBgDIAMoAlIGbWF0cml4');

@$core.Deprecated('Use actionModeConfigDescriptor instead')
const ActionModeConfig$json = {
  '1': 'ActionModeConfig',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 5, '10': 'type'},
    {'1': 'startTime', '3': 2, '4': 1, '5': 3, '10': 'startTime'},
    {
      '1': 'mode',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.ActionModeConfig.Mode',
      '10': 'mode'
    },
  ],
  '4': [ActionModeConfig_Mode$json],
};

@$core.Deprecated('Use actionModeConfigDescriptor instead')
const ActionModeConfig_Mode$json = {
  '1': 'Mode',
  '2': [
    {'1': 'ACTION_SELECT', '2': 0},
    {'1': 'ACTION_WRITING', '2': 1},
    {'1': 'ACTION_SHAPE_CIRCLE', '2': 2},
    {'1': 'ACTION_SHAPE_RECT', '2': 3},
    {'1': 'ACTION_ERASER_VIEW', '2': 5},
    {'1': 'ACTION_ERASER_WRITING', '2': 6},
    {'1': 'ACTION_DELETE', '2': 7},
    {'1': 'ACTION_WRITING_MOVE', '2': 8},
    {'1': 'ACTION_WRITING_MOVE_VERTICAL', '2': 9},
  ],
};

/// Descriptor for `ActionModeConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List actionModeConfigDescriptor = $convert.base64Decode(
    'ChBBY3Rpb25Nb2RlQ29uZmlnEhIKBHR5cGUYASABKAVSBHR5cGUSHAoJc3RhcnRUaW1lGAIgAS'
    'gDUglzdGFydFRpbWUSKgoEbW9kZRgEIAEoDjIWLkFjdGlvbk1vZGVDb25maWcuTW9kZVIEbW9k'
    'ZSLeAQoETW9kZRIRCg1BQ1RJT05fU0VMRUNUEAASEgoOQUNUSU9OX1dSSVRJTkcQARIXChNBQ1'
    'RJT05fU0hBUEVfQ0lSQ0xFEAISFQoRQUNUSU9OX1NIQVBFX1JFQ1QQAxIWChJBQ1RJT05fRVJB'
    'U0VSX1ZJRVcQBRIZChVBQ1RJT05fRVJBU0VSX1dSSVRJTkcQBhIRCg1BQ1RJT05fREVMRVRFEA'
    'cSFwoTQUNUSU9OX1dSSVRJTkdfTU9WRRAIEiAKHEFDVElPTl9XUklUSU5HX01PVkVfVkVSVElD'
    'QUwQCQ==');

@$core.Deprecated('Use actionFitterConfigDescriptor instead')
const ActionFitterConfig$json = {
  '1': 'ActionFitterConfig',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 5, '10': 'type'},
    {'1': 'startTime', '3': 2, '4': 1, '5': 3, '10': 'startTime'},
    {'1': 'scale', '3': 3, '4': 1, '5': 2, '10': 'scale'},
    {'1': 'centerX', '3': 4, '4': 1, '5': 5, '10': 'centerX'},
    {'1': 'centerY', '3': 5, '4': 1, '5': 5, '10': 'centerY'},
    {'1': 'px', '3': 6, '4': 1, '5': 5, '10': 'px'},
    {'1': 'py', '3': 7, '4': 1, '5': 5, '10': 'py'},
  ],
};

/// Descriptor for `ActionFitterConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List actionFitterConfigDescriptor = $convert.base64Decode(
    'ChJBY3Rpb25GaXR0ZXJDb25maWcSEgoEdHlwZRgBIAEoBVIEdHlwZRIcCglzdGFydFRpbWUYAi'
    'ABKANSCXN0YXJ0VGltZRIUCgVzY2FsZRgDIAEoAlIFc2NhbGUSGAoHY2VudGVyWBgEIAEoBVIH'
    'Y2VudGVyWBIYCgdjZW50ZXJZGAUgASgFUgdjZW50ZXJZEg4KAnB4GAYgASgFUgJweBIOCgJweR'
    'gHIAEoBVICcHk=');

@$core.Deprecated('Use actionClearBoardDescriptor instead')
const ActionClearBoard$json = {
  '1': 'ActionClearBoard',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 5, '10': 'type'},
    {'1': 'startTime', '3': 2, '4': 1, '5': 3, '10': 'startTime'},
  ],
};

/// Descriptor for `ActionClearBoard`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List actionClearBoardDescriptor = $convert.base64Decode(
    'ChBBY3Rpb25DbGVhckJvYXJkEhIKBHR5cGUYASABKAVSBHR5cGUSHAoJc3RhcnRUaW1lGAIgAS'
    'gDUglzdGFydFRpbWU=');

@$core.Deprecated('Use actionPrevActionDescriptor instead')
const ActionPrevAction$json = {
  '1': 'ActionPrevAction',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 5, '10': 'type'},
    {'1': 'startTime', '3': 2, '4': 1, '5': 3, '10': 'startTime'},
  ],
};

/// Descriptor for `ActionPrevAction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List actionPrevActionDescriptor = $convert.base64Decode(
    'ChBBY3Rpb25QcmV2QWN0aW9uEhIKBHR5cGUYASABKAVSBHR5cGUSHAoJc3RhcnRUaW1lGAIgAS'
    'gDUglzdGFydFRpbWU=');

@$core.Deprecated('Use actionNextActionDescriptor instead')
const ActionNextAction$json = {
  '1': 'ActionNextAction',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 5, '10': 'type'},
    {'1': 'startTime', '3': 2, '4': 1, '5': 3, '10': 'startTime'},
  ],
};

/// Descriptor for `ActionNextAction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List actionNextActionDescriptor = $convert.base64Decode(
    'ChBBY3Rpb25OZXh0QWN0aW9uEhIKBHR5cGUYASABKAVSBHR5cGUSHAoJc3RhcnRUaW1lGAIgAS'
    'gDUglzdGFydFRpbWU=');

@$core.Deprecated('Use actionZoomDescriptor instead')
const ActionZoom$json = {
  '1': 'ActionZoom',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 5, '10': 'type'},
    {'1': 'startTime', '3': 2, '4': 1, '5': 3, '10': 'startTime'},
    {'1': 'scaleX', '3': 3, '4': 1, '5': 2, '10': 'scaleX'},
    {'1': 'scaleY', '3': 4, '4': 1, '5': 2, '10': 'scaleY'},
    {'1': 'centerX', '3': 5, '4': 1, '5': 2, '10': 'centerX'},
    {'1': 'centerY', '3': 6, '4': 1, '5': 2, '10': 'centerY'},
    {'1': 'keep', '3': 7, '4': 1, '5': 8, '10': 'keep'},
  ],
};

/// Descriptor for `ActionZoom`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List actionZoomDescriptor = $convert.base64Decode(
    'CgpBY3Rpb25ab29tEhIKBHR5cGUYASABKAVSBHR5cGUSHAoJc3RhcnRUaW1lGAIgASgDUglzdG'
    'FydFRpbWUSFgoGc2NhbGVYGAMgASgCUgZzY2FsZVgSFgoGc2NhbGVZGAQgASgCUgZzY2FsZVkS'
    'GAoHY2VudGVyWBgFIAEoAlIHY2VudGVyWBIYCgdjZW50ZXJZGAYgASgCUgdjZW50ZXJZEhIKBG'
    'tlZXAYByABKAhSBGtlZXA=');

@$core.Deprecated('Use actionTranslationDescriptor instead')
const ActionTranslation$json = {
  '1': 'ActionTranslation',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 5, '10': 'type'},
    {'1': 'startTime', '3': 2, '4': 1, '5': 3, '10': 'startTime'},
    {
      '1': 'transX',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.FloatValue',
      '10': 'transX'
    },
    {
      '1': 'transY',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.FloatValue',
      '10': 'transY'
    },
    {'1': 'keep', '3': 5, '4': 1, '5': 8, '10': 'keep'},
  ],
};

/// Descriptor for `ActionTranslation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List actionTranslationDescriptor = $convert.base64Decode(
    'ChFBY3Rpb25UcmFuc2xhdGlvbhISCgR0eXBlGAEgASgFUgR0eXBlEhwKCXN0YXJ0VGltZRgCIA'
    'EoA1IJc3RhcnRUaW1lEjMKBnRyYW5zWBgDIAEoCzIbLmdvb2dsZS5wcm90b2J1Zi5GbG9hdFZh'
    'bHVlUgZ0cmFuc1gSMwoGdHJhbnNZGAQgASgLMhsuZ29vZ2xlLnByb3RvYnVmLkZsb2F0VmFsdW'
    'VSBnRyYW5zWRISCgRrZWVwGAUgASgIUgRrZWVw');

@$core.Deprecated('Use actionResetMatrixDescriptor instead')
const ActionResetMatrix$json = {
  '1': 'ActionResetMatrix',
  '2': [
    {'1': 'startTime', '3': 1, '4': 1, '5': 3, '10': 'startTime'},
  ],
};

/// Descriptor for `ActionResetMatrix`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List actionResetMatrixDescriptor = $convert.base64Decode(
    'ChFBY3Rpb25SZXNldE1hdHJpeBIcCglzdGFydFRpbWUYASABKANSCXN0YXJ0VGltZQ==');

@$core.Deprecated('Use audioStartActionDescriptor instead')
const AudioStartAction$json = {
  '1': 'AudioStartAction',
  '2': [
    {'1': 'startTime', '3': 1, '4': 1, '5': 3, '10': 'startTime'},
    {'1': 'fileName', '3': 2, '4': 1, '5': 9, '10': 'fileName'},
  ],
};

/// Descriptor for `AudioStartAction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List audioStartActionDescriptor = $convert.base64Decode(
    'ChBBdWRpb1N0YXJ0QWN0aW9uEhwKCXN0YXJ0VGltZRgBIAEoA1IJc3RhcnRUaW1lEhoKCGZpbG'
    'VOYW1lGAIgASgJUghmaWxlTmFtZQ==');

@$core.Deprecated('Use audioStopActionDescriptor instead')
const AudioStopAction$json = {
  '1': 'AudioStopAction',
  '2': [
    {'1': 'startTime', '3': 1, '4': 1, '5': 3, '10': 'startTime'},
    {'1': 'fileName', '3': 2, '4': 1, '5': 9, '10': 'fileName'},
  ],
};

/// Descriptor for `AudioStopAction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List audioStopActionDescriptor = $convert.base64Decode(
    'Cg9BdWRpb1N0b3BBY3Rpb24SHAoJc3RhcnRUaW1lGAEgASgDUglzdGFydFRpbWUSGgoIZmlsZU'
    '5hbWUYAiABKAlSCGZpbGVOYW1l');

@$core.Deprecated('Use graphResetDataDescriptor instead')
const GraphResetData$json = {
  '1': 'GraphResetData',
  '2': [
    {'1': 'factoryGraphName', '3': 1, '4': 1, '5': 9, '10': 'factoryGraphName'},
    {
      '1': 'factoryActionGraphName',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'factoryActionGraphName'
    },
    {
      '1': 'action',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.GraphResetData.ActionFactory',
      '10': 'action'
    },
    {
      '1': 'graphConfig',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.ActionGraphConfig.GraphConfig',
      '10': 'graphConfig'
    },
    {
      '1': 'modeConfig',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.ActionModeConfig.Mode',
      '10': 'modeConfig'
    },
    {'1': 'backgroundColor', '3': 8, '4': 1, '5': 5, '10': 'backgroundColor'},
    {
      '1': 'drawArea',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.DrawArea',
      '10': 'drawArea'
    },
  ],
  '3': [GraphResetData_ActionFactory$json],
};

@$core.Deprecated('Use graphResetDataDescriptor instead')
const GraphResetData_ActionFactory$json = {
  '1': 'ActionFactory',
  '2': [
    {
      '1': 'baseAction',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.ActionModeConfig.Mode',
      '10': 'baseAction'
    },
    {'1': 'factoryGraphName', '3': 2, '4': 1, '5': 9, '10': 'factoryGraphName'},
    {
      '1': 'factoryActionGraphName',
      '3': 3,
      '4': 1,
      '5': 9,
      '10': 'factoryActionGraphName'
    },
  ],
};

/// Descriptor for `GraphResetData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List graphResetDataDescriptor = $convert.base64Decode(
    'Cg5HcmFwaFJlc2V0RGF0YRIqChBmYWN0b3J5R3JhcGhOYW1lGAEgASgJUhBmYWN0b3J5R3JhcG'
    'hOYW1lEjYKFmZhY3RvcnlBY3Rpb25HcmFwaE5hbWUYAiABKAlSFmZhY3RvcnlBY3Rpb25HcmFw'
    'aE5hbWUSNQoGYWN0aW9uGAUgASgLMh0uR3JhcGhSZXNldERhdGEuQWN0aW9uRmFjdG9yeVIGYW'
    'N0aW9uEkAKC2dyYXBoQ29uZmlnGAYgASgLMh4uQWN0aW9uR3JhcGhDb25maWcuR3JhcGhDb25m'
    'aWdSC2dyYXBoQ29uZmlnEjYKCm1vZGVDb25maWcYByABKA4yFi5BY3Rpb25Nb2RlQ29uZmlnLk'
    '1vZGVSCm1vZGVDb25maWcSKAoPYmFja2dyb3VuZENvbG9yGAggASgFUg9iYWNrZ3JvdW5kQ29s'
    'b3ISJQoIZHJhd0FyZWEYCSABKAsyCS5EcmF3QXJlYVIIZHJhd0FyZWEaqwEKDUFjdGlvbkZhY3'
    'RvcnkSNgoKYmFzZUFjdGlvbhgBIAEoDjIWLkFjdGlvbk1vZGVDb25maWcuTW9kZVIKYmFzZUFj'
    'dGlvbhIqChBmYWN0b3J5R3JhcGhOYW1lGAIgASgJUhBmYWN0b3J5R3JhcGhOYW1lEjYKFmZhY3'
    'RvcnlBY3Rpb25HcmFwaE5hbWUYAyABKAlSFmZhY3RvcnlBY3Rpb25HcmFwaE5hbWU=');
