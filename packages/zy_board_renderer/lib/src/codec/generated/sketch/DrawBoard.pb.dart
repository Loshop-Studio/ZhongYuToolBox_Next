// This is a generated file - do not edit.
//
// Generated from DrawBoard.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/any.pb.dart' as $0;
import 'package:protobuf/well_known_types/google/protobuf/wrappers.pb.dart'
    as $2;

import 'DrawBoard.pbenum.dart';
import 'SketchGraphSnapshot.pb.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'DrawBoard.pbenum.dart';

/// 画板
class DrawBoard extends $pb.GeneratedMessage {
  factory DrawBoard({
    BoardHead? boardHead,
    BoardBody? boardBody,
  }) {
    final result = DrawBoard._();
    if (boardHead != null) result.boardHead = boardHead;
    if (boardBody != null) result.boardBody = boardBody;
    return result;
  }

  DrawBoard._();

  factory DrawBoard.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DrawBoard()..mergeFromBuffer(data, registry);
  factory DrawBoard.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DrawBoard()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DrawBoard',
      createEmptyInstance: DrawBoard.$_createMessage)
    ..aOM<BoardHead>(1, _omitFieldNames ? '' : 'boardHead',
        protoName: 'boardHead', subBuilder: BoardHead.$_createMessage)
    ..aOM<BoardBody>(2, _omitFieldNames ? '' : 'boardBody',
        protoName: 'boardBody', subBuilder: BoardBody.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DrawBoard clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DrawBoard copyWith(void Function(DrawBoard) updates) =>
      super.copyWith((message) => updates(message as DrawBoard)) as DrawBoard;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DrawBoard() / DrawBoard.new instead')
  static DrawBoard create() => DrawBoard._();
  static $pb.GeneratedMessage $_createMessage() => DrawBoard._();
  @$core.override
  DrawBoard createEmptyInstance() => DrawBoard._();
  @$core.pragma('dart2js:noInline')
  static DrawBoard getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DrawBoard>(DrawBoard.$_createMessage);
  static DrawBoard? _defaultInstance;

  @$pb.TagNumber(1)
  BoardHead get boardHead => $_getN(0);
  @$pb.TagNumber(1)
  set boardHead(BoardHead value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBoardHead() => $_has(0);
  @$pb.TagNumber(1)
  void clearBoardHead() => $_clearField(1);
  @$pb.TagNumber(1)
  BoardHead ensureBoardHead() => $_ensure(0);

  @$pb.TagNumber(2)
  BoardBody get boardBody => $_getN(1);
  @$pb.TagNumber(2)
  set boardBody(BoardBody value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasBoardBody() => $_has(1);
  @$pb.TagNumber(2)
  void clearBoardBody() => $_clearField(2);
  @$pb.TagNumber(2)
  BoardBody ensureBoardBody() => $_ensure(1);
}

/// 画板V1
class DrawBoardV1 extends $pb.GeneratedMessage {
  factory DrawBoardV1({
    BoardHead? boardHead,
    BoardBodyV1? boardBodyV1,
  }) {
    final result = DrawBoardV1._();
    if (boardHead != null) result.boardHead = boardHead;
    if (boardBodyV1 != null) result.boardBodyV1 = boardBodyV1;
    return result;
  }

  DrawBoardV1._();

  factory DrawBoardV1.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DrawBoardV1()..mergeFromBuffer(data, registry);
  factory DrawBoardV1.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DrawBoardV1()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DrawBoardV1',
      createEmptyInstance: DrawBoardV1.$_createMessage)
    ..aOM<BoardHead>(1, _omitFieldNames ? '' : 'boardHead',
        protoName: 'boardHead', subBuilder: BoardHead.$_createMessage)
    ..aOM<BoardBodyV1>(2, _omitFieldNames ? '' : 'boardBodyV1',
        protoName: 'boardBodyV1', subBuilder: BoardBodyV1.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DrawBoardV1 clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DrawBoardV1 copyWith(void Function(DrawBoardV1) updates) =>
      super.copyWith((message) => updates(message as DrawBoardV1))
          as DrawBoardV1;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DrawBoardV1() / DrawBoardV1.new instead')
  static DrawBoardV1 create() => DrawBoardV1._();
  static $pb.GeneratedMessage $_createMessage() => DrawBoardV1._();
  @$core.override
  DrawBoardV1 createEmptyInstance() => DrawBoardV1._();
  @$core.pragma('dart2js:noInline')
  static DrawBoardV1 getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DrawBoardV1>(
          DrawBoardV1.$_createMessage);
  static DrawBoardV1? _defaultInstance;

  @$pb.TagNumber(1)
  BoardHead get boardHead => $_getN(0);
  @$pb.TagNumber(1)
  set boardHead(BoardHead value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBoardHead() => $_has(0);
  @$pb.TagNumber(1)
  void clearBoardHead() => $_clearField(1);
  @$pb.TagNumber(1)
  BoardHead ensureBoardHead() => $_ensure(0);

  @$pb.TagNumber(2)
  BoardBodyV1 get boardBodyV1 => $_getN(1);
  @$pb.TagNumber(2)
  set boardBodyV1(BoardBodyV1 value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasBoardBodyV1() => $_has(1);
  @$pb.TagNumber(2)
  void clearBoardBodyV1() => $_clearField(2);
  @$pb.TagNumber(2)
  BoardBodyV1 ensureBoardBodyV1() => $_ensure(1);
}

/// 头部信息 记录裁剪的时间
class BoardHead extends $pb.GeneratedMessage {
  factory BoardHead({
    $core.int? version,
    $core.int? width,
    $core.int? height,
    $fixnum.Int64? createDate,
    $fixnum.Int64? updateDate,
    $core.String? author,
    $core.int? type,
  }) {
    final result = BoardHead._();
    if (version != null) result.version = version;
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    if (createDate != null) result.createDate = createDate;
    if (updateDate != null) result.updateDate = updateDate;
    if (author != null) result.author = author;
    if (type != null) result.type = type;
    return result;
  }

  BoardHead._();

  factory BoardHead.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardHead()..mergeFromBuffer(data, registry);
  factory BoardHead.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardHead()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BoardHead',
      createEmptyInstance: BoardHead.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'version')
    ..aI(3, _omitFieldNames ? '' : 'width')
    ..aI(4, _omitFieldNames ? '' : 'height')
    ..aInt64(5, _omitFieldNames ? '' : 'createDate', protoName: 'createDate')
    ..aInt64(6, _omitFieldNames ? '' : 'updateDate', protoName: 'updateDate')
    ..aOS(7, _omitFieldNames ? '' : 'author')
    ..aI(8, _omitFieldNames ? '' : 'type')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardHead clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardHead copyWith(void Function(BoardHead) updates) =>
      super.copyWith((message) => updates(message as BoardHead)) as BoardHead;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BoardHead() / BoardHead.new instead')
  static BoardHead create() => BoardHead._();
  static $pb.GeneratedMessage $_createMessage() => BoardHead._();
  @$core.override
  BoardHead createEmptyInstance() => BoardHead._();
  @$core.pragma('dart2js:noInline')
  static BoardHead getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BoardHead>(BoardHead.$_createMessage);
  static BoardHead? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get version => $_getIZ(0);
  @$pb.TagNumber(1)
  set version($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => $_clearField(1);

  @$pb.TagNumber(3)
  $core.int get width => $_getIZ(1);
  @$pb.TagNumber(3)
  set width($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(3)
  $core.bool hasWidth() => $_has(1);
  @$pb.TagNumber(3)
  void clearWidth() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get height => $_getIZ(2);
  @$pb.TagNumber(4)
  set height($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(4)
  $core.bool hasHeight() => $_has(2);
  @$pb.TagNumber(4)
  void clearHeight() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get createDate => $_getI64(3);
  @$pb.TagNumber(5)
  set createDate($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(5)
  $core.bool hasCreateDate() => $_has(3);
  @$pb.TagNumber(5)
  void clearCreateDate() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get updateDate => $_getI64(4);
  @$pb.TagNumber(6)
  set updateDate($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(6)
  $core.bool hasUpdateDate() => $_has(4);
  @$pb.TagNumber(6)
  void clearUpdateDate() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get author => $_getSZ(5);
  @$pb.TagNumber(7)
  set author($core.String value) => $_setString(5, value);
  @$pb.TagNumber(7)
  $core.bool hasAuthor() => $_has(5);
  @$pb.TagNumber(7)
  void clearAuthor() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get type => $_getIZ(6);
  @$pb.TagNumber(8)
  set type($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(8)
  $core.bool hasType() => $_has(6);
  @$pb.TagNumber(8)
  void clearType() => $_clearField(8);
}

/// 画板的具体数据
class BoardBody extends $pb.GeneratedMessage {
  factory BoardBody({
    $core.Iterable<ActionContent>? actionContent,
  }) {
    final result = BoardBody._();
    if (actionContent != null) result.actionContent.addAll(actionContent);
    return result;
  }

  BoardBody._();

  factory BoardBody.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardBody()..mergeFromBuffer(data, registry);
  factory BoardBody.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardBody()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BoardBody',
      createEmptyInstance: BoardBody.$_createMessage)
    ..pPM<ActionContent>(1, _omitFieldNames ? '' : 'ActionContent',
        protoName: 'ActionContent', subBuilder: ActionContent.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardBody clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardBody copyWith(void Function(BoardBody) updates) =>
      super.copyWith((message) => updates(message as BoardBody)) as BoardBody;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BoardBody() / BoardBody.new instead')
  static BoardBody create() => BoardBody._();
  static $pb.GeneratedMessage $_createMessage() => BoardBody._();
  @$core.override
  BoardBody createEmptyInstance() => BoardBody._();
  @$core.pragma('dart2js:noInline')
  static BoardBody getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BoardBody>(BoardBody.$_createMessage);
  static BoardBody? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ActionContent> get actionContent => $_getList(0);
}

/// 画板的具体数据
class BoardBodyV1 extends $pb.GeneratedMessage {
  factory BoardBodyV1({
    $core.Iterable<$0.Any>? actionContent,
  }) {
    final result = BoardBodyV1._();
    if (actionContent != null) result.actionContent.addAll(actionContent);
    return result;
  }

  BoardBodyV1._();

  factory BoardBodyV1.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardBodyV1()..mergeFromBuffer(data, registry);
  factory BoardBodyV1.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BoardBodyV1()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BoardBodyV1',
      createEmptyInstance: BoardBodyV1.$_createMessage)
    ..pPM<$0.Any>(1, _omitFieldNames ? '' : 'ActionContent',
        protoName: 'ActionContent', subBuilder: $0.Any.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardBodyV1 clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoardBodyV1 copyWith(void Function(BoardBodyV1) updates) =>
      super.copyWith((message) => updates(message as BoardBodyV1))
          as BoardBodyV1;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BoardBodyV1() / BoardBodyV1.new instead')
  static BoardBodyV1 create() => BoardBodyV1._();
  static $pb.GeneratedMessage $_createMessage() => BoardBodyV1._();
  @$core.override
  BoardBodyV1 createEmptyInstance() => BoardBodyV1._();
  @$core.pragma('dart2js:noInline')
  static BoardBodyV1 getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BoardBodyV1>(
          BoardBodyV1.$_createMessage);
  static BoardBodyV1? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$0.Any> get actionContent => $_getList(0);
}

class ActionContent extends $pb.GeneratedMessage {
  factory ActionContent({
    ActionEnum? type,
    $0.Any? action,
    $1.GraphData? graphSnapshot,
    GraphResetData? resetData,
  }) {
    final result = ActionContent._();
    if (type != null) result.type = type;
    if (action != null) result.action = action;
    if (graphSnapshot != null) result.graphSnapshot = graphSnapshot;
    if (resetData != null) result.resetData = resetData;
    return result;
  }

  ActionContent._();

  factory ActionContent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionContent()..mergeFromBuffer(data, registry);
  factory ActionContent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionContent()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActionContent',
      createEmptyInstance: ActionContent.$_createMessage)
    ..aE<ActionEnum>(1, _omitFieldNames ? '' : 'type',
        enumValues: ActionEnum.values)
    ..aOM<$0.Any>(2, _omitFieldNames ? '' : 'action',
        subBuilder: $0.Any.$_createMessage)
    ..aOM<$1.GraphData>(3, _omitFieldNames ? '' : 'graphSnapshot',
        protoName: 'graphSnapshot', subBuilder: $1.GraphData.$_createMessage)
    ..aOM<GraphResetData>(5, _omitFieldNames ? '' : 'resetData',
        protoName: 'resetData', subBuilder: GraphResetData.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionContent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionContent copyWith(void Function(ActionContent) updates) =>
      super.copyWith((message) => updates(message as ActionContent))
          as ActionContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ActionContent() / ActionContent.new instead')
  static ActionContent create() => ActionContent._();
  static $pb.GeneratedMessage $_createMessage() => ActionContent._();
  @$core.override
  ActionContent createEmptyInstance() => ActionContent._();
  @$core.pragma('dart2js:noInline')
  static ActionContent getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ActionContent>(
          ActionContent.$_createMessage);
  static ActionContent? _defaultInstance;

  @$pb.TagNumber(1)
  ActionEnum get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(ActionEnum value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Any get action => $_getN(1);
  @$pb.TagNumber(2)
  set action($0.Any value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAction() => $_has(1);
  @$pb.TagNumber(2)
  void clearAction() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Any ensureAction() => $_ensure(1);

  @$pb.TagNumber(3)
  $1.GraphData get graphSnapshot => $_getN(2);
  @$pb.TagNumber(3)
  set graphSnapshot($1.GraphData value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasGraphSnapshot() => $_has(2);
  @$pb.TagNumber(3)
  void clearGraphSnapshot() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.GraphData ensureGraphSnapshot() => $_ensure(2);

  @$pb.TagNumber(5)
  GraphResetData get resetData => $_getN(3);
  @$pb.TagNumber(5)
  set resetData(GraphResetData value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasResetData() => $_has(3);
  @$pb.TagNumber(5)
  void clearResetData() => $_clearField(5);
  @$pb.TagNumber(5)
  GraphResetData ensureResetData() => $_ensure(3);
}

class ActionTouchEvent_TouchEvent_PointerProperties
    extends $pb.GeneratedMessage {
  factory ActionTouchEvent_TouchEvent_PointerProperties({
    $core.int? id,
    $core.int? toolType,
  }) {
    final result = ActionTouchEvent_TouchEvent_PointerProperties._();
    if (id != null) result.id = id;
    if (toolType != null) result.toolType = toolType;
    return result;
  }

  ActionTouchEvent_TouchEvent_PointerProperties._();

  factory ActionTouchEvent_TouchEvent_PointerProperties.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionTouchEvent_TouchEvent_PointerProperties()
        ..mergeFromBuffer(data, registry);
  factory ActionTouchEvent_TouchEvent_PointerProperties.fromJson(
          $core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionTouchEvent_TouchEvent_PointerProperties()
        ..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActionTouchEvent.TouchEvent.PointerProperties',
      createEmptyInstance:
          ActionTouchEvent_TouchEvent_PointerProperties.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aI(2, _omitFieldNames ? '' : 'toolType', protoName: 'toolType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionTouchEvent_TouchEvent_PointerProperties clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionTouchEvent_TouchEvent_PointerProperties copyWith(
          void Function(ActionTouchEvent_TouchEvent_PointerProperties)
              updates) =>
      super.copyWith((message) =>
              updates(message as ActionTouchEvent_TouchEvent_PointerProperties))
          as ActionTouchEvent_TouchEvent_PointerProperties;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ActionTouchEvent_TouchEvent_PointerProperties() / ActionTouchEvent_TouchEvent_PointerProperties.new instead')
  static ActionTouchEvent_TouchEvent_PointerProperties create() =>
      ActionTouchEvent_TouchEvent_PointerProperties._();
  static $pb.GeneratedMessage $_createMessage() =>
      ActionTouchEvent_TouchEvent_PointerProperties._();
  @$core.override
  ActionTouchEvent_TouchEvent_PointerProperties createEmptyInstance() =>
      ActionTouchEvent_TouchEvent_PointerProperties._();
  @$core.pragma('dart2js:noInline')
  static ActionTouchEvent_TouchEvent_PointerProperties getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
              ActionTouchEvent_TouchEvent_PointerProperties>(
          ActionTouchEvent_TouchEvent_PointerProperties.$_createMessage);
  static ActionTouchEvent_TouchEvent_PointerProperties? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get toolType => $_getIZ(1);
  @$pb.TagNumber(2)
  set toolType($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasToolType() => $_has(1);
  @$pb.TagNumber(2)
  void clearToolType() => $_clearField(2);
}

class ActionTouchEvent_TouchEvent_PointerCoords extends $pb.GeneratedMessage {
  factory ActionTouchEvent_TouchEvent_PointerCoords({
    $core.double? x,
    $core.double? y,
  }) {
    final result = ActionTouchEvent_TouchEvent_PointerCoords._();
    if (x != null) result.x = x;
    if (y != null) result.y = y;
    return result;
  }

  ActionTouchEvent_TouchEvent_PointerCoords._();

  factory ActionTouchEvent_TouchEvent_PointerCoords.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionTouchEvent_TouchEvent_PointerCoords()
        ..mergeFromBuffer(data, registry);
  factory ActionTouchEvent_TouchEvent_PointerCoords.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionTouchEvent_TouchEvent_PointerCoords()
        ..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActionTouchEvent.TouchEvent.PointerCoords',
      createEmptyInstance:
          ActionTouchEvent_TouchEvent_PointerCoords.$_createMessage)
    ..aD(1, _omitFieldNames ? '' : 'x', fieldType: $pb.PbFieldType.OF)
    ..aD(2, _omitFieldNames ? '' : 'y', fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionTouchEvent_TouchEvent_PointerCoords clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionTouchEvent_TouchEvent_PointerCoords copyWith(
          void Function(ActionTouchEvent_TouchEvent_PointerCoords) updates) =>
      super.copyWith((message) =>
              updates(message as ActionTouchEvent_TouchEvent_PointerCoords))
          as ActionTouchEvent_TouchEvent_PointerCoords;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ActionTouchEvent_TouchEvent_PointerCoords() / ActionTouchEvent_TouchEvent_PointerCoords.new instead')
  static ActionTouchEvent_TouchEvent_PointerCoords create() =>
      ActionTouchEvent_TouchEvent_PointerCoords._();
  static $pb.GeneratedMessage $_createMessage() =>
      ActionTouchEvent_TouchEvent_PointerCoords._();
  @$core.override
  ActionTouchEvent_TouchEvent_PointerCoords createEmptyInstance() =>
      ActionTouchEvent_TouchEvent_PointerCoords._();
  @$core.pragma('dart2js:noInline')
  static ActionTouchEvent_TouchEvent_PointerCoords getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
              ActionTouchEvent_TouchEvent_PointerCoords>(
          ActionTouchEvent_TouchEvent_PointerCoords.$_createMessage);
  static ActionTouchEvent_TouchEvent_PointerCoords? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get x => $_getN(0);
  @$pb.TagNumber(1)
  set x($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasX() => $_has(0);
  @$pb.TagNumber(1)
  void clearX() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get y => $_getN(1);
  @$pb.TagNumber(2)
  set y($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasY() => $_has(1);
  @$pb.TagNumber(2)
  void clearY() => $_clearField(2);
}

class ActionTouchEvent_TouchEvent extends $pb.GeneratedMessage {
  factory ActionTouchEvent_TouchEvent({
    $fixnum.Int64? eventTime,
    $core.int? action,
    $core.int? pointerCount,
    $core.Iterable<ActionTouchEvent_TouchEvent_PointerProperties>?
        pointerProperties,
    $core.Iterable<ActionTouchEvent_TouchEvent_PointerCoords>? pointerCoords,
    $core.double? x,
    $core.double? y,
  }) {
    final result = ActionTouchEvent_TouchEvent._();
    if (eventTime != null) result.eventTime = eventTime;
    if (action != null) result.action = action;
    if (pointerCount != null) result.pointerCount = pointerCount;
    if (pointerProperties != null)
      result.pointerProperties.addAll(pointerProperties);
    if (pointerCoords != null) result.pointerCoords.addAll(pointerCoords);
    if (x != null) result.x = x;
    if (y != null) result.y = y;
    return result;
  }

  ActionTouchEvent_TouchEvent._();

  factory ActionTouchEvent_TouchEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionTouchEvent_TouchEvent()..mergeFromBuffer(data, registry);
  factory ActionTouchEvent_TouchEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionTouchEvent_TouchEvent()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActionTouchEvent.TouchEvent',
      createEmptyInstance: ActionTouchEvent_TouchEvent.$_createMessage)
    ..aInt64(2, _omitFieldNames ? '' : 'eventTime', protoName: 'eventTime')
    ..aI(3, _omitFieldNames ? '' : 'action')
    ..aI(4, _omitFieldNames ? '' : 'pointerCount', protoName: 'pointerCount')
    ..pPM<ActionTouchEvent_TouchEvent_PointerProperties>(
        5, _omitFieldNames ? '' : 'pointerProperties',
        protoName: 'pointerProperties',
        subBuilder:
            ActionTouchEvent_TouchEvent_PointerProperties.$_createMessage)
    ..pPM<ActionTouchEvent_TouchEvent_PointerCoords>(
        6, _omitFieldNames ? '' : 'pointerCoords',
        protoName: 'pointerCoords',
        subBuilder: ActionTouchEvent_TouchEvent_PointerCoords.$_createMessage)
    ..aD(15, _omitFieldNames ? '' : 'x', fieldType: $pb.PbFieldType.OF)
    ..aD(16, _omitFieldNames ? '' : 'y', fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionTouchEvent_TouchEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionTouchEvent_TouchEvent copyWith(
          void Function(ActionTouchEvent_TouchEvent) updates) =>
      super.copyWith(
              (message) => updates(message as ActionTouchEvent_TouchEvent))
          as ActionTouchEvent_TouchEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ActionTouchEvent_TouchEvent() / ActionTouchEvent_TouchEvent.new instead')
  static ActionTouchEvent_TouchEvent create() =>
      ActionTouchEvent_TouchEvent._();
  static $pb.GeneratedMessage $_createMessage() =>
      ActionTouchEvent_TouchEvent._();
  @$core.override
  ActionTouchEvent_TouchEvent createEmptyInstance() =>
      ActionTouchEvent_TouchEvent._();
  @$core.pragma('dart2js:noInline')
  static ActionTouchEvent_TouchEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ActionTouchEvent_TouchEvent>(
          ActionTouchEvent_TouchEvent.$_createMessage);
  static ActionTouchEvent_TouchEvent? _defaultInstance;

  @$pb.TagNumber(2)
  $fixnum.Int64 get eventTime => $_getI64(0);
  @$pb.TagNumber(2)
  set eventTime($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(2)
  $core.bool hasEventTime() => $_has(0);
  @$pb.TagNumber(2)
  void clearEventTime() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get action => $_getIZ(1);
  @$pb.TagNumber(3)
  set action($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(3)
  $core.bool hasAction() => $_has(1);
  @$pb.TagNumber(3)
  void clearAction() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get pointerCount => $_getIZ(2);
  @$pb.TagNumber(4)
  set pointerCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(4)
  $core.bool hasPointerCount() => $_has(2);
  @$pb.TagNumber(4)
  void clearPointerCount() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<ActionTouchEvent_TouchEvent_PointerProperties>
      get pointerProperties => $_getList(3);

  @$pb.TagNumber(6)
  $pb.PbList<ActionTouchEvent_TouchEvent_PointerCoords> get pointerCoords =>
      $_getList(4);

  @$pb.TagNumber(15)
  $core.double get x => $_getN(5);
  @$pb.TagNumber(15)
  set x($core.double value) => $_setFloat(5, value);
  @$pb.TagNumber(15)
  $core.bool hasX() => $_has(5);
  @$pb.TagNumber(15)
  void clearX() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.double get y => $_getN(6);
  @$pb.TagNumber(16)
  set y($core.double value) => $_setFloat(6, value);
  @$pb.TagNumber(16)
  $core.bool hasY() => $_has(6);
  @$pb.TagNumber(16)
  void clearY() => $_clearField(16);
}

/// 触摸数据
class ActionTouchEvent extends $pb.GeneratedMessage {
  factory ActionTouchEvent({
    $core.int? type,
    $fixnum.Int64? startTime,
    $fixnum.Int64? endTime,
    $core.Iterable<ActionTouchEvent_TouchEvent>? touchEvent,
  }) {
    final result = ActionTouchEvent._();
    if (type != null) result.type = type;
    if (startTime != null) result.startTime = startTime;
    if (endTime != null) result.endTime = endTime;
    if (touchEvent != null) result.touchEvent.addAll(touchEvent);
    return result;
  }

  ActionTouchEvent._();

  factory ActionTouchEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionTouchEvent()..mergeFromBuffer(data, registry);
  factory ActionTouchEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionTouchEvent()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActionTouchEvent',
      createEmptyInstance: ActionTouchEvent.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'type')
    ..aInt64(2, _omitFieldNames ? '' : 'startTime', protoName: 'startTime')
    ..aInt64(3, _omitFieldNames ? '' : 'endTime', protoName: 'endTime')
    ..pPM<ActionTouchEvent_TouchEvent>(4, _omitFieldNames ? '' : 'touchEvent',
        protoName: 'touchEvent',
        subBuilder: ActionTouchEvent_TouchEvent.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionTouchEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionTouchEvent copyWith(void Function(ActionTouchEvent) updates) =>
      super.copyWith((message) => updates(message as ActionTouchEvent))
          as ActionTouchEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ActionTouchEvent() / ActionTouchEvent.new instead')
  static ActionTouchEvent create() => ActionTouchEvent._();
  static $pb.GeneratedMessage $_createMessage() => ActionTouchEvent._();
  @$core.override
  ActionTouchEvent createEmptyInstance() => ActionTouchEvent._();
  @$core.pragma('dart2js:noInline')
  static ActionTouchEvent getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ActionTouchEvent>(
          ActionTouchEvent.$_createMessage);
  static ActionTouchEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get type => $_getIZ(0);
  @$pb.TagNumber(1)
  set type($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get startTime => $_getI64(1);
  @$pb.TagNumber(2)
  set startTime($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStartTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartTime() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get endTime => $_getI64(2);
  @$pb.TagNumber(3)
  set endTime($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEndTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearEndTime() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<ActionTouchEvent_TouchEvent> get touchEvent => $_getList(3);
}

class ActionImageConfig extends $pb.GeneratedMessage {
  factory ActionImageConfig({
    $core.int? type,
    $fixnum.Int64? startTime,
    $core.String? path,
    $core.int? width,
    $core.int? height,
    $core.int? viewWidth,
    $core.int? viewHeight,
    $core.int? positionFlag,
  }) {
    final result = ActionImageConfig._();
    if (type != null) result.type = type;
    if (startTime != null) result.startTime = startTime;
    if (path != null) result.path = path;
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    if (viewWidth != null) result.viewWidth = viewWidth;
    if (viewHeight != null) result.viewHeight = viewHeight;
    if (positionFlag != null) result.positionFlag = positionFlag;
    return result;
  }

  ActionImageConfig._();

  factory ActionImageConfig.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionImageConfig()..mergeFromBuffer(data, registry);
  factory ActionImageConfig.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionImageConfig()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActionImageConfig',
      createEmptyInstance: ActionImageConfig.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'type')
    ..aInt64(2, _omitFieldNames ? '' : 'startTime', protoName: 'startTime')
    ..aOS(3, _omitFieldNames ? '' : 'path')
    ..aI(4, _omitFieldNames ? '' : 'width')
    ..aI(5, _omitFieldNames ? '' : 'height')
    ..aI(6, _omitFieldNames ? '' : 'viewWidth', protoName: 'viewWidth')
    ..aI(7, _omitFieldNames ? '' : 'viewHeight', protoName: 'viewHeight')
    ..aI(8, _omitFieldNames ? '' : 'positionFlag', protoName: 'positionFlag')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionImageConfig clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionImageConfig copyWith(void Function(ActionImageConfig) updates) =>
      super.copyWith((message) => updates(message as ActionImageConfig))
          as ActionImageConfig;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ActionImageConfig() / ActionImageConfig.new instead')
  static ActionImageConfig create() => ActionImageConfig._();
  static $pb.GeneratedMessage $_createMessage() => ActionImageConfig._();
  @$core.override
  ActionImageConfig createEmptyInstance() => ActionImageConfig._();
  @$core.pragma('dart2js:noInline')
  static ActionImageConfig getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ActionImageConfig>(
          ActionImageConfig.$_createMessage);
  static ActionImageConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get type => $_getIZ(0);
  @$pb.TagNumber(1)
  set type($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get startTime => $_getI64(1);
  @$pb.TagNumber(2)
  set startTime($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStartTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartTime() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get path => $_getSZ(2);
  @$pb.TagNumber(3)
  set path($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPath() => $_has(2);
  @$pb.TagNumber(3)
  void clearPath() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get width => $_getIZ(3);
  @$pb.TagNumber(4)
  set width($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasWidth() => $_has(3);
  @$pb.TagNumber(4)
  void clearWidth() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get height => $_getIZ(4);
  @$pb.TagNumber(5)
  set height($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearHeight() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get viewWidth => $_getIZ(5);
  @$pb.TagNumber(6)
  set viewWidth($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasViewWidth() => $_has(5);
  @$pb.TagNumber(6)
  void clearViewWidth() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get viewHeight => $_getIZ(6);
  @$pb.TagNumber(7)
  set viewHeight($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasViewHeight() => $_has(6);
  @$pb.TagNumber(7)
  void clearViewHeight() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get positionFlag => $_getIZ(7);
  @$pb.TagNumber(8)
  set positionFlag($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPositionFlag() => $_has(7);
  @$pb.TagNumber(8)
  void clearPositionFlag() => $_clearField(8);
}

class ActionWebViewConfig extends $pb.GeneratedMessage {
  factory ActionWebViewConfig({
    $core.int? type,
    $fixnum.Int64? startTime,
    $core.String? path,
    $core.int? width,
    $core.int? height,
    $core.int? viewWidth,
    $core.int? viewHeight,
  }) {
    final result = ActionWebViewConfig._();
    if (type != null) result.type = type;
    if (startTime != null) result.startTime = startTime;
    if (path != null) result.path = path;
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    if (viewWidth != null) result.viewWidth = viewWidth;
    if (viewHeight != null) result.viewHeight = viewHeight;
    return result;
  }

  ActionWebViewConfig._();

  factory ActionWebViewConfig.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionWebViewConfig()..mergeFromBuffer(data, registry);
  factory ActionWebViewConfig.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionWebViewConfig()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActionWebViewConfig',
      createEmptyInstance: ActionWebViewConfig.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'type')
    ..aInt64(2, _omitFieldNames ? '' : 'startTime', protoName: 'startTime')
    ..aOS(3, _omitFieldNames ? '' : 'path')
    ..aI(4, _omitFieldNames ? '' : 'width')
    ..aI(5, _omitFieldNames ? '' : 'height')
    ..aI(6, _omitFieldNames ? '' : 'viewWidth', protoName: 'viewWidth')
    ..aI(7, _omitFieldNames ? '' : 'viewHeight', protoName: 'viewHeight')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionWebViewConfig clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionWebViewConfig copyWith(void Function(ActionWebViewConfig) updates) =>
      super.copyWith((message) => updates(message as ActionWebViewConfig))
          as ActionWebViewConfig;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use ActionWebViewConfig() / ActionWebViewConfig.new instead')
  static ActionWebViewConfig create() => ActionWebViewConfig._();
  static $pb.GeneratedMessage $_createMessage() => ActionWebViewConfig._();
  @$core.override
  ActionWebViewConfig createEmptyInstance() => ActionWebViewConfig._();
  @$core.pragma('dart2js:noInline')
  static ActionWebViewConfig getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ActionWebViewConfig>(
          ActionWebViewConfig.$_createMessage);
  static ActionWebViewConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get type => $_getIZ(0);
  @$pb.TagNumber(1)
  set type($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get startTime => $_getI64(1);
  @$pb.TagNumber(2)
  set startTime($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStartTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartTime() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get path => $_getSZ(2);
  @$pb.TagNumber(3)
  set path($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPath() => $_has(2);
  @$pb.TagNumber(3)
  void clearPath() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get width => $_getIZ(3);
  @$pb.TagNumber(4)
  set width($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasWidth() => $_has(3);
  @$pb.TagNumber(4)
  void clearWidth() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get height => $_getIZ(4);
  @$pb.TagNumber(5)
  set height($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearHeight() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get viewWidth => $_getIZ(5);
  @$pb.TagNumber(6)
  set viewWidth($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasViewWidth() => $_has(5);
  @$pb.TagNumber(6)
  void clearViewWidth() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get viewHeight => $_getIZ(6);
  @$pb.TagNumber(7)
  set viewHeight($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasViewHeight() => $_has(6);
  @$pb.TagNumber(7)
  void clearViewHeight() => $_clearField(7);
}

class ActionGraphConfig_GraphConfig extends $pb.GeneratedMessage {
  factory ActionGraphConfig_GraphConfig({
    $core.double? width,
    $core.int? color,
  }) {
    final result = ActionGraphConfig_GraphConfig._();
    if (width != null) result.width = width;
    if (color != null) result.color = color;
    return result;
  }

  ActionGraphConfig_GraphConfig._();

  factory ActionGraphConfig_GraphConfig.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionGraphConfig_GraphConfig()..mergeFromBuffer(data, registry);
  factory ActionGraphConfig_GraphConfig.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionGraphConfig_GraphConfig()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActionGraphConfig.GraphConfig',
      createEmptyInstance: ActionGraphConfig_GraphConfig.$_createMessage)
    ..aD(1, _omitFieldNames ? '' : 'width', fieldType: $pb.PbFieldType.OF)
    ..aI(2, _omitFieldNames ? '' : 'color')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionGraphConfig_GraphConfig clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionGraphConfig_GraphConfig copyWith(
          void Function(ActionGraphConfig_GraphConfig) updates) =>
      super.copyWith(
              (message) => updates(message as ActionGraphConfig_GraphConfig))
          as ActionGraphConfig_GraphConfig;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use ActionGraphConfig_GraphConfig() / ActionGraphConfig_GraphConfig.new instead')
  static ActionGraphConfig_GraphConfig create() =>
      ActionGraphConfig_GraphConfig._();
  static $pb.GeneratedMessage $_createMessage() =>
      ActionGraphConfig_GraphConfig._();
  @$core.override
  ActionGraphConfig_GraphConfig createEmptyInstance() =>
      ActionGraphConfig_GraphConfig._();
  @$core.pragma('dart2js:noInline')
  static ActionGraphConfig_GraphConfig getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ActionGraphConfig_GraphConfig>(
          ActionGraphConfig_GraphConfig.$_createMessage);
  static ActionGraphConfig_GraphConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get width => $_getN(0);
  @$pb.TagNumber(1)
  set width($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWidth() => $_has(0);
  @$pb.TagNumber(1)
  void clearWidth() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get color => $_getIZ(1);
  @$pb.TagNumber(2)
  set color($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasColor() => $_has(1);
  @$pb.TagNumber(2)
  void clearColor() => $_clearField(2);
}

class ActionGraphConfig extends $pb.GeneratedMessage {
  factory ActionGraphConfig({
    $core.int? type,
    $fixnum.Int64? startTime,
    ActionGraphConfig_GraphConfig? config,
  }) {
    final result = ActionGraphConfig._();
    if (type != null) result.type = type;
    if (startTime != null) result.startTime = startTime;
    if (config != null) result.config = config;
    return result;
  }

  ActionGraphConfig._();

  factory ActionGraphConfig.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionGraphConfig()..mergeFromBuffer(data, registry);
  factory ActionGraphConfig.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionGraphConfig()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActionGraphConfig',
      createEmptyInstance: ActionGraphConfig.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'type')
    ..aInt64(2, _omitFieldNames ? '' : 'startTime', protoName: 'startTime')
    ..aOM<ActionGraphConfig_GraphConfig>(4, _omitFieldNames ? '' : 'config',
        subBuilder: ActionGraphConfig_GraphConfig.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionGraphConfig clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionGraphConfig copyWith(void Function(ActionGraphConfig) updates) =>
      super.copyWith((message) => updates(message as ActionGraphConfig))
          as ActionGraphConfig;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ActionGraphConfig() / ActionGraphConfig.new instead')
  static ActionGraphConfig create() => ActionGraphConfig._();
  static $pb.GeneratedMessage $_createMessage() => ActionGraphConfig._();
  @$core.override
  ActionGraphConfig createEmptyInstance() => ActionGraphConfig._();
  @$core.pragma('dart2js:noInline')
  static ActionGraphConfig getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ActionGraphConfig>(
          ActionGraphConfig.$_createMessage);
  static ActionGraphConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get type => $_getIZ(0);
  @$pb.TagNumber(1)
  set type($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get startTime => $_getI64(1);
  @$pb.TagNumber(2)
  set startTime($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStartTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartTime() => $_clearField(2);

  @$pb.TagNumber(4)
  ActionGraphConfig_GraphConfig get config => $_getN(2);
  @$pb.TagNumber(4)
  set config(ActionGraphConfig_GraphConfig value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasConfig() => $_has(2);
  @$pb.TagNumber(4)
  void clearConfig() => $_clearField(4);
  @$pb.TagNumber(4)
  ActionGraphConfig_GraphConfig ensureConfig() => $_ensure(2);
}

class ActionDrawConfig extends $pb.GeneratedMessage {
  factory ActionDrawConfig({
    $core.int? type,
    $fixnum.Int64? startTime,
    $core.int? backgroundColor,
    DrawArea? drawArea,
  }) {
    final result = ActionDrawConfig._();
    if (type != null) result.type = type;
    if (startTime != null) result.startTime = startTime;
    if (backgroundColor != null) result.backgroundColor = backgroundColor;
    if (drawArea != null) result.drawArea = drawArea;
    return result;
  }

  ActionDrawConfig._();

  factory ActionDrawConfig.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionDrawConfig()..mergeFromBuffer(data, registry);
  factory ActionDrawConfig.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionDrawConfig()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActionDrawConfig',
      createEmptyInstance: ActionDrawConfig.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'type')
    ..aInt64(2, _omitFieldNames ? '' : 'startTime', protoName: 'startTime')
    ..aI(3, _omitFieldNames ? '' : 'backgroundColor',
        protoName: 'backgroundColor')
    ..aOM<DrawArea>(4, _omitFieldNames ? '' : 'drawArea',
        protoName: 'drawArea', subBuilder: DrawArea.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionDrawConfig clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionDrawConfig copyWith(void Function(ActionDrawConfig) updates) =>
      super.copyWith((message) => updates(message as ActionDrawConfig))
          as ActionDrawConfig;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ActionDrawConfig() / ActionDrawConfig.new instead')
  static ActionDrawConfig create() => ActionDrawConfig._();
  static $pb.GeneratedMessage $_createMessage() => ActionDrawConfig._();
  @$core.override
  ActionDrawConfig createEmptyInstance() => ActionDrawConfig._();
  @$core.pragma('dart2js:noInline')
  static ActionDrawConfig getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ActionDrawConfig>(
          ActionDrawConfig.$_createMessage);
  static ActionDrawConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get type => $_getIZ(0);
  @$pb.TagNumber(1)
  set type($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get startTime => $_getI64(1);
  @$pb.TagNumber(2)
  set startTime($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStartTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartTime() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get backgroundColor => $_getIZ(2);
  @$pb.TagNumber(3)
  set backgroundColor($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBackgroundColor() => $_has(2);
  @$pb.TagNumber(3)
  void clearBackgroundColor() => $_clearField(3);

  @$pb.TagNumber(4)
  DrawArea get drawArea => $_getN(3);
  @$pb.TagNumber(4)
  set drawArea(DrawArea value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasDrawArea() => $_has(3);
  @$pb.TagNumber(4)
  void clearDrawArea() => $_clearField(4);
  @$pb.TagNumber(4)
  DrawArea ensureDrawArea() => $_ensure(3);
}

class DrawArea extends $pb.GeneratedMessage {
  factory DrawArea({
    $1.PointF? leftTopPoint,
    $1.PointF? rightBottomPoint,
    $core.Iterable<$core.double>? matrix,
  }) {
    final result = DrawArea._();
    if (leftTopPoint != null) result.leftTopPoint = leftTopPoint;
    if (rightBottomPoint != null) result.rightBottomPoint = rightBottomPoint;
    if (matrix != null) result.matrix.addAll(matrix);
    return result;
  }

  DrawArea._();

  factory DrawArea.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DrawArea()..mergeFromBuffer(data, registry);
  factory DrawArea.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DrawArea()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DrawArea',
      createEmptyInstance: DrawArea.$_createMessage)
    ..aOM<$1.PointF>(1, _omitFieldNames ? '' : 'leftTopPoint',
        protoName: 'leftTopPoint', subBuilder: $1.PointF.$_createMessage)
    ..aOM<$1.PointF>(2, _omitFieldNames ? '' : 'rightBottomPoint',
        protoName: 'rightBottomPoint', subBuilder: $1.PointF.$_createMessage)
    ..p<$core.double>(3, _omitFieldNames ? '' : 'matrix', $pb.PbFieldType.KF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DrawArea clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DrawArea copyWith(void Function(DrawArea) updates) =>
      super.copyWith((message) => updates(message as DrawArea)) as DrawArea;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DrawArea() / DrawArea.new instead')
  static DrawArea create() => DrawArea._();
  static $pb.GeneratedMessage $_createMessage() => DrawArea._();
  @$core.override
  DrawArea createEmptyInstance() => DrawArea._();
  @$core.pragma('dart2js:noInline')
  static DrawArea getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DrawArea>(DrawArea.$_createMessage);
  static DrawArea? _defaultInstance;

  @$pb.TagNumber(1)
  $1.PointF get leftTopPoint => $_getN(0);
  @$pb.TagNumber(1)
  set leftTopPoint($1.PointF value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasLeftTopPoint() => $_has(0);
  @$pb.TagNumber(1)
  void clearLeftTopPoint() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.PointF ensureLeftTopPoint() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.PointF get rightBottomPoint => $_getN(1);
  @$pb.TagNumber(2)
  set rightBottomPoint($1.PointF value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasRightBottomPoint() => $_has(1);
  @$pb.TagNumber(2)
  void clearRightBottomPoint() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.PointF ensureRightBottomPoint() => $_ensure(1);

  @$pb.TagNumber(3)
  $pb.PbList<$core.double> get matrix => $_getList(2);
}

class ActionModeConfig extends $pb.GeneratedMessage {
  factory ActionModeConfig({
    $core.int? type,
    $fixnum.Int64? startTime,
    ActionModeConfig_Mode? mode,
  }) {
    final result = ActionModeConfig._();
    if (type != null) result.type = type;
    if (startTime != null) result.startTime = startTime;
    if (mode != null) result.mode = mode;
    return result;
  }

  ActionModeConfig._();

  factory ActionModeConfig.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionModeConfig()..mergeFromBuffer(data, registry);
  factory ActionModeConfig.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionModeConfig()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActionModeConfig',
      createEmptyInstance: ActionModeConfig.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'type')
    ..aInt64(2, _omitFieldNames ? '' : 'startTime', protoName: 'startTime')
    ..aE<ActionModeConfig_Mode>(4, _omitFieldNames ? '' : 'mode',
        enumValues: ActionModeConfig_Mode.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionModeConfig clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionModeConfig copyWith(void Function(ActionModeConfig) updates) =>
      super.copyWith((message) => updates(message as ActionModeConfig))
          as ActionModeConfig;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ActionModeConfig() / ActionModeConfig.new instead')
  static ActionModeConfig create() => ActionModeConfig._();
  static $pb.GeneratedMessage $_createMessage() => ActionModeConfig._();
  @$core.override
  ActionModeConfig createEmptyInstance() => ActionModeConfig._();
  @$core.pragma('dart2js:noInline')
  static ActionModeConfig getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ActionModeConfig>(
          ActionModeConfig.$_createMessage);
  static ActionModeConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get type => $_getIZ(0);
  @$pb.TagNumber(1)
  set type($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get startTime => $_getI64(1);
  @$pb.TagNumber(2)
  set startTime($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStartTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartTime() => $_clearField(2);

  @$pb.TagNumber(4)
  ActionModeConfig_Mode get mode => $_getN(2);
  @$pb.TagNumber(4)
  set mode(ActionModeConfig_Mode value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasMode() => $_has(2);
  @$pb.TagNumber(4)
  void clearMode() => $_clearField(4);
}

class ActionFitterConfig extends $pb.GeneratedMessage {
  factory ActionFitterConfig({
    $core.int? type,
    $fixnum.Int64? startTime,
    $core.double? scale,
    $core.int? centerX,
    $core.int? centerY,
    $core.int? px,
    $core.int? py,
  }) {
    final result = ActionFitterConfig._();
    if (type != null) result.type = type;
    if (startTime != null) result.startTime = startTime;
    if (scale != null) result.scale = scale;
    if (centerX != null) result.centerX = centerX;
    if (centerY != null) result.centerY = centerY;
    if (px != null) result.px = px;
    if (py != null) result.py = py;
    return result;
  }

  ActionFitterConfig._();

  factory ActionFitterConfig.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionFitterConfig()..mergeFromBuffer(data, registry);
  factory ActionFitterConfig.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionFitterConfig()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActionFitterConfig',
      createEmptyInstance: ActionFitterConfig.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'type')
    ..aInt64(2, _omitFieldNames ? '' : 'startTime', protoName: 'startTime')
    ..aD(3, _omitFieldNames ? '' : 'scale', fieldType: $pb.PbFieldType.OF)
    ..aI(4, _omitFieldNames ? '' : 'centerX', protoName: 'centerX')
    ..aI(5, _omitFieldNames ? '' : 'centerY', protoName: 'centerY')
    ..aI(6, _omitFieldNames ? '' : 'px')
    ..aI(7, _omitFieldNames ? '' : 'py')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionFitterConfig clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionFitterConfig copyWith(void Function(ActionFitterConfig) updates) =>
      super.copyWith((message) => updates(message as ActionFitterConfig))
          as ActionFitterConfig;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ActionFitterConfig() / ActionFitterConfig.new instead')
  static ActionFitterConfig create() => ActionFitterConfig._();
  static $pb.GeneratedMessage $_createMessage() => ActionFitterConfig._();
  @$core.override
  ActionFitterConfig createEmptyInstance() => ActionFitterConfig._();
  @$core.pragma('dart2js:noInline')
  static ActionFitterConfig getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ActionFitterConfig>(
          ActionFitterConfig.$_createMessage);
  static ActionFitterConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get type => $_getIZ(0);
  @$pb.TagNumber(1)
  set type($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get startTime => $_getI64(1);
  @$pb.TagNumber(2)
  set startTime($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStartTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartTime() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get scale => $_getN(2);
  @$pb.TagNumber(3)
  set scale($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasScale() => $_has(2);
  @$pb.TagNumber(3)
  void clearScale() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get centerX => $_getIZ(3);
  @$pb.TagNumber(4)
  set centerX($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCenterX() => $_has(3);
  @$pb.TagNumber(4)
  void clearCenterX() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get centerY => $_getIZ(4);
  @$pb.TagNumber(5)
  set centerY($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCenterY() => $_has(4);
  @$pb.TagNumber(5)
  void clearCenterY() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get px => $_getIZ(5);
  @$pb.TagNumber(6)
  set px($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPx() => $_has(5);
  @$pb.TagNumber(6)
  void clearPx() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get py => $_getIZ(6);
  @$pb.TagNumber(7)
  set py($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPy() => $_has(6);
  @$pb.TagNumber(7)
  void clearPy() => $_clearField(7);
}

class ActionClearBoard extends $pb.GeneratedMessage {
  factory ActionClearBoard({
    $core.int? type,
    $fixnum.Int64? startTime,
  }) {
    final result = ActionClearBoard._();
    if (type != null) result.type = type;
    if (startTime != null) result.startTime = startTime;
    return result;
  }

  ActionClearBoard._();

  factory ActionClearBoard.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionClearBoard()..mergeFromBuffer(data, registry);
  factory ActionClearBoard.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionClearBoard()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActionClearBoard',
      createEmptyInstance: ActionClearBoard.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'type')
    ..aInt64(2, _omitFieldNames ? '' : 'startTime', protoName: 'startTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionClearBoard clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionClearBoard copyWith(void Function(ActionClearBoard) updates) =>
      super.copyWith((message) => updates(message as ActionClearBoard))
          as ActionClearBoard;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ActionClearBoard() / ActionClearBoard.new instead')
  static ActionClearBoard create() => ActionClearBoard._();
  static $pb.GeneratedMessage $_createMessage() => ActionClearBoard._();
  @$core.override
  ActionClearBoard createEmptyInstance() => ActionClearBoard._();
  @$core.pragma('dart2js:noInline')
  static ActionClearBoard getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ActionClearBoard>(
          ActionClearBoard.$_createMessage);
  static ActionClearBoard? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get type => $_getIZ(0);
  @$pb.TagNumber(1)
  set type($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get startTime => $_getI64(1);
  @$pb.TagNumber(2)
  set startTime($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStartTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartTime() => $_clearField(2);
}

class ActionPrevAction extends $pb.GeneratedMessage {
  factory ActionPrevAction({
    $core.int? type,
    $fixnum.Int64? startTime,
  }) {
    final result = ActionPrevAction._();
    if (type != null) result.type = type;
    if (startTime != null) result.startTime = startTime;
    return result;
  }

  ActionPrevAction._();

  factory ActionPrevAction.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionPrevAction()..mergeFromBuffer(data, registry);
  factory ActionPrevAction.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionPrevAction()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActionPrevAction',
      createEmptyInstance: ActionPrevAction.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'type')
    ..aInt64(2, _omitFieldNames ? '' : 'startTime', protoName: 'startTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionPrevAction clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionPrevAction copyWith(void Function(ActionPrevAction) updates) =>
      super.copyWith((message) => updates(message as ActionPrevAction))
          as ActionPrevAction;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ActionPrevAction() / ActionPrevAction.new instead')
  static ActionPrevAction create() => ActionPrevAction._();
  static $pb.GeneratedMessage $_createMessage() => ActionPrevAction._();
  @$core.override
  ActionPrevAction createEmptyInstance() => ActionPrevAction._();
  @$core.pragma('dart2js:noInline')
  static ActionPrevAction getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ActionPrevAction>(
          ActionPrevAction.$_createMessage);
  static ActionPrevAction? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get type => $_getIZ(0);
  @$pb.TagNumber(1)
  set type($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get startTime => $_getI64(1);
  @$pb.TagNumber(2)
  set startTime($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStartTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartTime() => $_clearField(2);
}

class ActionNextAction extends $pb.GeneratedMessage {
  factory ActionNextAction({
    $core.int? type,
    $fixnum.Int64? startTime,
  }) {
    final result = ActionNextAction._();
    if (type != null) result.type = type;
    if (startTime != null) result.startTime = startTime;
    return result;
  }

  ActionNextAction._();

  factory ActionNextAction.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionNextAction()..mergeFromBuffer(data, registry);
  factory ActionNextAction.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionNextAction()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActionNextAction',
      createEmptyInstance: ActionNextAction.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'type')
    ..aInt64(2, _omitFieldNames ? '' : 'startTime', protoName: 'startTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionNextAction clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionNextAction copyWith(void Function(ActionNextAction) updates) =>
      super.copyWith((message) => updates(message as ActionNextAction))
          as ActionNextAction;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ActionNextAction() / ActionNextAction.new instead')
  static ActionNextAction create() => ActionNextAction._();
  static $pb.GeneratedMessage $_createMessage() => ActionNextAction._();
  @$core.override
  ActionNextAction createEmptyInstance() => ActionNextAction._();
  @$core.pragma('dart2js:noInline')
  static ActionNextAction getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ActionNextAction>(
          ActionNextAction.$_createMessage);
  static ActionNextAction? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get type => $_getIZ(0);
  @$pb.TagNumber(1)
  set type($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get startTime => $_getI64(1);
  @$pb.TagNumber(2)
  set startTime($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStartTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartTime() => $_clearField(2);
}

class ActionZoom extends $pb.GeneratedMessage {
  factory ActionZoom({
    $core.int? type,
    $fixnum.Int64? startTime,
    $core.double? scaleX,
    $core.double? scaleY,
    $core.double? centerX,
    $core.double? centerY,
    $core.bool? keep,
  }) {
    final result = ActionZoom._();
    if (type != null) result.type = type;
    if (startTime != null) result.startTime = startTime;
    if (scaleX != null) result.scaleX = scaleX;
    if (scaleY != null) result.scaleY = scaleY;
    if (centerX != null) result.centerX = centerX;
    if (centerY != null) result.centerY = centerY;
    if (keep != null) result.keep = keep;
    return result;
  }

  ActionZoom._();

  factory ActionZoom.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionZoom()..mergeFromBuffer(data, registry);
  factory ActionZoom.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionZoom()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActionZoom',
      createEmptyInstance: ActionZoom.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'type')
    ..aInt64(2, _omitFieldNames ? '' : 'startTime', protoName: 'startTime')
    ..aD(3, _omitFieldNames ? '' : 'scaleX',
        protoName: 'scaleX', fieldType: $pb.PbFieldType.OF)
    ..aD(4, _omitFieldNames ? '' : 'scaleY',
        protoName: 'scaleY', fieldType: $pb.PbFieldType.OF)
    ..aD(5, _omitFieldNames ? '' : 'centerX',
        protoName: 'centerX', fieldType: $pb.PbFieldType.OF)
    ..aD(6, _omitFieldNames ? '' : 'centerY',
        protoName: 'centerY', fieldType: $pb.PbFieldType.OF)
    ..aOB(7, _omitFieldNames ? '' : 'keep')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionZoom clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionZoom copyWith(void Function(ActionZoom) updates) =>
      super.copyWith((message) => updates(message as ActionZoom)) as ActionZoom;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ActionZoom() / ActionZoom.new instead')
  static ActionZoom create() => ActionZoom._();
  static $pb.GeneratedMessage $_createMessage() => ActionZoom._();
  @$core.override
  ActionZoom createEmptyInstance() => ActionZoom._();
  @$core.pragma('dart2js:noInline')
  static ActionZoom getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ActionZoom>(ActionZoom.$_createMessage);
  static ActionZoom? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get type => $_getIZ(0);
  @$pb.TagNumber(1)
  set type($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get startTime => $_getI64(1);
  @$pb.TagNumber(2)
  set startTime($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStartTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartTime() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get scaleX => $_getN(2);
  @$pb.TagNumber(3)
  set scaleX($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasScaleX() => $_has(2);
  @$pb.TagNumber(3)
  void clearScaleX() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get scaleY => $_getN(3);
  @$pb.TagNumber(4)
  set scaleY($core.double value) => $_setFloat(3, value);
  @$pb.TagNumber(4)
  $core.bool hasScaleY() => $_has(3);
  @$pb.TagNumber(4)
  void clearScaleY() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get centerX => $_getN(4);
  @$pb.TagNumber(5)
  set centerX($core.double value) => $_setFloat(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCenterX() => $_has(4);
  @$pb.TagNumber(5)
  void clearCenterX() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get centerY => $_getN(5);
  @$pb.TagNumber(6)
  set centerY($core.double value) => $_setFloat(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCenterY() => $_has(5);
  @$pb.TagNumber(6)
  void clearCenterY() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get keep => $_getBF(6);
  @$pb.TagNumber(7)
  set keep($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasKeep() => $_has(6);
  @$pb.TagNumber(7)
  void clearKeep() => $_clearField(7);
}

class ActionTranslation extends $pb.GeneratedMessage {
  factory ActionTranslation({
    $core.int? type,
    $fixnum.Int64? startTime,
    $2.FloatValue? transX,
    $2.FloatValue? transY,
    $core.bool? keep,
  }) {
    final result = ActionTranslation._();
    if (type != null) result.type = type;
    if (startTime != null) result.startTime = startTime;
    if (transX != null) result.transX = transX;
    if (transY != null) result.transY = transY;
    if (keep != null) result.keep = keep;
    return result;
  }

  ActionTranslation._();

  factory ActionTranslation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionTranslation()..mergeFromBuffer(data, registry);
  factory ActionTranslation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionTranslation()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActionTranslation',
      createEmptyInstance: ActionTranslation.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'type')
    ..aInt64(2, _omitFieldNames ? '' : 'startTime', protoName: 'startTime')
    ..aOM<$2.FloatValue>(3, _omitFieldNames ? '' : 'transX',
        protoName: 'transX', subBuilder: $2.FloatValue.$_createMessage)
    ..aOM<$2.FloatValue>(4, _omitFieldNames ? '' : 'transY',
        protoName: 'transY', subBuilder: $2.FloatValue.$_createMessage)
    ..aOB(5, _omitFieldNames ? '' : 'keep')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionTranslation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionTranslation copyWith(void Function(ActionTranslation) updates) =>
      super.copyWith((message) => updates(message as ActionTranslation))
          as ActionTranslation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ActionTranslation() / ActionTranslation.new instead')
  static ActionTranslation create() => ActionTranslation._();
  static $pb.GeneratedMessage $_createMessage() => ActionTranslation._();
  @$core.override
  ActionTranslation createEmptyInstance() => ActionTranslation._();
  @$core.pragma('dart2js:noInline')
  static ActionTranslation getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ActionTranslation>(
          ActionTranslation.$_createMessage);
  static ActionTranslation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get type => $_getIZ(0);
  @$pb.TagNumber(1)
  set type($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get startTime => $_getI64(1);
  @$pb.TagNumber(2)
  set startTime($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStartTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartTime() => $_clearField(2);

  @$pb.TagNumber(3)
  $2.FloatValue get transX => $_getN(2);
  @$pb.TagNumber(3)
  set transX($2.FloatValue value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTransX() => $_has(2);
  @$pb.TagNumber(3)
  void clearTransX() => $_clearField(3);
  @$pb.TagNumber(3)
  $2.FloatValue ensureTransX() => $_ensure(2);

  @$pb.TagNumber(4)
  $2.FloatValue get transY => $_getN(3);
  @$pb.TagNumber(4)
  set transY($2.FloatValue value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasTransY() => $_has(3);
  @$pb.TagNumber(4)
  void clearTransY() => $_clearField(4);
  @$pb.TagNumber(4)
  $2.FloatValue ensureTransY() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.bool get keep => $_getBF(4);
  @$pb.TagNumber(5)
  set keep($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasKeep() => $_has(4);
  @$pb.TagNumber(5)
  void clearKeep() => $_clearField(5);
}

class ActionResetMatrix extends $pb.GeneratedMessage {
  factory ActionResetMatrix({
    $fixnum.Int64? startTime,
  }) {
    final result = ActionResetMatrix._();
    if (startTime != null) result.startTime = startTime;
    return result;
  }

  ActionResetMatrix._();

  factory ActionResetMatrix.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionResetMatrix()..mergeFromBuffer(data, registry);
  factory ActionResetMatrix.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ActionResetMatrix()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActionResetMatrix',
      createEmptyInstance: ActionResetMatrix.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'startTime', protoName: 'startTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionResetMatrix clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActionResetMatrix copyWith(void Function(ActionResetMatrix) updates) =>
      super.copyWith((message) => updates(message as ActionResetMatrix))
          as ActionResetMatrix;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ActionResetMatrix() / ActionResetMatrix.new instead')
  static ActionResetMatrix create() => ActionResetMatrix._();
  static $pb.GeneratedMessage $_createMessage() => ActionResetMatrix._();
  @$core.override
  ActionResetMatrix createEmptyInstance() => ActionResetMatrix._();
  @$core.pragma('dart2js:noInline')
  static ActionResetMatrix getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ActionResetMatrix>(
          ActionResetMatrix.$_createMessage);
  static ActionResetMatrix? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get startTime => $_getI64(0);
  @$pb.TagNumber(1)
  set startTime($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStartTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearStartTime() => $_clearField(1);
}

class AudioStartAction extends $pb.GeneratedMessage {
  factory AudioStartAction({
    $fixnum.Int64? startTime,
    $core.String? fileName,
  }) {
    final result = AudioStartAction._();
    if (startTime != null) result.startTime = startTime;
    if (fileName != null) result.fileName = fileName;
    return result;
  }

  AudioStartAction._();

  factory AudioStartAction.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AudioStartAction()..mergeFromBuffer(data, registry);
  factory AudioStartAction.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AudioStartAction()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AudioStartAction',
      createEmptyInstance: AudioStartAction.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'startTime', protoName: 'startTime')
    ..aOS(2, _omitFieldNames ? '' : 'fileName', protoName: 'fileName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AudioStartAction clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AudioStartAction copyWith(void Function(AudioStartAction) updates) =>
      super.copyWith((message) => updates(message as AudioStartAction))
          as AudioStartAction;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AudioStartAction() / AudioStartAction.new instead')
  static AudioStartAction create() => AudioStartAction._();
  static $pb.GeneratedMessage $_createMessage() => AudioStartAction._();
  @$core.override
  AudioStartAction createEmptyInstance() => AudioStartAction._();
  @$core.pragma('dart2js:noInline')
  static AudioStartAction getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AudioStartAction>(
          AudioStartAction.$_createMessage);
  static AudioStartAction? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get startTime => $_getI64(0);
  @$pb.TagNumber(1)
  set startTime($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStartTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearStartTime() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fileName => $_getSZ(1);
  @$pb.TagNumber(2)
  set fileName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFileName() => $_has(1);
  @$pb.TagNumber(2)
  void clearFileName() => $_clearField(2);
}

class AudioStopAction extends $pb.GeneratedMessage {
  factory AudioStopAction({
    $fixnum.Int64? startTime,
    $core.String? fileName,
  }) {
    final result = AudioStopAction._();
    if (startTime != null) result.startTime = startTime;
    if (fileName != null) result.fileName = fileName;
    return result;
  }

  AudioStopAction._();

  factory AudioStopAction.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AudioStopAction()..mergeFromBuffer(data, registry);
  factory AudioStopAction.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AudioStopAction()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AudioStopAction',
      createEmptyInstance: AudioStopAction.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'startTime', protoName: 'startTime')
    ..aOS(2, _omitFieldNames ? '' : 'fileName', protoName: 'fileName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AudioStopAction clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AudioStopAction copyWith(void Function(AudioStopAction) updates) =>
      super.copyWith((message) => updates(message as AudioStopAction))
          as AudioStopAction;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AudioStopAction() / AudioStopAction.new instead')
  static AudioStopAction create() => AudioStopAction._();
  static $pb.GeneratedMessage $_createMessage() => AudioStopAction._();
  @$core.override
  AudioStopAction createEmptyInstance() => AudioStopAction._();
  @$core.pragma('dart2js:noInline')
  static AudioStopAction getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AudioStopAction>(
          AudioStopAction.$_createMessage);
  static AudioStopAction? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get startTime => $_getI64(0);
  @$pb.TagNumber(1)
  set startTime($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStartTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearStartTime() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fileName => $_getSZ(1);
  @$pb.TagNumber(2)
  set fileName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFileName() => $_has(1);
  @$pb.TagNumber(2)
  void clearFileName() => $_clearField(2);
}

class GraphResetData_ActionFactory extends $pb.GeneratedMessage {
  factory GraphResetData_ActionFactory({
    ActionModeConfig_Mode? baseAction,
    $core.String? factoryGraphName,
    $core.String? factoryActionGraphName,
  }) {
    final result = GraphResetData_ActionFactory._();
    if (baseAction != null) result.baseAction = baseAction;
    if (factoryGraphName != null) result.factoryGraphName = factoryGraphName;
    if (factoryActionGraphName != null)
      result.factoryActionGraphName = factoryActionGraphName;
    return result;
  }

  GraphResetData_ActionFactory._();

  factory GraphResetData_ActionFactory.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GraphResetData_ActionFactory()..mergeFromBuffer(data, registry);
  factory GraphResetData_ActionFactory.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GraphResetData_ActionFactory()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GraphResetData.ActionFactory',
      createEmptyInstance: GraphResetData_ActionFactory.$_createMessage)
    ..aE<ActionModeConfig_Mode>(1, _omitFieldNames ? '' : 'baseAction',
        protoName: 'baseAction', enumValues: ActionModeConfig_Mode.values)
    ..aOS(2, _omitFieldNames ? '' : 'factoryGraphName',
        protoName: 'factoryGraphName')
    ..aOS(3, _omitFieldNames ? '' : 'factoryActionGraphName',
        protoName: 'factoryActionGraphName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GraphResetData_ActionFactory clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GraphResetData_ActionFactory copyWith(
          void Function(GraphResetData_ActionFactory) updates) =>
      super.copyWith(
              (message) => updates(message as GraphResetData_ActionFactory))
          as GraphResetData_ActionFactory;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GraphResetData_ActionFactory() / GraphResetData_ActionFactory.new instead')
  static GraphResetData_ActionFactory create() =>
      GraphResetData_ActionFactory._();
  static $pb.GeneratedMessage $_createMessage() =>
      GraphResetData_ActionFactory._();
  @$core.override
  GraphResetData_ActionFactory createEmptyInstance() =>
      GraphResetData_ActionFactory._();
  @$core.pragma('dart2js:noInline')
  static GraphResetData_ActionFactory getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GraphResetData_ActionFactory>(
          GraphResetData_ActionFactory.$_createMessage);
  static GraphResetData_ActionFactory? _defaultInstance;

  @$pb.TagNumber(1)
  ActionModeConfig_Mode get baseAction => $_getN(0);
  @$pb.TagNumber(1)
  set baseAction(ActionModeConfig_Mode value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBaseAction() => $_has(0);
  @$pb.TagNumber(1)
  void clearBaseAction() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get factoryGraphName => $_getSZ(1);
  @$pb.TagNumber(2)
  set factoryGraphName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFactoryGraphName() => $_has(1);
  @$pb.TagNumber(2)
  void clearFactoryGraphName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get factoryActionGraphName => $_getSZ(2);
  @$pb.TagNumber(3)
  set factoryActionGraphName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFactoryActionGraphName() => $_has(2);
  @$pb.TagNumber(3)
  void clearFactoryActionGraphName() => $_clearField(3);
}

class GraphResetData extends $pb.GeneratedMessage {
  factory GraphResetData({
    $core.String? factoryGraphName,
    $core.String? factoryActionGraphName,
    GraphResetData_ActionFactory? action,
    ActionGraphConfig_GraphConfig? graphConfig,
    ActionModeConfig_Mode? modeConfig,
    $core.int? backgroundColor,
    DrawArea? drawArea,
  }) {
    final result = GraphResetData._();
    if (factoryGraphName != null) result.factoryGraphName = factoryGraphName;
    if (factoryActionGraphName != null)
      result.factoryActionGraphName = factoryActionGraphName;
    if (action != null) result.action = action;
    if (graphConfig != null) result.graphConfig = graphConfig;
    if (modeConfig != null) result.modeConfig = modeConfig;
    if (backgroundColor != null) result.backgroundColor = backgroundColor;
    if (drawArea != null) result.drawArea = drawArea;
    return result;
  }

  GraphResetData._();

  factory GraphResetData.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GraphResetData()..mergeFromBuffer(data, registry);
  factory GraphResetData.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GraphResetData()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GraphResetData',
      createEmptyInstance: GraphResetData.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'factoryGraphName',
        protoName: 'factoryGraphName')
    ..aOS(2, _omitFieldNames ? '' : 'factoryActionGraphName',
        protoName: 'factoryActionGraphName')
    ..aOM<GraphResetData_ActionFactory>(5, _omitFieldNames ? '' : 'action',
        subBuilder: GraphResetData_ActionFactory.$_createMessage)
    ..aOM<ActionGraphConfig_GraphConfig>(
        6, _omitFieldNames ? '' : 'graphConfig',
        protoName: 'graphConfig',
        subBuilder: ActionGraphConfig_GraphConfig.$_createMessage)
    ..aE<ActionModeConfig_Mode>(7, _omitFieldNames ? '' : 'modeConfig',
        protoName: 'modeConfig', enumValues: ActionModeConfig_Mode.values)
    ..aI(8, _omitFieldNames ? '' : 'backgroundColor',
        protoName: 'backgroundColor')
    ..aOM<DrawArea>(9, _omitFieldNames ? '' : 'drawArea',
        protoName: 'drawArea', subBuilder: DrawArea.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GraphResetData clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GraphResetData copyWith(void Function(GraphResetData) updates) =>
      super.copyWith((message) => updates(message as GraphResetData))
          as GraphResetData;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GraphResetData() / GraphResetData.new instead')
  static GraphResetData create() => GraphResetData._();
  static $pb.GeneratedMessage $_createMessage() => GraphResetData._();
  @$core.override
  GraphResetData createEmptyInstance() => GraphResetData._();
  @$core.pragma('dart2js:noInline')
  static GraphResetData getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GraphResetData>(
          GraphResetData.$_createMessage);
  static GraphResetData? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get factoryGraphName => $_getSZ(0);
  @$pb.TagNumber(1)
  set factoryGraphName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFactoryGraphName() => $_has(0);
  @$pb.TagNumber(1)
  void clearFactoryGraphName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get factoryActionGraphName => $_getSZ(1);
  @$pb.TagNumber(2)
  set factoryActionGraphName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFactoryActionGraphName() => $_has(1);
  @$pb.TagNumber(2)
  void clearFactoryActionGraphName() => $_clearField(2);

  @$pb.TagNumber(5)
  GraphResetData_ActionFactory get action => $_getN(2);
  @$pb.TagNumber(5)
  set action(GraphResetData_ActionFactory value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasAction() => $_has(2);
  @$pb.TagNumber(5)
  void clearAction() => $_clearField(5);
  @$pb.TagNumber(5)
  GraphResetData_ActionFactory ensureAction() => $_ensure(2);

  @$pb.TagNumber(6)
  ActionGraphConfig_GraphConfig get graphConfig => $_getN(3);
  @$pb.TagNumber(6)
  set graphConfig(ActionGraphConfig_GraphConfig value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasGraphConfig() => $_has(3);
  @$pb.TagNumber(6)
  void clearGraphConfig() => $_clearField(6);
  @$pb.TagNumber(6)
  ActionGraphConfig_GraphConfig ensureGraphConfig() => $_ensure(3);

  @$pb.TagNumber(7)
  ActionModeConfig_Mode get modeConfig => $_getN(4);
  @$pb.TagNumber(7)
  set modeConfig(ActionModeConfig_Mode value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasModeConfig() => $_has(4);
  @$pb.TagNumber(7)
  void clearModeConfig() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get backgroundColor => $_getIZ(5);
  @$pb.TagNumber(8)
  set backgroundColor($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(8)
  $core.bool hasBackgroundColor() => $_has(5);
  @$pb.TagNumber(8)
  void clearBackgroundColor() => $_clearField(8);

  @$pb.TagNumber(9)
  DrawArea get drawArea => $_getN(6);
  @$pb.TagNumber(9)
  set drawArea(DrawArea value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasDrawArea() => $_has(6);
  @$pb.TagNumber(9)
  void clearDrawArea() => $_clearField(9);
  @$pb.TagNumber(9)
  DrawArea ensureDrawArea() => $_ensure(6);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
