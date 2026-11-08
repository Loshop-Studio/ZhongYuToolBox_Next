import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:pointycastle/export.dart' as pc;

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';

/// 常用学生端应用（与官方 APK 包名一致）
const List<({String name, String packageName})> studentApps = [
  (name: '优课畅学', packageName: 'com.zhongyukejiao.learningexpert'),
  (name: '云笔记', packageName: 'com.friday.cloudsnote'),
  (name: '新测评', packageName: 'com.zykj.evaluation'),
  (name: '错题本', packageName: 'com.zykj.mistake'),
  (name: '随身答', packageName: 'com.zykj.student.dialogue'),
  (name: '在线专栏', packageName: 'com.zykj.subscriber'),
  (name: '用户中心', packageName: 'com.zykj.manage'),
];

const int _maxApkSize = 512 * 1024 * 1024;

class OfficialApp {
  const OfficialApp({
    required this.name,
    required this.packageName,
    required this.versionName,
    required this.versionCode,
    required this.fileUrl,
    required this.size,
    required this.icon,
  });

  final String name;
  final String packageName;
  final String versionName;
  final int versionCode;
  final String fileUrl;
  final int size;
  final String icon;

  String get sizeText {
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(0)} KB';
    return '${(size / 1024 / 1024).toStringAsFixed(2)} MB';
  }
}

/// 中育应用下载（复刻 src/api/appStore.ts）
class AppStoreApi {
  AppStoreApi._();

  /// 只接受官方域名，避免被引导到任意地址
  static String officialResourceUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) throw ApiException('官方接口返回了不支持的资源地址');
    final host = uri.host.toLowerCase();
    final officialHost = RegExp(r'(^|\.)zykj\.org$').hasMatch(host) ||
        RegExp(r'^ezy-[a-z0-9-]+\.oss-cn-[a-z0-9-]+\.aliyuncs\.com$').hasMatch(host);
    if (!officialHost ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.userInfo.isNotEmpty ||
        uri.hasPort) {
      throw ApiException('官方接口返回了不支持的资源地址');
    }
    return uri.toString();
  }

  static Future<OfficialApp?> checkUpdate(String packageName) async {
    final pkg = packageName.trim();
    if (!RegExp(r'^[a-zA-Z]\w*(?:\.[a-zA-Z]\w*){2,}$').hasMatch(pkg)) {
      throw ApiException('请输入有效的 Android 包名，例如 com.zykj.mistake');
    }
    final data = await ApiClient.instance.request(
      '/api/services/app/AppStore/CheckUpdateAsync',
      query: {'packageName': pkg, 'version': '0', 'appType': '0'},
      skipAuth: true,
      skipRecover: true,
    );
    final app = data is Map ? data['result'] : null;
    if (app is! Map) return null;
    if (app['disabled'] == true) return null;
    if ((app['packageName'] ?? '').toString() != pkg) {
      throw ApiException('官方返回的包名不匹配');
    }
    final size = (app['size'] as num?)?.toInt() ?? 0;
    if (size <= 0 || size > _maxApkSize) throw ApiException('官方安装包大小无效');
    var icon = '';
    try {
      if ((app['icon'] ?? '').toString().isNotEmpty) {
        icon = officialResourceUrl(app['icon'].toString());
      }
    } catch (_) {
      icon = '';
    }
    return OfficialApp(
      name: (app['name'] ?? pkg).toString(),
      packageName: pkg,
      versionName: (app['versionName'] ?? '').toString(),
      versionCode: (app['versionCode'] as num?)?.toInt() ?? 0,
      fileUrl: officialResourceUrl((app['fileUrl'] ?? '').toString()),
      size: size,
      icon: icon,
    );
  }

  static String fileName(OfficialApp app) {
    final version = app.versionName.isNotEmpty ? app.versionName : '${app.versionCode}';
    final name = '${app.name}-$version-${app.packageName}.apk';
    return name.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1f]'), '_');
  }

  /// 下载并校验 APK，返回字节与 SHA-256
  static Future<({Uint8List bytes, String sha256})> downloadApk(
    OfficialApp app, {
    void Function(int received, int total)? onProgress,
  }) async {
    final url = officialResourceUrl(app.fileUrl);
    final dio = Dio(BaseOptions(
      validateStatus: (_) => true,
      receiveTimeout: const Duration(minutes: 5),
    ));
    final response = await dio.get<dynamic>(
      url,
      options: Options(responseType: ResponseType.bytes),
      onReceiveProgress: onProgress,
    );
    final data = response.data;
    if (data is! List<int> || data.isEmpty) throw ApiException('APK 下载失败');
    if (data.length > app.size || data.length > _maxApkSize) {
      throw ApiException('下载大小超出官方记录，请刷新版本后重试');
    }
    if (data.length != app.size) {
      throw ApiException('安装包不完整：下载大小与官方记录不一致');
    }
    final bytes = Uint8List.fromList(data);

    final archive = ZipDecoder().decodeBytes(bytes, verify: false);
    final hasManifest = archive.files.any((f) => f.name == 'AndroidManifest.xml');
    final hasDex = archive.files.any((f) => RegExp(r'^classes\d*\.dex$').hasMatch(f.name));
    if (!hasManifest || !hasDex) throw ApiException('下载内容不是有效的 Android APK');

    final digest = pc.SHA256Digest().process(bytes);
    final sha256 = digest.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return (bytes: bytes, sha256: sha256);
  }
}
