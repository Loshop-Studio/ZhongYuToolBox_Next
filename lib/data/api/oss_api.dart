import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:pointycastle/export.dart' as pc;

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';

/// 上传类型 -> fc 数值映射（复刻 V_MAP）
const Map<String, int> _vMap = {
  'note_v2': 1,
  'eval_v2': 2,
  'quora_v2': 3,
  'mistake_v2': 4,
  'study_v2': 5,
  'column_v2': 6,
  'paper_v2': 7,
  'revise_v2': 8,
  'selection_v2': 9,
  'manage_v2': 19,
};

const String _fr = 'res';
const int _ft = 2;
const String _fe = '';
const String _fo = '0';

class StsCredential {
  const StsCredential({
    required this.accessKeyId,
    required this.accessKeySecret,
    required this.securityToken,
    this.region = 'oss-cn-hangzhou',
    this.bucket = '',
    this.endpoint = '',
  });

  final String accessKeyId;
  final String accessKeySecret;
  final String securityToken;
  final String region;
  final String bucket;
  final String endpoint;

  factory StsCredential.fromJson(Map<String, dynamic> json) {
    return StsCredential(
      accessKeyId: (json['accessKeyId'] ?? '').toString(),
      accessKeySecret: (json['accessKeySecret'] ?? '').toString(),
      securityToken: (json['securityToken'] ?? '').toString(),
      region: (json['region'] ?? 'oss-cn-hangzhou').toString(),
      bucket: (json['bucket'] ?? '').toString(),
      endpoint: (json['endpoint'] ?? '').toString(),
    );
  }
}

/// 阿里云 OSS 直传（复刻 src/utils/oss.ts）
class OssApi {
  OssApi._();

  static final Random _random = Random.secure();

  static String _md5Upper(String value) {
    final digest = pc.Digest('MD5').process(utf8.encode(value));
    return digest.map((b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase();
  }

  static String _hmacSha1Base64(String value, String key) {
    final hmac = pc.HMac(pc.SHA1Digest(), 64)
      ..init(pc.KeyParameter(utf8.encode(key)));
    final out = hmac.process(utf8.encode(value));
    return base64.encode(out);
  }

  /// UUID 风格 nonce（复刻 generateNonce）
  static String generateNonce() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String hex(int start, int end) => bytes
        .sublist(start, end)
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
  }

  static String _dateFolder() {
    final now = DateTime.now();
    String pad(int v) => v.toString().padLeft(2, '0');
    return '${now.year}${pad(now.month)}${pad(now.day)}';
  }

  /// 请求 STS 临时凭证
  static Future<StsCredential> generateStsToken(
    String userId,
    String fc,
    String nonce,
  ) async {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final sign = _md5Upper('$userId+$fc+$_fr+$_ft+$_fe+$_fo+$nonce+$ts');
    final data = await ApiClient.instance.request(
      '/api/services/app/ObjectStorage/GenerateTokenV2Async',
      method: 'POST',
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      data: jsonEncode({
        'fc': _vMap[fc] ?? 1,
        'fr': 1,
        'ft': _ft,
        'fe': _fe,
        'fo': _fo,
        'nonce': nonce,
        'ts': ts,
        'sign': sign,
      }),
    );
    final result = data is Map ? data['result'] : null;
    if (result is! Map) throw ApiException('获取上传凭证失败，请重新登录后再试');
    return StsCredential.fromJson(Map<String, dynamic>.from(result));
  }

  /// 上传文件，返回完整 URL
  static Future<String> uploadBytes({
    required Uint8List bytes,
    required String fileName,
    required String userId,
    required String fc,
    String mime = 'application/octet-stream',
    String nonceInput = '',
  }) async {
    final nonce = nonceInput.trim().isNotEmpty ? nonceInput.trim() : generateNonce();
    final remoteFileName = fileName.trim().isNotEmpty ? fileName.trim() : nonce;
    final credential = await generateStsToken(userId, fc, nonce);

    final remoteFile = '$fc/$_fr/$userId/${_dateFolder()}/$nonce/$remoteFileName';
    final bucket = credential.bucket.isNotEmpty
        ? credential.bucket
        : (credential.endpoint.contains('//')
            ? credential.endpoint.split('//').last.split('.').first
            : 'ezy-sxz');
    final endpoint = credential.endpoint.isNotEmpty
        ? credential.endpoint
        : 'https://$bucket.${credential.region}.aliyuncs.com';
    final url = '${endpoint.replaceAll(RegExp(r'/+$'), '')}/$remoteFile';

    final date = HttpDate.format(DateTime.now().toUtc());
    final canonical = [
      'PUT',
      '',
      mime,
      date,
      'x-oss-security-token:${credential.securityToken}',
      '/$bucket/$remoteFile',
    ].join('\n');
    final signature = _hmacSha1Base64(canonical, credential.accessKeySecret);

    final dio = Dio(BaseOptions(validateStatus: (_) => true));
    final response = await dio.put<dynamic>(
      url,
      data: Stream.fromIterable([bytes]),
      options: Options(
        method: 'PUT',
        headers: {
          'Date': date,
          'Content-Type': mime,
          'Content-Length': bytes.length,
          'x-oss-security-token': credential.securityToken,
          'Authorization': 'OSS ${credential.accessKeyId}:$signature',
        },
        responseType: ResponseType.plain,
      ),
    );
    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      throw ApiException('OSS 上传失败($status)');
    }
    return url;
  }

  /// 当前登录用户 ID
  static Future<String> fetchUserId() async {
    final data = await ApiClient.instance
        .request('/api/services/app/User/GetInfoAsync');
    final result = data is Map ? data['result'] : null;
    final id = result is Map ? (result['id'] ?? result['userId']) : null;
    if (id == null || id.toString().isEmpty) throw ApiException('无法获取用户ID');
    return id.toString();
  }
}
