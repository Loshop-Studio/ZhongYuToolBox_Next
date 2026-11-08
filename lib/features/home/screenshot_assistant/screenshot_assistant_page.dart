import 'dart:io';

import 'package:flutter/material.dart';

import 'screenshot_assistant_service.dart';

class ScreenshotAssistantPage extends StatefulWidget {
  const ScreenshotAssistantPage({super.key});

  @override
  State<ScreenshotAssistantPage> createState() =>
      _ScreenshotAssistantPageState();
}

class _ScreenshotAssistantPageState extends State<ScreenshotAssistantPage> {
  late final ScreenshotAssistantService _service = ScreenshotAssistantService()
    ..addListener(_onServiceChanged);
  List<String> _addresses = <String>[];
  String? _selectedAddress;
  bool _loadingAddresses = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      final addresses = await ScreenshotAssistantService.availableAddresses();
      if (!mounted) return;
      setState(() {
        _addresses = addresses;
        _selectedAddress = addresses.contains(_selectedAddress)
            ? _selectedAddress
            : (addresses.isEmpty ? null : addresses.first);
        _loadingAddresses = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingAddresses = false);
    }
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    _service.dispose();
    super.dispose();
  }

  Future<void> _toggleService() async {
    if (_service.status == ScreenshotAssistantStatus.running) {
      await _service.stop();
    } else {
      await _service.start(preferredAddress: _selectedAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    final running = _service.status == ScreenshotAssistantStatus.running;
    final starting = _service.status == ScreenshotAssistantStatus.starting;
    return Scaffold(
      appBar: AppBar(title: const Text('截图助手')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            running
                                ? Icons.wifi_tethering
                                : Icons.wifi_tethering_off,
                            color: running
                                ? Colors.green
                                : Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              running
                                  ? '服务运行中'
                                  : starting
                                  ? '正在启动服务…'
                                  : '服务已停止',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: starting ? null : _toggleService,
                            icon: starting
                                ? const SizedBox.square(
                                    dimension: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(running ? Icons.stop : Icons.play_arrow),
                            label: Text(running ? '停止' : '启动'),
                          ),
                        ],
                      ),
                      if (running) ...[
                        const Divider(height: 28),
                        _InfoRow(
                          label: '局域网地址',
                          value: _service.localAddress ?? '—',
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          label: '连接码',
                          value: _service.connectionCode ?? '—',
                          emphasize: true,
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          label: 'MQTT / FTP',
                          value:
                              '${ScreenshotAssistantService.mqttPort} / ${ScreenshotAssistantService.ftpPort}',
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          label: '截图目录',
                          value: _service.screenshotDirectory ?? '—',
                        ),
                      ],
                      if (!running && !starting) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedAddress,
                                decoration: const InputDecoration(
                                  labelText: 'UDP 广播网卡 IP',
                                  isDense: true,
                                ),
                                items: _addresses
                                    .map(
                                      (address) => DropdownMenuItem<String>(
                                        value: address,
                                        child: Text(address),
                                      ),
                                    )
                                    .toList(),
                                onChanged: _loadingAddresses
                                    ? null
                                    : (address) => setState(
                                        () => _selectedAddress = address,
                                      ),
                              ),
                            ),
                            IconButton(
                              tooltip: '刷新 IP 列表',
                              onPressed: _loadingAddresses
                                  ? null
                                  : _loadAddresses,
                              icon: _loadingAddresses
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.refresh),
                            ),
                          ],
                        ),
                        if (_addresses.isEmpty && !_loadingAddresses)
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Text('未找到可用 IPv4 地址。'),
                          ),
                      ],
                      if (_service.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _service.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '已接收截图',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    '${_service.screenshots.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_service.screenshots.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 36),
                  child: Center(child: Text('启动服务并通过 OpenFlier 客户端请求截图')),
                )
              else
                ..._service.screenshots.map(
                  (file) => _ScreenshotTile(file: file),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 95,
        child: Text(label, style: Theme.of(context).textTheme.bodySmall),
      ),
      Expanded(
        child: SelectableText(
          value,
          style: emphasize
              ? Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                )
              : Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    ],
  );
}

class _ScreenshotTile extends StatelessWidget {
  const _ScreenshotTile({required this.file});

  final File file;

  @override
  Widget build(BuildContext context) {
    final name = file.uri.pathSegments.last;
    final modified = file.lastModifiedSync();
    return Card(
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.file(
            file,
            width: 68,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const SizedBox(
              width: 68,
              height: 48,
              child: Icon(Icons.broken_image_outlined),
            ),
          ),
        ),
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('${modified.toLocal()}'.split('.').first),
        trailing: IconButton(
          tooltip: '打开截图',
          onPressed: () => showDialog<void>(
            context: context,
            builder: (context) =>
                Dialog(child: InteractiveViewer(child: Image.file(file))),
          ),
          icon: const Icon(Icons.open_in_full),
        ),
      ),
    );
  }
}
