/// 云笔记节点（type: 0 文件夹 / 1 笔记 / 12 笔记）
class NoteItem {
  NoteItem({
    required this.fileId,
    required this.fileName,
    required this.type,
    required this.parentId,
    required this.raw,
  });

  final String fileId;
  final String fileName;
  final int type;
  final String parentId;
  final Map<String, dynamic> raw;

  bool get isFolder => type == 0;
  bool get isNote => type == 1 || type == 12;
  bool get isRecycleBin => raw['isRecycleBin'] == true;

  String get createTime => (raw['createTime'] ?? '').toString();
  String get updateTime => (raw['updateTime'] ?? '').toString();

  factory NoteItem.fromJson(Map<String, dynamic> json) {
    return NoteItem(
      fileId: (json['fileId'] ?? '').toString(),
      fileName: (json['fileName'] ?? '').toString(),
      type: (json['type'] as num?)?.toInt() ?? 1,
      parentId: (json['parentId'] ?? '0').toString(),
      raw: json,
    );
  }

  NoteItem copyWith({String? fileName, String? parentId}) {
    final next = Map<String, dynamic>.from(raw);
    if (fileName != null) next['fileName'] = fileName;
    if (parentId != null) next['parentId'] = parentId;
    return NoteItem.fromJson(next);
  }
}

class NoteResource {
  NoteResource({
    required this.ossImageUrl,
    required this.pageIndex,
    required this.resourceType,
  });

  final String ossImageUrl;
  final int pageIndex;
  final int resourceType;

  factory NoteResource.fromJson(Map<String, dynamic> json) {
    return NoteResource(
      ossImageUrl: (json['ossImageUrl'] ?? '').toString(),
      pageIndex: (json['pageIndex'] as num?)?.toInt() ?? 0,
      resourceType: (json['resourceType'] as num?)?.toInt() ?? 0,
    );
  }
}
