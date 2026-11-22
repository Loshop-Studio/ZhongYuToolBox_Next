import 'package:flutter/material.dart';

import '../../core/plugins/plugin_manager.dart';
import '../../core/plugins/plugin_models.dart';
import '../../core/plugins/plugin_runtime_page.dart';
import '../widgets/app_actions.dart';

Future<void> openPluginAction(
  BuildContext context,
  RegisteredPluginAction action,
  Map<String, dynamic> pageContext,
) async {
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => PluginRuntimePage(
        pluginId: action.plugin.manifest.id,
        pageId: action.action.pageId,
        pageContext: Map<String, dynamic>.from(pageContext),
      ),
    ),
  );
}

class PluginActionButton extends StatelessWidget {
  const PluginActionButton({
    super.key,
    required this.posId,
    required this.pageContext,
    this.tooltip = '插件',
  });

  final String posId;
  final Map<String, dynamic> pageContext;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PluginManager.instance,
      builder: (context, _) {
        final actions = PluginManager.instance.actionsFor(posId);
        if (actions.isEmpty) return const SizedBox.shrink();
        if (actions.length == 1) {
          final action = actions.single;
          return IconButton(
            tooltip: action.action.label,
            icon: Icon(pluginIcon(action.action.icon)),
            onPressed: () => openPluginAction(context, action, pageContext),
          );
        }
        return IconButton(
          tooltip: tooltip,
          icon: const Icon(Icons.extension_outlined),
          onPressed: () => _showPluginActions(context, actions, pageContext),
        );
      },
    );
  }
}

class MergedPluginActionButton extends StatelessWidget {
  const MergedPluginActionButton({
    super.key,
    required this.posId,
    required this.pageContext,
    required this.nativeLabel,
    required this.nativeIcon,
    required this.onNative,
  });

  final String posId;
  final Map<String, dynamic> pageContext;
  final String nativeLabel;
  final IconData nativeIcon;
  final VoidCallback onNative;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PluginManager.instance,
      builder: (context, _) {
        final plugins = PluginManager.instance.actionsFor(posId);
        if (plugins.isEmpty) {
          return TextButton.icon(
            onPressed: onNative,
            icon: Icon(nativeIcon, size: 18),
            label: Text(nativeLabel),
          );
        }
        return TextButton.icon(
          icon: Icon(nativeIcon, size: 18),
          label: Text(nativeLabel),
          onPressed: () async {
            final selected = await showAppActions(
              context,
              title: '选择操作',
              actions: [
                AppAction(
                  value: '_native',
                  label: nativeLabel,
                  icon: nativeIcon,
                ),
                for (final action in plugins)
                  AppAction(
                    value: action.value,
                    label: action.action.label,
                    icon: pluginIcon(action.action.icon),
                    subtitle: action.plugin.manifest.name,
                  ),
              ],
            );
            if (!context.mounted || selected == null) return;
            if (selected == '_native') {
              onNative();
              return;
            }
            final action = plugins
                .where((e) => e.value == selected)
                .firstOrNull;
            if (action != null) {
              await openPluginAction(context, action, pageContext);
            }
          },
        );
      },
    );
  }
}

Future<void> showNativeAndPluginActions(
  BuildContext context, {
  required String posId,
  required Map<String, dynamic> pageContext,
  required String nativeLabel,
  required IconData nativeIcon,
  required VoidCallback onNative,
}) async {
  final plugins = PluginManager.instance.actionsFor(posId);
  if (plugins.isEmpty) {
    onNative();
    return;
  }
  final replacesNative = plugins.any(
    (action) => action.action.replacesNative,
  );
  if (replacesNative && plugins.length == 1) {
    await openPluginAction(context, plugins.single, pageContext);
    return;
  }
  final selected = await showAppActions(
    context,
    title: '选择操作',
    actions: [
      if (!replacesNative)
        AppAction(value: '_native', label: nativeLabel, icon: nativeIcon),
      for (final action in plugins)
        AppAction(
          value: action.value,
          label: action.action.label,
          icon: pluginIcon(action.action.icon),
          subtitle: action.plugin.manifest.name,
        ),
    ],
  );
  if (!context.mounted || selected == null) return;
  if (selected == '_native') {
    onNative();
    return;
  }
  final action = plugins.where((e) => e.value == selected).firstOrNull;
  if (action != null) await openPluginAction(context, action, pageContext);
}

Future<void> _showPluginActions(
  BuildContext context,
  List<RegisteredPluginAction> actions,
  Map<String, dynamic> pageContext,
) async {
  final selected = await showAppActions(
    context,
    title: '插件操作',
    actions: [
      for (final action in actions)
        AppAction(
          value: action.value,
          label: action.action.label,
          icon: pluginIcon(action.action.icon),
          subtitle: action.plugin.manifest.name,
        ),
    ],
  );
  if (!context.mounted || selected == null) return;
  final action = actions.where((e) => e.value == selected).firstOrNull;
  if (action != null) await openPluginAction(context, action, pageContext);
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
