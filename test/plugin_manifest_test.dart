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

  test('rejects web runtimes', () {
    for (final runtime in ['web', 'html', 'webview', 'legacy']) {
      final manifest = _copy(validManifest)..['runtime'] = runtime;
      expect(() => PluginManifest.fromJson(manifest), throwsFormatException);
    }
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
              $Closure((runtime, target, args) {
                return runtime.wrap(<String, dynamic>{
                  'token': 'fresh',
                }, recursive: true);
              }),
              $Closure((runtime, target, args) => null),
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
          bytecodeLoader: (path) => File(path).readAsBytesSync(),
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

  testWidgets('normalizes dynamic host arguments before executeLib', (
    tester,
  ) async {
    final compiler = Compiler()..addPlugin(flutterEvalPlugin);
    final program = compiler.compile({
      'dynamic_args_demo': {
        'main.dart': '''
import 'package:flutter/material.dart';

Widget buildHome(Map<String, dynamic> host) =>
    Text(host['label']);
''',
      },
    });
    final temp = Directory.systemTemp.createTempSync('zytb-plugin-dynamic-');
    addTearDown(() {
      if (temp.existsSync()) temp.deleteSync(recursive: true);
    });
    final bytecode = File('${temp.path}${Platform.pathSeparator}plugin.evc');
    bytecode.writeAsBytesSync(program.write(), flush: true);

    await tester.pumpWidget(
      MaterialApp(
        home: PluginProgramWidget(
          bytecodePath: bytecode.path,
          bytecodeLoader: (path) => File(path).readAsBytesSync(),
          library: 'package:dynamic_args_demo/main.dart',
          function: 'buildHome',
          // Deliberately keep the public argument list dynamically typed, as
          // PluginRuntimePage does when it assembles host callbacks.
          args: <dynamic>[
            $Map.wrap(<$Value, $Value>{
              $String('label'): $String('dynamic-args-ok'),
            }),
          ],
        ),
      ),
    );
    await tester.pump();
    expect(find.text('dynamic-args-ok'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('evaluated plugin can submit nested host HTTP options', (
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
    request('POST', 'https://example.invalid', {
      'requestId': 'demo',
      'headers': {'X-Test': 'nested-header'},
      'body': {
        'items': [
          {'id': 7, 'tags': ['a', 'b']},
        ],
      },
    });
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
    Object? receivedOptions;
    final host = $Map.wrap(<$Value, $Value>{
      $String('httpRequest'): $Closure((runtime, target, args) {
        completed = true;
        receivedOptions = args[2]!.$reified;
        return null;
      }),
    });
    await tester.pumpWidget(
      MaterialApp(
        home: PluginProgramWidget(
          bytecodePath: bytecode.path,
          bytecodeLoader: (path) => File(path).readAsBytesSync(),
          library: 'package:host_http_demo/main.dart',
          function: 'buildHome',
          args: [host],
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('request'));
    for (var i = 0; i < 10 && !completed; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(completed, isTrue);
    expect(receivedOptions, isA<Map>());
    expect(receivedOptions, {
      'requestId': 'demo',
      'headers': {'X-Test': 'nested-header'},
      'body': {
        'items': [
          {
            'id': 7,
            'tags': ['a', 'b'],
          },
        ],
      },
    });
  });

  test('username example uses the host HTTP API for User/GetInfoAsync', () {
    final source = File('plugin/example/lib/main.dart').readAsStringSync();
    expect(source, contains('/api/services/app/User/GetInfoAsync'));
    expect(source, contains('host[\'httpRequest\']'));
    expect(source, contains('getLatestHost()'));
  });

  testWidgets(
    'built username example renders and submits User/GetInfoAsync',
    (tester) async {
      final bytecode = File(
        'plugin/example/build/package/plugin.evc',
      ).readAsBytesSync();
      var submitted = false;
      var submittedUrl = '';
      var pending = false;
      var completed = false;
      final hostRevision = ValueNotifier<int>(0);
      addTearDown(hostRevision.dispose);
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
        $String('httpRequest'): $Closure((runtime, target, args) {
          submitted = true;
          submittedUrl = args.length > 1
              ? args[1]?.$reified?.toString() ?? ''
              : '';
          pending = true;
          hostRevision.value++;
          return null;
        }),
        $String('getHttpResult'): $Closure((runtime, target, args) {
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
      Object? pluginError;
      await tester.pumpWidget(
        MaterialApp(
          home: PluginProgramWidget(
            bytecodePath: 'example-plugin.evc',
            bytecodeLoader: (_) => bytecode,
            library: 'package:zytb_username_example/main.dart',
            function: 'buildUsernamePage',
            updateListenable: hostRevision,
            onError: (context, error, stackTrace) {
              pluginError = error;
              return Text('plugin-error: $error');
            },
            args: [
              $Map.wrap(<$Value, $Value>{
                $String('route'): $String('/home'),
                $String('posId'): $String('Homepage:Menu'),
              }),
              host,
              $Closure((runtime, target, args) => buildHost()),
              $Closure((runtime, target, args) => null),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(pluginError, isNull, reason: '$pluginError');
      expect(find.text('尚未请求'), findsOneWidget);
      expect(find.text('获取用户名'), findsWidgets);
      await tester.tap(find.widgetWithText(ElevatedButton, '获取用户名'));
      await tester.pump();
      expect(submitted, isTrue);
      expect(
        submittedUrl,
        'https://example.invalid/api/services/app/User/GetInfoAsync',
      );
      expect(tester.takeException(), isNull);
      expect(find.text('正在请求用户信息……'), findsOneWidget);
      pending = false;
      completed = true;
      hostRevision.value++;
      await tester.pump();
      expect(find.text('student'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    skip: !File('plugin/example/build/package/plugin.evc').existsSync(),
  );

  testWidgets(
    'optional profile plugin renders and submits profile edits',
    (tester) async {
      final package = ZipDecoder().decodeBytes(
        File(
          'plugin/profile/dist/com.zhongyu.toolbox.profile/'
          'com.zhongyu.toolbox.profile.zytbplugin',
        ).readAsBytesSync(),
      );
      final bytecodeFile = package.findFile('plugin.evc');
      expect(bytecodeFile, isNotNull);
      final bytecode = Uint8List.fromList(bytecodeFile!.content as List<int>);

      const requestProfile = <String, dynamic>{
        'userName': 'ada',
        'number': '1001',
        'surname': 'Ada',
        'name': 'Lovelace',
        'fullName': 'Ada Lovelace',
        'pictrue': 'https://example.invalid/avatar.png',
        'hasPicture': true,
        'gender': 2,
        'schoolName': 'Analytical School',
      };
      final results = <String, Map<String, dynamic>>{};
      final hostRevision = ValueNotifier<int>(0);
      addTearDown(hostRevision.dispose);
      Map<String, dynamic>? submittedProfile;
      var loaded = false;

      $Map<$Value, $Value> buildHost() => $Map.wrap(<$Value, $Value>{
        $String('schoolCode'): $String('test-school'),
        $String('userId'): $String('3'),
        $String('schoolName'): $String('Analytical School'),
        $String('requestPageRebuild'): $Closure((runtime, target, args) {
          hostRevision.value++;
          return null;
        }),
        $String('getProfileResult'): $Closure((runtime, target, args) {
          final requestId = args.first?.$reified?.toString() ?? '';
          return runtime.wrap(
            results[requestId] ??
                <String, dynamic>{
                  'started': false,
                  'pending': false,
                  'error': '',
                  'profile': <String, dynamic>{},
                  'response': <String, dynamic>{},
                },
            recursive: true,
          );
        }),
        $String('loadUserProfile'): $Closure((runtime, target, args) {
          final requestId = args.first?.$reified?.toString() ?? '';
          loaded = true;
          results[requestId] = <String, dynamic>{
            'started': true,
            'pending': false,
            'error': '',
            'profile': requestProfile,
            'response': <String, dynamic>{},
          };
          hostRevision.value++;
          return null;
        }),
        $String('pickAndUploadAvatar'): $Closure((runtime, target, args) {
          final requestId = args.first?.$reified?.toString() ?? '';
          results[requestId] = <String, dynamic>{
            'started': true,
            'pending': false,
            'error': '',
            'profile': requestProfile,
            'response': <String, dynamic>{'cancelled': true},
          };
          hostRevision.value++;
          return null;
        }),
        $String('updateUserProfile'): $Closure((runtime, target, args) {
          final requestId = args.first?.$reified?.toString() ?? '';
          final raw = args.length > 1 ? args[1]?.$reified : null;
          submittedProfile = raw is Map
              ? raw.map((key, value) => MapEntry(key.toString(), value))
              : null;
          final updated = <String, dynamic>{
            ...requestProfile,
            ...?submittedProfile,
            'fullName':
                '${submittedProfile?['surname'] ?? ''} ${submittedProfile?['name'] ?? ''}'
                    .trim(),
          };
          results[requestId] = <String, dynamic>{
            'started': true,
            'pending': false,
            'error': '',
            'profile': updated,
            'response': <String, dynamic>{'saved': true},
          };
          hostRevision.value++;
          return null;
        }),
      });

      Object? pluginError;
      StackTrace? pluginStack;
      await tester.pumpWidget(
        MaterialApp(
          home: PluginProgramWidget(
            bytecodePath: 'profile-plugin.evc',
            bytecodeLoader: (_) => bytecode,
            library: 'package:zytb_profile_plugin/main.dart',
            function: 'buildProfilePage',
            updateListenable: hostRevision,
            onError: (context, error, stackTrace) {
              pluginError = error;
              pluginStack = stackTrace;
              return Text('plugin-error: $error');
            },
            args: [
              $Map.wrap(<$Value, $Value>{}),
              buildHost(),
              $Closure((runtime, target, args) => buildHost()),
              $Closure((runtime, target, args) => null),
            ],
          ),
        ),
      );

      for (var i = 0; i < 20 && !loaded; i++) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      for (
        var i = 0;
        i < 20 && find.text('Ada Lovelace').evaluate().isEmpty;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(loaded, isTrue);
      expect(pluginError, isNull, reason: '$pluginError\n$pluginStack');
      expect(find.text('Ada Lovelace'), findsNWidgets(2));
      expect(find.text('1001'), findsNWidgets(2));
      expect(find.byType(TextField), findsNothing);
      expect(find.byTooltip('编辑'), findsOneWidget);

      await tester.tap(find.byTooltip('编辑'));
      await tester.pump();
      expect(pluginError, isNull, reason: '$pluginError\n$pluginStack');
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byTooltip('取消'), findsOneWidget);
      expect(find.byTooltip('保存'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Grace');
      await tester.tap(find.byTooltip('保存'));
      await tester.pump();

      expect(submittedProfile, {
        'surname': 'Grace',
        'name': 'Lovelace',
        'picture': 'https://example.invalid/avatar.png',
      });
      expect(pluginError, isNull, reason: '$pluginError');
      expect(find.text('Grace Lovelace'), findsNWidgets(2));
      expect(find.text('个人信息已保存'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    skip: !File(
      'plugin/profile/dist/com.zhongyu.toolbox.profile/'
      'com.zhongyu.toolbox.profile.zytbplugin',
    ).existsSync(),
  );

  testWidgets(
    'optional profile plugin handles a missing host API gracefully',
    (tester) async {
      final package = ZipDecoder().decodeBytes(
        File(
          'plugin/profile/dist/com.zhongyu.toolbox.profile/'
          'com.zhongyu.toolbox.profile.zytbplugin',
        ).readAsBytesSync(),
      );
      final bytecodeFile = package.findFile('plugin.evc');
      expect(bytecodeFile, isNotNull);
      final bytecode = Uint8List.fromList(bytecodeFile!.content as List<int>);
      final host = $Map.wrap(<$Value, $Value>{});
      Object? pluginError;
      StackTrace? pluginStack;

      await tester.pumpWidget(
        MaterialApp(
          home: PluginProgramWidget(
            bytecodePath: 'profile-plugin.evc',
            bytecodeLoader: (_) => bytecode,
            library: 'package:zytb_profile_plugin/main.dart',
            function: 'buildProfilePage',
            onError: (context, error, stackTrace) {
              pluginError = error;
              pluginStack = stackTrace;
              return const Text('plugin-error');
            },
            args: [
              $Map.wrap(<$Value, $Value>{}),
              host,
              $Closure((runtime, target, args) => host),
              $Closure((runtime, target, args) => null),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(pluginError, isNull, reason: '$pluginError\n$pluginStack');
      expect(find.text('当前应用版本缺少个人信息插件接口，请更新应用后重新打开。'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    skip: !File(
      'plugin/profile/dist/com.zhongyu.toolbox.profile/'
      'com.zhongyu.toolbox.profile.zytbplugin',
    ).existsSync(),
  );
}

Map<String, dynamic> _copy(Map<String, dynamic> source) {
  return Map<String, dynamic>.from(jsonDecode(jsonEncode(source)) as Map);
}
