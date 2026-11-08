import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_exception.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/theme/app_theme.dart';
import '../../core/util/formatters.dart';
import '../../data/api/note_api.dart';
import '../../data/models/note.dart';
import '../../shared/widgets/app_actions.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/fab_menu.dart';
import 'gallery_page.dart';
import 'note_detail_page.dart';

/// 资源 tab：云笔记 / 图库
class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _galleryRecycle = false;
  final GlobalKey<GalleryTabState> _galleryKey = GlobalKey<GalleryTabState>();

  int get _tab => _tabController.index;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      initialIndex: widget.initialTab,
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);
  }

  @override
  void didUpdateWidget(covariant ResourcesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab &&
        widget.initialTab != _tabController.index) {
      _tabController.animateTo(widget.initialTab);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('资源'),
        actions: [
          if (_tab == 0) ...[
            IconButton(
              tooltip: '搜索笔记',
              icon: const Icon(Icons.search),
              onPressed: () => context.push('/note-search'),
            ),
            IconButton(
              tooltip: '回收站',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => context.push('/note-recycle'),
            ),
            const SizedBox(width: 4),
          ] else
            IconButton(
              tooltip: _galleryRecycle ? '返回图库' : '图库回收站',
              icon: Icon(
                _galleryRecycle
                    ? Icons.photo_library_outlined
                    : Icons.delete_outline,
              ),
              onPressed: () {
                setState(() => _galleryRecycle = !_galleryRecycle);
                _galleryKey.currentState?.reload();
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '云笔记'),
            Tab(text: '图库'),
          ],
        ),
      ),
      body: _tab == 0
          ? const NoteBrowser()
          : GalleryTab(key: _galleryKey, recycle: _galleryRecycle),
    );
  }
}

/// 移动目标选择：按 parentId 组成可折叠的文件夹树（默认全部展开）
class _FolderTree extends StatefulWidget {
  const _FolderTree({required this.folders, required this.onPick});

  final List<NoteItem> folders;
  final ValueChanged<String> onPick;

  @override
  State<_FolderTree> createState() => _FolderTreeState();
}

class _FolderTreeState extends State<_FolderTree> {
  final Map<String, List<NoteItem>> _children = <String, List<NoteItem>>{};
  late final List<NoteItem> _roots;
  late final Set<String> _expanded;

  @override
  void initState() {
    super.initState();
    final ids = widget.folders.map((e) => e.fileId).toSet();
    for (final folder in widget.folders) {
      var parent = folder.parentId;
      // 父节点缺失 / 自引用时挂到根目录，避免节点丢失或死循环
      if (parent.isEmpty || parent == folder.fileId || !ids.contains(parent)) {
        parent = '0';
      }
      _children.putIfAbsent(parent, () => <NoteItem>[]).add(folder);
    }
    _roots = _children['0'] ?? <NoteItem>[];
    _expanded = widget.folders.map((e) => e.fileId).toSet();
  }

  void _toggle(String id) {
    setState(() {
      if (!_expanded.remove(id)) _expanded.add(id);
    });
  }

  List<Widget> _tiles(NoteItem folder, int depth, Set<String> path) {
    if (!path.add(folder.fileId)) return const <Widget>[];
    final children = _children[folder.fileId] ?? <NoteItem>[];
    final expanded = _expanded.contains(folder.fileId);
    final result = <Widget>[
      ListTile(
        dense: true,
        contentPadding: EdgeInsets.only(left: 16.0 + depth * 18, right: 12),
        leading: Icon(
          expanded && children.isNotEmpty
              ? Icons.folder_open_outlined
              : Icons.folder_outlined,
          color: const Color(0xFFE8B34B),
          size: 20,
        ),
        title: Text(
          folder.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: children.isEmpty
            ? null
            : IconButton(
                tooltip: expanded ? '折叠' : '展开',
                icon: Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                ),
                onPressed: () => _toggle(folder.fileId),
              ),
        onTap: () => widget.onPick(folder.fileId),
      ),
    ];
    if (expanded) {
      for (final child in children) {
        result.addAll(_tiles(child, depth + 1, path));
      }
    }
    path.remove(folder.fileId);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          dense: true,
          leading: const Icon(Icons.home_outlined, size: 20),
          title: const Text('根目录'),
          onTap: () => widget.onPick('0'),
        ),
        for (final folder in _roots) ..._tiles(folder, 0, <String>{}),
      ],
    );
  }
}

class _Crumb {
  _Crumb(this.id, this.name);

  final String id;
  final String name;
}

/// 笔记浏览（移动端单列表 + 桌面端左右分栏）
class NoteBrowser extends StatefulWidget {
  const NoteBrowser({super.key});

