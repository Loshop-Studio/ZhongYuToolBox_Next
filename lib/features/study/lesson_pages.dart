import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../data/api/lesson_api.dart';
import '../../data/models/lesson.dart';
import '../../shared/widgets/common.dart';

/// 优客畅学课程列表
class LessonCoursesPage extends StatefulWidget {
  const LessonCoursesPage({super.key});

  @override
  State<LessonCoursesPage> createState() => _LessonCoursesPageState();
}

class _LessonCoursesPageState extends State<LessonCoursesPage> {
  bool _loading = true;
  String? _error;
  List<LessonCourse> _courses = <LessonCourse>[];

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
      final courses = await LessonApi.getLearningCourses();
      if (!mounted) return;
      setState(() {
        _courses = courses;
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
        title: const Text('优客畅学'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          const SizedBox(width: 4),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView(text: '正在加载课程…');
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_courses.isEmpty) {
      return const EmptyView(icon: Icons.school_outlined, text: '暂无在学课程');
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: _courses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final course = _courses[index];
          return SectionCard(
            padding: const EdgeInsets.all(10),
            onTap: () => context.push(
              '/lesson/${course.id}?title=${Uri.encodeComponent(course.title)}',
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 76,
                    height: 56,
                    child: course.cover.isEmpty
                        ? Container(color: AppColors.field)
                        : CachedNetworkImage(
                            imageUrl: course.cover,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                Container(color: AppColors.field),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title.isEmpty ? '未命名课程' : course.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (course.subjectName.isNotEmpty)
                            Text(
                              course.subjectName,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          const Spacer(),
                          Text(
                            '进度 ${(course.progress * 100).clamp(0, 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 课程章节目录
class LessonCatalogPage extends StatefulWidget {
  const LessonCatalogPage({
    super.key,
    required this.courseId,
    required this.title,
  });

  final int courseId;
  final String title;

  @override
  State<LessonCatalogPage> createState() => _LessonCatalogPageState();
}

class _LessonCatalogPageState extends State<LessonCatalogPage> {
  bool _loading = true;
  String? _error;
  List<LessonCatalog> _catalogs = <LessonCatalog>[];

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
      final catalogs = await LessonApi.getCourseDetail(widget.courseId);
      if (!mounted) return;
      setState(() {
        _catalogs = catalogs;
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
        title: Text(
          widget.title.isEmpty ? '课程目录' : widget.title,
          overflow: TextOverflow.ellipsis,
        ),
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
    if (_loading) return const LoadingView(text: '正在加载目录…');
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_catalogs.isEmpty) {
      return const EmptyView(icon: Icons.list_alt, text: '该课程暂无章节');
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 32),
      children: [
        for (final catalog in _catalogs)
          _CatalogTile(node: catalog, courseId: widget.courseId, depth: 0),
      ],
    );
  }
}

class _CatalogTile extends StatelessWidget {
  const _CatalogTile({
    required this.node,
    required this.courseId,
    required this.depth,
  });

  final LessonCatalog node;
  final int courseId;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final children = node.children;
    if (children.isEmpty) {
      return ListTile(
        contentPadding: EdgeInsets.only(left: 16 + depth * 16.0, right: 16),
        leading: const Icon(Icons.play_circle_outline, size: 18),
        title: Text(
          node.title.isEmpty ? '未命名章节' : node.title,
          style: const TextStyle(fontSize: 13.5),
        ),
        trailing: const Icon(Icons.chevron_right, size: 18),
        onTap: () => context.push(
          '/lesson/$courseId/${node.id}?title=${Uri.encodeComponent(node.title)}',
        ),
      );
    }
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.only(left: 16 + depth * 16.0, right: 16),
        childrenPadding: EdgeInsets.zero,
        leading: const Icon(
          Icons.folder_outlined,
          size: 18,
          color: AppColors.primary,
        ),
        title: Text(
          node.title.isEmpty ? '未命名分组' : node.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        children: [
          for (final child in children)
            _CatalogTile(node: child, courseId: courseId, depth: depth + 1),
        ],
      ),
    );
  }
}

// 章节内容已改为直接加载官方 Web 页面，见 lesson_web_page.dart
