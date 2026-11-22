import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/network/api_client.dart';
import '../models/quora.dart';

/// 随身答接口（复刻 src/api/quora.ts）
class QuoraApi {
  QuoraApi._();

  static Future<List<QuoraCatalog>> getCatalogs() async {
    final data = await ApiClient.instance.request(
      '/api/services/app/Quora/GetCatalogs',
    );
    _logResponse('GetCatalogs', data);
    final result = data is Map ? data['result'] : null;
    if (result is! List) return <QuoraCatalog>[];
    return result
        .whereType<Map>()
        .map((e) => QuoraCatalog.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<List<QuoraSession>> getSessions({
    String keyword = '',
    int catalogId = 0,
    int topicId = 0,
    int orderBy = 0,
    int skip = 0,
    int take = 20,
    List<int> justWatch = const <int>[],
    String updateStart = '',
    String updateEnd = '',
    String joinStart = '',
    String joinEnd = '',
  }) async {
    final data = await ApiClient.instance.request(
      '/api/services/app/Quora/GetSessions',
      method: 'POST',
      data: jsonEncode({
        'keyword': keyword,
        'catalogId': catalogId,
        'topicId': topicId,
        'orderBy': orderBy,
        'skip': skip,
        'take': take,
        'updateTime': {'start': updateStart, 'end': updateEnd},
        'joinTime': {'start': joinStart, 'end': joinEnd},
        'justWatch': justWatch,
      }),
    );
    _logResponse('GetSessions', data);
    final result = data is Map ? data['result'] : null;
    if (result is! List) return <QuoraSession>[];
    return result
        .whereType<Map>()
        .map((e) => QuoraSession.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<List<QuoraMessage>> getMessages(
    String sessionId, {
    int skip = 0,
    int take = 1000,
  }) async {
    final data = await ApiClient.instance.request(
      '/api/services/app/Quora/GetMessages',
      method: 'POST',
      data: jsonEncode({'SessionId': sessionId, 'Skip': skip, 'Take': take}),
    );
    _logResponse('GetMessages', data);
    final result = data is Map ? data['result'] : null;
    if (result is! List) return <QuoraMessage>[];
    return result
        .whereType<Map>()
        .map((e) => QuoraMessage.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> resetReadState(String sessionId) async {
    final data = await ApiClient.instance.request(
      '/api/services/app/Quora/ResetReadState',
      query: {'sessionId': sessionId},
    );
    _logResponse('ResetReadState', data);
  }

  static Future<void> addMessage({
    required String content,
    required String sessionId,
    String snapshot = '',
  }) async {
    final data = await ApiClient.instance.request(
      '/api/services/app/Quora/AddMessage',
      method: 'POST',
      data: jsonEncode({
        'content': content,
        'sessionId': sessionId,
        'snapshot': snapshot,
      }),
    );
    _logResponse('AddMessage', data);
  }

  static void _logResponse(String endpoint, Object? data) {
    if (!kDebugMode) return;
    String body;
    try {
      body = const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      body = data.toString();
    }
    debugPrint('[QuoraApi.$endpoint] 响应:\n$body', wrapWidth: 1024);
  }
}
