import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eval/flutter_eval.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zhongyu_toolbox/core/plugins/plugin_manager.dart';
import 'package:zhongyu_toolbox/core/plugins/plugin_models.dart';
import 'package:zhongyu_toolbox/core/plugins/plugin_program_widget.dart';

void main() {
  const validManifest = <String, dynamic>{
    'id': 'com.example.demo',
    'name': 'Demo',
    'version': '1.0.0',
    'bytecode': 'plugin.evc',
    'pages': [
      {
        'id': 'home',
        'title': 'Home',
        'library': 'package:demo/main.dart',
        'function': 'buildHome',
      },
    ],
    'actions': [
      {
        'id': 'entry',
        'posId': PluginPositions.homepageMenu,
        'label': 'Demo',
        'pageId': 'home',
      },
    ],
  };

  test('parses a valid manifest', () {
    final manifest = PluginManifest.fromJson(validManifest);
    expect(manifest.id, 'com.example.demo');
    expect(manifest.pages.single.id, 'home');
    expect(manifest.actions.single.posId, PluginPositions.homepageMenu);
  });

  test('rejects unknown positions and missing pages', () {
    final unknownPosition = _copy(validManifest);
    (unknownPosition['actions'] as List).first['posId'] = 'Unknown:Position';
    expect(
      () => PluginManifest.fromJson(unknownPosition),
      throwsFormatException,
    );

    final missingPage = _copy(validManifest);
    (missingPage['actions'] as List).first['pageId'] = 'missing';
    expect(() => PluginManifest.fromJson(missingPage), throwsFormatException);
  });

  test('inspects a packaged plugin', () {
    final manifestBytes = utf8.encode(jsonEncode(validManifest));
    final archive = Archive()
      ..addFile(
        ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
      )
      ..addFile(ArchiveFile('plugin.evc', 4, <int>[1, 2, 3, 4]));
    final bytes = Uint8List.fromList(ZipEncoder().encode(archive)!);
    final manifest = PluginManager.instance.inspectPackage(bytes);
    expect(manifest.name, 'Demo');
  });

  testWidgets('plugin page ABI can render and read latest host info', (
    tester,
  ) async {
    final compiler = Compiler()..addPlugin(flutterEvalPlugin);
    final program = compiler.compile({
      'demo': {
        'main.dart': '''
import 'package:flutter/material.dart';

Widget buildHome(
  Map<String, dynamic> pageContext,
  Map<String, dynamic> host,
  Map<String, dynamic> Function() getLatestHost,
  void Function(String, Map<String, dynamic>) openPage,
) {
  return Text(pageContext['fileId'] + ':' + getLatestHost()['token']);
}
''',
      },
    });
    final runtime = Runtime.ofProgram(program)..addPlugin(flutterEvalPlugin);
    final pageContext = $Map.wrap(<$Value, $Value>{
      $String('fileId'): $String('note-1'),
    });
    final host = $Map.wrap(<$Value, $Value>{$String('token'): $String('old')});
    final widget =
        runtime.executeLib('package:demo/main.dart', 'buildHome', [
              pageContext,
              host,
              $Function((runtime, target, args) {
                return runtime.wrap(<String, dynamic>{
                  'token': 'fresh',
                }, recursive: true);
              }),
              $Function((runtime, target, args) => null),
            ]).$value
            as Widget;
    await tester.pumpWidget(MaterialApp(home: widget));
    expect(find.text('note-1:fresh'), findsOneWidget);
  });

  testWidgets('loads bytecode from a native local file path', (tester) async {
    final compiler = Compiler()..addPlugin(flutterEvalPlugin);
    final program = compiler.compile({
      'native_path_demo': {
        'main.dart': '''
import 'package:flutter/material.dart';

Widget buildHome() => const Text('native-path-ok');
''',
      },
    });
    final temp = Directory.systemTemp.createTempSync('zytb-plugin-path-');
    addTearDown(() {
      if (temp.existsSync()) temp.deleteSync(recursive: true);
    });
    final bytecode = File('${temp.path}${Platform.pathSeparator}plugin.evc');
    bytecode.writeAsBytesSync(program.write(), flush: true);

    await tester.pumpWidget(
      MaterialApp(
        home: PluginProgramWidget(
          bytecodePath: bytecode.path,
          library: 'package:native_path_demo/main.dart',
          function: 'buildHome',
        ),
      ),
    );
    for (
      var i = 0;
      i < 20 && find.text('native-path-ok').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('native-path-ok'), findsOneWidget);
  });

  testWidgets('evaluated plugin can submit a host HTTP request', (
    tester,
  ) async {
    final compiler = Compiler()..addPlugin(flutterEvalPlugin);
    final program = compiler.compile({
      'host_http_demo': {
        'main.dart': '''
import 'package:flutter/material.dart';

Widget buildHome(Map<String, dynamic> host) {
  return DemoPage(host: host);
}

class DemoPage extends StatelessWidget {
  const DemoPage({super.key, required this.host});

  final Map<String, dynamic> host;

  void _request() {
    final void Function(
      String,
      String,
      Map<String, dynamic>,
    ) request = host['httpRequest'];
    request('GET', 'https://example.invalid', {'requestId': 'demo'});
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _request(),
      child: const Text('request'),
    );
  }
}
''',
      },
    });
    final temp = Directory.systemTemp.createTempSync('zytb-plugin-http-');
    addTearDown(() {
      if (temp.existsSync()) temp.deleteSync(recursive: true);
    });
    final bytecode = File('${temp.path}${Platform.pathSeparator}plugin.evc');
    bytecode.writeAsBytesSync(program.write(), flush: true);

    var completed = false;
    final host = $Map.wrap(<$Value, $Value>{
      $String('httpRequest'): $Function((runtime, target, args) {
        completed = true;
        return null;
      }),
    });
    await tester.pumpWidget(
      MaterialApp(
        home: PluginProgramWidget(
          bytecodePath: bytecode.path,
          library: 'package:host_http_demo/main.dart',
          function: 'buildHome',
          args: [host],
        ),
      ),
    );
    await tester.tap(find.text('request'));
    for (var i = 0; i < 10 && !completed; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(completed, isTrue);
  });

  testWidgets('packaged username example renders its first frame', (
    tester,
  ) async {
    final bytecode = File('plugin/example/build/package/plugin.evc');
    expect(bytecode.existsSync(), isTrue);
    var submitted = false;
    var pending = false;
    var completed = false;
    var revision = 0;
    StateSetter? rebuild;
    $Map<$Value, $Value> buildHost() => $Map.wrap(<$Value, $Value>{
      $String('apiHost'): $String('https://example.invalid'),
      $String('webHost'): $String('https://web.example.invalid'),
      $String('token'): $String('token'),
      $String('username'): $String('student'),
      $String('displayName'): $String('Test Student'),
      $String('avatar'): $String('https://example.invalid/avatar.png'),
      $String('avatarRaw'): $String('/avatar.png'),
      $String('userId'): $String('123'),
      $String('schoolCode'): $String('test'),
      $String('schoolName'): $String('Test School'),
      $String('pluginId'): $String('com.zhongyu.toolbox.example.username'),
      $String('pluginPath'): $String(r'D:\plugins\username'),
      $String('httpRequest'): $Function((runtime, target, args) {
        submitted = true;
        pending = true;
        revision++;
        rebuild?.call(() {});
        return null;
      }),
      $String('getHttpResult'): $Function((runtime, target, args) {
        return runtime.wrap(<String, dynamic>{
          'started': pending || completed,
          'pending': pending,
          'error': '',
          'response': completed
              ? <String, dynamic>{
                  'statusCode': 200,
                  'body': '{"result":{"userName":"student"}}',
                  'json': <String, dynamic>{
                    'result': <String, dynamic>{'userName': 'student'},
                  },
                }
              : <String, dynamic>{},
        }, recursive: true);
      }),
    });
    final host = buildHost();
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return PluginProgramWidget(
              bytecodePath: bytecode.absolute.path,
              library: 'package:zytb_username_example/main.dart',
              function: 'buildUsernamePage',
              revision: revision,
              args: [
                $Map.wrap(<$Value, $Value>{
                  $String('route'): $String('/home'),
                  $String('posId'): $String('Homepage:Menu'),
                }),
                host,
                $Function((runtime, target, args) => buildHost()),
                $Function((runtime, target, args) => null),
              ],
            );
          },
        ),
      ),
    );
    await tester.pump();
    expect(find.text('尚未请求'), findsOneWidget);
    expect(find.text('获取用户名'), findsWidgets);
    await tester.tap(find.widgetWithText(ElevatedButton, '获取用户名'));
    await tester.pump();
    expect(submitted, isTrue);
    expect(tester.takeException(), isNull);
    expect(find.text('正在请求用户信息……'), findsOneWidget);
    pending = false;
    completed = true;
    revision++;
    rebuild?.call(() {});
    await tester.pump();
    expect(find.text('student'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Map<String, dynamic> _copy(Map<String, dynamic> source) {
  return Map<String, dynamic>.from(jsonDecode(jsonEncode(source)) as Map);
}
