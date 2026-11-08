import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:win32_registry/win32_registry.dart';

import '../storage/local_store.dart';

/// 主题色模式：跟随系统 / 自定义。
enum ThemeColorMode {
  system,
  custom,
}

/// 主题色偏好（持久化到 LocalStore.settings.json）。
///
/// - 跟随系统：Android 读取 Material You 取色；Windows 读取系统强调色；
///   两者都读取不到时回退为默认蓝色。
/// - 自定义：使用用户在设置里选定的颜色。
class ThemePrefs extends ChangeNotifier {
  ThemePrefs._();

  static final ThemePrefs instance = ThemePrefs._();

  static const String _kMode = 'zy_theme_color_mode';
  static const String _kColor = 'zy_theme_color';

  /// 读不到系统色时的默认蓝。
  static const Color defaultBlue = Color(0xFF1565C0);

  ThemeColorMode _mode = ThemeColorMode.system;
  Color _customColor = defaultBlue;
  Color _seedColor = defaultBlue;

  ThemeColorMode get mode => _mode;
  Color get customColor => _customColor;

  /// 当前生效的主题色（已解析系统色或用户自定义色）。
  Color get seedColor => _seedColor;

  Future<void> init() async {
    final modeStr = LocalStore.instance.getString(_kMode);
    _mode =
        modeStr == 'custom' ? ThemeColorMode.custom : ThemeColorMode.system;
    final c = LocalStore.instance.getString(_kColor);
    final parsed = c == null ? null : int.tryParse(c);
    if (parsed != null) _customColor = Color(parsed);
    await _resolve();
  }

  Future<void> _resolve() async {
    if (_mode == ThemeColorMode.custom) {
      _seedColor = _customColor;
    } else {
      _seedColor = await _systemColor() ?? defaultBlue;
    }
    notifyListeners();
  }

  Future<void> setMode(ThemeColorMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    await LocalStore.instance.setString(
      _kMode,
      mode == ThemeColorMode.custom ? 'custom' : 'system',
    );
    await _resolve();
  }

  Future<void> setCustomColor(Color color) async {
    _customColor = color;
    await LocalStore.instance.setString(_kColor, color.toARGB32().toString());
    if (_mode == ThemeColorMode.custom) {
      _seedColor = color;
      notifyListeners();
    }
  }

  /// 读取平台系统强调色；不支持或失败返回 null。
  static Future<Color?> _systemColor() async {
    if (kIsWeb) return null;
    if (Platform.isAndroid) return _androidColor();
    if (Platform.isWindows) return _windowsAccent();
    return null;
  }

  static Future<Color?> _androidColor() async {
    try {
      final palette = await DynamicColorPlugin.getCorePalette();
      final value = palette?.primary.get(40);
      if (value != null) return Color(value);
    } catch (_) {
      // Android < 12 或取色失败，回退默认蓝。
    }
    return null;
  }

  /// 读取 Windows 标题栏/强调色（DWM ColorizationColor，REG_DWORD）。
  static Color? _windowsAccent() {
    try {
      final key = Registry.openPath(
        RegistryHive.currentUser,
        path: r'Software\Microsoft\Windows\DWM',
      );
      final value = key.getValue('ColorizationColor');
      key.close();
      if (value != null && value.type == RegistryValueType.int32) {
        final raw = value.data as int;
        // ColorizationColor 以 0x00BBGGRR 形式存储。
        final r = raw & 0xFF;
        final g = (raw >> 8) & 0xFF;
        final b = (raw >> 16) & 0xFF;
        return Color.fromRGBO(r, g, b, 1);
      }
    } catch (_) {
      // 注册表不可读时回退默认蓝。
    }
    return null;
  }
}
