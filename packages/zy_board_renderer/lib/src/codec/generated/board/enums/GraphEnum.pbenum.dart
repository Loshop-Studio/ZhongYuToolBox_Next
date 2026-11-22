// This is a generated file - do not edit.
//
// Generated from enums/GraphEnum.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class GraphEnum extends $pb.ProtobufEnum {
  static const GraphEnum BOUNDED_CONTAINER_GRAPH =
      GraphEnum._(0, _omitEnumNames ? '' : 'BOUNDED_CONTAINER_GRAPH');
  static const GraphEnum GROUP_GRAPH =
      GraphEnum._(1, _omitEnumNames ? '' : 'GROUP_GRAPH');
  static const GraphEnum IMAGE_GRAPH =
      GraphEnum._(2, _omitEnumNames ? '' : 'IMAGE_GRAPH');
  static const GraphEnum STROKE_GRAPH =
      GraphEnum._(3, _omitEnumNames ? '' : 'STROKE_GRAPH');
  static const GraphEnum BEELINE_STROKE_GRAPH =
      GraphEnum._(4, _omitEnumNames ? '' : 'BEELINE_STROKE_GRAPH');
  static const GraphEnum TEXT_GRAPH =
      GraphEnum._(5, _omitEnumNames ? '' : 'TEXT_GRAPH');
  static const GraphEnum GEOMETRY_GRAPH =
      GraphEnum._(6, _omitEnumNames ? '' : 'GEOMETRY_GRAPH');

  static const $core.List<GraphEnum> values = <GraphEnum>[
    BOUNDED_CONTAINER_GRAPH,
    GROUP_GRAPH,
    IMAGE_GRAPH,
    STROKE_GRAPH,
    BEELINE_STROKE_GRAPH,
    TEXT_GRAPH,
    GEOMETRY_GRAPH,
  ];

  static final $core.List<GraphEnum?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static GraphEnum? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const GraphEnum._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
