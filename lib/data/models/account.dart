/// 已添加的账号（凭据 + 学校信息）
class Account {
  Account({
    required this.schoolCode,
    required this.schoolName,
    required this.userName,
    required this.password,
    required this.apiBaseUrl,
    this.webServer = '',
    this.realName = '',
    this.photo = '',
    this.userId = '',
    this.lastLoginAt,
  });

  final String schoolCode;
  final String schoolName;
  final String userName;
  final String password;
  final String apiBaseUrl;
  final String webServer;
  final String realName;
  final String photo;
  final String userId;
  final DateTime? lastLoginAt;

  /// 同一学校 + 同一用户视为一个账号
  String get id => '${origin}|${userId.isNotEmpty ? userId : userName}';

  String get origin {
    final parsed = Uri.tryParse(apiBaseUrl);
    if (parsed == null || parsed.host.isEmpty) return apiBaseUrl;
    return '${parsed.scheme}://${parsed.host}${parsed.hasPort ? ':${parsed.port}' : ''}';
  }

  String get displayName => realName.isNotEmpty ? realName : userName;

  String get schoolLabel => schoolName.isNotEmpty ? schoolName : schoolCode.toUpperCase();

  Account copyWith({
    String? schoolCode,
    String? schoolName,
    String? userName,
    String? password,
    String? apiBaseUrl,
    String? webServer,
    String? realName,
    String? photo,
    String? userId,
    DateTime? lastLoginAt,
  }) {
    return Account(
      schoolCode: schoolCode ?? this.schoolCode,
      schoolName: schoolName ?? this.schoolName,
      userName: userName ?? this.userName,
      password: password ?? this.password,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      webServer: webServer ?? this.webServer,
      realName: realName ?? this.realName,
      photo: photo ?? this.photo,
      userId: userId ?? this.userId,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      schoolCode: (json['schoolCode'] ?? '').toString(),
      schoolName: (json['schoolName'] ?? '').toString(),
      userName: (json['userName'] ?? '').toString(),
      password: (json['password'] ?? '').toString(),
      apiBaseUrl: (json['apiBaseUrl'] ?? '').toString(),
      webServer: (json['webServer'] ?? '').toString(),
      realName: (json['realName'] ?? '').toString(),
      photo: (json['photo'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      lastLoginAt: DateTime.tryParse((json['lastLoginAt'] ?? '').toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'schoolCode': schoolCode,
        'schoolName': schoolName,
        'userName': userName,
        'password': password,
        'apiBaseUrl': apiBaseUrl,
        'webServer': webServer,
        'realName': realName,
        'photo': photo,
        'userId': userId,
        'lastLoginAt': lastLoginAt?.toIso8601String() ?? '',
      };
}

/// discover 返回结果
class DiscoverResult {
  DiscoverResult({
    required this.name,
    required this.server,
    this.lcid = '',
    this.webServer = '',
  });

  final String name;
  final String server;
  final String lcid;
  final String webServer;

  bool get isValid => server.trim().isNotEmpty;

  factory DiscoverResult.fromJson(Map<String, dynamic> json) {
    return DiscoverResult(
      name: (json['name'] ?? '').toString(),
      server: (json['server'] ?? '').toString(),
      lcid: (json['lcid'] ?? '').toString(),
      webServer: (json['webServer'] ?? '').toString(),
    );
  }
}
