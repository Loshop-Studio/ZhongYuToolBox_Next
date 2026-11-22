// This is a generated file - do not edit.
//
// Generated from RouterRecord.proto.

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

@$core.Deprecated('Use routerRecordDescriptor instead')
const RouterRecord$json = {
  '1': 'RouterRecord',
  '2': [
    {
      '1': 'commandRecord',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.RouterRecord.SourceCommandRecord',
      '10': 'commandRecord'
    },
    {
      '1': 'audioRecord',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.RouterRecord.SourceCommandRecord',
      '10': 'audioRecord'
    },
    {
      '1': 'touchSourceRecord',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.RouterRecord.SourceCommandRecord',
      '10': 'touchSourceRecord'
    },
    {
      '1': 'matrixSourceRecord',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.RouterRecord.SourceCommandRecord',
      '10': 'matrixSourceRecord'
    },
    {
      '1': 'fileSourceRecord',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.RouterRecord.SourceCommandRecord',
      '10': 'fileSourceRecord'
    },
    {
      '1': 'textSourceRecord',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.RouterRecord.SourceCommandRecord',
      '10': 'textSourceRecord'
    },
    {
      '1': 'geometrySourceRecord',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.RouterRecord.SourceCommandRecord',
      '10': 'geometrySourceRecord'
    },
  ],
  '3': [RouterRecord_SourceCommandRecord$json],
};

@$core.Deprecated('Use routerRecordDescriptor instead')
const RouterRecord_SourceCommandRecord$json = {
  '1': 'SourceCommandRecord',
  '2': [
    {'1': 'fileName', '3': 1, '4': 1, '5': 9, '10': 'fileName'},
    {'1': 'validate', '3': 2, '4': 1, '5': 9, '10': 'validate'},
  ],
};

/// Descriptor for `RouterRecord`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List routerRecordDescriptor = $convert.base64Decode(
    'CgxSb3V0ZXJSZWNvcmQSRwoNY29tbWFuZFJlY29yZBgBIAMoCzIhLlJvdXRlclJlY29yZC5Tb3'
    'VyY2VDb21tYW5kUmVjb3JkUg1jb21tYW5kUmVjb3JkEkMKC2F1ZGlvUmVjb3JkGAIgAygLMiEu'
    'Um91dGVyUmVjb3JkLlNvdXJjZUNvbW1hbmRSZWNvcmRSC2F1ZGlvUmVjb3JkEk8KEXRvdWNoU2'
    '91cmNlUmVjb3JkGAMgAygLMiEuUm91dGVyUmVjb3JkLlNvdXJjZUNvbW1hbmRSZWNvcmRSEXRv'
    'dWNoU291cmNlUmVjb3JkElEKEm1hdHJpeFNvdXJjZVJlY29yZBgEIAMoCzIhLlJvdXRlclJlY2'
    '9yZC5Tb3VyY2VDb21tYW5kUmVjb3JkUhJtYXRyaXhTb3VyY2VSZWNvcmQSTQoQZmlsZVNvdXJj'
    'ZVJlY29yZBgFIAMoCzIhLlJvdXRlclJlY29yZC5Tb3VyY2VDb21tYW5kUmVjb3JkUhBmaWxlU2'
    '91cmNlUmVjb3JkEk0KEHRleHRTb3VyY2VSZWNvcmQYBiADKAsyIS5Sb3V0ZXJSZWNvcmQuU291'
    'cmNlQ29tbWFuZFJlY29yZFIQdGV4dFNvdXJjZVJlY29yZBJVChRnZW9tZXRyeVNvdXJjZVJlY2'
    '9yZBgHIAMoCzIhLlJvdXRlclJlY29yZC5Tb3VyY2VDb21tYW5kUmVjb3JkUhRnZW9tZXRyeVNv'
    'dXJjZVJlY29yZBpNChNTb3VyY2VDb21tYW5kUmVjb3JkEhoKCGZpbGVOYW1lGAEgASgJUghmaW'
    'xlTmFtZRIaCgh2YWxpZGF0ZRgCIAEoCVIIdmFsaWRhdGU=');
