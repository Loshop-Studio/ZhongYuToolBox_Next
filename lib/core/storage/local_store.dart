import 'app_file_store.dart';

/// 应用本地数据存储：账号 / 会话 / 偏好全部落在应用数据目录的 JSON 文件里。
///
/// - accounts.json：已添加账号（含自动登录凭据）
/// - session.json ：当前 token 与学校地址
/// - settings.json：非敏感偏好（上次账号、渲染器选择等）
class LocalStore {
  LocalStore._();

  static final LocalStore instance = LocalStore._();

  static const String keyAccounts = 'zy_accounts';
  static const String keySession = 'zy_session';
  static const String keyLastAccount = 'zy_last_account';
  static const String keyNoteRenderer = 'zy_note_renderer';
  static const String keyMistakeBookVersion = 'zy_mistakebook_version';

  final AppFileStore _files = AppFileStore.instance;
  Map<String, String> _settings = <String, String>{};
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await _files.directory();
    final stored = await _files.readJson('settings.json');
    _settings = stored.map((key, value) => MapEntry(key, value.toString()));
    _initialized = true;
  }

  String _fileName(String key) {
    switch (key) {
      case keyAccounts:
        return 'accounts.json';
      case keySession:
        return 'session.json';
      default:
        return '${key.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}.json';
    }
  }

  Future<String?> readSecret(String key) async {
    await init();
    return _files.readText(_fileName(key));
  }

  Future<void> writeSecret(String key, String value) async {
    await init();
    await _files.writeText(_fileName(key), value);
  }

  Future<void> deleteSecret(String key) async {
    await init();
    await _files.delete(_fileName(key));
  }

  String? getString(String key) => _settings[key];

  Future<void> setString(String key, String value) async {
    await init();
    _settings[key] = value;
    await _files.writeJson('settings.json', Map<String, dynamic>.from(_settings));
  }

  Future<void> removeString(String key) async {
    await init();
    _settings.remove(key);
    await _files.writeJson('settings.json', Map<String, dynamic>.from(_settings));
  }

  Future<String> dataDirectoryPath() => _files.dataDirectoryPath();
}
