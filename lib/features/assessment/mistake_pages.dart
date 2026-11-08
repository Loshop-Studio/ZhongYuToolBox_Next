import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/html/question_html.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../core/util/formatters.dart';
import '../../core/util/urls.dart';
import '../../data/api/mistake_api.dart';
import '../../data/models/mistake.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/content_html_view.dart';

/// 错题本列表
class MistakeBooksPage extends StatefulWidget {
  const MistakeBooksPage({super.key});

  @override
  State<MistakeBooksPage> createState() => _MistakeBooksPageState();
}

class _MistakeBooksPageState extends State<MistakeBooksPage> {
  bool _loading = true;
  String? _error;
  List<MistakeBook> _books = <MistakeBook>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final books = await MistakeApi.getMyBooks();
      if (!mounted) return;
      setState(() {
        _books = books;
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
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: const Text('错题本'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          const SizedBox(width: 4),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView(text: '正在加载错题本…');
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_books.isEmpty) {
      return const EmptyView(icon: Icons.menu_book_outlined, text: '还没有错题本');
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _books.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 56),
      itemBuilder: (context, index) {
        final book = _books[index];
        return ListTile(
          leading: Icon(
            Icons.menu_book_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(book.name, maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: const Icon(Icons.chevron_right, size: 18),
          onTap: () => context.push(
            '/mistake/${book.id}?name=${Uri.encodeComponent(book.name)}',
          ),
        );
      },
    );
  }
}

/// 某个错题本里的题目
class MistakeItemsPage extends StatefulWidget {
  const MistakeItemsPage({super.key, required this.bookId, required this.name});

  final String bookId;
  final String name;

  @override
  State<MistakeItemsPage> createState() => _MistakeItemsPageState();
}

class _MistakeItemsPageState extends State<MistakeItemsPage> {
  bool _loading = true;
  String? _error;
  List<MistakeItem> _items = <MistakeItem>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await MistakeApi.searchItems(widget.bookId);
      if (!mounted) return;
      setState(() {
        _items = result.items;
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

  Future<void> _remove(MistakeItem item) async {
    final ok = await confirmDialog(
      context,
      title: '移出错题本',
      content: '将这道错题从错题本中移除？',
      confirmText: '移除',
      danger: true,
    );
    if (!ok) return;
    try {
      await MistakeApi.removeItems(widget.bookId, [item.id]);
      if (!mounted) return;
      showToast(context, '已移除');
      _load();
    } catch (e) {
      if (!mounted) return;
      showToast(context, errorText(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: Text(widget.name, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          const SizedBox(width: 4),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView(text: '正在加载错题…');
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_items.isEmpty) {
      return const EmptyView(icon: Icons.task_alt, text: '这个错题本是空的');
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = _items[index];
        return SectionCard(
          padding: const EdgeInsets.all(10),
          onTap: () => context.push('/mistake/item/${item.id}'),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: item.stemShoot.isEmpty
                      ? Container(
                          color: AppColors.field,
                          child: const Icon(Icons.image_outlined, size: 20),
                        )
                      : CachedNetworkImage(
                          imageUrl: imageDisplayUrl(absoluteOssUrl(item.stemShoot)),
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.field,
                            child: const Icon(Icons.broken_image_outlined, size: 18),
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
                      item.source.isEmpty ? '错题 ${index + 1}' : item.source,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDateTime(item.creationTime),
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: '移出错题本',
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                onPressed: () => _remove(item),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 错题详情（题目 HTML + 笔记）
class MistakeDetailPage extends StatefulWidget {
  const MistakeDetailPage({super.key, required this.itemId});

  final String itemId;

  @override
  State<MistakeDetailPage> createState() => _MistakeDetailPageState();
}

class _MistakeDetailPageState extends State<MistakeDetailPage> {
  bool _loading = true;
  String? _error;
  String _html = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detail = await MistakeApi.getDetail(widget.itemId);
      if (detail == null) throw ApiException('该错题已不存在');
      final raw = detail.qstPath.isEmpty
          ? '<div class="stem">暂无题目内容</div>'
          : await MistakeApi.fetchQuestionHtml(detail.qstPath);
      final parsed = QuestionHtml.parseQuestionHtml(raw);
      final screenshot = await MistakeApi.fetchNoteScreenshot(detail.note);
      if (!mounted) return;
      setState(() {
        _html = _compose(parsed, detail, screenshot);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      log('[错题详情] 加载失败 itemId=${widget.itemId}: $e', name: 'Mistake');
      setState(() {
        _error = errorText(e);
        _loading = false;
      });
    }
  }

  String _compose(
    ParsedQuestion parsed,
    MistakeDetail detail,
    String? screenshot,
  ) {
    final buffer = StringBuffer();
    buffer.write('<h3>题干</h3>${parsed.stem}');
    buffer.write('<h3>答案</h3>${parsed.answer}');
    if (parsed.analysis.isNotEmpty) {
      buffer.write('<h3>解析</h3>${parsed.analysis}');
    }
    if (parsed.knowledge.isNotEmpty) {
      buffer.write('<h3>知识点</h3>${parsed.knowledge}');
    }
    if (screenshot != null && screenshot.isNotEmpty) {
      // note-shot：告诉 ContentHtmlView 这是整幅截图，不做题干图片的 1/5 收缩
      buffer.write('<h3>笔记截图</h3>');
      buffer.write('<img class="note-shot" src="$screenshot">');
    }
    if (detail.pictureNote.isNotEmpty) {
      buffer.write('<h3>图片笔记</h3>');
      for (final url in detail.pictureNote) {
        buffer.write(
          '<img class="note-shot" src="${imageDisplayUrl(absoluteOssUrl(url))}">',
        );
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: const Text('错题详情'),
      ),
      body: _loading
          ? const LoadingView(text: '正在加载错题…')
          : (_error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : ContentHtmlView(html: _html)),
    );
  }
}
