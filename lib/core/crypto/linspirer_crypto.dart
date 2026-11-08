import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:pointycastle/export.dart';

/// 领创 AES-CBC 加解密 + MD5（复刻旧项目 src/utils/crypto.ts）
class LinspirerCrypto {
  LinspirerCrypto._();

  static const String key = '1191ADF18489D8DA';
  static const String iv = '5E9B755A8B674394';

  static final enc.Key _key = enc.Key.fromUtf8(key);
  static final enc.IV _iv = enc.IV.fromUtf8(iv);
  static final enc.Encrypter _encrypter = enc.Encrypter(
    enc.AES(_key, mode: enc.AESMode.cbc, padding: 'PKCS7'),
  );

  static String encrypt(String text) =>
      _encrypter.encrypt(text, iv: _iv).base64;

  static String decrypt(String base64Text) =>
      _encrypter.decrypt64(base64Text, iv: _iv);

  static String md5(String text) {
    final digest = Digest('MD5').process(Uint8List.fromList(utf8.encode(text)));
    return digest.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
