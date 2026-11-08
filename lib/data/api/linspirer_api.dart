import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/crypto/linspirer_crypto.dart';
import '../../core/network/api_exception.dart';
import '../models/linspirer.dart';

/// 领创（Linspirer）接口，复刻旧项目 src/api/linspirer.ts
///
/// 独立于中育功能，仅共享用户名；请求参数 AES-CBC 加密，响应整体加密。
class LinspirerApi {
  LinspirerApi._();

  static const String api =
      'https://cloud.linspirer.com:883/public-interface.php';
  static const String apiBase = 'https://cloud.linspirer.com:883';
  static const String clientVersion = 'zhongyukejiao_hem_6.10.004.6';
  static const String fixedUuid = '40E06F51-30D0-D6AD-7F7D-008AD0ADC570';

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 40),
    ),
  );

  /// JSON-RPC 信封调用（params 加密，响应整体解密）
  static Future<Map<String, dynamic>> call(
    String method,
    Map<String, dynamic> params,
  ) async {
    final envelope = <String, dynamic>{
      'id': 1,
      '!version': 6,
      'jsonrpc': '2.0',
      'is_encrypt': true,
      'client_version': clientVersion,
      'method': method,
      'params': LinspirerCrypto.encrypt(jsonEncode(params)),
    };

    final response = await _dio.post<dynamic>(
      api,
      data: jsonEncode(envelope),
      options: Options(
        contentType: 'application/json',
        responseType: ResponseType.plain,
        validateStatus: (_) => true,
      ),
    );

    final status = response.statusCode ?? 0;
    if (status >= 400) throw ApiException('HTTP $status');

    final text = response.data?.toString().trim() ?? '';
    if (text.isEmpty) throw ApiException('领创接口返回为空');

    Map<String, dynamic> result;
    try {
      result =
          jsonDecode(LinspirerCrypto.decrypt(text)) as Map<String, dynamic>;
    } catch (_) {
      try {
        final plain = jsonDecode(text);
        if (plain is Map) {
          result = Map<String, dynamic>.from(plain);
        } else {
          throw const FormatException('not a map');
        }
      } catch (_) {
        throw ApiException('领创响应解析失败');
      }
    }

    final code = result['code'];
    if (code != null && code != 0) {
      throw ApiException(
        (result['msg'] ?? result['message'] ?? '领创接口错误').toString(),
      );
    }
    return result;
  }

  /// 绑定设备
  static Future<void> bindDevice(
    String swdid,
    String account,
    String model,
  ) async {
    await call('com.linspirer.device.setdevice', <String, dynamic>{
      'brand': '',
      'deviceid': '',
      'email': account,
      'isrooted': false,
      'model': model,
      'romavailablesize': 0,
      'romtotalsize': 0,
      'romversion': '',
      'simserialnumber': 'unknown',
      'swdid': swdid,
      'systemversion': '',
      'token': '',
      'wifimacaddress': '',
    });
  }

  /// 策略应用 + 兴趣应用
  static Future<List<LinspirerApp>> getAllApps(
    String swdid,
    String account,
    String model,
  ) async {
    final result = await call(
      'com.linspirer.tactics.gettactics',
      <String, dynamic>{
        'swdid': swdid,
        'email': account,
        'model': model,
        'launcher_version': clientVersion,
      },
    );
    final data = result['data'];
    final list = <LinspirerApp>[];
    if (data is Map) {
      final tactics = data['app_tactics'];
      if (tactics is Map && tactics['applist'] is List) {
        for (final item in tactics['applist'] as List) {
          if (item is Map) {
            list.add(
              LinspirerApp.fromJson(
                Map<String, dynamic>.from(item),
                source: '策略应用',
              ),
            );
          }
        }
      }
      if (data['interest_applist'] is List) {
        for (final item in data['interest_applist'] as List) {
          if (item is Map) {
            list.add(
              LinspirerApp.fromJson(
                Map<String, dynamic>.from(item),
                source: '兴趣应用',
              ),
            );
          }
        }
      }
    }
    return list;
  }

  /// 应用详情
  static Future<LinspirerAppDetail> getAppDetail(
    String swdid,
    String account,
    String model,
    String appId,
  ) async {
    final result = await call('com.linspirer.app.getdetail', <String, dynamic>{
      'swdid': swdid,
      'email': account,
      'model': model,
      'launcher_version': clientVersion,
      'appid': appId,
    });
    final data = result['data'];
    return LinspirerAppDetail.fromJson(
      data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{},
    );
  }

  /// 用户信息（密码计算需要 studentId）
  static Future<String?> getUserStudentId(
    String swdid,
    String account,
    String model,
  ) async {
    try {
      final result =
          await call('com.linspirer.user.getuserinfo', <String, dynamic>{
            'swdid': swdid,
            'email': account,
            'model': model,
            'launcher_version': clientVersion,
          });
      final data = result['data'];
      if (data is Map && data['id'] != null) return data['id'].toString();
    } catch (_) {
      // 取不到 studentId 时退化为不带 sid 计算
    }
    return null;
  }

  /// 计算管理员密码（联网：必要时先取 studentId）
  static Future<String> calcPassword(
    String swdid,
    String account,
    String model, {
    String? studentId,
  }) async {
    final id = swdid.trim().toLowerCase();
    if (id.isEmpty || id == 'unknown') return 'unknown';
    var sid = studentId;
    if (sid == null || sid.isEmpty) {
      sid = await getUserStudentId(id, account, model);
    }
    final now = DateTime.now();
    final date = '${now.year}${_two(now.month)}${_two(now.day)}';
    var seed = '$date$id$fixedUuid';
    if (sid != null && sid.isNotEmpty) seed += sid;
    final hex = LinspirerCrypto.md5(seed);
    final last8 = hex.substring(hex.length - 8);
    var dec = int.parse(last8, radix: 16).toString();
    if (dec.length > 8) dec = dec.substring(dec.length - 8);
    return dec.length >= 6 ? dec.substring(0, 6) : 'unknown';
  }

  static String _two(int value) => value.toString().padLeft(2, '0');

  /// 静态资源代理（cloud.linspirer.com 的资源走 883）
  static String proxyUrl(String url) {
    if (url.isEmpty) return url;
    return url
        .replaceAll('http://cloud.linspirer.com:880', apiBase)
        .replaceAll('https://cloud.linspirer.com:883', apiBase);
  }
}
