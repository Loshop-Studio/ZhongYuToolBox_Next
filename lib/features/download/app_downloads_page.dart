import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/util/file_saver.dart';
import '../../data/api/app_store_api.dart';
import '../../shared/widgets/common.dart';

/// 中育应用下载（复刻 AppDownloadsView）
class AppDownloadsPage extends StatefulWidget {
  const AppDownloadsPage({super.key});

  @override
  State<AppDownloadsPage> createState() => _AppDownloadsPageState();
}

class _AppDownloadsPageState extends State<AppDownloadsPage> {
  final TextEditingController _packageController = TextEditingController();

  final Map<String, OfficialApp?> _apps = <String, OfficialApp?>{};
  final Map<String, String> _errors = <String, String>{};
  final Map<String, double> _progress = <String, double>{};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _packageController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _errors.clear();
    });
    for (final app in studentApps) {
      await _load(app.packageName);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _load(String packageName) async {
    try {
      final app = await AppStoreApi.checkUpdate(packageName);
      if (!mounted) return;
      setState(() {
        _apps[packageName] = app;
        _errors.remove(packageName);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _apps[packageName] = null;
        _errors[packageName] = errorText(e);
      });
    }
  }

  Future<void> _download(OfficialApp app) async {
    if (_progress.containsKey(app.packageName)) return;
    setState(() => _progress[app.packageName] = 0);
    try {
      final result = await AppStoreApi.downloadApk(
        app,
        onProgress: (received, total) {
          if (total <= 0) return;
          setState(() => _progress[app.packageName] = received / total);
        },
      );
      final path = await FileSaver.save(AppStoreApi.fileName(app), result.bytes);
      if (!mounted) return;
      showToast(
        context,
        path == null ? '已取消保存' : '已保存：$path\nSHA-256：${result.sha256.substring(0, 16)}…',
      );
    } catch (e) {
      if (!mounted) return;
      showToast(context, errorText(e));
    } finally {
      if (mounted) setState(() => _progress.remove(app.packageName));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('中育应用下载'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAll),
          const SizedBox(width: 4),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        controller: _packageController,
                        label: 'Android 包名',
                        hint: '例如 com.zykj.mistake',
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: () async {
                            final pkg = _packageController.text.trim();
                            if (pkg.isEmpty) return;
                            await _load(pkg);
                            if (!mounted) return;
                            final error = _errors[pkg];
                            if (error != null) showToast(context, error);
                          },
                          child: const Text('查询'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              for (final item in _apps.entries)
                if (item.value != null)
                  _AppTile(
                    app: item.value!,
                    progress: _progress[item.key],
                    onDownload: () => _download(item.value!),
                  )
                else if (_errors[item.key] != null)
                  ListTile(
                    leading: const Icon(Icons.error_outline),
                    title: Text(item.key),
                    subtitle: Text(_errors[item.key]!),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppTile extends StatelessWidget {
  const _AppTile({required this.app, required this.progress, required this.onDownload});

  final OfficialApp app;
  final double? progress;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final busy = progress != null;
    return Card(
      child: ListTile(
        leading: SizedBox.square(
          dimension: 40,
          child: app.icon.isEmpty
              ? const Icon(Icons.android)
              : CachedNetworkImage(
                  imageUrl: app.icon,
                  errorWidget: (_, __, ___) => const Icon(Icons.android),
                ),
        ),
        title: Text(app.name),
        subtitle: Text(
          '${app.versionName}（${app.versionCode}）· ${app.sizeText}\n${app.packageName}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        isThreeLine: true,
        trailing: busy
            ? SizedBox.square(
                dimension: 28,
                child: CircularProgressIndicator(value: progress),
              )
            : TextButton(onPressed: onDownload, child: const Text('下载')),
      ),
    );
  }
}
