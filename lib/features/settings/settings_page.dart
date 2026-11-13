import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../core/storage/image_cache_manager.dart';
import '../../core/storage/local_store.dart';
import '../../core/storage/session_manager.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_prefs.dart';
import '../../data/models/account.dart';
import '../../shared/widgets/common.dart';
import '../auth/account_tile.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SessionManager _session = SessionManager.instance;
  String? _switchingId;
  bool _clearingImageCache = false;

  static const List<Color> _presets = [
    ThemePrefs.defaultBlue,
    Color(0xFFC62828),
    Color(0xFFAD1457),
    Color(0xFF6A1B9A),
    Color(0xFF4527A0),
    Color(0xFF283593),
    Color(0xFF00897B),
    Color(0xFF2E7D32),
    Color(0xFFEF6C00),
    Color(0xFF5D4037),
    Color(0xFF37474F),
  ];

  @override
  void initState() {
    super.initState();
    _session.addListener(_onChanged);
    ThemePrefs.instance.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _session.removeListener(_onChanged);
    ThemePrefs.instance.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  Widget _buildThemeSection() {
    final theme = ThemePrefs.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: const Text('主题色'),
          subtitle: const Text('默认跟随系统，读不到时回退蓝色'),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: SegmentedButton<ThemeColorMode>(
            segments: const [
              ButtonSegment<ThemeColorMode>(
                value: ThemeColorMode.system,
                label: Text('跟随系统'),
                icon: Icon(Icons.auto_awesome_outlined),
              ),
              ButtonSegment<ThemeColorMode>(
                value: ThemeColorMode.custom,
                label: Text('自定义'),
                icon: Icon(Icons.build_outlined),
              ),
            ],
            selected: {theme.mode},
            onSelectionChanged: (selected) =>
                theme.setMode(selected.first),
          ),
        ),
        if (theme.mode == ThemeColorMode.custom) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final color in _presets)
                  _ColorSwatch(
                    color: color,
                    selected: theme.customColor.toARGB32() == color.toARGB32(),
                    onTap: () => theme.setCustomColor(color),
                  ),
                _ColorSwatch(
                  color: theme.customColor,
                  custom: true,
                  selected: !_presets
                      .any((c) => c.toARGB32() == theme.customColor.toARGB32()),
                  onTap: _pickCustomColor,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickCustomColor() async {
    final theme = ThemePrefs.instance;
    Color pickerColor = theme.customColor;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('自定义主题色'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (c) => pickerColor = c,
            enableAlpha: false,
            labelTypes: const [ColorLabelType.hex],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (result == true && mounted) {
      await theme.setCustomColor(pickerColor);
    }
  }

  Future<void> _switch(Account account) async {
    if (_switchingId != null) return;
    if (_session.currentAccount?.id == account.id && _session.isLoggedIn) {
      showToast(context, '已经是当前账号');
      return;
    }
    setState(() => _switchingId = account.id);
    try {
      final ok = await _session.autoLoginFor(account);
      if (!mounted) return;
      if (ok) {
        context.go('/home');
      } else {
        showToast(context, _session.lastError ?? '登录失败，请检查账号密码');
      }
    } finally {
      if (mounted) setState(() => _switchingId = null);
    }
  }

  Future<void> _clearImageCache() async {
    final confirmed = await confirmDialog(
      context,
      title: '清除图片缓存',
      content: '将删除图库、领创图标和随身答图片的本地缓存。下次查看时会重新下载。',
      confirmText: '清除',
      danger: true,
    );
    if (!confirmed || !mounted) return;
    setState(() => _clearingImageCache = true);
    try {
      await ZyImageCacheManager.clear();
      if (mounted) showToast(context, '图片缓存已清除');
    } catch (e) {
      if (mounted) showToast(context, '清除图片缓存失败：$e');
    } finally {
      if (mounted) setState(() => _clearingImageCache = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    final accounts = session.accounts;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: const Text('设置'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              ListTile(
                leading: const Icon(Icons.people_outline),
                title: const Text('账号'),
                subtitle: const Text('点击切换账号，长按（桌面右键）删除'),
                trailing: TextButton.icon(
                  onPressed: () => context.push('/add-account'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('添加'),
                ),
              ),
              if (accounts.isEmpty)
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(session.displayName),
                  subtitle: Text(
                    '${session.schoolLabel} · 尚未添加账号',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => context.push('/login'),
                )
              else
                for (final account in accounts)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: AccountTile(
                      account: account,
                      active:
                          session.currentAccount?.id == account.id &&
                          session.isLoggedIn,
                      busy: _switchingId == account.id,
                      onTap: () => _switch(account),
                      onMore: (position) => showAccountActions(
                        context,
                        account,
                        anchor: position,
                      ),
                    ),
                  ),
              const Divider(),
              _buildThemeSection(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_sweep_outlined),
                title: const Text('清除图片缓存'),
                subtitle: const Text('图库、领创图标和随身答图片'),
                trailing: _clearingImageCache
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: _clearingImageCache ? null : _clearImageCache,
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('版本'),
                subtitle: const Text(AppConfig.appVersion),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('关于'),
                subtitle: const Text('版本信息、更新日志与支持'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/about'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.groups_outlined),
                title: const Text('问题反馈'),
                subtitle: Text('QQ 群 ${AppConfig.supportQqGroup}'),
              ),
              FutureBuilder<String>(
                future: LocalStore.instance.dataDirectoryPath(),
                builder: (context, snapshot) => ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: const Text('数据目录'),
                  subtitle: Text(
                    snapshot.data ?? '正在读取…',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.danger),
                title: const Text(
                  '退出登录',
                  style: TextStyle(color: AppColors.danger),
                ),
                subtitle: const Text('账号仍会保留，可随时一键登录'),
                onTap: () async {
                  final ok = await confirmDialog(
                    context,
                    title: '退出登录',
                    content: '退出后需要重新点击账号登录，账号信息会保留在本机。',
                    confirmText: '退出',
                    danger: true,
                  );
                  if (!ok) return;
                  await SessionManager.instance.logout();
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 主题色选择圆点；选中时显示描边，自定义项显示「+」。
class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.onTap,
    this.selected = false,
    this.custom = false,
  });

  final Color color;
  final VoidCallback onTap;
  final bool selected;
  final bool custom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected
              ? Border.all(color: theme.colorScheme.onSurface, width: 3)
              : null,
        ),
        child: custom
            ? const Icon(Icons.add, color: Colors.white, size: 20)
            : null,
      ),
    );
  }
}
