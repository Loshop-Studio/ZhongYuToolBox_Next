import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/storage/session_manager.dart';
import '../../core/theme/app_theme.dart';

/// 封禁全屏阻断（复刻 ForceBlock）
class BlockPage extends StatelessWidget {
  const BlockPage({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.block, size: 56, color: AppColors.danger),
                  const SizedBox(height: 16),
                  const Text(
                    '账号已被封禁',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () async {
                      SessionManager.instance.clearBlock();
                      await SessionManager.instance.logout();
                    },
                    child: const Text('退出登录'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'QQ 群 ${AppConfig.supportQqGroup}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
