import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/crypto/zy_aes.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/note.dart';

/// 云笔记接口（全 AES-ECB 加密，复刻 src/api/note.ts）
class NoteApi {
  NoteApi._();

  static String get _base => ApiClient.instance.defaultBaseUrl;

  static void _ensureOk(dynamic data) {
    if (data is Map) {
      final code = data['code'];
      final isOk =
          code == null ||
          (code is num ? code.toInt() == 0 : code.toString() == '0');
      if (!isOk) {
        throw ApiException((data['msg'] ?? '云笔记操作失败').toString());
      }
    }
  }

  static Map<String, dynamic> _decode(dynamic data) {
    _ensureOk(data);
    final cipher = data is Map ? data['data']?.toString() : null;
    return ZyAes.decryptJson(cipher);
  }

  static List<NoteItem> _toItems(dynamic list) {
    if (list is! List) return <NoteItem>[];
    return list
        .whereType<Map>()
        .map((e) => NoteItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// 某文件夹下的子节点
  static Future<List<NoteItem>> getByParentId(String parentId) async {
    final param = ZyAes.encrypt('parentid=$parentId&isNoteNode=true');
    final data = await ApiClient.instance.request(
      '$_base/CloudNotes/api/Notes/GetByParentId?$param',
    );
    final decoded = _decode(data);
    return _toItems(decoded['noteList']).where((e) => !e.isRecycleBin).toList();
  }

  /// 全量节点（含回收站）
  static Future<List<NoteItem>> getAllNodes({bool recycle = false}) async {
    final data = await ApiClient.instance.request(
      '$_base/CloudNotes/api/Notes/GetAll',
    );
    final decoded = _decode(data);
    return _toItems(
      decoded['noteList'],
    ).where((e) => e.isRecycleBin == recycle).toList();
  }

  /// 全部笔记（仅 type 1/12）
  static Future<List<NoteItem>> getAllNotes() async {
    final nodes = await getAllNodes();
    return nodes.where((e) => e.isNote).toList();
  }

  /// 回收站里的笔记
  static Future<List<NoteItem>> getRecycledNotes() async {
    final nodes = await getAllNodes(recycle: true);
    return nodes.where((e) => e.isNote).toList();
  }

  /// 关键词搜索
  static Future<List<NoteItem>> search(String fileName) async {
    final param = ZyAes.encrypt('fileName=$fileName');
    final data = await ApiClient.instance.request(
      '$_base/CloudNotes/api/Notes/Search?$param',
    );
    final decoded = _decode(data);
    return _toItems(
      decoded['noteList'],
    ).where((e) => !e.isRecycleBin && e.isNote).toList();
  }

  static Future<dynamic> _mutate(String endpoint, Object payload) async {
    final data = await ApiClient.instance.request(
      '$_base/CloudNotes/api/Notes/$endpoint',
      method: 'POST',
      data: ZyAes.encrypt(jsonEncode(payload)),
    );
    _ensureOk(data);
    if (data is Map && data['data'] != null) {
      final plain = ZyAes.decrypt(data['data'].toString());
      if (plain.isEmpty) return null;
      try {
        return jsonDecode(plain);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// 更新用的完整节点（复刻 buildRenamePayload）
  static Map<String, dynamic> buildUpdatePayload(
    NoteItem note, {
    String? fileName,
    String? parentId,
  }) {
    final payload = Map<String, dynamic>.from(note.raw);
    if (fileName != null) payload['fileName'] = fileName;
    if (parentId != null) payload['parentId'] = parentId;
    payload.remove('noteList');
    payload.remove('createTime');
    payload.remove('updateTime');
    for (final field in [
      'fileId',
      'fileUrl',
      'parentId',
      'type',
      'version',
      'shared',
      'isRecycleBin',
      'expirationTimeStamp',
    ]) {
      if (!payload.containsKey(field)) {
        throw ApiException('笔记数据不完整（缺少 $field），请刷新后重试');
      }
    }
    return payload;
  }

  static Future<void> rename(NoteItem note, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ApiException('笔记名称不能为空');
    final result = await _mutate(
      'Update',
      buildUpdatePayload(note, fileName: trimmed),
    );
    if (result is Map && result['version'] != null) {
      note.raw['version'] = result['version'];
    }
  }

  /// 移入回收站（官方回收站，可在官方客户端恢复）
  static Future<void> moveToRecycleBin(List<String> fileIds) async {
    final ids = fileIds.where((e) => e.isNotEmpty).toSet().toList();
    if (ids.isEmpty) throw ApiException('请先选择笔记');
    await _mutate('MoveToRecycleBin', ids);
  }

  /// 彻底删除（仅回收站内可用）
  static Future<void> deletePermanently(List<String> fileIds) async {
    final ids = fileIds.where((e) => e.isNotEmpty).toSet().toList();
    if (ids.isEmpty) throw ApiException('请先选择笔记');
    await _mutate('Delete', ids);
  }

  /// 批量移动到目标文件夹（逐个 Update 改 parentId）
  static Future<
    ({List<String> moved, List<String> skipped, List<String> failed})
  >
  moveToFolder(List<String> fileIds, String parentId) async {
    if (parentId.isEmpty) throw ApiException('请选择目标文件夹');
    final nodes = await getAllNodes(recycle: true);
    final all = await getAllNodes();
    final lookup = <String, NoteItem>{
      for (final node in [...all, ...nodes]) node.fileId: node,
    };

    final moved = <String>[];
    final skipped = <String>[];
    final failed = <String>[];

    for (final id in fileIds.toSet()) {
      final note = lookup[id];
      if (note == null || !note.isNote) {
        failed.add(id);
        continue;
      }
      if (note.parentId == parentId) {
        skipped.add(id);
        continue;
      }
      try {
        await _mutate('Update', buildUpdatePayload(note, parentId: parentId));
        moved.add(id);
      } catch (_) {
        failed.add(id);
      }
    }
    return (moved: moved, skipped: skipped, failed: failed);
  }

  /// 生成自定义 fileId（复刻 generateCustomFileId，须含 g-z 字符）
  static String generateFileId() {
    const chars = '0123456789abcdefghijklmnopqrstuvwxyz';
    final random = DateTime.now().microsecondsSinceEpoch;
    for (var attempt = 0; attempt < 50; attempt++) {
      final buffer = StringBuffer('h');
      var seed = random + attempt * 7919;
      for (var i = 0; i < 32; i++) {
        seed = seed * 1103515245 + 12345;
        buffer.write(chars[(seed.abs() >> 8) % chars.length]);
      }
      final value = buffer.toString();
      if (RegExp(r'[g-z]').hasMatch(value)) return value;
    }
    return 'h${random.toString().padLeft(32, '0').substring(0, 32)}';
  }

  static Future<void> _addOrUpdate(Map<String, dynamic> payload) async {
    final data = await ApiClient.instance.request(
      '$_base/CloudNotes/api/Notes/AddOrUpdate',
      method: 'POST',
      data: ZyAes.encrypt(jsonEncode(payload)),
    );
    _ensureOk(data);
  }

  /// 新建文件夹
  static Future<void> createFolder(String name, String parentId) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ApiException('文件夹名称不能为空');
    await _addOrUpdate({
      'fileId': generateFileId(),
      'fileName': trimmed,
      'parentId': parentId,
      'type': 0,
      'fileUrl': '',
    });
  }

  /// 新建笔记（空白笔记，fileUrl 留空由服务端初始化）
  static Future<void> createNote(String name, String parentId) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ApiException('笔记名称不能为空');
    await _addOrUpdate({
      'fileId': generateFileId(),
      'fileName': trimmed,
      'parentId': parentId,
      'type': 12,
      'fileUrl': '',
    });
  }

  /// 笔记页资源
  static Future<List<NoteResource>> getResources(String fileId) async {
    final param = ZyAes.encrypt('fileId=$fileId');
    final data = await ApiClient.instance.request(
      '$_base/CloudNotes/api/Resources/GetByFileId?$param',
    );
    final decoded = _decode(data);
    debugPrint(
      '[NoteApi.getResources] fileId=$fileId 解密结果:\n'
      '${const JsonEncoder.withIndent('  ').convert(decoded)}',
    );
    final list = decoded['resourceList'];
    if (list is! List) return <NoteResource>[];
    return list
        .whereType<Map>()
        .map((e) => NoteResource.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
