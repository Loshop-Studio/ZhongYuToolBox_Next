/// 全局常量中心（对应旧项目 src/config/index.ts）
class AppConfig {
  AppConfig._();

  static const String appName = '中育Toolbox';
  static const String appVersion = '9.9.9';

  /// 学校发现网关
  static const String discoveryBase =
      'https://hagateway.zykj.org/api/discovery';

  /// 未登录时的兜底 API 地址（登录后会替换为当前学校 server）
  static const String defaultApiBaseUrl = 'http://sxz.api.zykj.org';

  /// 云笔记资源 OSS 前缀
  static const String ossBase =
      'http://friday-note.oss-cn-hangzhou.aliyuncs.com/';

  /// 优客畅学平板端 Web（章节内容用官方页面渲染，比接口 + HTML 更完整）
  static const String lessonPadBase = 'http://ykcx-pad.school.zykj.org/';

  /// alicdn 图片域名替换规则（复刻 proxyImgSrc）
  static const String alicdnHost = 'http://sxz.alicdn.zykj.org/';
  static const String ossImageHost =
      'https://ezy-sxz.oss-cn-hangzhou.aliyuncs.com/';

  static const String supportQqGroup = '1067807011';
  static const String projectUrl = 'https://github.com/Loshop-Studio';

  /// 学科常量（复刻旧项目 SUBJECTS）
  static const List<({int id, String name})> subjects = [
    (id: 4, name: '语文'),
    (id: 5, name: '数学'),
    (id: 6, name: '外语'),
    (id: 7, name: '物理'),
    (id: 8, name: '化学'),
    (id: 9, name: '生物'),
    (id: 10, name: '政治'),
    (id: 11, name: '历史'),
    (id: 12, name: '地理'),
    (id: 13, name: '全科专用（级部发布）'),
    (id: 14, name: '信息技术'),
    (id: 15, name: '通用技术'),
    (id: 24, name: '体育与健康'),
    (id: 34, name: '技术'),
    (id: 35, name: '艺术'),
    (id: 41, name: '研创大任务'),
    (id: 42, name: '级部管理'),
    (id: 53, name: '家务劳动'),
    (id: 66, name: '调查问卷'),
  ];

  /// 预设学校（其它学校通过 discover 解析）
  ///
  static const List<SchoolPreset> schoolPresets = [
    SchoolPreset(code: 'sxz', name: '省锡中'),
    SchoolPreset(code: 'sxzbh', name: '省锡中滨湖分校'),
    SchoolPreset(code: 'bjbsz', name: '北京80中学'),
    SchoolPreset(code: 'sxzxx', name: '江苏省锡山高级中学锡西分校'),
    SchoolPreset(code: 'sxzsyxx', name: '匡园双语学校'),
    SchoolPreset(code: 'nswgy', name: '深圳市南山外国语学校'),
    SchoolPreset(code: 'szgy', name: '苏州国裕外语学校'),
  ];
}

class SchoolPreset {
  const SchoolPreset({required this.code, required this.name});

  final String code;
  final String name;

  String get displayName => name.isNotEmpty ? name : code.toUpperCase();
}

/// 中育 AES 密钥（复刻 index.js generateAesKey）：按当天日期动态生成 16 字符 key
String generateZyAesKey() {
  const table = ":F0wKU!Qg3}UkbW+w[:9|D3-5h=:T;7t#_GZ4#G;~ZNSq{8;}QIP>'{q.lje";
  final now = DateTime.now();
  final year = now.year;
  final month = now.month;
  final day = now.day;

  final mixed = 33 + day * month * 33;
  final head = String.fromCharCode((mixed % 94) + 33);
  final tailIndex = day + month;
  final tail = tailIndex < table.length
      ? table[tailIndex]
      : table[table.length - 1];

  final offset = (year * month * day) % table.length;
  final rotated = table.substring(offset) + table.substring(0, offset);
  final middle = rotated.substring(0, 14);

  return '$head$middle$tail';
}
