import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/config/app_config.dart';
import '../../core/network/api_exception.dart';
import '../../data/api/oss_api.dart';
import '../../shared/widgets/common.dart';

/// 开发工具：OSS 上传测试（复刻 DevelopView）
class DevelopPage extends StatefulWidget {
  const DevelopPage({super.key});

  @override
  State<DevelopPage> createState() => _DevelopPageState();
}

class _DevelopPageState extends State<DevelopPage> {
  String _prefix = 'manage_v2';
  bool _uploading = false;
  String? _lastUrl;

  Future<void> _upload() async {
    if (_uploading) return;
    final picked = await FilePicker.platform.pickFiles(withData: true);
    final files = picked?.files;
    if (files == null || files.isEmpty) return;
    final file = files.first;
    if (file.bytes == null) return;
    setState(() => _uploading = true);
    try {
      final userId = await OssApi.fetchUserId();
      final url = await OssApi.uploadBytes(
        bytes: Uint8List.fromList(file.bytes!),
        fileName: file.name,
        userId: userId,
        fc: _prefix,
        mime: 'application/octet-stream',
      );
      if (!mounted) return;
      setState(() => _lastUrl = url);
      showToast(context, '上传成功');
    } catch (e) {
      if (!mounted) return;
      showToast(context, errorText(e));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: const Text('开发工具'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('OSS 上传', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: _prefix,
                        decoration: const InputDecoration(
                          labelText: '上传类型',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'manage_v2', child: Text('manage_v2')),
                          DropdownMenuItem(value: 'note_v2', child: Text('note_v2')),
                          DropdownMenuItem(value: 'eval_v2', child: Text('eval_v2')),
                          DropdownMenuItem(value: 'mistake_v2', child: Text('mistake_v2')),
                        ],
                        onChanged: (value) =>
                            setState(() => _prefix = value ?? 'manage_v2'),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _uploading ? null : _upload,
                        icon: _uploading
                            ? const SizedBox.square(
                                dimension: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.upload_file),
                        label: const Text('选择文件并上传'),
                      ),
                      if (_lastUrl != null) ...[
                        const SizedBox(height: 12),
                        SelectableText(_lastUrl!),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: _lastUrl!));
                            if (!mounted) return;
                            showToast(context, '已复制');
                          },
                          icon: const Icon(Icons.copy, size: 18),
                          label: const Text('复制链接'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('当前账号'),
                  subtitle: Text(
                    '${AppConfig.appName} ${AppConfig.appVersion}',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
