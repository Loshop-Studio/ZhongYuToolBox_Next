import 'package:flutter/material.dart';

/// FAB 菜单项
class FabMenuItem {
  const FabMenuItem({
    required this.label,
    required this.icon,
    required this.onSelected,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback onSelected;
  final bool enabled;
}

/// Material 3 风格的 FAB 菜单（speed dial）：
/// 点击主 FAB 后图标旋转成 ×，操作项从主按钮上方依次浮出，
/// 点击遮罩或再次点击主按钮收起。
///
/// 需要铺满父容器（放在 `Positioned.fill` 里），遮罩才能覆盖整个列表区域。
class FabMenu extends StatefulWidget {
  const FabMenu({
    super.key,
    required this.items,
    this.tooltip = '新建',
    this.heroTag = 'fab-menu-main',
    this.expandedIconBuilder,
  });

  final List<FabMenuItem> items;
  final String tooltip;
  final String heroTag;

  /// 展开后替换主按钮图标（默认 + 旋转 45° 成 ×）
  final WidgetBuilder? expandedIconBuilder;

  @override
  State<FabMenu> createState() => _FabMenuState();
}

class _FabMenuState extends State<FabMenu> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  bool _open = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _show() {
    if (_open) return;
    setState(() => _open = true);
    _controller.forward();
  }

  void _close() {
    if (!_open) return;
    setState(() => _open = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_open)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _close,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, __) => ColoredBox(
                  color: Colors.black.withValues(
                    alpha: 0.12 * _controller.value,
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 倒序渲染：列表第一项紧贴主按钮
              for (var i = widget.items.length - 1; i >= 0; i--)
                _buildItem(context, i),
              const SizedBox(height: 12),
              _buildFab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final item = widget.items[index];
    final theme = Theme.of(context);
    // 越靠近主按钮的项越早出现
    final start = index * 0.12;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.isDismissed && !_open) return const SizedBox.shrink();
        final t = ((_controller.value - start) / (1 - start)).clamp(0.0, 1.0);
        return IgnorePointer(
          ignoring: !_open,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, (1 - t) * 14),
                child: child,
              ),
            ),
          ),
        );
      },
      child: FloatingActionButton.extended(
        heroTag: null,
        elevation: 1.5,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        foregroundColor: theme.colorScheme.onSurface,
        onPressed: item.enabled
            ? () {
                _close();
                item.onSelected();
              }
            : null,
        icon: Icon(item.icon, size: 18),
        label: Text(item.label, style: const TextStyle(fontSize: 13)),
      ),
    );
  }

  Widget _buildFab() {
    final expanded = widget.expandedIconBuilder?.call(context);
    return FloatingActionButton(
      heroTag: widget.heroTag,
      tooltip: _open ? '收起' : widget.tooltip,
      onPressed: _open ? _close : _show,
      child: AnimatedRotation(
        turns: _open && expanded == null ? 0.125 : 0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: _open && expanded != null ? expanded : const Icon(Icons.add),
      ),
    );
  }
}
