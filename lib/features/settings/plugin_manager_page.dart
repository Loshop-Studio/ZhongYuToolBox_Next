import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/plugins/plugin_manager.dart';
import '../../core/plugins/plugin_models.dart';
import '../../core/plugins/plugin_source_models.dart';
import '../../shared/widgets/common.dart';

class PluginManagerPage extends StatefulWidget {
  const PluginManagerPage({super.key});

  @override
  State<PluginManagerPage> createState() => _PluginManagerPageState();
}

class _PluginManagerPageState extends State<PluginManagerPage>
    with SingleTickerProviderStateMixin {
  final PluginManager _manager = PluginManager.instance;
  late final TabController _tabController;
  bool _importing = false;
  bool _addingSource = false;
  String? _busySourceUrl;
  String? _catalogInstallingId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _manager.addListener(_onChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _manager.catalog.isEmpty) _refreshCatalog();
    });
  }

  @override
  void dispose() {
    _manager.removeListener(_onChanged);
    _tabController.dispose();
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
    String? warning,
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
              if (warning != null) ...[
                const SizedBox(height: 12),
                Text(
                  warning,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
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

  Future<void> _refreshCatalog() async {
    try {
      await _manager.refreshCatalog();
    } catch (e) {
      if (mounted) showToast(context, '刷新插件索引失败：${errorText(e)}');
    }
  }

  Future<void> _addSource() async {
    if (_addingSource) return;
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final url = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('添加插件索引源'),
        content: SizedBox(
          width: 440,
          child: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: '索引文件 URL',
                hintText: 'https://example.com/plugins/index.txt',
              ),
              validator: (value) {
                final uri = Uri.tryParse((value ?? '').trim());
                if (uri == null ||
                    !uri.hasAuthority ||
                    (uri.scheme != 'https' && uri.scheme != 'http')) {
                  return '请输入有效的 HTTP/HTTPS 地址';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                if (formKey.currentState?.validate() == true) {
                  Navigator.of(dialogContext).pop(controller.text.trim());
                }
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() == true) {
                Navigator.of(dialogContext).pop(controller.text.trim());
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (url == null || url.isEmpty || !mounted) return;

    setState(() => _addingSource = true);
    try {
      await _manager.addSource(url);
      if (mounted) {
        setState(() => _addingSource = false);
        showToast(context, '插件索引源已添加，正在后台读取索引');
      }
      // Do not keep the add action busy while an unavailable source waits for
      // network timeouts. The catalog page exposes the refresh state and
      // errors independently, so this can safely run in the background.
      unawaited(_refreshCatalog());
    } catch (e) {
      if (mounted) showToast(context, '添加插件索引源失败：${errorText(e)}');
      if (mounted) setState(() => _addingSource = false);
    }
  }

  Future<void> _removeSource(PluginIndexSource source) async {
    if (source.isOfficial || _busySourceUrl != null) return;
    final confirmed = await confirmDialog(
      context,
      title: '移除插件索引源',
      content: '确定移除「${_sourceLabel(source)}」？已安装的插件不会被卸载。',
      confirmText: '移除',
      danger: true,
    );
    if (!confirmed) return;

    setState(() => _busySourceUrl = source.url);
    try {
      await _manager.removeSource(source.url);
      if (mounted) showToast(context, '插件索引源已移除');
    } catch (e) {
      if (mounted) showToast(context, '移除插件索引源失败：${errorText(e)}');
    } finally {
      if (mounted) setState(() => _busySourceUrl = null);
    }
  }

  Future<void> _setSourceAutoUpdate(
    PluginIndexSource source,
    bool enabled,
  ) async {
    if (_busySourceUrl != null) return;
    if (enabled) {
      final confirmed = await confirmDialog(
        context,
        title: '启用自动更新',
        content: '从此来源安装的插件会在后台检查并自动更新。请确认你信任此来源。',
        confirmText: '启用',
      );
      if (!confirmed) return;
    }

    setState(() => _busySourceUrl = source.url);
    try {
      await _manager.setSourceAutoUpdate(source.url, enabled);
    } catch (e) {
      if (mounted) showToast(context, '更新索引源设置失败：${errorText(e)}');
    } finally {
      if (mounted) setState(() => _busySourceUrl = null);
    }
  }

  Future<void> _installFromCatalog(PluginIndexEntry entry) async {
    if (_catalogInstallingId != null) return;
    setState(() => _catalogInstallingId = entry.uuid);
    try {
      final bytes = await _manager.downloadCatalogPlugin(entry);
      final manifest = _manager.inspectPackage(bytes);
      final detailVersion = entry.version == null
          ? entry.detail?.version
          : null;
      final parsedDetailVersion = PluginVersion.tryParse(detailVersion);
      final parsedPackageVersion = PluginVersion.tryParse(manifest.version);
      final metadataWarning =
          parsedDetailVersion != null &&
              (parsedPackageVersion == null ||
                  parsedDetailVersion.compareTo(parsedPackageVersion) != 0)
          ? 'detail.txt 声明版本为 $detailVersion，插件包实际版本为 '
                '${manifest.version}；将以插件包版本为准。'
          : null;
      final installed = _manager.plugins
          .where((plugin) => plugin.manifest.id == manifest.id)
          .firstOrNull;
      if (installed != null) {
        final comparison = _compareVersions(
          manifest.version,
          installed.manifest.version,
        );
        if (comparison != null && comparison <= 0) {
          if (mounted) showToast(context, '当前已安装相同或更新版本');
          return;
        }
      }

      final confirmed = await _confirmInstall(
        manifest,
        update: installed != null,
        warning: metadataWarning,
      );
      if (!confirmed || !mounted) return;
      await _manager.installPackage(bytes, sourceUrl: entry.source.url);
      if (mounted) showToast(context, installed == null ? '插件已安装' : '插件已更新');
    } catch (e) {
      if (mounted) showToast(context, '安装插件失败：${errorText(e)}');
    } finally {
      if (mounted) setState(() => _catalogInstallingId = null);
    }
  }

  String _sourceLabel(PluginIndexSource source) {
    final displayName = source.displayName.trim();
    if (displayName.isNotEmpty) return displayName;
    if (source.isOfficial) return '官方源';
    return Uri.tryParse(source.url)?.host ?? source.url;
  }

  int? _compareVersions(String left, String right) {
    final leftParts = _parseVersion(left);
    final rightParts = _parseVersion(right);
    if (leftParts == null || rightParts == null) return null;
    for (var i = 0; i < 3; i++) {
      final comparison = leftParts[i].compareTo(rightParts[i]);
      if (comparison != 0) return comparison;
    }
    return 0;
  }

  List<int>? _parseVersion(String value) {
    final match = RegExp(r'^(\d+)\.(\d+)\.(\d+)$').firstMatch(value.trim());
    if (match == null) return null;
    return [
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    ];
  }

  Widget _buildInstalled(List<InstalledPlugin> plugins) {
    if (plugins.isEmpty) {
      return const EmptyView(
        icon: Icons.extension_outlined,
        text: '还没有安装插件\n可从右上角导入 .zytbplugin 文件或浏览插件源',
      );
    }
    return ListView.separated(
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
    );
  }

  Widget _buildSources() {
    final sources = _manager.sources;
    final catalog = _manager.catalog;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ListTile(
          title: const Text('索引源'),
          subtitle: Text('${sources.length} 个来源'),
          trailing: IconButton(
            onPressed: _addingSource ? null : _addSource,
            tooltip: '添加索引源',
            icon: _addingSource
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add),
          ),
        ),
        for (final source in sources)
          _SourceTile(
            source: source,
            label: _sourceLabel(source),
            error: _manager.catalogErrors[source.url],
            busy: _busySourceUrl == source.url,
            onAutoUpdateChanged: (value) => _setSourceAutoUpdate(source, value),
            onRemove: source.isOfficial ? null : () => _removeSource(source),
          ),
        const Divider(height: 24),
        ListTile(
          title: const Text('可用插件'),
          subtitle: Text('${catalog.length} 个插件'),
        ),
        if (_manager.isRefreshing && catalog.isEmpty)
          const ListTile(
            leading: SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            title: Text('正在读取索引'),
          )
        else if (catalog.isEmpty)
          ListTile(
            leading: const Icon(Icons.extension_off_outlined),
            title: Text(_manager.catalogErrors.isEmpty ? '没有可用插件' : '无法读取插件索引'),
            subtitle: _manager.catalogErrors.isEmpty
                ? null
                : Text('${_manager.catalogErrors.length} 个索引源读取失败，可点右上角刷新重试。'),
          )
        else
          for (final entry in catalog)
            _CatalogPluginTile(
              key: ValueKey('${entry.uuid}:${entry.source.url}'),
              entry: entry,
              installed: _manager.plugins
                  .where((plugin) => plugin.manifest.id == entry.uuid)
                  .firstOrNull,
              sourceLabel: _sourceLabel(entry.source),
              busy: _catalogInstallingId == entry.uuid,
              comparingVersions: _compareVersions,
              detailLoading: _manager.isCatalogDetailLoading(entry),
              detailError: _manager.catalogDetailError(entry),
              onRetryDetail: () => _manager.fetchCatalogDetail(entry),
              onPressed: () => _installFromCatalog(entry),
            ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final plugins = _manager.plugins;
    return Scaffold(
      appBar: AppBar(
        title: const Text('插件'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '已安装'),
            Tab(text: '插件源'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _manager.isRefreshing ? null : _refreshCatalog,
            tooltip: '刷新插件索引',
            icon: _manager.isRefreshing
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _addingSource ? null : _addSource,
            tooltip: '添加索引源',
            icon: const Icon(Icons.add_link),
          ),
          IconButton(
            onPressed: _importing ? null : _import,
            tooltip: '从文件导入插件',
            icon: _importing
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.file_open_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: TabBarView(
            controller: _tabController,
            children: [_buildInstalled(plugins), _buildSources()],
          ),
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.source,
    required this.label,
    required this.error,
    required this.busy,
    required this.onAutoUpdateChanged,
    required this.onRemove,
  });

  final PluginIndexSource source;
  final String label;
  final String? error;
  final bool busy;
  final ValueChanged<bool> onAutoUpdateChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;
    return ListTile(
      leading: Icon(
        source.isOfficial ? Icons.verified_outlined : Icons.link_outlined,
      ),
      title: Text(label),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(source.url, maxLines: 2, overflow: TextOverflow.ellipsis),
          if (error != null) Text(error!, style: TextStyle(color: errorColor)),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: '自动更新',
            child: Switch.adaptive(
              value: source.autoUpdate,
              onChanged: busy ? null : onAutoUpdateChanged,
            ),
          ),
          if (source.isOfficial)
            const Tooltip(
              message: '官方源不可删除',
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.lock_outline),
              ),
            )
          else
            IconButton(
              onPressed: busy ? null : onRemove,
              tooltip: '移除索引源',
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
    );
  }
}

class _CatalogPluginTile extends StatelessWidget {
  const _CatalogPluginTile({
    super.key,
    required this.entry,
    required this.installed,
    required this.sourceLabel,
    required this.busy,
    required this.comparingVersions,
    required this.detailLoading,
    required this.detailError,
    required this.onRetryDetail,
    required this.onPressed,
  });

  final PluginIndexEntry entry;
  final InstalledPlugin? installed;
  final String sourceLabel;
  final bool busy;
  final int? Function(String, String) comparingVersions;
  final bool detailLoading;
  final String? detailError;
  final VoidCallback onRetryDetail;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final currentVersion = installed?.manifest.version;
    final catalogVersion = entry.displayVersion;
    final comparison = currentVersion == null || catalogVersion == null
        ? null
        : comparingVersions(catalogVersion, currentVersion);
    final isCurrentOrNewer = comparison != null && comparison <= 0;
    final actionLabel = isCurrentOrNewer
        ? '已安装'
        : installed == null
        ? '安装'
        : catalogVersion == null
        ? '检查更新'
        : '更新';

    final author = entry.detail?.author.trim() ?? '';
    final updateLog = entry.detail?.updateLog.trim() ?? '';

    return ListTile(
      leading: const Icon(Icons.extension_outlined),
      title: Text(entry.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${catalogVersion == null ? '版本以插件包为准' : 'v$catalogVersion'} · $sourceLabel',
          ),
          if (entry.description.trim().isNotEmpty)
            Text(
              entry.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          if (entry.detail != null) ...[
            Text('作者：${author.isEmpty ? '未提供' : author}'),
            Text('版本：${catalogVersion ?? '以插件包为准'}'),
            Text(
              '更新日志：${updateLog.isEmpty ? '未提供' : updateLog}',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (detailLoading && entry.detail == null)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox.square(
                    dimension: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('正在加载插件详情'),
                ],
              ),
            )
          else if (!detailLoading && entry.detail == null)
            Row(
              children: [
                Expanded(
                  child: Text(
                    detailError == null ? '暂无插件详情' : '插件详情加载失败：$detailError',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: detailError == null
                        ? null
                        : TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
                if (detailError != null)
                  IconButton(
                    onPressed: onRetryDetail,
                    tooltip: '重新加载插件详情',
                    visualDensity: VisualDensity.compact,
                    iconSize: 18,
                    icon: const Icon(Icons.refresh),
                  ),
              ],
            ),
        ],
      ),
      trailing: busy
          ? const SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : FilledButton.tonal(
              onPressed: isCurrentOrNewer ? null : onPressed,
              child: Text(actionLabel),
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
                      title: Text(
                        '卸载插件',
                        style: TextStyle(color: errorColor),
                      ),
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
