import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:dart_eval/dart_eval_security.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:flutter/material.dart';

import '../../shared/widgets/common.dart';
import '../../data/api/oss_api.dart';
import '../../data/api/user_profile_api.dart';
import '../../data/models/user_profile.dart';
import '../../shared/widgets/user_avatar.dart';
import '../storage/session_manager.dart';
import '../util/urls.dart';
import 'plugin_http_service.dart';
import 'plugin_manager.dart';
import 'plugin_models.dart';
import 'plugin_program_widget.dart';

/// Hosts one Flutter/EVC plugin page inside the application navigator.
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
  final Map<String, Map<String, dynamic>> _profileResults = {};
  UserProfile? _profileCache;
  final ValueNotifier<int> _hostRevision = ValueNotifier<int>(0);
  late Future<bool> _sessionReady;

  @override
  void initState() {
    super.initState();
    _session.addListener(_onSessionChanged);
    _sessionReady = _session.ensureValidSession();
  }

  @override
  void dispose() {
    _session.removeListener(_onSessionChanged);
    _hostRevision.dispose();
    super.dispose();
  }

  void _onSessionChanged() {
    _profileCache = null;
    _notifyHostChanged();
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
        if (snapshot.hasError || snapshot.data != true) {
          return Scaffold(
            appBar: AppBar(title: Text(page.title)),
            body: ErrorView(
              message: snapshot.hasError
                  ? '会话准备失败：${snapshot.error}'
                  : '当前没有有效登录会话',
              onRetry: () {
                setState(() {
                  _sessionReady = _session.ensureValidSession();
                });
              },
            ),
          );
        }

        return PluginProgramWidget(
          key: ValueKey(
            '${plugin.manifest.id}:${page.id}:${plugin.manifest.version}',
          ),
          bytecodePath: plugin.bytecodePath,
          library: page.library,
          function: page.function,
          permissions: [FilesystemPermission.any, NetworkPermission.any],
          updateListenable: _hostRevision,
          args: [
            _wrapMap(widget.pageContext),
            _wrapHostInfo(plugin),
            $Closure((runtime, target, args) {
              return _wrapHostInfo(plugin);
            }),
            $Closure((runtime, target, args) {
              _openPage(plugin, args);
              return null;
            }),
          ],
          loading: Scaffold(
            appBar: AppBar(title: Text(page.title)),
            body: const LoadingView(text: '正在加载插件…'),
          ),
          onError: (context, error, stackTrace) => Scaffold(
            appBar: AppBar(title: Text(page.title)),
            body: _PluginErrorView(error: error, stackTrace: stackTrace),
          ),
        );
      },
    );
  }

  void _openPage(InstalledPlugin plugin, List<$Value?> args) {
    final pageId = args.isEmpty ? '' : _valueString(args[0]);
    final raw = args.length > 1 ? _valueReified(args[1]) : null;
    final extra = raw is Map
        ? raw.map((key, value) => MapEntry(key.toString(), value))
        : <String, dynamic>{};
    if (pageId.isEmpty || !mounted) return;
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
    values[$String('getHttpResult')] = $Closure((runtime, target, args) {
      final requestId = args.isEmpty ? '' : _valueString(args[0]);
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
    values[$String('httpRequest')] = $Closure((runtime, target, args) {
      final method = args.isEmpty ? 'GET' : _valueString(args[0]);
      final url = args.length < 2 ? '' : _valueString(args[1]);
      final rawOptions = args.length < 3 ? null : _valueReified(args[2]);
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
      _notifyHostChanged();
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
            _notifyHostChanged();
          },
          onError: (Object error, StackTrace stackTrace) {
            _httpResults[requestId] = <String, dynamic>{
              'started': true,
              'pending': false,
              'error': error.toString(),
              'response': <String, dynamic>{},
            };
            _notifyHostChanged();
          },
        ),
      );
      return null;
    });
    values[$String('getProfileResult')] = $Closure((runtime, target, args) {
      final requestId = args.isEmpty ? 'profile' : _valueString(args[0]);
      return runtime.wrap(
        _profileResults[requestId] ?? _emptyProfileState(),
        recursive: true,
      );
    });
    values[$String('buildProfileAvatar')] =
        $Closure((runtime, target, args) {
      final name = args.isEmpty ? '' : _valueString(args[0]);
      final photo = args.length < 2 ? '' : _valueString(args[1]);
      final editing = args.length > 2 && _valueReified(args[2]) == true;
      final uploading = args.length > 3 && _valueReified(args[3]) == true;
      return runtime.wrapAlways(
        _buildProfileAvatar(
          name: name,
          photo: photo,
          editing: editing,
          uploading: uploading,
        ),
      );
    });
    values[$String('loadUserProfile')] = $Closure((runtime, target, args) {
      final requestId = args.isEmpty ? 'profile' : _valueString(args[0]);
      _startProfileRequest(requestId);
      unawaited(_loadUserProfile(requestId));
      return null;
    });
    values[$String('pickAndUploadAvatar')] = $Closure((runtime, target, args) {
      final requestId = args.isEmpty ? 'avatar' : _valueString(args[0]);
      _startProfileRequest(requestId);
      unawaited(_pickAndUploadAvatar(requestId));
      return null;
    });
    values[$String('updateUserProfile')] = $Closure((runtime, target, args) {
      final requestId = args.isEmpty ? 'profile-save' : _valueString(args[0]);
      final raw = args.length > 1 ? _valueReified(args[1]) : null;
      final updateValues = raw is Map
          ? raw.map((key, value) => MapEntry(key.toString(), value))
          : <String, dynamic>{};
      _startProfileRequest(requestId);
      unawaited(_updateUserProfile(requestId, updateValues));
      return null;
    });
    values[$String('requestPageRebuild')] = $Closure((runtime, target, args) {
      _notifyHostChanged();
      return null;
    });
    return $Map.wrap(values);
  }

  Map<String, dynamic> _emptyProfileState() => <String, dynamic>{
    'started': false,
    'pending': false,
    'error': '',
    'profile': <String, dynamic>{},
    'response': <String, dynamic>{},
  };

  void _startProfileRequest(String requestId) {
    _profileResults[requestId] = <String, dynamic>{
      'started': true,
      'pending': true,
      'error': '',
      'profile': _profileCache == null
          ? <String, dynamic>{}
          : _profileToMap(_profileCache!),
      'response': <String, dynamic>{},
    };
    _notifyHostChanged();
  }

  Future<void> _loadUserProfile(String requestId) async {
    try {
      final session = _session.session;
      final profile = await UserProfileApi.getUserInfo(
        school: session.schoolCode,
        userId: session.userId,
      );
      _profileCache = profile;
      _finishProfileRequest(requestId, profile: profile);
    } catch (error) {
      _failProfileRequest(requestId, error);
    }
  }

  Future<void> _pickAndUploadAvatar(String requestId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        _finishProfileRequest(requestId, response: {'cancelled': true});
        return;
      }
      final picked = result.files.single;
      var bytes = picked.bytes;
      if ((bytes == null || bytes.isEmpty) && picked.path != null) {
        bytes = await File(picked.path!).readAsBytes();
      }
      if (bytes == null || bytes.isEmpty) throw StateError('无法读取所选头像');
      final session = _session.session;
      final url = await OssApi.uploadBytes(
        bytes: Uint8List.fromList(bytes),
        fileName: picked.name,
        userId: session.userId,
        fc: 'manage_v2',
        mime: _mimeFor(picked.name),
      );
      _finishProfileRequest(
        requestId,
        response: {
          'picture': userAvatarUrl(url, apiBaseUrl: session.apiBaseUrl),
        },
      );
    } catch (error) {
      _failProfileRequest(requestId, error);
    }
  }

  Future<void> _updateUserProfile(
    String requestId,
    Map<String, dynamic> values,
  ) async {
    try {
      final session = _session.session;
      final profile =
          _profileCache ??
          await UserProfileApi.getUserInfo(
            school: session.schoolCode,
            userId: session.userId,
          );
      final surname = (values['surname'] ?? profile.surname).toString().trim();
      final name = (values['name'] ?? profile.name).toString().trim();
      final picture =
          (values['picture'] ?? values['pictrue'] ?? profile.pictrue)
              .toString()
              .trim();
      await UserProfileApi.updateUserInfo(
        school: session.schoolCode,
        userId: session.userId,
        profile: profile,
        surname: surname,
        name: name,
        picture: picture,
      );
      final updated = profile.copyWith(
        surname: surname,
        name: name,
        pictrue: picture,
      );
      _profileCache = updated;
      final account = _session.currentAccount;
      if (account != null) {
        await _session.editAccount(
          account,
          realName: updated.fullName,
          photo: updated.pictrue,
        );
      }
      _finishProfileRequest(
        requestId,
        profile: updated,
        response: {'saved': true},
      );
    } catch (error) {
      _failProfileRequest(requestId, error);
    }
  }

  void _finishProfileRequest(
    String requestId, {
    UserProfile? profile,
    Map<String, dynamic>? response,
  }) {
    final current = _profileResults[requestId] ?? _emptyProfileState();
    _profileResults[requestId] = <String, dynamic>{
      ...current,
      'started': true,
      'pending': false,
      'error': '',
      if (profile != null) 'profile': _profileToMap(profile),
      'response': response ?? <String, dynamic>{},
    };
    _notifyHostChanged();
  }

  void _failProfileRequest(String requestId, Object error) {
    final current = _profileResults[requestId] ?? _emptyProfileState();
    _profileResults[requestId] = <String, dynamic>{
      ...current,
      'started': true,
      'pending': false,
      'error': error.toString(),
      'response': <String, dynamic>{},
    };
    _notifyHostChanged();
  }

  static String _mimeFor(String fileName) =>
      switch (fileName.split('.').last.toLowerCase()) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        'gif' => 'image/gif',
        _ => 'image/jpeg',
      };

  static Map<String, dynamic> _profileToMap(UserProfile profile) => {
    'id': profile.id,
    'pictrue': userAvatarUrl(
      profile.pictrue,
      apiBaseUrl: SessionManager.instance.session.apiBaseUrl,
    ),
    'hasPicture': profile.pictrue.isNotEmpty,
    'picture': userAvatarUrl(
      profile.pictrue,
      apiBaseUrl: SessionManager.instance.session.apiBaseUrl,
    ),
    'userName': profile.userName,
    'number': profile.number,
    'name': profile.name,
    'surname': profile.surname,
    'fullName': profile.fullName,
    'gender': profile.gender,
    'enterSchoolYearGradeId': profile.enterSchoolYearGradeId,
    'classId': profile.classId,
    'enterSchoolYear': profile.enterSchoolYear,
    'gradeName': profile.gradeName,
    'className': profile.className,
    'credentialsType': profile.credentialsType,
    'idNumber': profile.idNumber,
    'brithDay': profile.brithDay,
    'birthplace': profile.birthplace,
    'nation': profile.nation,
    'homeAddress': profile.homeAddress,
    'mobile': profile.mobile,
    'telephone': profile.telephone,
    'schoolRollState': profile.schoolRollState,
    'state': profile.state,
  };

  void _notifyHostChanged() {
    if (mounted) _hostRevision.value++;
  }

  Widget _buildProfileAvatar({
    required String name,
    required String photo,
    required bool editing,
    required bool uploading,
  }) {
    final session = _session.session;
    return SizedBox.square(
      dimension: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          UserAvatar(
            name: name,
            photo: photo,
            apiBaseUrl: session.apiBaseUrl,
            radius: 36,
          ),
          if (editing)
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(22),
                child: Icon(Icons.camera_alt_outlined, color: Colors.white),
              ),
            ),
          if (uploading)
            const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  static String _valueString(dynamic value) {
    final reified = _valueReified(value);
    return reified?.toString() ?? '';
  }

  static dynamic _valueReified(dynamic value) {
    if (value is $Value) return value.$reified;
    return value;
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
    if (value is $Value) return value;
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

class _PluginErrorView extends StatelessWidget {
  const _PluginErrorView({required this.error, this.stackTrace});

  final Object error;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    final details = stackTrace?.toString() ?? '';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: SelectableText(
        details.isEmpty ? '插件运行失败：$error' : '插件运行失败：$error\n\n$details',
      ),
    );
  }
}
