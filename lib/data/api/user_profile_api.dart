import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart' as pc;

import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/user_profile.dart';

/// zytbapi 个人资料接口。
class UserProfileApi {
  UserProfileApi._();

  static const String _getPath = '/zytbapi/plus/GetUserInfo';
  static const String _updatePath = '/zytbapi/plus/UpdateUserInfo';
  static const String _secret = '@_LoshopStudio_2026';
  static final Random _random = Random.secure();

  static Future<UserProfile> getUserInfo({
    required String school,
    required String userId,
  }) async {
    final schoolCode = school.trim();
    final id = userId.trim();
    if (schoolCode.isEmpty || id.isEmpty) {
      throw ApiException('缺少学校代码或用户 ID，无法获取个人信息');
    }

    final method = 'GET';
    final ts = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final nonce = _nonce();
    final params = <String, String>{
      'school': schoolCode,
      'userId': id,
      'ts': ts,
      'nonce': nonce,
    };
    final signature = _sign(method, _getPath, params, '');
    final data = await ApiClient.instance.request(
      _getPath,
      baseUrl: AppConfig.workerApiBaseUrl,
      skipAuth: true,
      skipRecover: true,
      query: {...params, 'sign': signature},
    );
    final result = data is Map ? data['result'] : null;
    if (result is! Map) {
      final error = data is Map ? data['error'] : null;
      final message = error is Map && error['message'] != null
          ? error['message'].toString()
          : '获取个人信息失败';
      throw ApiException(message);
    }
    return UserProfile.fromJson(Map<String, dynamic>.from(result));
  }

  static Future<void> updateUserInfo({
    required String school,
    required String userId,
    required UserProfile profile,
    required String surname,
    required String name,
    required String picture,
  }) async {
    final schoolCode = school.trim();
    final id = userId.trim();
    if (schoolCode.isEmpty || id.isEmpty) {
      throw ApiException('缺少学校代码或用户 ID，无法更新个人信息');
    }
    final userInfoId = profile.id ?? int.tryParse(id);
    if (userInfoId == null) throw ApiException('个人信息缺少有效 ID');

    final body = jsonEncode({
      'id': userInfoId,
      'number': profile.number,
      'classId': profile.className.isNotEmpty
          ? profile.className
          : profile.classId?.toString() ?? '',
      'user': {
        'pictrue': picture,
        'brithDay': profile.brithDay,
        'userName': profile.userName,
        'number': profile.number,
        'surname': surname,
        'name': name,
        'enterSchoolYear': [
          profile.enterSchoolYear,
          profile.gradeName,
        ].where((value) => value.trim().isNotEmpty).join(' '),
        'credentialsType': profile.credentialsType ?? 0,
        'birthplace': profile.birthplace,
        'homeAddress': profile.homeAddress,
        'gender': profile.gender ?? 0,
        'idNumber': profile.idNumber,
        'nation': profile.nation,
        'telephone': profile.telephone,
        'mobile': profile.mobile ?? '',
      },
    });
    final params = _requestParams(schoolCode, id);
    final signature = _sign('POST', _updatePath, params, body);
    final data = await ApiClient.instance.request(
      _updatePath,
      method: 'POST',
      baseUrl: AppConfig.workerApiBaseUrl,
      skipAuth: true,
      skipRecover: true,
      query: {...params, 'sign': signature},
      headers: const {'Content-Type': 'application/json'},
      data: body,
    );
    if (data is Map && data['success'] == false) {
      final error = data['error'];
      final message = error is Map && error['message'] != null
          ? error['message'].toString()
          : '更新个人信息失败';
      throw ApiException(message);
    }
  }

  static Map<String, String> _requestParams(String school, String userId) => {
    'school': school,
    'userId': userId,
    'ts': (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
    'nonce': _nonce(),
  };

  static String _nonce() {
    final bytes = List<int>.generate(32, (_) => _random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static String _sign(
    String method,
    String path,
    Map<String, String> params,
    String body,
  ) {
    final canonicalQuery = params.entries.toList()
      ..sort(
        (a, b) => a.key.compareTo(b.key) != 0
            ? a.key.compareTo(b.key)
            : a.value.compareTo(b.value),
      );
    final query = canonicalQuery
        .map(
          (entry) =>
              '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}',
        )
        .join('&');
    final message = '$method\n$path\n$query\n$body';
    final hmac = pc.HMac(pc.SHA256Digest(), 64)
      ..init(pc.KeyParameter(Uint8List.fromList(utf8.encode(_secret))));
    final digest = hmac.process(Uint8List.fromList(utf8.encode(message)));
    return base64UrlEncode(digest).replaceAll('=', '');
  }
}
