import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../data/models/account.dart';
import '../../data/models/session.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';
import '../network/api_exception.dart';
import '../../data/api/track_api.dart';
import 'local_store.dart';

/// 账号与会话管理（复刻 src/stores/auth.ts，并扩展为多账号）
class SessionManager extends ChangeNotifier {
  SessionManager._();

  static final SessionManager instance = SessionManager._();

  Session session = Session();
  List<Account> accounts = <Account>[];
  Account? currentAccount;

  bool _ready = false;
  bool _busy = false;
  String _busyText = '';
  String? _lastError;
  String? _blockMessage;

  Timer? _refreshTimer;
  Future<bool>? _recovering;

  bool get ready => _ready;
  bool get busy => _busy;
  String get busyText => _busyText;
  String? get lastError => _lastError;

  bool get isLoggedIn => session.isTokenValid;
  bool get hasAccounts => accounts.isNotEmpty;

  /// 命中封禁时的全屏提示文案（null 表示未封禁）
  String? get blockMessage => _blockMessage;

  String get displayName {
    if (session.displayName.isNotEmpty) return session.displayName;
    final cached = currentAccount?.displayName ?? '';
    return cached.isNotEmpty ? cached : '未登录';
  }

  String get schoolLabel {
    if (session.schoolName.isNotEmpty) return session.schoolName;
    final cached = currentAccount?.schoolLabel ?? '';
    return cached.isNotEmpty ? cached : '';
  }

  Future<void> bootstrap() async {
    await LocalStore.instance.init();
    _loadAccounts(await LocalStore.instance.readSecret(LocalStore.keyAccounts));
    final rawSession = await LocalStore.instance.readSecret(LocalStore.keySession);
    if (rawSession != null && rawSession.isNotEmpty) {
      try {
        session = Session.fromJson(
          Map<String, dynamic>.from(jsonDecode(rawSession) as Map),
        );
      } catch (_) {
        session = Session();
      }
    }
    final lastId = LocalStore.instance.getString(LocalStore.keyLastAccount);
    currentAccount = _findAccount(lastId) ??
        (accounts.isNotEmpty ? accounts.first : null);
    _ready = true;
    startAutoRefresh();
    notifyListeners();
  }

