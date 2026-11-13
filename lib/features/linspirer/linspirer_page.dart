import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/network/api_exception.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/storage/image_cache_manager.dart';
import '../../core/storage/local_store.dart';
import '../../core/storage/session_manager.dart';
import '../../core/theme/app_theme.dart';
import '../../data/api/linspirer_api.dart';
import '../../data/models/linspirer.dart';
import '../../shared/widgets/common.dart';
import '../study/attachment_opener.dart';

/// 领创：设备绑定 / 应用管理 / 管理员密码（复刻旧项目 LinspirerView）
class LinspirerPage extends StatefulWidget {
  const LinspirerPage({super.key});

  @override
  State<LinspirerPage> createState() => _LinspirerPageState();
}

class _LinspirerPageState extends State<LinspirerPage>
    with SingleTickerProviderStateMixin {
  static const List<String> _tabs = ['绑定', '应用', '密码'];

  final SessionManager _session = SessionManager.instance;
  late final TabController _tabController;

  final TextEditingController _swdidController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  late final TextEditingController _accountController;

  int _tabIndex = 0;
  String _boundSwdid = '';
  String _boundModel = '';
  String _studentId = '';

  bool _binding = false;
  bool _editingBinding = false;
  bool _loadingApps = false;
  List<LinspirerApp> _apps = <LinspirerApp>[];

  bool _calcLoading = false;
  String _pwdResult = '';

  String get _account => _session.session.userName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _accountController = TextEditingController(text: _account);
    _boundSwdid = LocalStore.instance.getString('linspirer_swdid') ?? '';
    _boundModel = LocalStore.instance.getString('linspirer_model') ?? '';
    _studentId = LocalStore.instance.getString('linspirer_studentId') ?? '';
    _swdidController.text = _boundSwdid;
    _modelController.text = _boundModel;
    if (_boundSwdid.isNotEmpty) _loadApps();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _swdidController.dispose();
    _modelController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  /// 只在 tab 真正切换时重建，避免滚动/动画过程反复刷新输入框
  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == _tabIndex) return;
    setState(() => _tabIndex = _tabController.index);
  }

  Future<void> _bind() async {
    final swdid = _swdidController.text.trim();
    final model = _modelController.text.trim();
    if (swdid.isEmpty) {
      showToast(context, '请输入设备号');
      return;
    }
    setState(() => _binding = true);
    try {
      await LinspirerApi.bindDevice(swdid, _account, model);
      if (!mounted) return;
      setState(() {
        _boundSwdid = swdid;
        _boundModel = model;
        _apps = <LinspirerApp>[];
        _editingBinding = false;
      });
      await LocalStore.instance.setString('linspirer_swdid', swdid);
      await LocalStore.instance.setString('linspirer_model', model);
      await _loadApps();
      if (!mounted) return;
      showToast(context, '绑定成功，共 ${_apps.length} 个应用');
      _tabController.animateTo(1);
    } catch (e) {
      if (!mounted) return;
      showToast(context, errorText(e));
    } finally {
      if (mounted) setState(() => _binding = false);
    }
  }

  Future<void> _loadApps() async {
    if (_boundSwdid.isEmpty) return;
    setState(() => _loadingApps = true);
    try {
      final apps = await LinspirerApi.getAllApps(
        _boundSwdid,
        _account,
        _boundModel,
      );
      if (!mounted) return;
      setState(() => _apps = apps);
    } catch (e) {
      if (!mounted) return;
      showToast(context, errorText(e));
    } finally {
      if (mounted) setState(() => _loadingApps = false);
    }
  }

  Future<void> _viewApp(LinspirerApp app) async {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => _AppDetailDialog(
        app: app,
        swdid: _boundSwdid,
        account: _account,
        model: _boundModel,
      ),
    );
  }

  Future<void> _downloadApp(LinspirerApp app) async {
    try {
      final detail = await LinspirerApi.getAppDetail(
        _boundSwdid,
        _account,
        _boundModel,
        app.id,
      );
      final path = detail.downloadPath(_boundSwdid);
      if (path.isEmpty) {
        if (mounted) showToast(context, '该应用没有下载链接');
        return;
      }
      final url = LinspirerApi.proxyUrl(path);
      if (!mounted) return;
      showToast(context, '开始下载 ${app.name}');
      final saved = await downloadAttachment(
        url,
        detail.downloadFileName(app.name),
      );
      if (!mounted) return;
      showToast(context, saved == null ? '已取消保存' : '已保存：$saved');
    } catch (e) {
      if (!mounted) return;
      showToast(context, errorText(e));
    }
  }

  Future<void> _calc() async {
    if (_boundSwdid.isEmpty) {
      showToast(context, '请先在「绑定」中绑定设备');
      return;
    }
    setState(() => _calcLoading = true);
    try {
      final pwd = await LinspirerApi.calcPassword(
        _boundSwdid,
        _account,
        _boundModel,
        studentId: _studentId.isEmpty ? null : _studentId,
      );
      if (!mounted) return;
      setState(() => _pwdResult = pwd);
    } catch (e) {
      if (!mounted) return;
      showToast(context, errorText(e));
    } finally {
      if (mounted) setState(() => _calcLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: const Text('领创'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [for (final label in _tabs) Tab(text: label)],
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.isDesktopLayout ? 900 : 760,
          ),
          child: _buildCurrent(),
        ),
      ),
    );
  }

  /// 不用 TabBarView：它的 PageView 会吃掉桌面滚轮（滚轮变成切 tab），
  /// 这里按 index 直接换内容，滚轮只作用于内容里的 ListView。
  Widget _buildCurrent() {
    switch (_tabIndex) {
      case 1:
        return _buildApps();
      case 2:
        return _buildPassword();
      default:
        return _buildBind();
    }
  }

  Widget _buildBind() {
    if (_boundSwdid.isNotEmpty && !_editingBinding) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 32),
        children: [
          Text('设备已绑定', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Text('设备号：$_boundSwdid'),
          const SizedBox(height: 6),
          Text('设备型号：${_boundModel.isEmpty ? '—' : _boundModel}'),
          const SizedBox(height: 6),
          Text('用户名：$_account'),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => setState(() => _editingBinding = true),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('更换设备'),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 32),
      children: [
        AppTextField(
          controller: _swdidController,
          label: '设备号 (swdid)',
          hint: '请输入设备号',
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: _modelController,
          label: '设备型号',
          hint: '如 Pixel 6',
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: _accountController,
          label: '用户名',
          hint: '中育用户名',
          enabled: false,
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _binding ? null : _bind,
          icon: _binding
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.link),
          label: const Text('绑定并获取应用'),
        ),
        if (_boundSwdid.isNotEmpty) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() => _editingBinding = false),
            child: const Text('取消更换'),
          ),
        ],
      ],
    );
  }

  Widget _buildApps() {
    if (_boundSwdid.isEmpty) {
      return const EmptyView(icon: Icons.info_outline, text: '请先在「绑定」中绑定设备');
    }
    if (_loadingApps) {
      return const LoadingView(text: '正在获取应用…');
    }
    if (_apps.isEmpty) {
      return EmptyView(
        icon: Icons.apps_outlined,
        text: '暂无应用',
        action: OutlinedButton.icon(
          onPressed: _loadApps,
          icon: const Icon(Icons.refresh),
          label: const Text('刷新'),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadApps,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
        itemCount: _apps.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == _apps.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Center(
                child: Text(
                  '已绑定设备：$_boundSwdid',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            );
          }
          final app = _apps[index];
          return _LinspirerAppCard(
            app: app,
            swdid: _boundSwdid,
            account: _account,
            model: _boundModel,
            onView: () => _viewApp(app),
            onDownload: () => _downloadApp(app),
          );
        },
      ),
    );
  }

  Widget _buildPassword() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 32),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '与「绑定」「应用」共用同一台已绑定设备',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text('设备号：${_boundSwdid.isEmpty ? '未绑定' : _boundSwdid}'),
                const SizedBox(height: 4),
                Text('设备型号：${_boundModel.isEmpty ? '—' : _boundModel}'),
                const SizedBox(height: 4),
                Text('用户名：$_account'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _calcLoading ? null : _calc,
          icon: _calcLoading
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.key),
          label: const Text('计算管理员密码'),
        ),
        if (_pwdResult.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('管理员密码', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 6),
                  Text(
                    _pwdResult,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: _pwdResult),
                        );
                        if (!mounted) return;
                        showToast(context, '已复制');
                      },
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('复制密码'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _LinspirerAppCard extends StatefulWidget {
  const _LinspirerAppCard({
    required this.app,
    required this.swdid,
    required this.account,
    required this.model,
    required this.onView,
    required this.onDownload,
  });

  final LinspirerApp app;
  final String swdid;
  final String account;
  final String model;
  final VoidCallback onView;
  final VoidCallback onDownload;

  @override
  State<_LinspirerAppCard> createState() => _LinspirerAppCardState();
}

class _LinspirerAppCardState extends State<_LinspirerAppCard> {
  String _icon = '';

  @override
  void initState() {
    super.initState();
    _icon = widget.app.icon;
    if (_icon.isEmpty) _loadDetailIcon();
  }

  Future<void> _loadDetailIcon() async {
    try {
      final detail = await LinspirerApi.getAppDetail(
        widget.swdid,
        widget.account,
        widget.model,
        widget.app.id,
      );
      if (!mounted || detail.icon.isEmpty) return;
      setState(() => _icon = detail.icon);
    } catch (_) {
      // 图标加载失败时保留默认图标，不影响应用列表使用。
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 48,
                height: 48,
                child: _icon.isEmpty
                    ? const ColoredBox(
                        color: AppColors.field,
                        child: Icon(Icons.android),
                      )
                    : CachedNetworkImage(
                        imageUrl: LinspirerApi.proxyUrl(_icon),
                        cacheManager: ZyImageCacheManager.instance,
                        fit: BoxFit.contain,
                        errorWidget: (_, __, ___) => const ColoredBox(
                          color: AppColors.field,
                          child: Icon(Icons.android),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.app.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.app.packageName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text(widget.app.source),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                TextButton(onPressed: widget.onView, child: const Text('详情')),
                TextButton(
                  onPressed: widget.onDownload,
                  child: const Text('下载'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AppDetailDialog extends StatefulWidget {
  const _AppDetailDialog({
    required this.app,
    required this.swdid,
    required this.account,
    required this.model,
  });

  final LinspirerApp app;
  final String swdid;
  final String account;
  final String model;

  @override
  State<_AppDetailDialog> createState() => _AppDetailDialogState();
}

class _AppDetailDialogState extends State<_AppDetailDialog> {
  bool _loading = true;
  LinspirerAppDetail? _detail;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final detail = await LinspirerApi.getAppDetail(
        widget.swdid,
        widget.account,
        widget.model,
        widget.app.id,
      );
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = errorText(e);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    final icon = detail?.icon.isNotEmpty == true
        ? detail!.icon
        : widget.app.icon;
    return AlertDialog(
      title: Text(widget.app.name),
      content: SizedBox(
        width: 360,
        child: _loading
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            : (_error != null
                  ? ErrorView(message: _error!, onRetry: _load)
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (icon.isNotEmpty)
                          Center(
                            child: CachedNetworkImage(
                              imageUrl: LinspirerApi.proxyUrl(icon),
                              cacheManager: ZyImageCacheManager.instance,
                              width: 64,
                              height: 64,
                              errorWidget: (_, __, ___) =>
                                  const Icon(Icons.android, size: 48),
                            ),
                          ),
                        const SizedBox(height: 12),
                        if (detail != null) ...[
                          Text(
                            detail.packageName,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(detail.description),
                        ],
                      ],
                    )),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
        if (!_loading && _error == null && detail != null)
          FilledButton.icon(
            onPressed: () async {
              final path = detail.downloadPath(widget.swdid);
              if (path.isEmpty) {
                showToast(context, '该应用没有下载链接');
                return;
              }
              final url = LinspirerApi.proxyUrl(path);
              Navigator.of(context).pop();
              showToast(context, '开始下载 ${widget.app.name}');
              try {
                final saved = await downloadAttachment(
                  url,
                  detail.downloadFileName(widget.app.name),
                );
                if (!context.mounted) return;
                showToast(context, saved == null ? '已取消保存' : '已保存：$saved');
              } catch (e) {
                if (!context.mounted) return;
                showToast(context, errorText(e));
              }
            },
            icon: const Icon(Icons.download_outlined, size: 18),
            label: const Text('下载 APK'),
          ),
      ],
    );
  }
}
