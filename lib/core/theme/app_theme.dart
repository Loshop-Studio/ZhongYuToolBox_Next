import 'package:flutter/material.dart';

import 'theme_prefs.dart';

/// 亮色主题：以单一主题色作为 colorScheme 种子，整体派生配色。
class AppTheme {
  AppTheme._();

  static ThemeData light([Color? seed]) => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seed ?? ThemePrefs.defaultBlue,
        appBarTheme: const AppBarTheme(centerTitle: false),
      );
}

/// Material 3 默认亮色配色（baseline purple）的语义别名。
///
/// 仅在少数无法直接拿到 BuildContext 的常量位置使用；组件内一律优先
/// 用 Theme.of(context).colorScheme。
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6750A4);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFEADDFF);
  static const Color onPrimaryContainer = Color(0xFF21005D);
  static const Color secondaryContainer = Color(0xFFE8DEF8);
  static const Color tertiary = Color(0xFF7D5260);
  static const Color tertiaryContainer = Color(0xFFFFD8E4);
  static const Color onTertiaryContainer = Color(0xFF31111D);
  static const Color background = Color(0xFFFFFBFE);
  static const Color card = Color(0xFFFFFBFE);
  static const Color surface = Color(0xFFFFFBFE);
  static const Color field = Color(0xFFE6E0E9);
  static const Color surfaceContainerHighest = Color(0xFFE6E0E9);
  static const Color border = Color(0xFFCAC4D0);
  static const Color outline = Color(0xFF79747E);
  static const Color textPrimary = Color(0xFF1D1B20);
  static const Color textSecondary = Color(0xFF49454F);
  static const Color danger = Color(0xFFB3261E);
  static const Color success = Color(0xFF2E7D32);
}
