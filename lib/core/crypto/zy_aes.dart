import 'dart:convert';

import 'package:encrypt/encrypt.dart' as enc;

import '../config/app_config.dart';

/// 中育 AES-ECB/PKCS7 加解密（复刻 CryptoJS.enc.Utf8 + AES ECB）
///
/// 注意：key 与当前日期绑定，跨天会变化；每次调用都重新生成。
class ZyAes {
  ZyAes._();

  static enc.Encrypter _encrypter() {
    final key = enc.Key(utf8.encode(generateZyAesKey()));
    return enc.Encrypter(enc.AES(key, mode: enc.AESMode.ecb, padding: 'PKCS7'));
  }

  static final enc.IV _iv = enc.IV.fromLength(16);

  static String encrypt(String data) {
    return _encrypter().encrypt(data, iv: _iv).base64;
  }

  static String decrypt(String? cipherBase64) {
    if (cipherBase64 == null || cipherBase64.isEmpty) return '';
    final text = cipherBase64.trim();
    if (text.isEmpty) return '';
    try {
      return _encrypter().decrypt(enc.Encrypted.fromBase64(text), iv: _iv);
    } catch (_) {
      return '';
    }
  }

  /// 解密后再按 JSON 解析（云笔记接口固定格式）
  static Map<String, dynamic> decryptJson(String? cipherBase64) {
    final plain = decrypt(cipherBase64);
    if (plain.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(plain);
    return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
  }
}
