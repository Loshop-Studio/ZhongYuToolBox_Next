import '../config/app_config.dart';

/// 云笔记资源绝对地址
String absoluteOssUrl(String ossImageUrl) {
  if (ossImageUrl.isEmpty) return ossImageUrl;
  if (ossImageUrl.startsWith('http://') || ossImageUrl.startsWith('https://')) {
    return ossImageUrl;
  }
  return '${AppConfig.ossBase}$ossImageUrl';
}

/// 图片展示地址（复刻 proxyImgSrc：alicdn 源换 OSS 域名）
String imageDisplayUrl(String url) {
  if (url.isEmpty) return url;
  if (url.startsWith(AppConfig.alicdnHost)) {
    return url.replaceFirst(AppConfig.alicdnHost, AppConfig.ossImageHost);
  }
  return url;
}

/// 用户头像地址：后端可能返回绝对地址、alicdn 地址或相对路径
String userAvatarUrl(String raw, {String apiBaseUrl = ''}) {
  final value = raw.trim();
  if (value.isEmpty) return '';
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return imageDisplayUrl(value);
  }
  final base = apiBaseUrl.isNotEmpty ? apiBaseUrl : AppConfig.defaultApiBaseUrl;
  final cleaned = base.replaceAll(RegExp(r'/+$'), '');
  final path = value.startsWith('/') ? value : '/$value';
  return '$cleaned$path';
}

/// 把相对路径解析为当前学校域名下的绝对地址
String resolveApiUrl(String path, String apiBaseUrl) {
  if (path.isEmpty) return path;
  final uri = Uri.tryParse(path);
  if (uri != null && uri.hasScheme) return path;
  final base = apiBaseUrl.endsWith('/') ? apiBaseUrl : '$apiBaseUrl/';
  return Uri.parse(base).resolve(path).toString();
}
