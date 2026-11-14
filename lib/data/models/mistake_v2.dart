class MistakeTopic {
  const MistakeTopic({
    required this.id,
    required this.name,
    required this.count,
  });

  final int id;
  final String name;
  final int count;

  factory MistakeTopic.fromJson(Map<String, dynamic> json) => MistakeTopic(
    id: (json['topicId'] as num?)?.toInt() ?? 0,
    name: (json['topicName'] ?? '').toString(),
    count: (json['totalQstCount'] as num?)?.toInt() ?? 0,
  );
}

class MistakeItemV2 {
  const MistakeItemV2({
    required this.id,
    required this.topicName,
    required this.source,
    required this.title,
    required this.examName,
    required this.number,
    required this.stemShoot,
    required this.creationTime,
    required this.raw,
  });

  final String id;
  final String topicName;
  final String? source;
  final String? title;
  final String? examName;
  final String? number;
  final String stemShoot;
  final String creationTime;
  final Map<String, dynamic> raw;

  bool get isCustom => source == null || source!.isEmpty;
  String get displayTitle => (source?.trim().isNotEmpty ?? false)
      ? source!.trim()
      : (title?.trim().isNotEmpty ?? false)
      ? title!.trim()
      : '自定义错题';

  factory MistakeItemV2.fromJson(Map<String, dynamic> json) => MistakeItemV2(
    id: (json['id'] ?? '').toString(),
    topicName: (json['topicName'] ?? '').toString(),
    source: json['source']?.toString(),
    title: json['title']?.toString(),
    examName: json['examName']?.toString(),
    number: json['number']?.toString(),
    stemShoot: (json['stemShoot'] ?? '').toString(),
    creationTime: (json['creationTime'] ?? '').toString(),
    raw: json,
  );
}
