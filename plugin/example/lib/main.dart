import 'package:flutter/material.dart';

Widget buildUsernamePage(
  Map<String, dynamic> pageContext,
  Map<String, dynamic> host,
  Map<String, dynamic> Function() getLatestHost,
  void Function(String, Map<String, dynamic>) openPage,
) {
  final latest = getLatestHost();
  final state = _requestState(latest);
  final pending = state['pending'] == true;
  Widget statusWidget;
  if (state['started'] != true) {
    statusWidget = const Text('尚未请求');
  } else if (pending) {
    statusWidget = const Text('正在请求用户信息……');
  } else if (state['error'] != null && state['error'] != '') {
    statusWidget = Text(state['error']);
  } else {
    final response = state['response'];
    final decoded = response is Map ? response['json'] : null;
    final result = decoded is Map ? decoded['result'] : null;
    final username = result is Map ? result['userName'] : null;
    statusWidget = username == null || username == ''
        ? const Text('接口未返回 userName')
        : Text(username);
  }
  return Scaffold(
    appBar: AppBar(title: const Text('获取用户名')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '点击按钮调用 User/GetInfoAsync，读取 result.userName。',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text('当前用户名 / 请求状态'),
            statusWidget,
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _loadUsername(getLatestHost),
              child: Text(pending ? '请求中……' : '获取用户名'),
            ),
          ],
        ),
      ),
    ),
  );
}

void _loadUsername(Map<String, dynamic> Function() getLatestHost) {
  final host = getLatestHost();
  final apiHost = host['apiHost'].toString();
  final endpoint = apiHost.endsWith('/')
      ? '${apiHost}api/services/app/User/GetInfoAsync'
      : '$apiHost/api/services/app/User/GetInfoAsync';
  final void Function(String, String, Map<String, dynamic>) httpRequest =
      host['httpRequest'];
  httpRequest(
    'GET',
    endpoint,
    {
      'headers': {
        'Authorization': 'Bearer ${host['token']}',
        'Content-Type': 'application/json',
      },
      'requestId': 'get-username',
      'timeoutSeconds': 20,
    },
  );
}

Map<String, dynamic> _requestState(Map<String, dynamic> host) {
  final Map<String, dynamic> Function(String) getHttpResult =
      host['getHttpResult'];
  return getHttpResult('get-username');
}
