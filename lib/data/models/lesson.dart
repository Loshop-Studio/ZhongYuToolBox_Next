class LessonCourse {
  LessonCourse({
    required this.id,
    required this.title,
    required this.cover,
    required this.progress,
    required this.subjectName,
    required this.status,
  });

  final int id;
  final String title;
  final String cover;
  final num progress;
  final String subjectName;
  final int status;

  factory LessonCourse.fromJson(Map<String, dynamic> json) {
    return LessonCourse(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '').toString(),
      cover: (json['cover'] ?? '').toString(),
      progress: (json['progress'] as num?) ?? 0,
      subjectName: (json['subjectName'] ?? '').toString(),
      status: (json['status'] as num?)?.toInt() ?? 0,
    );
  }
}

class LessonCatalog {
  LessonCatalog({
    required this.id,
    required this.title,
    required this.isLeaf,
    required this.children,
  });

  final String id;
  final String title;
  final bool isLeaf;
  final List<LessonCatalog> children;

  factory LessonCatalog.fromJson(Map<String, dynamic> json) {
    final children = json['children'];
    return LessonCatalog(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      isLeaf: json['isLeaf'] == true || children == null || (children is List && children.isEmpty),
      children: children is List
          ? children
              .whereType<Map>()
              .map((e) => LessonCatalog.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <LessonCatalog>[],
    );
  }
}
