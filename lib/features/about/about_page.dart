import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/app_config.dart';
import '../../data/api/track_api.dart';
import '../../features/about/force_update_page.dart';
import '../../shared/widgets/common.dart';

/// 关于与支持（复刻 AboutView / DonateView）
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late final Player _backgroundPlayer;
  bool _checking = false;
  String _versionMessage = '';
  List<String> _changelog = const <String>[];

  @override
  void initState() {
    super.initState();
    _backgroundPlayer = Player();
    _backgroundPlayer.setPlaylistMode(PlaylistMode.loop);
    _startBackgroundMusic();
    _loadChangelog();
  }

  Future<void> _startBackgroundMusic() async {
    try {
      final media = Media('asset:///assets/about_theme.aac');
      await _backgroundPlayer.open(media);
    } catch (_) {
      // 资源未随旧构建产物更新时，不阻塞关于页打开。
    }
  }

  @override
  void dispose() {
    _backgroundPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadChangelog() async {
    try {
      final json = await rootBundle.loadString('assets/changelog.json');
      final data = jsonDecode(json) as Map<String, dynamic>;
      final list = (data['changelog'] as List? ?? <dynamic>[])
          .map((e) {
            final m = e as Map<String, dynamic>;
            final version = (m['version'] ?? '').toString();
            final text = (m['text'] ?? '').toString();
            return version.isEmpty ? text : '$version $text';
          })
          .where((e) => e.isNotEmpty)
          .toList()
          .reversed
          .toList();
      if (mounted) setState(() => _changelog = list);
    } catch (_) {
      /* 配置文件缺失不影响其余功能 */
    }
  }

  Future<void> _checkUpdate() async {
    setState(() {
      _checking = true;
      _versionMessage = '';
    });
    try {
      // 仅用国内 track 接口（tbapi.loshop.com.cn/api/version）。
      // Flutter 端更新分发与 electron 桌面版共用同一个版本渠道。
      final data = await TrackApi.fetchVersion();
      if (data == null) {
        setState(() => _versionMessage = '检查更新失败，请稍后重试');
        return;
      }
      final info = data['electron'];
      final serverVersion = info is Map ? (info['version'] ?? '').toString() : '';
      if (serverVersion.isEmpty) {
        setState(() => _versionMessage = '已是最新版本');
        return;
      }
      final notes = info is Map ? (info['message'] ?? '').toString() : '';
      final cmp = _compareVersion(serverVersion, AppConfig.appVersion);
      if (cmp == null || cmp == 0) {
        setState(() => _versionMessage = '已是最新版本 $serverVersion');
      } else if (cmp > 0) {
        // 发现新版本：直接接管为不可关闭的强制更新页。
        if (mounted) {
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => ForceUpdatePage(
                info: ForceUpdateInfo(serverVersion, notes),
              ),
            ),
          );
        }
      } else {
        setState(() => _versionMessage =
            '当前为开发/测试版本（服务器 $serverVersion）');
      }
    } catch (_) {
      if (mounted) setState(() => _versionMessage = '检查更新失败，请稍后重试');
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      showToast(context, '无法打开链接');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: const Text('关于与支持'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              const ListTile(
                leading: Icon(Icons.apps),
                title: Text(AppConfig.appName),
                subtitle: Text('版本 ${AppConfig.appVersion}'),
              ),
              ListTile(
                leading: const Icon(Icons.system_update_alt),
                title: const Text('检查更新'),
                subtitle: Text(
                  _versionMessage.isEmpty ? '从服务器获取最新版本' : _versionMessage,
                ),
                trailing: _checking
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onTap: _checking ? null : _checkUpdate,
              ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: const Text('说明'),
                subtitle: const Text(
                  '本工具用于快捷查看中育账号资源，与中育智慧（无锡）数字技术有限公司及其关联公司无关。',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.groups_outlined),
                title: const Text('问题反馈'),
                subtitle: const Text('QQ 群 ${AppConfig.supportQqGroup}'),
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('项目主页'),
                subtitle: Text(AppConfig.projectUrl),
                onTap: () => _openUrl(AppConfig.projectUrl),
              ),
              ListTile(
                leading: const Icon(Icons.favorite_outline),
                title: const Text('支持作者'),
                subtitle: const Text('打赏与赞助（爱发电）'),
                onTap: () => _openUrl('https://afdian.com/a/loshopwu'),
              ),
              const Divider(),
              if (_changelog.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text('更新日志',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                for (final line in _changelog)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.history, size: 18),
                    title: Text(line, style: const TextStyle(fontSize: 13)),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
