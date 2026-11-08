import 'package:flutter/widgets.dart';

class Breakpoints {
  Breakpoints._();

  /// 桌面布局断点
  static const double desktop = 900;

  /// 平板断点
  static const double tablet = 600;
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  bool get isDesktopLayout => screenWidth >= Breakpoints.desktop;

  bool get isTabletLayout =>
      screenWidth >= Breakpoints.tablet && screenWidth < Breakpoints.desktop;

  bool get isPhoneLayout => screenWidth < Breakpoints.tablet;
}
