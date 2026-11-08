import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/app_config.dart';

/// 强制更新信息载体：服务器版本号与更新说明。
class ForceUpdateInfo {
  const ForceUpdateInfo(this.version, this.message);
  final String version;
  final String message;
}

/// 强制更新页：检测到新版本后全屏拦截，不可返回或关闭，只能前往项目主页查看。
class ForceUpdatePage extends StatelessWidget {
  const ForceUpdatePage({required this.info, super.key});

  final ForceUpdateInfo info;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.system_update_alt, size: 56),
                    const SizedBox(height: 16),
                    const Text(
                      '发现新版本',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '当前版本 ${AppConfig.appVersion}，请更新到 '
                      '${info.version} 后继续使用',
                      textAlign: TextAlign.center,
                    ),
                    if (info.message.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      const Text(
                        '更新说明',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        info.message,
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () async {
                        final uri = Uri.tryParse(AppConfig.projectUrl);
                        if (uri != null && await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('前往项目主页查看新版本'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
