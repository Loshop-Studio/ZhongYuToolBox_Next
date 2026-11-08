import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../shared/widgets/common.dart';
import 'pdf_note_service.dart';

/// 把 PDF 导入为云笔记（复刻旧项目 PdfUploadPanel 的单文件流程）
class PdfImportPage extends StatefulWidget {
  const PdfImportPage({
    super.key,
    this.parentId = '0',
    this.parentName = '根目录',
  });

  final String parentId;
  final String parentName;

  @override
  State<PdfImportPage> createState() => _PdfImportPageState();
}

class _PdfImportPageState extends State<PdfImportPage> {
  final TextEditingController _nameController = TextEditingController();

  Uint8List? _bytes;
  String _fileName = '';
  bool _busy = false;
  int _percent = 0;
  String _status = '';
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    if (_busy) return;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        withData: true,
      );
      final file = result?.files.single;
      final bytes = file?.bytes;
      if (bytes == null || bytes.isEmpty) return;
      if (!mounted) return;
      setState(() {
        _bytes = Uint8List.fromList(bytes);
        _fileName = file!.name;
        _error = null;
        _percent = 0;
        _status = '已选择 ${_fileName.isEmpty ? 'PDF' : _fileName}';
        if (_nameController.text.trim().isEmpty) {
          _nameController.text = _fileName.toLowerCase().endsWith('.pdf')
              ? _fileName.substring(0, _fileName.length - 4)
              : _fileName;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = errorText(e));
    }
  }

  Future<void> _import() async {
    final bytes = _bytes;
    if (bytes == null) {
      showToast(context, '请先选择 PDF 文件');
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      showToast(context, '请输入笔记名称');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _percent = 0;
      _status = '准备导入…';
    });
    try {
      await PdfNoteService.importPdf(
        pdfBytes: bytes,
        noteName: _nameController.text,
        parentId: widget.parentId,
        onProgress: (percent, text) {
          if (!mounted) return;
          setState(() {
            _percent = percent;
            _status = text;
          });
        },
      );
      if (!mounted) return;
      showToast(context, '导入成功');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = errorText(e);
        _status = '导入失败';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: const Text('导入 PDF 到云笔记'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 32),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: const Text('目标文件夹'),
                  subtitle: Text(
                    widget.parentName.isEmpty ? '根目录' : widget.parentName,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _busy ? null : _pick,
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: Text(
                  _fileName.isEmpty ? '选择 PDF 文件' : _fileName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _nameController,
                label: '笔记名称',
                hint: '导入后显示的笔记名',
                enabled: !_busy,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _busy ? null : _import,
                icon: _busy
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_file_outlined),
                label: Text(_busy ? '正在导入…' : '开始导入'),
              ),
              const SizedBox(height: 20),
              if (_status.isNotEmpty) ...[
                LinearProgressIndicator(value: _percent / 100),
                const SizedBox(height: 8),
                Text('$_percent% · $_status'),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 20),
              const Text(
                '每页会渲染成 2880×1800 的画布并上传为云笔记页面，'
                '页数越多耗时越长；导入期间请保持网络稳定。',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
