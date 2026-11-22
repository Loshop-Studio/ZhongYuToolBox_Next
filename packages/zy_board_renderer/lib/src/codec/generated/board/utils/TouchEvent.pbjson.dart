// This is a generated file - do not edit.
//
// Generated from utils/TouchEvent.proto.

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

@$core.Deprecated('Use touchEventDescriptor instead')
const TouchEvent$json = {
  '1': 'TouchEvent',
  '2': [
    {'1': 'eventTime', '3': 1, '4': 1, '5': 3, '10': 'eventTime'},
    {'1': 'action', '3': 2, '4': 1, '5': 5, '10': 'action'},
    {'1': 'x', '3': 3, '4': 1, '5': 2, '10': 'x'},
    {'1': 'y', '3': 4, '4': 1, '5': 2, '10': 'y'},
    {'1': 'pointerCount', '3': 5, '4': 1, '5': 5, '10': 'pointerCount'},
    {
      '1': 'pointerProperties',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.TouchEvent.PointerProperties',
      '10': 'pointerProperties'
    },
    {
      '1': 'pointerCoords',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.TouchEvent.PointerCoords',
      '10': 'pointerCoords'
    },
  ],
  '3': [TouchEvent_PointerProperties$json, TouchEvent_PointerCoords$json],
};

@$core.Deprecated('Use touchEventDescriptor instead')
const TouchEvent_PointerProperties$json = {
  '1': 'PointerProperties',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'toolType', '3': 2, '4': 1, '5': 5, '10': 'toolType'},
  ],
};

@$core.Deprecated('Use touchEventDescriptor instead')
const TouchEvent_PointerCoords$json = {
  '1': 'PointerCoords',
  '2': [
    {'1': 'x', '3': 1, '4': 1, '5': 2, '10': 'x'},
    {'1': 'y', '3': 2, '4': 1, '5': 2, '10': 'y'},
  ],
};

/// Descriptor for `TouchEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List touchEventDescriptor = $convert.base64Decode(
    'CgpUb3VjaEV2ZW50EhwKCWV2ZW50VGltZRgBIAEoA1IJZXZlbnRUaW1lEhYKBmFjdGlvbhgCIA'
    'EoBVIGYWN0aW9uEgwKAXgYAyABKAJSAXgSDAoBeRgEIAEoAlIBeRIiCgxwb2ludGVyQ291bnQY'
    'BSABKAVSDHBvaW50ZXJDb3VudBJLChFwb2ludGVyUHJvcGVydGllcxgGIAMoCzIdLlRvdWNoRX'
    'ZlbnQuUG9pbnRlclByb3BlcnRpZXNSEXBvaW50ZXJQcm9wZXJ0aWVzEj8KDXBvaW50ZXJDb29y'
    'ZHMYByADKAsyGS5Ub3VjaEV2ZW50LlBvaW50ZXJDb29yZHNSDXBvaW50ZXJDb29yZHMaPwoRUG'
    '9pbnRlclByb3BlcnRpZXMSDgoCaWQYASABKAVSAmlkEhoKCHRvb2xUeXBlGAIgASgFUgh0b29s'
    'VHlwZRorCg1Qb2ludGVyQ29vcmRzEgwKAXgYASABKAJSAXgSDAoBeRgCIAEoAlIBeQ==');
