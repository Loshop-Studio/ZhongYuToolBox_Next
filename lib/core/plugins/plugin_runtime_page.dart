import 'dart:async';

import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/dart_eval_security.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:flutter/material.dart';

import '../../shared/widgets/common.dart';
import '../storage/session_manager.dart';
import '../util/urls.dart';
import 'plugin_http_service.dart';
import 'plugin_manager.dart';
import 'plugin_models.dart';
import 'plugin_program_widget.dart';

class PluginRuntimePage extends StatefulWidget {
  const PluginRuntimePage({
    super.key,
    required this.pluginId,
    required this.pageId,
    this.pageContext = const <String, dynamic>{},
  });

  final String pluginId;
  final String pageId;
  final Map<String, dynamic> pageContext;

  @override
  State<PluginRuntimePage> createState() => _PluginRuntimePageState();
}

class _PluginRuntimePageState extends State<PluginRuntimePage> {
  final SessionManager _session = SessionManager.instance;
  final Map<String, Map<String, dynamic>> _httpResults = {};
  int _runtimeRevision = 0;
  late Future<bool> _sessionReady;

  @override
  void initState() {
    super.initState();
    _sessionReady = _session.ensureValidSession();
  }

  void _rebuildPlugin() {
    if (!mounted) return;
    setState(() => _runtimeRevision++);
  }

  @override
  Widget build(BuildContext context) {
    final manager = PluginManager.instance;
    final plugin = manager.findPlugin(widget.pluginId);
    final page = plugin == null
        ? null
        : manager.findPage(plugin, widget.pageId);
    if (plugin == null || page == null) {
      return const Scaffold(
        body: EmptyView(
          icon: Icons.extension_off_outlined,
          text: '插件或页面不存在/已停用',
        ),
      );
    }
    return FutureBuilder<bool>(
      future: _sessionReady,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: Text(page.title)),
            body: const LoadingView(text: '正在准备插件运行环境…'),
          );
        }
        return PluginProgramWidget(
          key: ValueKey(
            '${plugin.manifest.id}:${page.id}:${plugin.manifest.version}',
          ),
          bytecodePath: plugin.bytecodePath,
          library: page.library,
          function: page.function,
          revision: _runtimeRevision,
          permissions: [FilesystemPermission.any, NetworkPermission.any],
          args: [
            _wrapMap(widget.pageContext),
            _wrapHostInfo(plugin),
            $Function((runtime, target, args) {
              return _wrapHostInfo(plugin);
            }),
            $Function((runtime, target, args) {
              final pageId = args.isEmpty
                  ? ''
                  : args[0]?.$reified.toString() ?? '';
              final raw = args.length > 1 ? args[1]?.$reified : null;
              final extra = raw is Map
                  ? raw.map((key, value) => MapEntry(key.toString(), value))
                  : <String, dynamic>{};
              if (pageId.isNotEmpty && mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PluginRuntimePage(
                        pluginId: plugin.manifest.id,
                        pageId: pageId,
                        pageContext: extra,
                      ),
                    ),
                  );
                });
              }
              return null;
            }),
          ],
          loading: Scaffold(
            appBar: AppBar(title: Text(page.title)),
            body: const LoadingView(text: '正在加载插件…'),
          ),
          onError: (context, error, stackTrace) => Scaffold(
            appBar: AppBar(title: Text(page.title)),
            body: ErrorView(message: '插件运行失败：$error'),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _hostInfo(InstalledPlugin plugin) {
    final session = _session.session;
    return <String, dynamic>{
      'token': session.token,
      'apiHost': session.apiBaseUrl,
      'webHost': session.webServer,
      'username': session.userName,
      'displayName': _session.displayName,
      'avatar': userAvatarUrl(session.photo, apiBaseUrl: session.apiBaseUrl),
      'avatarRaw': session.photo,
      'userId': session.userId,
      'schoolCode': session.schoolCode,
      'schoolName': session.schoolName,
      'pluginId': plugin.manifest.id,
      'pluginPath': plugin.directoryPath,
    };
  }

  $Map<$Value, $Value> _wrapHostInfo(InstalledPlugin plugin) {
    final values = _hostInfo(
      plugin,
    ).map((key, value) => MapEntry<$Value, $Value>($String(key), _wrap(value)));
    values[$String('getHttpResult')] = $Function((runtime, target, args) {
      final requestId = args.isEmpty ? '' : args[0]?.$reified.toString() ?? '';
      final state = _httpResults[requestId];
      return runtime.wrap(
        state ??
            <String, dynamic>{
              'started': false,
              'pending': false,
              'error': '',
              'response': <String, dynamic>{},
            },
        recursive: true,
      );
    });
    values[$String('httpRequest')] = $Function((runtime, target, args) {
      final method = args.isEmpty
          ? 'GET'
          : args[0]?.$reified.toString() ?? 'GET';
      final url = args.length < 2 ? '' : args[1]?.$reified.toString() ?? '';
      final rawOptions = args.length < 3 ? null : args[2]?.$reified;
      final options = rawOptions is Map
          ? rawOptions.map((key, value) => MapEntry(key.toString(), value))
          : <String, dynamic>{};
      final requestId = (options['requestId'] ?? '').toString().trim();
      if (url.isEmpty || requestId.isEmpty) {
        throw ArgumentError('httpRequest 需要 url 和 options.requestId');
      }
      final rawHeaders = options['headers'];
      final headers = rawHeaders is Map
          ? rawHeaders.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            )
          : <String, String>{};
      final timeout = (options['timeoutSeconds'] as num?)?.toInt() ?? 40;
      _httpResults[requestId] = <String, dynamic>{
        'started': true,
        'pending': true,
        'error': '',
        'response': <String, dynamic>{},
      };
      _rebuildPlugin();
      unawaited(
        PluginHttpService.request(
          method: method,
          url: url,
          headers: headers,
          body: options['body'],
          timeoutSeconds: timeout,
        ).then(
          (response) {
            _httpResults[requestId] = <String, dynamic>{
              'started': true,
              'pending': false,
              'error': '',
              'response': response,
            };
            _rebuildPlugin();
          },
          onError: (Object error, StackTrace stackTrace) {
            _httpResults[requestId] = <String, dynamic>{
              'started': true,
              'pending': false,
              'error': error.toString(),
              'response': <String, dynamic>{},
            };
            _rebuildPlugin();
          },
        ),
      );
      return null;
    });
    return $Map.wrap(values);
  }

  static $Map<$Value, $Value> _wrapMap(Map<String, dynamic> map) {
    return $Map.wrap(
      map.map(
        (key, value) => MapEntry<$Value, $Value>($String(key), _wrap(value)),
      ),
    );
  }

  static $Value _wrap(dynamic value) {
    if (value == null) return const $null();
    if (value is String) return $String(value);
    if (value is int) return $int(value);
    if (value is double) return $double(value);
    if (value is bool) return $bool(value);
    if (value is Map) {
      return $Map.wrap(
        value.map(
          (key, item) =>
              MapEntry<$Value, $Value>(_wrap(key.toString()), _wrap(item)),
        ),
      );
    }
    if (value is Iterable) return $List.wrap(value.map(_wrap).toList());
    return $String(value.toString());
  }
}
