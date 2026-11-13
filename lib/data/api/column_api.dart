import 'dart:convert';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/column.dart';

/// 在线专栏接口（复刻 src/api/column.ts）
class ColumnApi {
  ColumnApi._();

  static dynamic _unwrap(dynamic data) {
    if (data is Map && data.containsKey('result')) return data['result'];
    return data;
  }

  static const Map<String, String> _webClientHeaders = <String, String>{
    'AppName': 'WebClient',
    'AppVersion': '0',
    'ClientCode': 'null',
  };

  static void _ensureSuccess(dynamic data) {
    if (data is! Map || data['success'] != false) return;
    final error = data['error'];
    final message = error is Map ? error['message'] : null;
    throw ApiException(message?.toString() ?? '操作失败，请稍后重试');
  }

  static String _validateMessage(String message) {
    final value = message.trim();
    if (value.isEmpty) throw ApiException('内容不能为空');
    if (value.runes.length > 100) throw ApiException('内容不能超过 100 字');
    return value;
  }

  /// 学科 + 专栏树
  static Future<List<TopicSpecial>> getTopicSpecial() async {
    final data = await ApiClient.instance
        .request('/api/services/app/appWebSite/GetTopicSpecialAsync');
    final result = _unwrap(data);
    if (result is! List) return <TopicSpecial>[];
    return result
        .whereType<Map>()
        .map((e) => TopicSpecial.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// 专栏里的文章（pageTitle 非空即为搜索）
  static Future<({List<ColumnPageItem> items, int total})> searchPagesByColId(
    int colId, {
    String pageTitle = '',
    int skipCount = 0,
    int maxResultCount = 20,
    String orderBy = 'PublishTime',
  }) async {
    final body = <String, dynamic>{
      'colId': colId,
      'skipCount': skipCount,
      'maxResultCount': maxResultCount,
      'orderBy': orderBy,
    };
    if (pageTitle.trim().isNotEmpty) body['pageTitle'] = pageTitle.trim();

    final data = await ApiClient.instance.request(
      '/api/services/app/appWebSite/SearchMyPagesByColIdAsync',
      method: 'POST',
      data: jsonEncode(body),
    );
    final result = _unwrap(data);
    if (result is! Map) return (items: <ColumnPageItem>[], total: 0);
    final items = result['items'];
    return (
      items: items is List
          ? items
              .whereType<Map>()
              .map((e) => ColumnPageItem.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <ColumnPageItem>[],
      total: (result['totalCount'] as num?)?.toInt() ?? 0,
    );
  }

  static Future<ColumnPageDetail> getPageDetail(int id) async {
    final data = await ApiClient.instance.request(
      '/api/services/app/appWebSite/GetPageAsync',
      query: {'id': id},
    );
    final result = _unwrap(data);
    final map = result is Map ? Map<String, dynamic>.from(result) : <String, dynamic>{};
    return ColumnPageDetail.fromJson(map);
  }

  static Future<void> hitPage(int pageId) async {
    await ApiClient.instance.request(
      '/api/services/app/AppWebSite/HitAsync',
      method: 'POST',
      query: {'pageId': pageId},
    );
  }

  /// 专栏文章评论，公开评论与我的评论共用同一个分页接口。
  static Future<({List<ColumnComment> items, int total})> getPageComments(
    int pageId, {
    required bool publicOnly,
    required bool myOnly,
    int skipCount = 0,
    int maxResultCount = 20,
  }) async {
    final data = await ApiClient.instance.request(
      '/api/services/app/appWebSite/GetPagedCommentsAndRepliesAsync',
      method: 'POST',
      headers: _webClientHeaders,
      data: jsonEncode({
        'pageId': pageId,
        'publicOnly': publicOnly,
        'skipCount': skipCount,
        'maxResultCount': maxResultCount,
        'myOnly': myOnly,
      }),
    );
    _ensureSuccess(data);
    final result = _unwrap(data);
    if (result is! Map) return (items: <ColumnComment>[], total: 0);
    final items = result['items'];
    return (
      items: items is List
          ? items
                .whereType<Map>()
                .map(
                  (e) => ColumnComment.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : <ColumnComment>[],
      total: (result['totalCount'] as num?)?.toInt() ?? 0,
    );
  }

  static Future<void> createPageComment(int pageId, String content) async {
    final data = await ApiClient.instance.request(
      '/api/services/app/appWebSite/CreateCommentAsync',
      method: 'POST',
      headers: _webClientHeaders,
      data: jsonEncode({
        'specialPageId': pageId,
        'content': _validateMessage(content),
      }),
    );
    _ensureSuccess(data);
  }

  static Future<void> replyPageComment(int commentId, String reply) async {
    final data = await ApiClient.instance.request(
      '/api/services/app/appWebSite/ReplyCommentAsync',
      method: 'POST',
      headers: _webClientHeaders,
      data: jsonEncode({
        'commentId': commentId,
        'reply': _validateMessage(reply),
      }),
    );
    _ensureSuccess(data);
  }

  /// 我的收藏夹
  static Future<List<ColumnCatalog>> getSpecialCatalog() async {
    final data = await ApiClient.instance
        .request('/api/services/app/AppWebSite/GetSpecialCatalogAsync');
    final result = _unwrap(data);
    if (result is! List) return <ColumnCatalog>[];
    return result
        .whereType<Map>()
        .map((e) => ColumnCatalog.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// 收藏夹里的文章
  static Future<({List<CatalogPageItem> items, int total})> getMyCatalogPages(
    int catalogId, {
    int skipCount = 0,
    int maxResultCount = 20,
  }) async {
    final data = await ApiClient.instance.request(
      '/api/services/app/AppWebSite/GetMyCatalogPagesAsync',
      query: {
        'catalogId': catalogId,
        'maxResultCount': maxResultCount,
        'skipCount': skipCount,
      },
    );
    final result = _unwrap(data);
    if (result is! Map) return (items: <CatalogPageItem>[], total: 0);
    final items = result['items'];
    return (
      items: items is List
          ? items
              .whereType<Map>()
              .map((e) => CatalogPageItem.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <CatalogPageItem>[],
      total: (result['totalCount'] as num?)?.toInt() ?? 0,
    );
  }

  /// 文章更新消息
  static Future<({List<AppMessage> items, int total})> getMyMessageList({
    int type = 2,
    int skipCount = 0,
    int maxResultCount = 20,
  }) async {
    final data = await ApiClient.instance.request(
      '/api/services/app/Message/GetMyMessageListAsync',
      method: 'POST',
      data: jsonEncode({
        'Type': type,
        'skipCount': skipCount,
        'MaxResultCount': maxResultCount,
      }),
    );
    final result = _unwrap(data);
    if (result is! Map) return (items: <AppMessage>[], total: 0);
    final items = result['items'];
    return (
      items: items is List
          ? items
              .whereType<Map>()
              .map((e) => AppMessage.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <AppMessage>[],
      total: (result['totalCount'] as num?)?.toInt() ?? 0,
    );
  }

  /// 标记单条消息已读
  static Future<void> setMessageRead(String messageId) async {
    await ApiClient.instance.request(
      '/api/services/app/Message/SetMessageReadAsync',
      method: 'POST',
      query: {'messageId': messageId},
    );
  }

  /// 公告详情内容（原生侧再 base64 注入到 webview 的 window.notificationContent）
  static Future<NoticeDetail> getNotice(int id) async {
    final data = await ApiClient.instance.request(
      '/api/services/app/Notice/GetNoticeAsync',
      query: {'id': id},
    );
    final result = _unwrap(data);
    final map = result is Map ? Map<String, dynamic>.from(result) : <String, dynamic>{};
    return NoticeDetail.fromJson(map);
  }
}
