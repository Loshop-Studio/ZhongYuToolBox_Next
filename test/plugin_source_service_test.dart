import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zhongyu_toolbox/core/plugins/plugin_source_models.dart';
import 'package:zhongyu_toolbox/core/plugins/plugin_source_service.dart';

void main() {
  test(
    'index requests refresh the v parameter and preserve other query values',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));

      late Uri requestedUri;
      server.listen((request) async {
        requestedUri = request.uri;
      request.response.write('(com.example.cache)[Cache]test');
        await request.response.close();
      });

      final before = DateTime.now().millisecondsSinceEpoch;
      await PluginSourceService().fetchIndex(
        PluginIndexSource(
          url:
              'http://${server.address.host}:${server.port}/index.txt?channel=stable&v=old',
        ),
      );
      final after = DateTime.now().millisecondsSinceEpoch;

      expect(requestedUri.queryParameters['channel'], 'stable');
      final cacheBuster = int.tryParse(requestedUri.queryParameters['v'] ?? '');
      expect(cacheBuster, isNotNull);
      expect(cacheBuster, inInclusiveRange(before, after));
    },
  );
}
