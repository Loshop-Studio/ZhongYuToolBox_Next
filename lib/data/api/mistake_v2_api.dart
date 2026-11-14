import 'dart:convert';

import '../../core/network/api_client.dart';
import '../../data/models/mistake_v2.dart';

class MistakeV2Api {
  MistakeV2Api._();

  static Future<List<MistakeTopic>> getTopics() async {
    final data = await ApiClient.instance.request(
      '/api/services/app/MistakeBook/GetMistakeBookFilterOptionsAsync',
    );
    final result = data is Map ? data['result'] : null;
    final topics = result is Map ? result['topics'] : null;
    if (topics is! List) return const [];
    return topics
        .whereType<Map>()
        .map((e) => MistakeTopic.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<({List<MistakeItemV2> items, int total})> search({
    List<int> topicIds = const [],
    int skipCount = 0,
    int maxResultCount = 30,
  }) async {
    final data = await ApiClient.instance.request(
      '/api/services/app/MistakeBook/SearchMistakeQstItemsAsync',
      method: 'POST',
      data: jsonEncode({
        'attainedLevel': [],
        'diff': [],
        'errorReason': [],
        'haveNoTag': false,
        'maxResultCount': maxResultCount,
        'skipCount': skipCount,
        'tagIdList': [],
        'timeType': 0,
        'topicIds': topicIds,
      }),
    );
    final result = data is Map ? data['result'] : null;
    if (result is! Map) return (items: const <MistakeItemV2>[], total: 0);
    final rows = result['items'];
    return (
      items: rows is List
          ? rows
                .whereType<Map>()
                .map(
                  (e) => MistakeItemV2.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const <MistakeItemV2>[],
      total: (result['totalCount'] as num?)?.toInt() ?? 0,
    );
  }

  static Future<Map<String, dynamic>?> getDetail(
    String itemId, {
    required bool custom,
  }) async {
    final data = await ApiClient.instance.request(
      custom
          ? '/api/services/app/MistakeBook/GetCustomMistakeQstItemDetailInfoAsync'
          : '/api/services/app/MistakeBook/GetMistakeQstItemDetailInfoAsync',
      query: {'itemId': itemId},
    );
    final result = data is Map ? data['result'] : null;
    return result is Map ? Map<String, dynamic>.from(result) : null;
  }

  static Future<Map<String, dynamic>?> getReviewHome() async {
    final data = await ApiClient.instance.request(
      '/api/services/app/MistakeReview/GetReviewHomeAsync',
    );
    final result = data is Map ? data['result'] : null;
    return result is Map ? Map<String, dynamic>.from(result) : null;
  }

  static Future<List<Map<String, dynamic>>> getCollections() async {
    final data = await ApiClient.instance.request(
      '/api/services/app/MistakeCollection/GetMyCollectionsAsync',
    );
    final result = data is Map ? data['result'] : null;
    final rows = result is Map ? result['items'] : null;
    if (rows is! List) return const [];
    return rows
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static Future<({List<MistakeItemV2> items, int total})> getCollectionItems(
    String collectionId, {
    int skipCount = 0,
    int maxResultCount = 30,
  }) async {
    final data = await ApiClient.instance.request(
      '/api/services/app/MistakeCollection/GetCollectionItemsAsync',
      method: 'POST',
      data: jsonEncode({
        'collectionId': int.tryParse(collectionId) ?? 0,
        'maxResultCount': maxResultCount,
        'skipCount': skipCount,
        'sortDirection': 1,
        'sortType': 0,
      }),
    );
    final result = data is Map ? data['result'] : null;
    if (result is! Map) return (items: const <MistakeItemV2>[], total: 0);
    final rows = result['items'];
    return (
      items: rows is List
          ? rows
                .whereType<Map>()
                .map(
                  (e) => MistakeItemV2.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const <MistakeItemV2>[],
      total: (result['totalCount'] as num?)?.toInt() ?? 0,
    );
  }

  static Future<void> createCollection(String name) async {
    await ApiClient.instance.request(
      '/api/services/app/MistakeCollection/CreateOrUpdateAsync',
      method: 'POST',
      data: jsonEncode({'id': 0, 'name': name}),
    );
  }

  static Future<void> addItemsToCollections({
    required List<int> collectionIds,
    required List<int> itemIds,
  }) async {
    if (collectionIds.isEmpty || itemIds.isEmpty) return;
    await ApiClient.instance.request(
      '/api/services/app/MistakeCollection/SyncItemsToCollectionsAsync',
      method: 'POST',
      data: jsonEncode({'collectionIds': collectionIds, 'itemIds': itemIds}),
    );
  }

  static Future<void> removeItemsFromCollection({
    required int collectionId,
    required List<int> itemIds,
  }) async {
    if (itemIds.isEmpty) return;
    await ApiClient.instance.request(
      '/api/services/app/MistakeCollection/RemoveItemsFromCollectionAsync',
      method: 'POST',
      data: jsonEncode({'collectionId': collectionId, 'itemIds': itemIds}),
    );
  }
}
