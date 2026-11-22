import 'dart:io';

import 'package:flutter/material.dart';

Widget buildHome(
  Map<String, dynamic> pageContext,
  Map<String, dynamic> host,
  Map<String, dynamic> Function() getLatestHost,
  void Function(String, Map<String, dynamic>) openPage,
) {
  final latest = getLatestHost();
  final Map<String, dynamic> Function(String) getHttpResult =
      latest['getHttpResult'];
  final httpState = getHttpResult('template-http');
  final pending = httpState['pending'] == true;
  final rawHttpError = httpState['error'];
  final response = httpState['response'];
  final httpStarted = httpState['started'] == true;
  Widget httpStatusWidget;
  if (pending) {
    httpStatusWidget = const Text('HTTP：请求中……');
  } else if (rawHttpError != null && rawHttpError != '') {
    httpStatusWidget = Text(rawHttpError);
  } else if (!httpStarted || response is! Map) {
    httpStatusWidget = const Text('HTTP：尚未请求');
  } else {
    httpStatusWidget = const Text('HTTP：请求完成');
  }
  return Scaffold(
    appBar: AppBar(title: const Text('Toolbox 插件模板')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('当前用户'),
        Text(latest['displayName']),
        const SizedBox(height: 8),
        const Text('来源 posId'),
        Text(pageContext['posId'] ?? '未知'),
        const Text('API Host'),
        Text(latest['apiHost']),
        Text(latest['token'] == '' ? 'Token：无' : 'Token：已获取'),
        httpStatusWidget,
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _writeFile(getLatestHost, openPage),
          child: const Text('测试本地文件读写'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _httpRequest(getLatestHost),
          child: Text(pending ? '请求中……' : '测试带 Token 的 HTTP 请求'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => openPage('detail', {
            'message': '来自首页的参数',
          }),
          child: const Text('打开插件第二页'),
        ),
      ],
    ),
  );
}

Widget buildDetail(
  Map<String, dynamic> pageContext,
  Map<String, dynamic> host,
  Map<String, dynamic> Function() getLatestHost,
  void Function(String, Map<String, dynamic>) openPage,
) {
  return Scaffold(
    appBar: AppBar(title: const Text('插件第二页')),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('上一页传入'),
          Text(pageContext['message'] ?? '无'),
        ],
      ),
    ),
  );
}

void _writeFile(
  Map<String, dynamic> Function() getLatestHost,
  void Function(String, Map<String, dynamic>) openPage,
) {
  try {
    final host = getLatestHost();
    final path = '${host['pluginPath']}/template-data.txt';
    final file = File(path);
    file.writeAsStringSync(
      'user=${host['username']}\ntime=${DateTime.now().toIso8601String()}\n',
    );
    final content = file.readAsStringSync();
    openPage('detail', {'message': '已写入 $path\n$content'});
  } catch (error) {
    openPage('detail', {'message': '文件操作失败：$error'});
  }
}

void _httpRequest(Map<String, dynamic> Function() getLatestHost) {
  final host = getLatestHost();
  final apiHost = host['apiHost'].toString();
  final endpoint = _joinApiPath(
    apiHost,
    '/api/services/app/User/GetInfoAsync',
  );
  if (endpoint.isEmpty) return;
  final void Function(String, String, Map<String, dynamic>) httpRequest =
      host['httpRequest'];
  httpRequest(
    'GET',
    endpoint,
    {
      'headers': {'Authorization': 'Bearer ${host['token']}'},
      'requestId': 'template-http',
      'timeoutSeconds': 20,
    },
  );
}

String _joinApiPath(String base, String path) {
  final cleanedBase = base.replaceFirst(RegExp(r'/+$'), '');
  if (cleanedBase.isEmpty) return '';
  final cleanedPath = path.startsWith('/') ? path : '/$path';
  return '$cleanedBase$cleanedPath';
}
