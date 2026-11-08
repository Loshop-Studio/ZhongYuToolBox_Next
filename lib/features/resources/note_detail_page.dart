import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/theme/app_theme.dart';
import '../../core/util/file_saver.dart';
import '../../data/api/note_api.dart';
import '../../shared/widgets/common.dart';
import 'note_export_service.dart';
import 'note_renderer.dart';

class NoteDetailPage extends StatelessWidget {
  const NoteDetailPage({
    super.key,
    required this.fileId,
    required this.fileName,
  });

  final String fileId;
  final String fileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: Text(
          fileName.isEmpty ? '笔记预览' : fileName,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: NoteDetailBody(fileId: fileId, fileName: fileName),
        ),
      ),
    );
  }
}

/// 笔记内容主体（桌面端也直接复用）
class NoteDetailBody extends StatefulWidget {
  const NoteDetailBody({
    super.key,
    required this.fileId,
    required this.fileName,
  });

  final String fileId;
  final String fileName;

  @override
  State<NoteDetailBody> createState() => _NoteDetailBodyState();
}

class _NoteDetailBodyState extends State<NoteDetailBody> {
  final PageController _pageController = PageController();
  final NoteBoardRenderer _renderer = const ScreenshotNoteRenderer();

  bool _loading = true;
  String? _error;
  List<NotePageData> _pages = const <NotePageData>[];
  int _index = 0;
  String? _busy;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant NoteDetailBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fileId != widget.fileId) {
      _index = 0;
      _load();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final resources = await NoteApi.getResources(widget.fileId);
      if (!mounted) return;
      setState(() {
        _pages = groupNotePages(resources);
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

  Future<void> _exportPdf() async {
    if (_busy != null) return;
    setState(() => _busy = 'pdf');
    try {
      final bytes = await NoteExportService.buildPdf(widget.fileId);
      final name = widget.fileName.isEmpty ? '笔记' : widget.fileName;
      final path = await FileSaver.save('$name.pdf', bytes);
      if (!mounted) return;
      showToast(context, path == null ? '已取消保存' : '已保存：$path');
    } catch (e) {
      if (!mounted) return;
      showToast(context, errorText(e));
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _downloadZip() async {
    if (_busy != null) return;
    setState(() => _busy = 'zip');
    try {
      final bytes = await NoteExportService.buildZip(widget.fileId);
      final name = widget.fileName.isEmpty ? '笔记' : widget.fileName;
      final path = await FileSaver.save('${name}图片.zip', bytes);
      if (!mounted) return;
      showToast(context, path == null ? '已取消保存' : '图片已保存：$path');
    } catch (e) {
      if (!mounted) return;
      showToast(context, errorText(e));
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: Row(
        children: [
          Text(
            '共 ${_pages.length} 页',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: _busy == null ? _exportPdf : null,
            icon: _busy == 'pdf'
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf_outlined, size: 18),
            label: const Text('导出 PDF'),
          ),
          Tooltip(
            message: '把该笔记的全部图片打包成 zip',
            child: TextButton.icon(
              onPressed: _busy == null ? _downloadZip : null,
              icon: _busy == 'zip'
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_outlined, size: 18),
              label: const Text('下载图片'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView(text: '正在加载笔记…');
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_pages.isEmpty) {
      return const EmptyView(
        icon: Icons.auto_stories_outlined,
        text: '该笔记暂无可预览内容\n矢量画板渲染将在后续版本支持',
      );
    }

    final current = _pages[_index.clamp(0, _pages.length - 1)];
    return Column(
      children: [
        _buildToolbar(),
        Expanded(
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: _renderer.buildPage(context, _pages[index]),
                    ),
                  );
                },
              ),
              if (_pages.length > 1)
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Chip(label: Text('${_index + 1} / ${_pages.length}')),
                ),
              if (_pages.length > 1)
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _PageArrow(
                      icon: Icons.chevron_left,
                      enabled: _index > 0,
                      onTap: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                      ),
                    ),
                  ),
                ),
              if (_pages.length > 1)
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _PageArrow(
                      icon: Icons.chevron_right,
                      enabled: _index < _pages.length - 1,
                      onTap: () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (current.originals.isNotEmpty)
          _OriginalsStrip(urls: current.originals)
        else
          const SizedBox(height: 8),
      ],
    );
  }
}

class _PageArrow extends StatelessWidget {
  const _PageArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox(width: 40);
    return IconButton.filledTonal(
      onPressed: onTap,
      icon: Icon(icon),
      tooltip: '翻页',
    );
  }
}

class _OriginalsStrip extends StatelessWidget {
  const _OriginalsStrip({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktopLayout;
    return Container(
      height: desktop ? 116 : 96,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '页内图片（${urls.length}）',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: urls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _openPreview(context, index),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: urls[index],
                      width: 68,
                      height: 68,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 68,
                        height: 68,
                        color: AppColors.field,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openPreview(BuildContext context, int index) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: InteractiveViewer(
            child: CachedNetworkImage(
              imageUrl: urls[index],
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
