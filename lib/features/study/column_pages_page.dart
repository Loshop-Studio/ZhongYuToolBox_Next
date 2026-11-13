import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../core/util/formatters.dart';
import '../../data/api/column_api.dart';
import '../../data/models/column.dart';
import '../../shared/widgets/common.dart';

/// 某个专栏下的文章列表（支持专栏内搜索）
class ColumnPagesPage extends StatefulWidget {
  const ColumnPagesPage({super.key, required this.colId, required this.name});

  final int colId;
  final String name;

  @override
  State<ColumnPagesPage> createState() => _ColumnPagesPageState();
}

class _ColumnPagesPageState extends State<ColumnPagesPage> {
  final ScrollController _controller = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final List<ColumnPageItem> _pages = <ColumnPageItem>[];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    _reload();
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 240) {
      _loadMore();
    }
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ColumnApi.searchPagesByColId(
        widget.colId,
        pageTitle: _searchController.text,
      );
      if (!mounted) return;
      setState(() {
        _pages
          ..clear()
          ..addAll(result.items);
        _total = result.total;
        _hasMore = result.items.isNotEmpty && _pages.length < result.total;
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

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final result = await ColumnApi.searchPagesByColId(
        widget.colId,
        pageTitle: _searchController.text,
        skipCount: _pages.length,
      );
      if (!mounted) return;
      setState(() {
        _pages.addAll(result.items);
        _hasMore = result.items.isNotEmpty && _pages.length < result.total;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: Text(
          widget.name.isEmpty ? '专栏' : widget.name,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: AppTextField(
                  controller: _searchController,
                  hint: '搜索专栏里的文章',
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _reload(),
                  suffix: IconButton(
                    icon: const Icon(Icons.search, size: 20),
                    onPressed: _reload,
                  ),
                ),
              ),
              if (_total > 0)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '共 $_total 篇',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView(text: '正在加载文章…');
    if (_error != null) return ErrorView(message: _error!, onRetry: _reload);
    if (_pages.isEmpty) {
      return const EmptyView(icon: Icons.article_outlined, text: '这个专栏还没有文章');
    }
    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView.separated(
        controller: _controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        itemCount: _pages.length + (_loadingMore ? 1 : 0),
        separatorBuilder: (_, index) => index < _pages.length - 1
            ? const Divider(height: 1, indent: 16, endIndent: 16)
            : const SizedBox.shrink(),
        itemBuilder: (context, index) {
          if (index >= _pages.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          final page = _pages[index];
          return InkWell(
            onTap: () => context.push('/article/${page.id}'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (page.isTop) ...[
                        Text(
                          '置顶',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (!page.isRead) ...[
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          page.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        formatDateTime(page.publishTime, pattern: 'yyyy-MM-dd'),
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.remove_red_eye_outlined,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${page.hits}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.star_border,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${page.stars}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
