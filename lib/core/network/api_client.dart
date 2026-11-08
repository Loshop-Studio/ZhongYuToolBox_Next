import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/session_manager.dart';
import 'api_exception.dart';

/// 统一请求层（复刻 src/utils/request.ts）
///
/// - 自动注入 `Authorization: Bearer <token>`
/// - 业务地址默认使用当前登录学校的 apiBaseUrl
/// - 401 时先 refreshToken，失败再用本地凭据自动重登，最后重试一次
class ApiClient {
  ApiClient._() {
    dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 40),
        sendTimeout: const Duration(seconds: 40),
        responseType: ResponseType.json,
        validateStatus: (_) => true,
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  static final ApiClient instance = ApiClient._();

  late final Dio dio;

  String get defaultBaseUrl {
    final base = SessionManager.instance.session.apiBaseUrl;
    return base.isNotEmpty ? base : AppConfig.defaultApiBaseUrl;
  }

  String resolveUrl(String path, String? baseUrl) {
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final base = (baseUrl != null && baseUrl.isNotEmpty) ? baseUrl : defaultBaseUrl;
    final cleaned = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final suffix = path.startsWith('/') ? path : '/$path';
    return '$cleaned$suffix';
  }

  Future<dynamic> request(
    String path, {
    String method = 'GET',
    Object? data,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    String? baseUrl,
    bool skipAuth = false,
    bool skipRecover = false,
  }) async {
    final session = SessionManager.instance.session;
    final url = resolveUrl(path, baseUrl);

    final finalHeaders = <String, String>{
      'Content-Type': 'application/json',
      if (!skipAuth && session.token.isNotEmpty)
        'Authorization': 'Bearer ${session.token}',
      ...?headers,
    };

    final response = await _send(url, method, data, query, finalHeaders);

    if (response.statusCode == 401 && !skipAuth && !skipRecover) {
      final recovered = await SessionManager.instance.recoverSession();
      if (recovered) {
        return request(
          path,
          method: method,
          data: data,
          query: query,
          headers: headers,
          baseUrl: baseUrl,
          skipAuth: skipAuth,
          skipRecover: true,
        );
      }
      await SessionManager.instance.clearSession();
      throw ApiException('登录已过期，请重新登录', statusCode: 401);
    }

    final status = response.statusCode ?? 0;
    if (status >= 400) {
      throw ApiException(_extractMessage(response) ?? '请求失败: $status', statusCode: status);
    }

    return response.data;
  }

  Future<Response<dynamic>> _send(
    String url,
    String method,
    Object? data,
    Map<String, dynamic>? query,
    Map<String, String> headers,
  ) async {
    try {
      return await dio.request<dynamic>(
        url,
        data: data,
        queryParameters: query,
        options: Options(method: method, headers: headers, validateStatus: (_) => true),
      );
    } on DioException catch (e) {
      throw ApiException(_dioMessage(e));
    }
  }

  /// 读取原始文本（题目 HTML 等）
  Future<String> getText(
    String path, {
    String? baseUrl,
    Map<String, String>? headers,
    bool skipAuth = false,
  }) async {
    final session = SessionManager.instance.session;
    final url = resolveUrl(path, baseUrl);
    final finalHeaders = <String, String>{
      if (!skipAuth && session.token.isNotEmpty)
        'Authorization': 'Bearer ${session.token}',
      ...?headers,
    };
    try {
      final resp = await dio.get<dynamic>(
        url,
        options: Options(
          headers: finalHeaders,
          responseType: ResponseType.plain,
          validateStatus: (_) => true,
        ),
      );
      if ((resp.statusCode ?? 0) >= 400) {
        throw ApiException('请求失败: ${resp.statusCode}', statusCode: resp.statusCode);
      }
      return resp.data?.toString() ?? '';
    } on DioException catch (e) {
      throw ApiException(_dioMessage(e));
    }
  }

  String? _extractMessage(Response<dynamic> response) {
    final data = response.data;
    if (data is Map) {
      final error = data['error'];
      if (error is Map && error['message'] != null) return error['message'].toString();
      if (data['message'] != null) return data['message'].toString();
      if (data['msg'] != null) return data['msg'].toString();
    }
    if (data is String && data.trim().isNotEmpty) return data.trim();
    return null;
  }

  String _dioMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '网络超时，请稍后重试';
      case DioExceptionType.connectionError:
        return '网络连接失败，请检查网络';
      case DioExceptionType.badCertificate:
        return '证书校验失败';
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.badResponse:
        return '请求失败: ${e.response?.statusCode}';
      default:
        return e.message ?? '网络请求失败';
    }
  }
}
