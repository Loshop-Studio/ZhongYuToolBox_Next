import 'package:flutter/material.dart';

import '../../core/responsive/breakpoints.dart';
import '../../core/theme/app_theme.dart';

/// 一个操作项（移动端底部抽屉 / 桌面端 MD3 菜单共用）
class AppAction {
  const AppAction({
    required this.value,
    required this.label,
    this.icon,
    this.subtitle,
    this.danger = false,
    this.enabled = true,
  });

  final String value;
  final String label;
  final IconData? icon;
  final String? subtitle;
  final bool danger;
  final bool enabled;
}

/// 操作菜单：
/// - 移动端：底部抽屉（带拖拽手柄）
/// - 桌面端：MD3 菜单，在 [anchor] 附近弹出（空间不足会自动向上展开）
///
/// [anchor] 是全局坐标（按钮中心或鼠标右键位置）；为空时落在屏幕中间。
Future<String?> showAppActions(
  BuildContext context, {
  required String title,
  required List<AppAction> actions,
  Offset? anchor,
}) {
  if (context.isDesktopLayout) {
    return _showMenu(context, title, actions, anchor);
  }
  return _showSheet(context, title, actions);
}

Future<String?> _showMenu(
  BuildContext context,
  String title,
  List<AppAction> actions,
  Offset? anchor,
) async {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
  final size = overlay?.size ?? MediaQuery.sizeOf(context);
  final point = anchor ?? Offset(size.width / 2, size.height / 2);
  final dx = point.dx.clamp(0.0, size.width);
  final dy = point.dy.clamp(0.0, size.height);

  final result = await showMenu<String>(
    context: context,
    position: RelativeRect.fromLTRB(dx, dy, size.width - dx, size.height - dy),
    items: [
      for (final action in actions)
        PopupMenuItem<String>(
          value: action.value,
          enabled: action.enabled,
          child: Row(
            children: [
              if (action.icon != null) ...[
                Icon(
                  action.icon,
                  size: 18,
                  color: action.danger ? AppColors.danger : null,
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      action.label,
                      style: action.danger
                          ? const TextStyle(color: AppColors.danger)
                          : null,
                    ),
                    if (action.subtitle != null)
                      Text(
                        action.subtitle!,
                        style: const TextStyle(fontSize: 11),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
    ],
  );
  return result;
}

Future<String?> _showSheet(
  BuildContext context,
  String title,
  List<AppAction> actions,
) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final action in actions)
            ListTile(
              enabled: action.enabled,
              leading: action.icon == null
                  ? null
                  : Icon(
                      action.icon,
                      color: action.danger ? AppColors.danger : null,
                    ),
              title: Text(
                action.label,
                style: action.danger
                    ? const TextStyle(color: AppColors.danger)
                    : null,
              ),
              subtitle: action.subtitle == null
                  ? null
                  : Text(
                      action.subtitle!,
                      style: const TextStyle(fontSize: 11),
                    ),
              onTap: action.enabled
                  ? () => Navigator.of(ctx).pop(action.value)
                  : null,
            ),
        ],
      ),
    ),
  );
}