  Account? _findAccount(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final account in accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  void _loadAccounts(String? raw) {
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        accounts = decoded
            .whereType<Map>()
            .map((e) => Account.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {
      accounts = <Account>[];
    }
  }

  Future<void> _persistAccounts() async {
    await LocalStore.instance.writeSecret(
      LocalStore.keyAccounts,
      jsonEncode(accounts.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _persistSession() async {
    await LocalStore.instance.writeSecret(
      LocalStore.keySession,
      jsonEncode(session.toJson()),
    );
  }

  /// 学校发现
  Future<DiscoverResult> discoverSchool(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) throw ApiException('请输入学校代码');
    final data = await ApiClient.instance.request(
      '${AppConfig.discoveryBase}/${Uri.encodeComponent(trimmed)}',
      skipAuth: true,
      skipRecover: true,
    );
    final map = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    final result = DiscoverResult.fromJson(map);
    if (!result.isValid) {
      throw ApiException('学校代码「$trimmed」不存在或该校服务暂不可用');
    }
    return result;
  }

  /// 登录（并写入账号列表）
  Future<Account> login({
    required String schoolCode,
    required String schoolName,
    required String userName,
    required String password,
    String webServer = '',
    bool silent = false,
  }) async {
    final account = userName.trim();
    if (account.isEmpty) throw ApiException('请输入用户名');
    if (password.isEmpty) throw ApiException('请输入密码');

    _setBusy(true, silent ? '正在登录…' : '正在登录…');
    try {
      final discover = await discoverSchool(schoolCode);
      final server = discover.server;

      final loginData = await ApiClient.instance.request(
        '/api/TokenAuth/Login',
        method: 'POST',
        baseUrl: server,
        skipAuth: true,
        skipRecover: true,
        data: jsonEncode({
          'userName': account,
          'password': password,
          'clientType': 1,
        }),
      );
      final result = loginData is Map ? loginData['result'] : null;
      if (result is! Map) {
        final error = loginData is Map ? loginData['error'] : null;
        final message = error is Map && error['message'] != null
            ? error['message'].toString()
            : '登录失败，请检查用户名和密码';
        throw ApiException(message);
      }

      session
        ..clear()
        ..apiBaseUrl = server
        ..webServer = discover.webServer.isNotEmpty ? discover.webServer : webServer
        ..schoolCode = schoolCode
        ..schoolName = schoolName
        ..userName = account;
      _applyToken(Map<String, dynamic>.from(result));

      final info = await _fetchUserInfo(server);
      session
        ..realName = (info['realName'] ?? '').toString()
        ..photo = (info['photo'] ?? '').toString()
        ..userId = (info['userId'] ?? info['id'] ?? '').toString();

      final effectiveSchoolName = _resolveSchoolName(
        code: schoolCode,
        discoverName: discover.name,
        fallback: schoolName,
      );

      final newAccount = Account(
        schoolCode: schoolCode,
        schoolName: effectiveSchoolName,
        userName: account,
        password: password,
        apiBaseUrl: server,
        webServer: session.webServer,
        realName: session.realName,
        photo: session.photo,
        userId: session.userId,
        lastLoginAt: DateTime.now(),
      );

      final index = accounts.indexWhere((e) => e.id == newAccount.id);
      if (index >= 0) {
        accounts[index] = newAccount;
      } else {
        accounts = [newAccount, ...accounts];
      }
      currentAccount = newAccount;
      session.schoolName = effectiveSchoolName;

      await _persistAccounts();
      await _persistSession();
      await LocalStore.instance.setString(LocalStore.keyLastAccount, newAccount.id);

      // 登录上报 + 封禁检查（每天最多一次；上报失败不影响主流程）
      await _reportLoginDaily();

      _lastError = null;
      startAutoRefresh();
      notifyListeners();
      return newAccount;
    } finally {
      _setBusy(false);
    }
  }

  /// 每日上报一次登录（并做封禁检查）。
  ///
  /// 规则：当天首次调用才真正请求服务器；当天内重复调用直接跳过。
  /// 触发点统一在 [login]（手动登录 / 自动重登 / 401 恢复都会经过），
  /// 因此「只要用户当天用了 App」就会在登录成功时上报一次，且每天不超过一次。
  static const String _kLastLoginReport = 'zy_last_login_report';

  Future<void> _reportLoginDaily() async {
    final account = currentAccount;
    if (account == null) return;
    final today = _todayKey();
    if (LocalStore.instance.getString(_kLastLoginReport) == today) return;
    try {
      final ban = await TrackApi.reportLogin(
        account.schoolCode,
        account.userName,
      );
      if (ban.banned) {
        _blockMessage = '${ban.message ?? '该账号已被管理员封禁'}'
            '\n\n如确认有误，请加 QQ 群 ${AppConfig.supportQqGroup}';
      }
      await LocalStore.instance.setString(_kLastLoginReport, today);
    } catch (_) {
      /* 上报失败不影响主流程 */
    }
  }

  static String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-'
        '${n.day.toString().padLeft(2, '0')}';
  }

  String _resolveSchoolName({
    required String code,
    required String discoverName,
    required String fallback,
  }) {
    final lower = discoverName.toLowerCase();
    final meaningful = discoverName.isNotEmpty &&
        lower != 'unknown' &&
        lower != code.toLowerCase();
    if (meaningful) return discoverName;
    if (fallback.isNotEmpty) return fallback;
    return code.toUpperCase();
  }

  Future<Map<String, dynamic>> _fetchUserInfo(String server) async {
    final data = await ApiClient.instance.request(
      '/api/services/app/User/GetInfoAsync',
      baseUrl: server,
      skipRecover: true,
    );
    final result = data is Map ? data['result'] : null;
    return result is Map ? Map<String, dynamic>.from(result) : <String, dynamic>{};
  }

  void _applyToken(Map<String, dynamic> result) {
    final expire = (result['expireInSeconds'] as num?)?.toInt() ?? 0;
    final refreshExpire = (result['refreshExpireInSeconds'] as num?)?.toInt() ?? 0;
    session
      ..token = (result['accessToken'] ?? '').toString()
      ..refreshToken = (result['refreshToken'] ?? '').toString()
      ..tokenExpire = DateTime.now().add(Duration(seconds: expire))
      ..refreshExpire = DateTime.now().add(Duration(seconds: refreshExpire));
  }

  /// 用本地凭据自动登录（打开应用 / 切换用户 / token 失效）
  Future<bool> autoLogin() async {
    final account = currentAccount;
    if (account == null) return false;
    try {
      await login(
        schoolCode: account.schoolCode,
        schoolName: account.schoolName,
        userName: account.userName,
        password: account.password,
        webServer: account.webServer,
        silent: true,
      );
      return true;
    } catch (e) {
      _lastError = errorText(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> switchAccount(Account account) async {
    final ok = await autoLoginFor(account);
    return ok;
  }

  Future<bool> autoLoginFor(Account account) async {
    currentAccount = account;
    notifyListeners();
    return autoLogin();
  }

  Future<Account?> editAccount(Account account, {String? realName}) async {
    final index = accounts.indexWhere((e) => e.id == account.id);
    if (index < 0) return null;
    final updated = accounts[index].copyWith(realName: realName);
    accounts[index] = updated;
    if (currentAccount?.id == updated.id) currentAccount = updated;
    await _persistAccounts();
    notifyListeners();
    return updated;
  }

  Future<void> removeAccount(Account account) async {
    accounts = accounts.where((e) => e.id != account.id).toList();
    if (currentAccount?.id == account.id) {
      currentAccount = accounts.isNotEmpty ? accounts.first : null;
      await clearSession();
    }
    await _persistAccounts();
    notifyListeners();
  }

  /// 刷新 token
  Future<bool> refreshSession() async {
    if (session.refreshToken.isEmpty) return false;
    try {
      final data = await ApiClient.instance.request(
        '/api/TokenAuth/RefreshToken',
        method: 'POST',
        baseUrl: session.apiBaseUrl,
        skipAuth: true,
        skipRecover: true,
        headers: {
          'refreshtoken': session.refreshToken,
          'Authorization': 'Bearer ${session.token}',
        },
      );
      final result = data is Map ? data['result'] : null;
      if (result is Map) {
        _applyToken(Map<String, dynamic>.from(result));
        await _persistSession();
        notifyListeners();
        return true;
      }
    } catch (_) {
      /* 交给上层兜底重登 */
    }
    return false;
  }

  /// 401 恢复：先刷新，再自动重登（并发只执行一次）
  Future<bool> recoverSession() async {
    final running = _recovering;
    if (running != null) return running;
    final future = _doRecover();
    _recovering = future;
    try {
      return await future;
    } finally {
      _recovering = null;
    }
  }

  Future<bool> _doRecover() async {
    if (await refreshSession()) return true;
    final account = currentAccount;
    if (account == null) return false;
    try {
      await login(
        schoolCode: account.schoolCode,
        schoolName: account.schoolName,
        userName: account.userName,
        password: account.password,
        webServer: account.webServer,
        silent: true,
      );
      return true;
    } catch (e) {
      _lastError = errorText(e);
      return false;
    }
  }

  Future<void> clearSession() async {
    session.clear();
    _stopAutoRefresh();
    await LocalStore.instance.deleteSecret(LocalStore.keySession);
    notifyListeners();
  }

  /// 退出登录（保留账号，便于下次一键切换）
  Future<void> logout() async {
    await clearSession();
  }

  void startAutoRefresh() {
    _stopAutoRefresh();
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (session.token.isEmpty) return;
      if (session.shouldRefresh && session.canRefresh) {
        refreshSession();
      }
    });
  }

  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  void _setBusy(bool value, [String text = '']) {
    _busy = value;
    _busyText = text;
    notifyListeners();
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  void clearBlock() {
    if (_blockMessage == null) return;
    _blockMessage = null;
    notifyListeners();
  }
}
