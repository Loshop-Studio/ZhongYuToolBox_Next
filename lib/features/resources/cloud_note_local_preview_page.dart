import 'dart:io';

import 'package:flutter/material.dart';

import '../../shared/widgets/common.dart';
import 'cloud_note_local_document.dart';
import 'cloud_note_renderer.dart';
import 'cloud_note_snapshot.dart';

/// Standalone viewer for the native 中育云笔记 directory format.
///
/// This page deliberately does not route the local data through the network
/// note model or the legacy ZIP/blackboard renderer.
class CloudNoteLocalPreviewPage extends StatefulWidget {
  const CloudNoteLocalPreviewPage({super.key, required this.path});

  final String path;

  @override
  State<CloudNoteLocalPreviewPage> createState() =>
      _CloudNoteLocalPreviewPageState();
}

class _CloudNoteLocalPreviewPageState extends State<CloudNoteLocalPreviewPage> {
  late Future<CloudNoteLocalDocument> _document;
  final PageController _pageController = PageController();
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _document = CloudNoteLocalDocument.open(widget.path);
  }

  @override
  void didUpdateWidget(covariant CloudNoteLocalPreviewPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _index = 0;
      _document = CloudNoteLocalDocument.open(widget.path);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('本地云笔记'),
        actions: [
          FutureBuilder<CloudNoteLocalDocument>(
            future: _document,
            builder: (context, snapshot) {
              final count = snapshot.data?.pages.length;
              if (count == null) return const SizedBox.shrink();
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text('$count 页'),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<CloudNoteLocalDocument>(
        future: _document,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView(text: '正在读取本地云笔记…');
          }
          if (snapshot.hasError) {
            return ErrorView(
              message: '读取失败：${snapshot.error}',
              onRetry: () => setState(
                () => _document = CloudNoteLocalDocument.open(widget.path),
              ),
            );
          }
          final document = snapshot.data;
          if (document == null || document.pages.isEmpty) {
            return const EmptyView(
              icon: Icons.note_outlined,
              text: '目录中没有找到 snapshot.bin 或 screenshot.png',
            );
          }
          final pageIndex = _index.clamp(0, document.pages.length - 1);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Row(
                  children: [
                    Text(
                      '${pageIndex + 1} / ${document.pages.length}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    if (document.pages.length > 1)
                      IconButton(
                        tooltip: '上一页',
                        onPressed: pageIndex == 0
                            ? null
                            : () => _pageController.previousPage(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOut,
                              ),
                        icon: const Icon(Icons.chevron_left),
                      ),
                    if (document.pages.length > 1)
                      IconButton(
                        tooltip: '下一页',
                        onPressed: pageIndex == document.pages.length - 1
                            ? null
                            : () => _pageController.nextPage(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOut,
                              ),
                        icon: const Icon(Icons.chevron_right),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: document.pages.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: _CloudNoteLocalPageView(page: document.pages[index]),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CloudNoteLocalPageView extends StatelessWidget {
  const _CloudNoteLocalPageView({required this.page});

  final CloudNoteLocalPage page;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: FutureBuilder<CloudNoteSnapshot?>(
        future: page.readParsedSnapshot(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final parsed = snapshot.data;
          if (parsed != null && _hasRenderableGraph(parsed.graphSnapshot)) {
            return CloudNoteSnapshotView(snapshot: parsed, page: page);
          }
          if (page.hasScreenshot) {
            return InteractiveViewer(
              minScale: 0.2,
              maxScale: 8,
              child: Center(child: Image.file(page.screenshotFile)),
            );
          }
          return const Center(child: Text('该页没有可渲染的 snapshot 或截图'));
        },
      ),
    );
  }

  bool _hasRenderableGraph(CloudNoteGraph? graph) {
    if (graph == null) return false;
    if (graph.childGraph.isNotEmpty ||
        graph.pointList.isNotEmpty ||
        (graph.content?.isNotEmpty ?? false) ||
        (graph.filePath?.isNotEmpty ?? false)) {
      return true;
    }
    return graph.childGraph.any(_hasRenderableGraph);
  }
}
