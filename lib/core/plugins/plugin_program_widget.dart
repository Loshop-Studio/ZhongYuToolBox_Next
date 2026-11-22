import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/dart_eval_security.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eval/flutter_eval.dart';

/// Loads and evaluates one Flutter/EVC plugin page.
///
/// The evaluator is deliberately created once for the lifetime of this
/// widget. A host update re-executes the entry against that same evaluator so
/// the returned Flutter tree can read updated HTTP/session data. Entry points
/// must be cheap and side-effect-free; Flutter reconciles the returned tree
/// and preserves state for stable widget types and keys.
class PluginProgramWidget extends StatefulWidget {
  const PluginProgramWidget({
    super.key,
    required this.bytecodePath,
    required this.library,
    required this.function,
    this.bytecodeLoader,
    this.args = const <dynamic>[],
    this.permissions = const <Permission>[],
    this.revision = 0,
    this.updateListenable,
    this.loading,
    this.onError,
  });

  final String bytecodePath;
  final String library;
  final String function;
  final FutureOr<Uint8List> Function(String path)? bytecodeLoader;
  final List<dynamic> args;
  final List<Permission> permissions;

  /// Kept for source compatibility with the first plugin ABI. A revision
  /// refreshes the rendered widget without recreating Runtime.
  final int revision;

  /// Notifies the page that mutable host data (for example an HTTP result)
  /// changed. The plugin entry is re-executed against the existing Runtime.
  final Listenable? updateListenable;
  final Widget? loading;
  final EvalErrorBuilder? onError;

  @override
  State<PluginProgramWidget> createState() => _PluginProgramWidgetState();
}

class _PluginProgramWidgetState extends State<PluginProgramWidget> {
  Runtime? _runtime;
  Widget? _result;
  Object? _error;
  StackTrace? _errorStackTrace;
  bool _loading = true;
  Listenable? _listenable;
  bool _executing = false;
  bool _executeQueued = false;
  bool _executeScheduled = false;
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _listenTo(widget.updateListenable);
    // Keep the first frame responsive and keep all evaluator work out of
    // build(). The EVC runtime itself is synchronous, so it starts only after
    // the loading frame has been submitted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_load());
    });
  }

  @override
  void didUpdateWidget(covariant PluginProgramWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.updateListenable != widget.updateListenable) {
      _listenTo(widget.updateListenable);
    }

    // Only a different program needs a new Runtime. HTTP/status revisions are
    // intentionally handled by _onHostChanged below.
    if (oldWidget.bytecodePath != widget.bytecodePath ||
        oldWidget.library != widget.library ||
        oldWidget.function != widget.function) {
      _disposeRuntime();
      unawaited(_load());
    } else if (oldWidget.revision != widget.revision) {
      _queueExecute();
    }
  }

  void _listenTo(Listenable? listenable) {
    _listenable?.removeListener(_onHostChanged);
    _listenable = listenable;
    _listenable?.addListener(_onHostChanged);
  }

  void _onHostChanged() {
    _queueExecute();
  }

  void _queueExecute() {
    if (!mounted || _runtime == null) return;
    if (_executing) {
      _executeQueued = true;
      return;
    }
    if (_executeScheduled) return;
    _executeScheduled = true;
    scheduleMicrotask(() {
      _executeScheduled = false;
      unawaited(_executeCurrent());
    });
  }

  Future<void> _load() async {
    final generation = ++_loadGeneration;
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
        _errorStackTrace = null;
        _result = null;
      });
    }

    try {
      // Native file I/O must not run from build(). This also avoids Windows
      // C:\ paths being interpreted as URI paths by RuntimeWidget.
      final bytes =
          await (widget.bytecodeLoader?.call(widget.bytecodePath) ??
              File(widget.bytecodePath).readAsBytes());
      if (!mounted || generation != _loadGeneration) return;
      final runtime = Runtime(ByteData.sublistView(Uint8List.fromList(bytes)));
      for (final permission in widget.permissions) {
        runtime.grant(permission);
      }
      runtime.addPlugin(flutterEvalPlugin);
      if (!mounted || generation != _loadGeneration) return;
      _runtime = runtime;
      await _executeCurrent();
    } catch (error, stackTrace) {
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _runtime = null;
        _result = null;
        _loading = false;
        _error = error;
        _errorStackTrace = stackTrace;
      });
    }
  }

  /// Re-run the page entry against the existing VM so its widget can read
  /// updated host state. Bytecode and bridge state are not recreated.
  /// dart_eval itself is synchronous and has no cancellation budget; plugin
  /// entry points must therefore return promptly.
  Future<void> _executeCurrent() async {
    if (!mounted || _runtime == null || _executing) return;
    _executing = true;
    try {
      final runtime = _runtime!;
      final value = runtime.executeLib(
        widget.library,
        widget.function,
        _runtimeArgs(runtime),
      );
      final evaluated = value is $Value ? value.$value : value;
      if (evaluated is! Widget) {
        throw StateError('插件入口必须返回 Widget，实际返回 ${evaluated.runtimeType}');
      }
      if (!mounted) return;
      setState(() {
        _result = evaluated;
        _loading = false;
        _error = null;
        _errorStackTrace = null;
      });
    } catch (error, stackTrace) {
      if (!mounted) return;
      setState(() {
        _result = null;
        _loading = false;
        _error = error;
        _errorStackTrace = stackTrace;
      });
    } finally {
      _executing = false;
      if (_executeQueued) {
        _executeQueued = false;
        _queueExecute();
      }
    }
  }

  void _disposeRuntime() {
    _loadGeneration++;
    _executeQueued = false;
    _executeScheduled = false;
    _runtime = null;
    _result = null;
    _error = null;
    _errorStackTrace = null;
    _loading = true;
  }

  @override
  void dispose() {
    _listenable?.removeListener(_onHostChanged);
    _disposeRuntime();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    if (error != null) {
      return widget.onError?.call(context, error, _errorStackTrace) ??
          _DefaultPluginError(error: error, stackTrace: _errorStackTrace);
    }
    if (_runtime == null || _loading || _result == null) {
      return widget.loading ?? const SizedBox.shrink();
    }

    return _result!;
  }

  /// dart_eval's bridge requires the outer list and every nested collection
  /// crossing the VM boundary to contain VM values. Host callers may
  /// still use dynamically typed lists, so wrap recursively at this ingress.
  List<$Value> _runtimeArgs(Runtime runtime) {
    return widget.args
        .map<$Value>((argument) {
          if (argument is $Value) return argument;
          return runtime.wrap(argument, recursive: true);
        })
        .toList(growable: false);
  }
}

class _DefaultPluginError extends StatelessWidget {
  const _DefaultPluginError({required this.error, this.stackTrace});

  final Object error;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    final details = stackTrace?.toString() ?? '';
    return Material(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: SelectableText(
            details.isEmpty ? '插件运行失败：$error' : '插件运行失败：$error\n\n$details',
          ),
        ),
      ),
    );
  }
}
