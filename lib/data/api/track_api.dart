import 'package:dio/dio.dart';

import '../../core/network/api_exception.dart';

/// 遥测 / 风控接口（复刻 src/utils/track.ts）
class TrackApi {
  TrackApi._();

  static const String trackApi = 'https://tbapi.loshop.com.cn/api';

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      validateStatus: (_) => true,
      headers: const {'Content-Type': 'application/json'},
    ),
  );

  /// 上报一次登录；命中封禁返回 403 + message
  static Future<({bool banned, String? message})> reportLogin(
    String school,
    String username, {
    String deviceId = '',
  }) async {
    if (school.isEmpty || username.isEmpty) return (banned: false, message: null);
    try {
      final response = await _dio.post<dynamic>(
        '$trackApi/login',
        data: {
          'school': school,
          'username': username,
          'deviceId': deviceId,
        },
      );
      if (response.statusCode == 403) {
        final data = response.data;
        final message = data is Map ? (data['message'] ?? '').toString() : '';
        return (
          banned: true,
          message: message.isNotEmpty ? message : '该账号已被管理员封禁',
        );
      }
      return (banned: false, message: null);
    } catch (_) {
      // 上报失败不影响主流程
      return (banned: false, message: null);
    }
  }

  /// 服务器版本配置
  static Future<Map<String, dynamic>?> fetchVersion() async {
    try {
      final response = await _dio.get<dynamic>('$trackApi/version');
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
    } catch (_) {
      /* ignore */
    }
    return null;
  }

  static String errorText(Object? error) {
    if (error is ApiException) return error.message;
    return error?.toString() ?? '未知错误';
  }
}
