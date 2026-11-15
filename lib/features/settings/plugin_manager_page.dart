import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/plugins/plugin_manager.dart';
import '../../core/plugins/plugin_models.dart';
import '../../shared/widgets/common.dart';

class PluginManagerPage extends StatefulWidget {
  const PluginManagerPage({super.key});

  @override
  State<PluginManagerPage> createState() => _PluginManagerPageState();
}

class _PluginManagerPageState extends State<PluginManagerPage> {
  final PluginManager _manager = PluginManager.instance;
  bool _importing = false;

  @override
  void initState() {
    super.initState();
    _manager.addListener(_onChanged);
  }

  @override
  void dispose() {
    _manager.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _import() async {
    if (_importing) return;
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: '选择中育 Toolbox 插件',
      type: FileType.custom,
      allowedExtensions: const ['zytbplugin', 'zip'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.single;
    Uint8List? bytes = picked.bytes;
    if ((bytes == null || bytes.isEmpty) && picked.path != null) {
      bytes = await File(picked.path!).readAsBytes();
    }
    if (!mounted) return;
    if (bytes == null || bytes.isEmpty) {
      showToast(context, '无法读取插件包');
      return;
    }

    try {
      final manifest = _manager.inspectPackage(bytes);
      final existing = _manager.plugins.any(
        (plugin) => plugin.manifest.id == manifest.id,
      );
      final confirmed = await _confirmInstall(manifest, update: existing);
      if (!confirmed || !mounted) return;
      setState(() => _importing = true);
      await _manager.installPackage(bytes);
      if (mounted) showToast(context, existing ? '插件已更新' : '插件已安装');
    } catch (e) {
      if (mounted) showToast(context, errorText(e));
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<bool> _confirmInstall(
    PluginManifest manifest, {
    required bool update,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${update ? '更新' : '安装'}「${manifest.name}」'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '版本 ${manifest.version}${manifest.author.isEmpty ? '' : ' · ${manifest.author}'}',
              ),
              if (manifest.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(manifest.description),
              ],
              const SizedBox(height: 16),
              Text(
                '高权限提醒',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '插件将获得完整本地文件系统读写权限、任意 HTTP/HTTPS 网络访问权限，'
                '并能读取当前账号的 token、API 地址、用户名和头像。请只安装你信任的插件。',
              ),
              const SizedBox(height: 12),
              Text(
                '注册 ${manifest.pages.length} 个页面、${manifest.actions.length} 个入口。',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(update ? '信任并更新' : '信任并安装'),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  Future<void> _remove(InstalledPlugin plugin) async {
    final confirmed = await confirmDialog(
      context,
      title: '卸载插件',
      content: '确定卸载「${plugin.manifest.name}」？插件目录及其中数据会一并删除。',
      confirmText: '卸载',
      danger: true,
    );
    if (!confirmed) return;
    try {
      await _manager.remove(plugin.manifest.id);
      if (mounted) showToast(context, '插件已卸载');
    } catch (e) {
      if (mounted) showToast(context, '卸载失败：$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final plugins = _manager.plugins;
    return Scaffold(
      appBar: AppBar(
        title: const Text('插件'),
        actions: [
          TextButton.icon(
            onPressed: _importing ? null : _import,
            icon: _importing
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add, size: 18),
            label: const Text('导入'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: plugins.isEmpty
              ? const EmptyView(
                  icon: Icons.extension_outlined,
                  text: '还没有安装插件\n可从右上角导入 .zytbplugin 文件',
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: plugins.length + 1,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const ListTile(
                        leading: Icon(Icons.warning_amber_outlined),
                        title: Text('插件拥有高权限'),
                        subtitle: Text('可读写全部本地文件、访问网络并读取当前登录凭据，请只安装可信插件。'),
                      );
                    }
                    final plugin = plugins[index - 1];
                    return _PluginTile(
                      key: ValueKey(plugin.manifest.id),
                      plugin: plugin,
                      onEnabledChanged: (value) =>
                          _manager.setEnabled(plugin.manifest.id, value),
                      onRemove: () => _remove(plugin),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _PluginTile extends StatefulWidget {
  const _PluginTile({
    super.key,
    required this.plugin,
    required this.onEnabledChanged,
    required this.onRemove,
  });

  final InstalledPlugin plugin;
  final ValueChanged<bool> onEnabledChanged;
  final VoidCallback onRemove;

  @override
  State<_PluginTile> createState() => _PluginTileState();
}

class _PluginTileState extends State<_PluginTile> {
  bool _expanded = false;

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final plugin = widget.plugin;
    final manifest = plugin.manifest;
    final errorColor = Theme.of(context).colorScheme.error;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          expanded: _expanded,
          child: ListTile(
            onTap: _toggleExpanded,
            leading: const Icon(Icons.extension_outlined),
            title: Text(manifest.name),
            subtitle: Text(
              'v${manifest.version}${manifest.author.isEmpty ? '' : ' · ${manifest.author}'}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: plugin.enabled,
                  onChanged: widget.onEnabledChanged,
                ),
                IconButton(
                  onPressed: _toggleExpanded,
                  tooltip: _expanded ? '收起插件详情' : '展开插件详情',
                  icon: AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: _expanded
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (manifest.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(manifest.description),
                        ),
                      ),
                    for (final action in manifest.actions)
                      ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        leading: Icon(pluginIcon(action.icon), size: 20),
                        title: Text(action.label),
                        subtitle: Text('${action.posId} → ${action.pageId}'),
                      ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                      ),
                      leading: Icon(Icons.delete_outline, color: errorColor),
                      title: Text('卸载插件', style: TextStyle(color: errorColor)),
                      onTap: widget.onRemove,
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
