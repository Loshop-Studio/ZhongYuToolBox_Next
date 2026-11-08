import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';

/// 测评错题同步接口（复刻 src/utils/examMistakes.ts 里的接口调用）
class ExamMistakeApi {
  ExamMistakeApi._();

  /// 官方题目视图（含 isInMistakeBook / path）
  static Future<List<Map<String, dynamic>>> officialView(
    int examId,
    int questionId, {
    bool related = false,
  }) async {
    final endpoint = related ? 'GetRelatedQstViewAsync' : 'GetQuestionViewAsync';
    final param = related ? 'relatedGroupId' : 'questionId';
    final data = await ApiClient.instance.request(
      '/api/services/app/Task/$endpoint',
      query: {'examId': examId, param: questionId},
    );
    final result = data is Map && data.containsKey('result') ? data['result'] : data;
    if (related) {
      if (result is List) {
        return result.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return <Map<String, dynamic>>[];
    }
    if (result is Map) return <Map<String, dynamic>>[Map<String, dynamic>.from(result)];
    if (result is List) {
      return result.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return <Map<String, dynamic>>[];
  }

  /// 加入官方错题本
  static Future<void> addToMistakeBook({
    required int examId,
    required int questionId,
    required bool isRelatedGroup,
    required String stemShoot,
  }) async {
    await ApiClient.instance.request(
      '/api/services/app/MistakeBook/AddInMistakeBookAsync',
      method: 'POST',
      data: jsonEncode({
        'examId': examId,
        'isRelatedGroup': isRelatedGroup,
        'questionId': questionId,
        'extraStems': <dynamic>[],
        'stemShoot': stemShoot,
        'diff': null,
        'attainedLevel': null,
        'errorReason': null,
        'tagIdList': <dynamic>[],
      }),
    );
  }

  /// 导出客观题答案（xlsx）
  static Future<Uint8List> exportObjectiveAnswers(int examId) async {
    final resp = await ApiClient.instance.dio.get<dynamic>(
      ApiClient.instance.resolveUrl(
        '/api/services/app/Exam/ExportObjectiveAnswersAsync',
        null,
      ),
      queryParameters: {'examId': examId},
      options: Options(
        headers: const {'AppName': 'WebClient', 'AppVersion': '0'},
        responseType: ResponseType.bytes,
        validateStatus: (_) => true,
      ),
    );
    final data = resp.data;
    if (data is List<int>) return Uint8List.fromList(data);
    throw ApiException('导出失败：${resp.statusCode}');
  }
}
