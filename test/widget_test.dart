import 'package:flutter_test/flutter_test.dart';
import 'package:zhongyu_toolbox/core/config/app_config.dart';
import 'package:zhongyu_toolbox/core/crypto/zy_aes.dart';

void main() {
  test('AES key 长度为 16', () {
    expect(generateZyAesKey().length, 16);
  });

  test('AES 加解密可往返', () {
    const plain = 'parentid=0&isNoteNode=true';
    final cipher = ZyAes.encrypt(plain);
    expect(cipher.isNotEmpty, true);
    expect(ZyAes.decrypt(cipher), plain);
  });

  test('JSON 解密辅助', () {
    final cipher = ZyAes.encrypt('{"noteList":[]}');
    expect(ZyAes.decryptJson(cipher)['noteList'], isEmpty);
  });

  test('预设学校代码', () {
    expect(
      AppConfig.schoolPresets.map((e) => e.code).toList(),
      ['sxz', 'sxzbh', 'bjsbsz', 'sxzxx', 'sxzsyxx'],
    );
  });
}
