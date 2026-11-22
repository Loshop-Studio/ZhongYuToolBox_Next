// This is a generated file - do not edit.
//
// Generated from SketchGraphSnapshot.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class GraphType extends $pb.ProtobufEnum {
  static const GraphType UNBOUNDED_CONTAINER_GRAPH =
      GraphType._(0, _omitEnumNames ? '' : 'UNBOUNDED_CONTAINER_GRAPH');
  static const GraphType BOUNDED_CONTAINER_GRAPH =
      GraphType._(1, _omitEnumNames ? '' : 'BOUNDED_CONTAINER_GRAPH');
  static const GraphType IMAGE_GRAPH =
      GraphType._(2, _omitEnumNames ? '' : 'IMAGE_GRAPH');
  static const GraphType WEB_VIEW_GRAPH =
      GraphType._(3, _omitEnumNames ? '' : 'WEB_VIEW_GRAPH');
  static const GraphType WRITING_GROUP_GRAPH =
      GraphType._(4, _omitEnumNames ? '' : 'WRITING_GROUP_GRAPH');
  static const GraphType STROKE_GRAPH =
      GraphType._(5, _omitEnumNames ? '' : 'STROKE_GRAPH');
  static const GraphType SHAPE_GRAPH =
      GraphType._(6, _omitEnumNames ? '' : 'SHAPE_GRAPH');

  static const $core.List<GraphType> values = <GraphType>[
    UNBOUNDED_CONTAINER_GRAPH,
    BOUNDED_CONTAINER_GRAPH,
    IMAGE_GRAPH,
    WEB_VIEW_GRAPH,
    WRITING_GROUP_GRAPH,
    STROKE_GRAPH,
    SHAPE_GRAPH,
  ];

  static final $core.List<GraphType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static GraphType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const GraphType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
