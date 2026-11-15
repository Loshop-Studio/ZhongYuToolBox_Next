import 'dart:io';
import 'dart:typed_data';

import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/dart_eval_security.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eval/flutter_eval.dart';

/// 从原生文件路径加载 EVC，避免 flutter_eval 将 Windows 的 `C:\...`
/// 转换为无法被 [File] 识别的 `/C:/...` URI path。
class PluginProgramWidget extends StatefulWidget {
  const PluginProgramWidget({
    super.key,
    required this.bytecodePath,
    required this.library,
    required this.function,
    this.args = const <dynamic>[],
    this.permissions = const <Permission>[],
    this.revision = 0,
    this.loading,
    this.onError,
  });

  final String bytecodePath;
  final String library;
  final String function;
  final List<dynamic> args;
  final List<Permission> permissions;
  final int revision;
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant PluginProgramWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bytecodePath != widget.bytecodePath) {
      _runtime = null;
      _result = null;
      _error = null;
      _errorStackTrace = null;
      _load();
    } else if (oldWidget.revision != widget.revision ||
        oldWidget.library != widget.library ||
        oldWidget.function != widget.function) {
      _runtime = null;
      _result = null;
      _error = null;
      _errorStackTrace = null;
      _load();
    }
  }

  void _load() {
    try {
      final bytes = File(widget.bytecodePath).readAsBytesSync();
      final runtime = Runtime(ByteData.sublistView(bytes));
      for (final permission in widget.permissions) {
        runtime.grant(permission);
      }
      runtime.addPlugin(flutterEvalPlugin);
      _runtime = runtime;
      _result = null;
      _error = null;
      _errorStackTrace = null;
    } catch (error, stackTrace) {
      _error = error;
      _errorStackTrace = stackTrace;
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    if (error != null) {
      return widget.onError?.call(context, error, _errorStackTrace) ??
          ErrorWidget(error);
    }
    final runtime = _runtime;
    if (runtime == null) return widget.loading ?? const SizedBox.shrink();
    final cached = _result;
    if (cached != null) return cached;
    try {
      final result = runtime.executeLib(
        widget.library,
        widget.function,
        widget.args,
      );
      final evaluated = (result as $Value).$value as Widget;
      _result = evaluated;
      return evaluated;
    } catch (error, stackTrace) {
      return widget.onError?.call(context, error, stackTrace) ??
          ErrorWidget(error);
    }
  }
}
