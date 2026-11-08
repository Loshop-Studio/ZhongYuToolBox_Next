import 'dart:convert';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/picture.dart';

/// 图库接口（复刻 src/api/picture.ts）
class PictureApi {
  PictureApi._();

  static const Map<String, String> _manageHeaders = {
    'Accept': 'application/json',
    'AppName': 'com.zykj.manage',
    'AppVersion': '32',
  };

  static Future<({List<PictureItem> items, int total})> getPictures({
    bool recycle = false,
    int skip = 0,
    int maxResultCount = 30,
  }) async {
    final data = await ApiClient.instance.request(
      '/api/services/app/PictureLibrary/GetAllPicturesFromLibrary',
      query: {
        'SkipCount': skip,
        'MaxResultCount': maxResultCount,
        'IsRecycleBin': recycle,
      },
    );
    final result = data is Map ? data['result'] : null;
    if (result is! Map) return (items: <PictureItem>[], total: 0);
    final items = result['items'];
    return (
      items: items is List
          ? items
              .whereType<Map>()
              .map((e) => PictureItem.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <PictureItem>[],
      total: (result['totalCount'] as num?)?.toInt() ?? 0,
    );
  }

  /// 上传后登记图片（picture 为 OSS 地址，name 为 nonce，size 为大小文案）
  static Future<void> addPicture(String picture, String name, String size) async {
    await ApiClient.instance.request(
      '/api/services/app/PictureLibrary/AddPictureAsync',
      method: 'POST',
      headers: _manageHeaders,
      data: jsonEncode({'picture': picture, 'name': name, 'size': size}),
    );
  }

  static Future<void> moveToRecycleBin(List<String> ids) async {
    if (ids.isEmpty) throw ApiException('请先选择图片');
    await ApiClient.instance.request(
      '/api/services/app/PictureLibrary/MoveToRecycleBinAsync',
      method: 'POST',
      headers: _manageHeaders,
      data: jsonEncode(ids),
    );
  }

  static Future<void> deletePermanently(List<String> ids) async {
    if (ids.isEmpty) throw ApiException('请先选择图片');
    final query = ids.map((e) => 'ids=${Uri.encodeQueryComponent(e)}').join('&');
    await ApiClient.instance.request(
      '/api/services/app/PictureLibrary/DeletePicture?$query',
      method: 'DELETE',
      headers: _manageHeaders,
    );
  }
}
