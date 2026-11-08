/// 测评任务（字段名各校/各版本略有差异，统一从 raw 里兜底取）
class ExamTask {
  ExamTask({required this.id, required this.name, required this.state, required this.raw});

  final int id;
  final String name;

  /// 任务状态（1 未开始 / 2 进行中 / 3 已结束，具体以接口为准）
  final int state;
  final Map<String, dynamic> raw;

  bool get finished => state == 3;

  String get createTime =>
      (raw['creationTime'] ?? raw['createTime'] ?? raw['publishTime'] ?? '').toString();

  String get subject =>
      (raw['subjectName'] ?? raw['subject'] ?? raw['courseName'] ?? '').toString();

  factory ExamTask.fromJson(Map<String, dynamic> json) {
    final rawId = json['examTaskId'] ??
        json['testPagerId'] ??
        json['examId'] ??
        json['id'] ??
        0;
    return ExamTask(
      id: rawId is num ? rawId.toInt() : int.tryParse(rawId.toString()) ?? 0,
      name: (json['examName'] ?? json['name'] ?? json['title'] ?? '未命名测评').toString(),
      state: (json['examState'] as num?)?.toInt() ?? (json['state'] as num?)?.toInt() ?? 0,
      raw: json,
    );
  }
}

/// 题目（从 examTask.groups[].questions[] 中拍平）
class ExamQuestion {
  ExamQuestion({required this.id, required this.raw});

  final int id;
  final Map<String, dynamic> raw;

  factory ExamQuestion.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['qstId'] ?? 0;
    return ExamQuestion(
      id: rawId is num ? rawId.toInt() : int.tryParse(rawId.toString()) ?? 0,
      raw: json,
    );
  }
}
