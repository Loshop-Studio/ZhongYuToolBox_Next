import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/responsive/breakpoints.dart';
import '../../core/storage/session_manager.dart';
import '../../data/api/exam_api.dart';
import '../../shared/widgets/user_avatar.dart';

/// 主页：账号、未完成测评、功能入口
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SessionManager _session = SessionManager.instance;
  bool _loadingStats = true;
  int _unfinished = 0;

  @override
  void initState() {
    super.initState();
    _session.addListener(_onSessionChanged);
    _loadStats();
  }

  @override
  void dispose() {
    _session.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadStats() async {
    setState(() => _loadingStats = true);
    try {
      // 「未完成」= 待处理作业（taskListType=1）的总数，不能靠 examState 推断
      final pending = await ExamApi.getTasks(1, taskListType: 1);
      if (!mounted) return;
      setState(() {
        _unfinished = pending.total > 0 ? pending.total : pending.items.length;
        _loadingStats = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('主页'),
        actions: [
          IconButton(
            tooltip: '消息',
            icon: const Icon(Icons.notifications_none),
            onPressed: () => context.push('/messages'),
          ),
          IconButton(
            tooltip: '设置',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.isDesktopLayout ? 980 : 760,
          ),
          child: RefreshIndicator(
            onRefresh: _loadStats,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
              children: [
                Card(
                  child: ListTile(
                    leading: UserAvatar(
                      name: _session.displayName,
                      photo: _session.session.photo,
                      apiBaseUrl: _session.session.apiBaseUrl,
                    ),
                    title: Text(_session.displayName),
                    subtitle: Text(
                      [
                        if (_session.schoolLabel.isNotEmpty)
                          _session.schoolLabel,
                        if (_session.session.userName.isNotEmpty)
                          _session.session.userName,
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      tooltip: '切换用户',
                      icon: const Icon(Icons.swap_horiz),
                      onPressed: () => context.push('/login'),
                    ),
                    onTap: () => context.push('/profile'),
                  ),
                ),
                const SizedBox(height: 8),
                _buildExamCard(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '功能',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                _EntryGrid(
                  entries: [
                    _Entry(
                      '云笔记',
                      Icons.description_outlined,
                      () => context.go('/resources'),
                    ),
                    _Entry(
                      '图库',
                      Icons.photo_library_outlined,
                      () => context.go('/resources?tab=gallery'),
                    ),
                    _Entry(
                      '随身答',
                      Icons.forum_outlined,
                      () => context.go('/qa'),
                    ),
                    _Entry(
                      '优客畅学',
                      Icons.menu_book_outlined,
                      () => context.go('/study'),
                    ),
                    _Entry(
                      '错题本',
                      Icons.fact_check_outlined,
                      () => context.push('/mistake'),
                    ),
                    _Entry(
                      '选课',
                      Icons.school_outlined,
                      () => context.push('/course'),
                    ),
                    _Entry(
                      '中育应用下载',
                      Icons.download_outlined,
                      () => context.push('/downloads'),
                    ),
                    _Entry(
                      '领创',
                      Icons.cast_for_education_outlined,
                      () => context.push('/linspirer'),
                    ),
                    if (Platform.isWindows)
                      _Entry(
                        '笔记截图助手',
                        Icons.screenshot_monitor_outlined,
                        () => context.push('/screenshot-assistant'),
                      ),
                    _Entry(
                      '开发工具',
                      Icons.build_outlined,
                      () => context.push('/dev'),
                    ),
                    _Entry(
                      '关于与支持',
                      Icons.info_outline,
                      () => context.push('/about'),
                    ),
                    _Entry(
                      '设置',
                      Icons.settings_outlined,
                      () => context.push('/settings'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExamCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '未完成测评',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (_loadingStats)
                  const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _loadingStats ? '—' : '$_unfinished',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Entry {
  _Entry(this.label, this.icon, this.onTap);

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class _EntryGrid extends StatelessWidget {
  const _EntryGrid({required this.entries});

  final List<_Entry> entries;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760
            ? 5
            : (constraints.maxWidth >= 480 ? 4 : 3);
        const spacing = 8.0;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final entry in entries)
              SizedBox(
                width: width,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: entry.onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 8,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            entry.icon,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entry.label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