  @override
  State<NoteBrowser> createState() => _NoteBrowserState();
}

class _NoteBrowserState extends State<NoteBrowser> {
  final List<_Crumb> _crumbs = <_Crumb>[_Crumb('0', '根目录')];
  List<NoteItem> _notes = <NoteItem>[];
  bool _loading = true;
  String? _error;

  /// true = 平铺全部笔记（Notes/GetAll），false = 按文件夹浏览
  bool _allMode = false;

  String? _selectedId;
  String _selectedName = '';

  String get _currentFolderId => _crumbs.last.id;

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
      final notes = _allMode
          ? await NoteApi.getAllNotes()
          : await NoteApi.getByParentId(_currentFolderId);
      if (!mounted) return;
      setState(() {
        _notes = notes;
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

  void _enterFolder(NoteItem folder) {
    setState(() {
      _allMode = false;
      _crumbs.add(_Crumb(folder.fileId, folder.fileName));
      _notes = <NoteItem>[];
      _selectedId = null;
    });
    _load();
  }

  void _jumpTo(int index) {
    if (index >= _crumbs.length - 1) return;
    setState(() {
      _allMode = false;
      _crumbs.removeRange(index + 1, _crumbs.length);
      _notes = <NoteItem>[];
      _selectedId = null;
    });
    _load();
  }

  void _toggleAllMode() {
    setState(() {
      _allMode = !_allMode;
      _notes = <NoteItem>[];
      _selectedId = null;
    });
    _load();
  }

  void _openNote(NoteItem note, bool desktop) {
    if (desktop) {
      setState(() {
        _selectedId = note.fileId;
        _selectedName = note.fileName;
      });
      return;
    }
    context.push(
      '/note/${note.fileId}?name=${Uri.encodeComponent(note.fileName)}',
    );
  }

  Future<void> _showNoteActions(NoteItem note, {Offset? anchor}) async {
    final action = await showAppActions(
      context,
      title: note.fileName,
      anchor: anchor,
      actions: [
        if (note.isNote)
          const AppAction(
            value: 'rename',
            label: '重命名',
            icon: Icons.drive_file_rename_outline,
          ),
        if (note.isNote)
          const AppAction(
            value: 'move',
            label: '移动到文件夹',
            icon: Icons.drive_file_move_outline,
          ),
        AppAction(
          value: 'delete',
          label: '移至回收站',
          icon: Icons.delete_outline,
          danger: true,
          subtitle: note.isFolder ? '文件夹请在官方客户端管理' : null,
        ),
      ],
    );
    switch (action) {
      case 'rename':
        await _rename(note);
        break;
      case 'move':
        await _move(note);
        break;
      case 'delete':
        await _delete(note);
        break;
    }
  }

  Future<void> _rename(NoteItem note) async {
    final controller = TextEditingController(text: note.fileName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('重命名'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '输入新的名称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null || result.isEmpty) return;
    try {
      await NoteApi.rename(note, result);
      if (!mounted) return;
      showToast(context, '已重命名');
      _load();
    } catch (e) {
      if (!mounted) return;
      showToast(context, errorText(e));
    }
  }

  /// 目标文件夹按 parentId 组成可折叠的树，而不是平铺列表
  Widget _buildFolderTree(BuildContext ctx, List<NoteItem> folders) {
    return _FolderTree(
      folders: folders,
      onPick: (id) => Navigator.of(ctx).pop(id),
    );
  }

  Future<void> _move(NoteItem note) async {
    List<NoteItem> folders;
    try {
      final nodes = await NoteApi.getAllNodes();
      folders = nodes.where((e) => e.isFolder).toList();
    } catch (e) {
      if (!mounted) return;
      showToast(context, errorText(e));
      return;
    }
    if (!mounted) return;
    final target = context.isDesktopLayout
        ? await showDialog<String>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('移动到'),
              content: SizedBox(
                width: 420,
                height: MediaQuery.sizeOf(ctx).height * 0.5,
                child: _buildFolderTree(ctx, folders),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('取消'),
                ),
              ],
            ),
          )
        : await showModalBottomSheet<String>(
            context: context,
            showDragHandle: true,
            isScrollControlled: true,
            builder: (ctx) => SafeArea(
              child: SizedBox(
                height: MediaQuery.sizeOf(ctx).height * 0.55,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        '移动到',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(child: _buildFolderTree(ctx, folders)),
                  ],
                ),
              ),
            ),
          );
    if (target == null) return;
    try {
      final result = await NoteApi.moveToFolder([note.fileId], target);
      if (!mounted) return;
      if (result.failed.isNotEmpty) {
        showToast(context, '移动失败，请重试');
      } else if (result.skipped.isNotEmpty) {
        showToast(context, '笔记已在该文件夹');
      } else {
        showToast(context, '已移动');
      }
      _load();
    } catch (e) {
      if (!mounted) return;
      showToast(context, errorText(e));
    }
  }

  Future<void> _delete(NoteItem note) async {
    if (note.isFolder) {
      showToast(context, '文件夹请先在官方客户端处理');
      return;
    }
    final ok = await confirmDialog(
      context,
      title: '移至回收站',
      content: '将「${note.fileName}」移入中育回收站？可在官方客户端恢复。',
      confirmText: '移至',
      danger: true,
    );
    if (!ok) return;
    try {
      await NoteApi.moveToRecycleBin([note.fileId]);
      if (!mounted) return;
      showToast(context, '已移至回收站');
      if (_selectedId == note.fileId) {
        setState(() => _selectedId = null);
      }
      _load();
    } catch (e) {
      if (!mounted) return;
      showToast(context, errorText(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktopLayout;
    if (desktop) {
      return Row(
        children: [
          SizedBox(width: 360, child: _buildList(context, desktop: true)),
          const VerticalDivider(width: 1),
          Expanded(child: _buildDetail()),
        ],
      );
    }
    return _buildList(context, desktop: false);
  }

  Widget _buildDetail() {
    final id = _selectedId;
    if (id == null) {
      return const EmptyView(
        icon: Icons.menu_book_outlined,
        text: '选择左侧笔记查看内容',
      );
    }
    return NoteDetailBody(fileId: id, fileName: _selectedName);
  }

  Widget _buildList(BuildContext context, {required bool desktop}) {
    return Stack(
      children: [
        Column(
          children: [
            _buildBreadcrumb(),
            const Divider(height: 1),
            Expanded(child: _buildBody(desktop)),
          ],
        ),
        Positioned.fill(
          child: FabMenu(
            tooltip: '新建',
            items: [
              FabMenuItem(
                icon: Icons.note_add_outlined,
                label: '新建笔记',
                onSelected: () => showToast(context, '新建笔记功能尚未完成'),
              ),
              FabMenuItem(
                icon: Icons.create_new_folder_outlined,
                label: '新建文件夹',
                onSelected: () => showToast(context, '新建文件夹功能尚未完成'),
              ),
              FabMenuItem(
                icon: Icons.upload_file_outlined,
                label: '导入 PDF',
                onSelected: () async {
                  final parentId = _allMode ? '0' : _currentFolderId;
                  final parentName = _allMode ? '根目录' : _crumbs.last.name;
                  final ok = await context.push<bool>(
                    '/pdf-import?parentId=${Uri.encodeComponent(parentId)}'
                    '&name=${Uri.encodeComponent(parentName)}',
                  );
                  if (ok == true && mounted) _load();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBreadcrumb() {
    if (_allMode) {
      return SizedBox(
        height: 42,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const Icon(
                Icons.list_alt_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                '全部笔记',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _toggleAllMode,
                icon: const Icon(Icons.folder_outlined, size: 16),
                label: const Text('按文件夹', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      );
    }
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _crumbs.length,
              separatorBuilder: (_, __) => const Icon(
                Icons.chevron_right,
                size: 16,
                color: AppColors.textSecondary,
              ),
              itemBuilder: (context, index) {
                final crumb = _crumbs[index];
                final last = index == _crumbs.length - 1;
                return Center(
                  child: GestureDetector(
                    onTap: () => _jumpTo(index),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 10,
                      ),
                      child: Text(
                        crumb.name,
                        style: TextStyle(
                          fontSize: 13,
                          color: last
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: last ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const VerticalDivider(width: 1, indent: 8, endIndent: 8),
          TextButton.icon(
            onPressed: _toggleAllMode,
            icon: const Icon(Icons.list_alt_outlined, size: 16),
            label: const Text('全部笔记', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool desktop) {
    if (_loading) return const LoadingView(text: '正在加载笔记…');
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_notes.isEmpty) {
      return EmptyView(
        icon: _allMode
            ? Icons.description_outlined
            : Icons.folder_open_outlined,
        text: _allMode ? '还没有笔记\n点右下角 + 新建笔记' : '这里还没有内容\n点右下角 + 新建笔记或文件夹',
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 88),
        itemCount: _notes.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 56),
        itemBuilder: (context, index) {
          final note = _notes[index];
          return _NoteRow(
            note: note,
            selected: desktop && note.fileId == _selectedId,
            onTap: () =>
                note.isFolder ? _enterFolder(note) : _openNote(note, desktop),
            onMore: (position) => _showNoteActions(note, anchor: position),
          );
        },
      ),
    );
  }
}

class _NoteRow extends StatelessWidget {
  const _NoteRow({
    required this.note,
    required this.selected,
    required this.onTap,
    required this.onMore,
  });

  final NoteItem note;
  final bool selected;
  final VoidCallback onTap;

  /// 移动端长按 / 桌面端右键
  final void Function(Offset? position) onMore;

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktopLayout;
    return GestureDetector(
      onSecondaryTapDown: desktop
          ? (details) => onMore(details.globalPosition)
          : null,
      child: ListTile(
        selected: selected,
        leading: Icon(
          note.isFolder ? Icons.folder : Icons.description_outlined,
        ),
        title: Text(
          note.fileName.isEmpty ? '未命名' : note.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          note.isFolder ? '文件夹' : '创建时间 ${formatDateTime(note.createTime)}',
        ),
        trailing: note.isFolder ? const Icon(Icons.chevron_right) : null,
        onTap: onTap,
        onLongPress: desktop ? null : () => onMore(null),
      ),
    );
  }
}

/// 笔记搜索页
class NoteSearchPage extends StatefulWidget {
  const NoteSearchPage({super.key});

  @override
  State<NoteSearchPage> createState() => _NoteSearchPageState();
}

class _NoteSearchPageState extends State<NoteSearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<NoteItem> _results = <NoteItem>[];
  bool _loading = false;
  bool _searched = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final keyword = _controller.text.trim();
    if (keyword.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await NoteApi.search(keyword);
      if (!mounted) return;
      setState(() {
        _results = results;
        _searched = true;
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
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
          decoration: const InputDecoration(
            hintText: '输入笔记名称搜索',
            border: InputBorder.none,
            isDense: true,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _search),
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
    if (_loading) return const LoadingView(text: '正在搜索…');
    if (_error != null) return ErrorView(message: _error!, onRetry: _search);
    if (!_searched) {
      return const EmptyView(icon: Icons.search, text: '输入关键词后回车搜索');
    }
    if (_results.isEmpty) {
      return const EmptyView(icon: Icons.search_off, text: '没有找到匹配的笔记');
    }
    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 56),
      itemBuilder: (context, index) {
        final note = _results[index];
        return ListTile(
          leading: const Icon(
            Icons.description_outlined,
            color: AppColors.primary,
          ),
          title: Text(
            note.fileName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text('创建时间 ${formatDateTime(note.createTime)}'),
          trailing: const Icon(Icons.chevron_right, size: 18),
          onTap: () => context.push(
            '/note/${note.fileId}?name=${Uri.encodeComponent(note.fileName)}',
          ),
        );
      },
    );
  }
}

/// 笔记回收站
class NoteRecyclePage extends StatefulWidget {
  const NoteRecyclePage({super.key});

  @override
  State<NoteRecyclePage> createState() => _NoteRecyclePageState();
}

class _NoteRecyclePageState extends State<NoteRecyclePage> {
  List<NoteItem> _notes = <NoteItem>[];
  bool _loading = true;
  String? _error;

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
      final notes = await NoteApi.getRecycledNotes();
      if (!mounted) return;
      setState(() {
        _notes = notes;
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

  Future<void> _delete(NoteItem note) async {
    final ok = await confirmDialog(
      context,
      title: '彻底删除',
      content: '「${note.fileName}」将被永久删除，无法恢复。',
      confirmText: '删除',
      danger: true,
    );
    if (!ok) return;
    try {
      await NoteApi.deletePermanently([note.fileId]);
      if (!mounted) return;
      showToast(context, '已删除');
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
        title: const Text('回收站'),
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
    if (_loading) return const LoadingView(text: '正在加载回收站…');
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_notes.isEmpty) {
      return const EmptyView(icon: Icons.delete_outline, text: '回收站是空的');
    }
    return ListView.separated(
      itemCount: _notes.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 56),
      itemBuilder: (context, index) {
        final note = _notes[index];
        return ListTile(
          leading: const Icon(
            Icons.description_outlined,
            color: AppColors.textSecondary,
          ),
          title: Text(
            note.fileName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text('创建时间 ${formatDateTime(note.createTime)}'),
          trailing: IconButton(
            tooltip: '彻底删除',
            icon: const Icon(
              Icons.delete_forever_outlined,
              color: AppColors.danger,
            ),
            onPressed: () => _delete(note),
          ),
        );
      },
    );
  }
}
