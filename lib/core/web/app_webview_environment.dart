import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';

/// Shared Windows WebView2 environment.
///
/// WebView2 otherwise creates its user data next to the executable. That path
/// is not writable after the app is installed under Program Files.
abstract final class AppWebViewEnvironment {
  static WebViewEnvironment? instance;
  static String? initializationError;

  static Future<void> initialize() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.windows) return;

    try {
      final runtimeVersion = await WebViewEnvironment.getAvailableVersion();
      if (runtimeVersion == null) {
        initializationError = '未检测到 Microsoft Edge WebView2 Runtime，请安装后重启应用';
        return;
      }

      final cacheDirectory = await getApplicationCacheDirectory();
      final userDataDirectory = Directory(
        '${cacheDirectory.path}${Platform.pathSeparator}webview2',
      );
      await userDataDirectory.create(recursive: true);

      instance = await WebViewEnvironment.create(
        settings: WebViewEnvironmentSettings(
          userDataFolder: userDataDirectory.path,
        ),
      ).timeout(const Duration(seconds: 15));
    } catch (error, stackTrace) {
      initializationError =
          'WebView2 初始化失败，请重启应用或重新安装 WebView2 Runtime。\n$error';
      debugPrint('$initializationError\n$stackTrace');
    }
  }
}
