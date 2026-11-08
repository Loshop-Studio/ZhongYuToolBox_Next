class MistakeBook {
  MistakeBook({required this.id, required this.name, required this.raw});

  final String id;
  final String name;
  final Map<String, dynamic> raw;

  factory MistakeBook.fromJson(Map<String, dynamic> json) {
    final topic = json['topic'];
    final name = topic is Map
        ? (topic['content'] ?? topic['name'] ?? '').toString()
        : (json['name'] ?? '').toString();
    return MistakeBook(
      id: (json['id'] ?? '').toString(),
      name: name.isEmpty ? '错题本' : name,
      raw: json,
    );
  }
}

class MistakeItem {
  MistakeItem({
    required this.id,
    required this.source,
    required this.stemShoot,
    required this.creationTime,
    required this.raw,
  });

  final String id;
  final String source;
  final String stemShoot;
  final String creationTime;
  final Map<String, dynamic> raw;

  factory MistakeItem.fromJson(Map<String, dynamic> json) {
    return MistakeItem(
      id: (json['id'] ?? '').toString(),
      source: (json['source'] ?? '').toString(),
      stemShoot: (json['stemShoot'] ?? '').toString(),
      creationTime: (json['creationTime'] ?? '').toString(),
      raw: json,
    );
  }
}

class MistakeDetail {
  MistakeDetail({required this.qstPath, required this.note, required this.pictureNote});

  final String qstPath;
  final String note;
  final List<String> pictureNote;

  factory MistakeDetail.fromJson(Map<String, dynamic> json) {
    final pictures = json['pictureNote'];
    return MistakeDetail(
      qstPath: (json['qstPath'] ?? '').toString(),
      note: (json['note'] ?? '').toString(),
      pictureNote: pictures is List
          ? pictures.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
          : <String>[],
    );
  }
}
