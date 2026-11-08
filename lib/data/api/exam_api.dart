import 'dart:convert';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/exam.dart';

/// 测评接口（复刻 src/api/exam.ts）
class ExamApi {
  ExamApi._();

  static const int pageSize = 20;

  static const Map<String, String> _webHeaders = {
    'AppName': 'WebClient',
    'AppVersion': '0',
  };

  static dynamic _unwrap(dynamic data) {
    if (data is Map && data.containsKey('result')) return data['result'];
    return data;
  }

  /// 学生测评任务列表
  /// taskListType：4 已完成作业 / 1 待处理作业 / 2 全部作业
  static Future<({List<ExamTask> items, int total})> getTasks(
    int page, {
    int taskListType = 4,
  }) async {
    final data = await ApiClient.instance.request(
      '/api/services/app/Task/GetStudentTaskListAsync',
      method: 'POST',
      data: jsonEncode({
        'maxResultCount': pageSize,
        'skipCount': (page - 1) * pageSize,
        'taskListType': taskListType,
      }),
    );
    final result = _unwrap(data);
    if (result is! Map) return (items: <ExamTask>[], total: 0);
    final items = result['items'];
    return (
      items: items is List
          ? items
              .whereType<Map>()
              .map((e) => ExamTask.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <ExamTask>[],
      total: (result['totalCount'] as num?)?.toInt() ?? 0,
    );
  }

  /// 测评详情（含 groups[].questions[]）
  static Future<Map<String, dynamic>> getTask(int examId) async {
    if (examId <= 0) throw ApiException('无效的测评编号');
    final data = await ApiClient.instance
        .request('/api/services/app/Task/GetExamTaskAsync', query: {'id': examId});
    final result = _unwrap(data);
    return result is Map ? Map<String, dynamic>.from(result) : <String, dynamic>{};
  }

  static Future<Map<String, dynamic>> getOverview(int examId) async {
    if (examId <= 0) throw ApiException('无效的测评编号');
    final data = await ApiClient.instance.request(
      '/api/services/app/LearningSituations/GetExamOverviewAsync',
      query: {'examId': examId},
      headers: _webHeaders,
    );
    final result = _unwrap(data);
    return result is Map ? Map<String, dynamic>.from(result) : <String, dynamic>{};
  }

  static Future<Map<String, dynamic>> getQuestionAnalysis(int examId) async {
    if (examId <= 0) throw ApiException('无效的测评编号');
    final data = await ApiClient.instance.request(
      '/api/services/app/LearningSituations/GetQuestionAnalysisAsync',
      query: {'examId': examId},
      headers: _webHeaders,
    );
    final result = _unwrap(data);
    return result is Map ? Map<String, dynamic>.from(result) : <String, dynamic>{};
  }

  /// 单题 HTML（含解析）
  static Future<String> getQuestionHtml(int qstId) async {
    if (qstId <= 0) throw ApiException('无效的题目编号');
    return ApiClient.instance
        .getText('/Question/View/$qstId?showAnalysis=true');
  }

  /// 从任务详情中拍平题目
  static List<ExamQuestion> questionsOf(Map<String, dynamic> task) {
    final groups = task['groups'];
    final result = <ExamQuestion>[];
    if (groups is List) {
      for (final group in groups) {
        if (group is Map) {
          final questions = group['questions'];
          if (questions is List) {
            result.addAll(questions.whereType<Map>().map(
                  (e) => ExamQuestion.fromJson(Map<String, dynamic>.from(e)),
                ));
          }
        }
      }
    }
    return result.where((e) => e.id > 0).toList();
  }
}
