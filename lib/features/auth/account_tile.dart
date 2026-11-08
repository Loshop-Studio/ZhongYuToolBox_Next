import 'package:flutter/material.dart';

import '../../core/responsive/breakpoints.dart';
import '../../core/storage/session_manager.dart';
import '../../core/util/formatters.dart';
import '../../data/models/account.dart';
import '../../shared/widgets/app_actions.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/user_avatar.dart';

/// 本机账号卡片（登录页 / 设置页共用）
///
/// 移动端长按、桌面端右键都会弹出账号操作（目前只有删除）。
class AccountTile extends StatelessWidget {
  const AccountTile({
    super.key,
    required this.account,
    required this.active,
    required this.busy,
    required this.onTap,
    required this.onMore,
  });

  final Account account;
  final bool active;
  final bool busy;
  final VoidCallback onTap;

  /// 移动端长按 / 桌面端右键
  final void Function(Offset? position) onMore;

  @override
  Widget build(BuildContext context) {
    final name = account.displayName;
    final desktop = context.isDesktopLayout;
    final lastLogin = account.lastLoginAt == null
        ? '尚未登录'
        : '上次登录：${formatDateTime(account.lastLoginAt!.toIso8601String())}';
    return GestureDetector(
      onSecondaryTapDown: desktop
          ? (details) => onMore(details.globalPosition)
          : null,
      child: Card(
        child: ListTile(
          isThreeLine: true,
          leading: UserAvatar(
            name: name,
            photo: account.photo,
            apiBaseUrl: account.apiBaseUrl,
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              if (active) ...[
                const SizedBox(width: 8),
                const Chip(label: Text('当前')),
              ],
            ],
          ),
          subtitle: Text(
            '${account.schoolLabel} · ${account.userName}\n$lastLogin',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.chevron_right),
          onTap: busy ? null : onTap,
          onLongPress: () => onMore(null),
        ),
      ),
    );
  }
}

/// 账号操作菜单 + 删除确认（桌面右键 / 移动端长按）
Future<void> showAccountActions(
  BuildContext context,
  Account account, {
  Offset? anchor,
}) async {
  final action = await showAppActions(
    context,
    title: '账号操作',
    anchor: anchor,
    actions: const [
      AppAction(value: 'delete', label: '删除账号', icon: Icons.delete_outline),
    ],
  );
  if (action != 'delete' || !context.mounted) return;
  final ok = await confirmDialog(
    context,
    title: '删除账号',
    content: '将从本机移除「${account.displayName}」的登录信息，可随时重新添加。',
    confirmText: '删除',
    danger: true,
  );
  if (ok) await SessionManager.instance.removeAccount(account);
}
