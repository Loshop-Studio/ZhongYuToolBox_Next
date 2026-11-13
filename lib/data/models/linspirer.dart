/// 领创应用 / 应用详情
class LinspirerApp {
  const LinspirerApp({required this.raw, required this.source});

  final Map<String, dynamic> raw;
  final String source;

  factory LinspirerApp.fromJson(
    Map<String, dynamic> json, {
    String source = '',
  }) {
    return LinspirerApp(raw: json, source: source);
  }

  String get id => (raw['id'] ?? raw['appid'] ?? '').toString();
  String get name => (raw['name'] ?? raw['appname'] ?? '未知应用').toString();
  String get packageName => (raw['packagename'] ?? raw['pkg'] ?? '').toString();
  String get icon =>
      (raw['iconpath'] ?? raw['icon'] ?? raw['appicon'] ?? '').toString();
  String get version => (raw['version'] ?? raw['appversion'] ?? '').toString();
}

class LinspirerAppDetail {
  const LinspirerAppDetail({required this.raw});

  final Map<String, dynamic> raw;

  factory LinspirerAppDetail.fromJson(Map<String, dynamic> json) {
    return LinspirerAppDetail(raw: json);
  }

  String get name => (raw['name'] ?? raw['appname'] ?? '未知').toString();
  String get packageName => (raw['packagename'] ?? raw['pkg'] ?? '').toString();
  String get version => (raw['version'] ?? raw['appversion'] ?? '').toString();
  String get description {
    final parts = <String>[];
    for (final key in const ['shortdescript', 'longdescript']) {
      final value = raw[key]?.toString().trim() ?? '';
      if (value.isNotEmpty && value != 'null' && !parts.contains(value)) {
        parts.add(value);
      }
    }
    if (parts.isNotEmpty) return parts.join('\n');

    for (final key in const ['description', 'desc']) {
      final value = raw[key]?.toString().trim() ?? '';
      if (value.isNotEmpty && value != 'null') return value;
    }
    return '无描述';
  }

  String get icon =>
      (raw['iconpath'] ?? raw['icon'] ?? raw['appicon'] ?? '').toString();

  String downloadFileName([String fallback = '领创应用']) {
    final base = name.trim().isEmpty ? fallback : name.trim();
    return base.toLowerCase().endsWith('.apk') ? base : '$base.apk';
  }

  /// 下载路径需要拼接设备号（复刻旧项目 path + swdid）
  String downloadPath(String swdid) {
    final path = (raw['path'] ?? '').toString();
    return path.isEmpty ? '' : '$path$swdid';
  }
}
