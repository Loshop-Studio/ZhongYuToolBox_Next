/// 当前登录会话（token 与当前学校地址）
class Session {
  Session({
    this.token = '',
    this.refreshToken = '',
    this.tokenExpire,
    this.refreshExpire,
    this.apiBaseUrl = '',
    this.webServer = '',
    this.userId = '',
    this.realName = '',
    this.photo = '',
    this.schoolCode = '',
    this.schoolName = '',
    this.userName = '',
  });

  String token;
  String refreshToken;
  DateTime? tokenExpire;
  DateTime? refreshExpire;
  String apiBaseUrl;
  String webServer;
  String userId;
  String realName;
  String photo;
  String schoolCode;
  String schoolName;
  String userName;

  bool get hasToken => token.isNotEmpty;

  bool get isTokenValid {
    if (token.isEmpty || tokenExpire == null) return false;
    return tokenExpire!.isAfter(DateTime.now());
  }

  /// 距离 token 过期是否已进入续期窗口
  bool get shouldRefresh {
    if (token.isEmpty || tokenExpire == null) return false;
    final left = tokenExpire!.difference(DateTime.now());
    return left.inSeconds <= 10;
  }

  bool get canRefresh {
    if (refreshToken.isEmpty || refreshExpire == null) return false;
    return refreshExpire!.isAfter(DateTime.now());
  }

  String get displayName => realName.isNotEmpty ? realName : userName;

  void clear() {
    token = '';
    refreshToken = '';
    tokenExpire = null;
    refreshExpire = null;
    apiBaseUrl = '';
    webServer = '';
    userId = '';
    realName = '';
    photo = '';
    schoolCode = '';
    schoolName = '';
    userName = '';
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'refreshToken': refreshToken,
        'tokenExpire': tokenExpire?.toIso8601String() ?? '',
        'refreshExpire': refreshExpire?.toIso8601String() ?? '',
        'apiBaseUrl': apiBaseUrl,
        'webServer': webServer,
        'userId': userId,
        'realName': realName,
        'photo': photo,
        'schoolCode': schoolCode,
        'schoolName': schoolName,
        'userName': userName,
      };

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      token: (json['token'] ?? '').toString(),
      refreshToken: (json['refreshToken'] ?? '').toString(),
      tokenExpire: DateTime.tryParse((json['tokenExpire'] ?? '').toString()),
      refreshExpire: DateTime.tryParse((json['refreshExpire'] ?? '').toString()),
      apiBaseUrl: (json['apiBaseUrl'] ?? '').toString(),
      webServer: (json['webServer'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      realName: (json['realName'] ?? '').toString(),
      photo: (json['photo'] ?? '').toString(),
      schoolCode: (json['schoolCode'] ?? '').toString(),
      schoolName: (json['schoolName'] ?? '').toString(),
      userName: (json['userName'] ?? '').toString(),
    );
  }
}
