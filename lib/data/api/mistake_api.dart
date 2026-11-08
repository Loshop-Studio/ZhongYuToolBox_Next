import 'dart:convert';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/util/urls.dart';
import '../models/mistake.dart';

/// 错题本接口（复刻 src/api/mistake.ts）
class MistakeApi {
  MistakeApi._();

  static Future<List<MistakeBook>> getMyBooks() async {
    final data = await ApiClient.instance
        .request('/api/services/app/MistakeBook/GetMyMistakeBooksAsync');
    final result = data is Map ? data['result'] : null;
    if (result is! List) return <MistakeBook>[];
    return result
        .whereType<Map>()
        .map((e) => MistakeBook.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<({List<MistakeItem> items, int total})> searchItems(
    String bookId, {
    int skipCount = 0,
    int maxResultCount = 200,
  }) async {
    final data = await ApiClient.instance.request(
      '/api/services/app/MistakeBook/SearchMistakeQstItemsAsync',
      method: 'POST',
      data: jsonEncode({
        'attainedLevel': <dynamic>[],
        'bookId': bookId,
        'diff': <dynamic>[],
        'errorReason': <dynamic>[],
        'haveNoTag': false,
        'maxResultCount': maxResultCount,
        'skipCount': skipCount,
        'tagIdList': <dynamic>[],
      }),
    );
    final result = data is Map ? data['result'] : null;
    if (result is! Map) return (items: <MistakeItem>[], total: 0);
    final items = result['items'];
    return (
      items: items is List
          ? items
              .whereType<Map>()
              .map((e) => MistakeItem.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <MistakeItem>[],
      total: (result['totalCount'] as num?)?.toInt() ?? 0,
    );
  }

  static Future<MistakeDetail?> getDetail(String itemId) async {
    final data = await ApiClient.instance.request(
      '/api/services/app/MistakeBook/GetMistakeQstItemDetailInfoAsync',
      query: {'itemId': itemId},
    );
    final result = data is Map ? data['result'] : null;
    if (result is! Map) return null;
    return MistakeDetail.fromJson(Map<String, dynamic>.from(result));
  }

  static Future<void> removeItems(String bookId, List<String> itemIds) async {
    if (itemIds.isEmpty) throw ApiException('请先选择错题');
    await ApiClient.instance.request(
      '/api/services/app/MistakeBook/MultiRemoveMistakeItemsAsync',
      method: 'POST',
      headers: const {'AppName': 'WebClient', 'AppVersion': '0'},
      data: jsonEncode({'bookId': bookId, 'itemIds': itemIds}),
    );
  }

  /// 笔记截图：fileList.json → screenshot.png
  static Future<String?> fetchNoteScreenshot(String noteUrl) async {
    if (noteUrl.isEmpty) return null;
    try {
      final base = ApiClient.instance.defaultBaseUrl;
      final resolved = resolveApiUrl(noteUrl, base);
      final data = await ApiClient.instance.request(resolved);
      if (data is! List) return null;
      for (final entry in data) {
        if (entry is! Map) continue;
        final url = (entry['url'] ?? '').toString();
        if (url.toLowerCase().endsWith('screenshot.png')) {
          return resolveApiUrl(url, base);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 题目 HTML（qstPath 可能是相对路径）
  static Future<String> fetchQuestionHtml(String qstPath) async {
    if (qstPath.isEmpty) throw ApiException('题目地址为空');
    final base = ApiClient.instance.defaultBaseUrl;
    var uri = Uri.parse(resolveApiUrl(qstPath, base));
    uri = uri.replace(queryParameters: {
      ...uri.queryParameters,
      'showAnalysis': 'true',
    });
    return ApiClient.instance.getText(uri.toString());
  }
}
