import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zhongyu_toolbox/core/plugins/plugin_http_service.dart';

void main() {
  test(
    'host HTTP service supports headers, body and response metadata',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      server.listen((request) async {
        final body = await utf8.decoder.bind(request).join();
        expect(request.method, 'POST');
        expect(request.headers.value('x-plugin-test'), 'yes');
        expect(jsonDecode(body), <String, dynamic>{'hello': 'world'});
        request.response
          ..statusCode = HttpStatus.created
          ..headers.set('x-host-result', 'ok')
          ..write(jsonEncode(<String, dynamic>{'userName': 'tester'}));
        await request.response.close();
      });

      final response = await PluginHttpService.request(
        method: 'POST',
        url: 'http://${server.address.host}:${server.port}/user',
        headers: const <String, String>{'x-plugin-test': 'yes'},
        body: <String, dynamic>{'hello': 'world'},
        timeoutSeconds: 5,
      );
      expect(response['statusCode'], HttpStatus.created);
      expect((response['headers'] as Map)['x-host-result'], 'ok');
      expect(jsonDecode(response['body'].toString()), <String, dynamic>{
        'userName': 'tester',
      });
    },
  );
}
