import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'plugin_source_models.dart';

/// Downloads and parses plugin catalogs without attaching the user's session
/// token. Catalogs and plugin packages are public source artifacts.
class PluginSourceService {
  PluginSourceService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 60),
              sendTimeout: const Duration(seconds: 30),
              followRedirects: true,
              validateStatus: (_) => true,
            ),
          );

  static final PluginSourceService instance = PluginSourceService();

  final Dio _dio;

  Future<PluginIndexDocument> fetchIndex(
    PluginIndexSource source, {
    int sourceOrder = 0,
  }) async {
    final uri = _validateHttpUrl(source.url);
    final response = await _dio.get<Object?>(
      _cacheBustedUrl(uri).toString(),
      options: Options(responseType: ResponseType.plain),
    );
    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      throw StateError('索引源请求失败（HTTP $status）：${source.url}');
    }
    final data = response.data;
    if (data == null) throw StateError('索引源返回为空：${source.url}');
    return parsePluginIndex(
      source,
      data is String ? data : data.toString(),
      sourceOrder: sourceOrder,
    );
  }

  /// Reads optional `${uuid}/detail.txt` metadata. A missing or empty file is
  /// normal for older sources; other HTTP failures remain visible to callers.
  Future<PluginIndexDetail?> fetchDetail(PluginIndexEntry entry) async {
    final uri = _validateHttpUrl(entry.detailUrl);
    final response = await _dio.get<Object?>(
      uri.toString(),
      options: Options(responseType: ResponseType.plain),
    );
    final status = response.statusCode ?? 0;
    if (status == 404 || status == 204) return null;
    if (status < 200 || status >= 300) {
      throw StateError('插件详情请求失败（HTTP $status）：${entry.detailUrl}');
    }
    final data = response.data;
    if (data == null || data.toString().trim().isEmpty) return null;
    final detail = parsePluginIndexDetail(
      data is String ? data : data.toString(),
    );
    return detail.isEmpty ? null : detail;
  }

  Future<Uint8List> downloadPlugin(PluginIndexEntry entry) async {
    final uri = _validateHttpUrl(entry.downloadUrl);
    final response = await _dio.get<List<int>>(
      uri.toString(),
      options: Options(responseType: ResponseType.bytes),
    );
    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      throw StateError('插件下载失败（HTTP $status）：${entry.downloadUrl}');
    }
    final data = response.data;
    if (data == null || data.isEmpty) {
      throw StateError('插件下载内容为空：${entry.downloadUrl}');
    }
    return Uint8List.fromList(data);
  }

  Uri _validateHttpUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw FormatException('索引源必须使用 HTTP/HTTPS：$value');
    }
    return uri;
  }

  String _cacheBustedUrl(Uri uri) {
    final query = <String, String>{
      ...uri.queryParameters,
      'v': DateTime.now().millisecondsSinceEpoch.toString(),
    };
    return uri.replace(queryParameters: query).toString();
  }
}
