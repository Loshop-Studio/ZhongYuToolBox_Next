import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/config/app_config.dart';
import 'core/storage/session_manager.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_prefs.dart';
import 'data/api/track_api.dart';
import 'features/about/force_update_page.dart';
import 'features/auth/block_page.dart';
import 'router.dart';

class ZhongYuApp extends StatefulWidget {
  const ZhongYuApp({super.key});

  @override
  State<ZhongYuApp> createState() => _ZhongYuAppState();
}

class _ZhongYuAppState extends State<ZhongYuApp> {
  bool _ready = false;
  ForceUpdateInfo? _forceUpdate;

  static const Locale _locale = Locale('zh', 'CN');
  static const List<LocalizationsDelegate<dynamic>> _delegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  @override
  void initState() {
    super.initState();
    ThemePrefs.instance.addListener(_onThemeChanged);
    _bootstrap();
  }

  @override
  void dispose() {
    ThemePrefs.instance.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _bootstrap() async {
    final session = SessionManager.instance;
    await session.bootstrap();
    await ThemePrefs.instance.init();

    // 启动强制更新检测：仅用 electron 渠道（Flutter 端共用）。
    // 接口不返回下载链接，仅用于判断是否需要强制升级。
    // 检测失败或版本号不可解析时不拦截，保证服务异常时仍可正常使用。
    try {
      final data = await TrackApi.fetchVersion();
      if (data != null) {
        final info = data['electron'];
        if (info is Map) {
          final serverVersion = (info['version'] ?? '').toString();
          if (serverVersion.isNotEmpty &&
              _compareVersion(serverVersion, AppConfig.appVersion) == 1) {
            _forceUpdate = ForceUpdateInfo(
              serverVersion,
              (info['message'] ?? '').toString(),
            );
          }
        }
      }
    } catch (_) {
      /* 忽略，不拦截 */
    }

    // 打开应用即用本地凭据静默登录
    if (session.currentAccount != null && !session.isLoggedIn) {
      await session.autoLogin();
    }
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.light(ThemePrefs.instance.seedColor);
    if (!_ready) {
      return MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: theme,
        locale: _locale,
        supportedLocales: const [_locale],
        localizationsDelegates: _delegates,
        home: const _SplashPage(),
      );
    }
    // 强制更新优先于一切：不可关闭，只能前往更新。
    if (_forceUpdate != null) {
      return MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: theme,
        locale: _locale,
        supportedLocales: const [_locale],
        localizationsDelegates: _delegates,
        home: ForceUpdatePage(info: _forceUpdate!),
      );
    }
    return ListenableBuilder(
      listenable: SessionManager.instance,
      builder: (context, _) {
        final block = SessionManager.instance.blockMessage;
        if (block != null) {
          return MaterialApp(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: theme,
            locale: _locale,
            supportedLocales: const [_locale],
            localizationsDelegates: _delegates,
            home: BlockPage(message: block),
          );
        }
        return MaterialApp.router(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,
          theme: theme,
          locale: _locale,
          supportedLocales: const [_locale],
          localizationsDelegates: _delegates,
          routerConfig: appRouter,
        );
      },
    );
  }

  static int? _compareVersion(String a, String b) {
    final pa = _parseVersion(a);
    final pb = _parseVersion(b);
    if (pa == null || pb == null) return null;
    for (var i = 0; i < 3; i++) {
      if (pa[i] != pb[i]) return pa[i] > pb[i] ? 1 : -1;
    }
    return 0;
  }

  static List<int>? _parseVersion(String v) {
    final m = RegExp(r'(\d+)\.(\d+)\.(\d+)').firstMatch(v.trim());
    if (m == null) return null;
    return <int>[
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
    ];
  }
}

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/icon/icon.png', width: 96, height: 96),
            const SizedBox(height: 16),
            const Text(
              '中育Toolbox',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
