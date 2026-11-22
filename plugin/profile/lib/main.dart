import 'package:flutter/material.dart';

const String _loadId = 'profile-load';
const String _avatarId = 'profile-avatar';
const String _saveId = 'profile-save';

String _identity = '';
String _surname = '';
String _name = '';
String _picture = '';
String _pendingPicture = '';
bool _editing = false;
bool _hasPendingPicture = false;
TextEditingController _surnameController = TextEditingController();
TextEditingController _nameController = TextEditingController();
String _avatarIdentity = '';
String _saveIdentity = '';

Widget buildProfilePage(
  Map<String, dynamic> pageContext,
  Map<String, dynamic> host,
  Map<String, dynamic> Function() getLatestHost,
  void Function(String, Map<String, dynamic>) openPage,
) {
  final latest = getLatestHost();
  if (!_hasHostApi(latest, 'getProfileResult') ||
      !_hasHostApi(latest, 'buildProfileAvatar') ||
      !_hasHostApi(latest, 'loadUserProfile') ||
      !_hasHostApi(latest, 'pickAndUploadAvatar') ||
      !_hasHostApi(latest, 'updateUserProfile') ||
      !_hasHostApi(latest, 'requestPageRebuild')) {
    return _incompatibleHost();
  }
  final Map Function(String) getResult = latest['getProfileResult'];
  final load = getResult(_loadId);
  if (load['started'] != true) {
    final void Function(String) loadProfile = latest['loadUserProfile'];
    loadProfile(_loadId);
    return _loading(latest, pending: false);
  }
  if (load['pending'] == true) {
    return _loading(latest, pending: true);
  }
  final error = _text(load['error']);
  if (error != '') {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人信息'),
        actions: [
          IconButton(
            tooltip: '刷新',
            onPressed: () {
              final void Function(String) retry =
                  getLatestHost()['loadUserProfile'];
              retry(_loadId);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 42),
              const SizedBox(height: 12),
              Text(
                error.replaceFirst('ApiException: ', ''),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final void Function(String) retry =
                      getLatestHost()['loadUserProfile'];
                  retry(_loadId);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh),
                    const SizedBox(width: 8),
                    const Text('重新加载'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final profile = _profile(latest, load);
  if (profile.isEmpty) return _loading(latest, pending: false);
  final key = _text(profile['id'] ?? profile['userName'] ?? 'profile');
  if (_identity != key) {
    _identity = key;
    _editing = false;
    _pendingPicture = '';
    _hasPendingPicture = false;
    _avatarIdentity = '';
    _surname = _text(profile['surname']);
    _name = _text(profile['name']);
    _surnameController = TextEditingController(text: _surname);
    _nameController = TextEditingController(text: _name);
    _picture = _text(profile['pictrue'] ?? profile['picture']);
  }
  final avatar = getResult(_avatarId);
  final avatarResponse = avatar['response'];
  if (_avatarIdentity == key &&
      avatarResponse is Map &&
      avatarResponse['picture'] != null &&
      avatar['pending'] != true) {
    _pendingPicture = _text(avatarResponse['picture']);
    _hasPendingPicture = true;
    _picture = _pendingPicture;
  }
  final save = getResult(_saveId);
  final response = save['response'];
  final saved = response is Map && response['saved'] == true;
  final busy = avatar['pending'] == true || save['pending'] == true;
  if (_saveIdentity == key && saved) {
    _editing = false;
    _pendingPicture = '';
    _avatarIdentity = '';
  }
  final fullName = _text(profile['fullName']);
  final username = _text(profile['userName']);
  final displayName = fullName != ''
      ? fullName
      : (username != '' ? username : _text(latest['displayName']));
  final avatarSource = _hasPendingPicture
      ? avatarResponse['picture']
      : (profile['pictrue'] ?? profile['picture']);
  final uploading = avatar['pending'] == true;
  final Widget Function(String, String, bool, bool) buildAvatar =
      latest['buildProfileAvatar'];

  var gender = '未填写';
  if (profile['gender'] == 1) {
    gender = '男';
  } else if (profile['gender'] == 2) {
    gender = '女';
  }

  final List<Widget> actions;
  if (_editing) {
    actions = <Widget>[
      IconButton(
        tooltip: '取消',
        onPressed: () {
          if (busy) return;
          _editing = false;
          _pendingPicture = '';
          _hasPendingPicture = false;
          _avatarIdentity = '';
          _surnameController =
              TextEditingController(text: _text(profile['surname']));
          _nameController = TextEditingController(text: _text(profile['name']));
          _picture = _text(profile['pictrue'] ?? profile['picture']);
          _requestRebuild(latest);
        },
        icon: const Icon(Icons.close),
      ),
      IconButton(
        tooltip: '保存',
        onPressed: () {
          if (busy) return;
          final surname = _surnameController.text.trim();
          final name = _nameController.text.trim();
          _saveIdentity = key;
          final void Function(String, Map<String, dynamic>) saveProfile =
              getLatestHost()['updateUserProfile'];
          saveProfile(_saveId, <String, dynamic>{
            'surname': surname,
            'name': name,
            'picture': _picture,
          });
          _requestRebuild(latest);
        },
        icon: busy && save['pending'] == true
            ? const SizedBox(
                width: 20,
                height: 20,
                child: Icon(Icons.autorenew),
              )
            : const Icon(Icons.check),
      ),
      IconButton(
        tooltip: '刷新',
        onPressed: () {
          if (busy) return;
          _editing = false;
          _pendingPicture = '';
          _hasPendingPicture = false;
          _avatarIdentity = '';
          _identity = '';
          final void Function(String) refresh =
              getLatestHost()['loadUserProfile'];
          refresh(_loadId);
        },
        icon: const Icon(Icons.refresh),
      ),
    ];
  } else {
    actions = <Widget>[
      IconButton(
        tooltip: '编辑',
        onPressed: () {
          _surnameController =
              TextEditingController(text: _text(profile['surname']));
          _nameController = TextEditingController(text: _text(profile['name']));
          _editing = true;
          _requestRebuild(latest);
        },
        icon: const Icon(Icons.edit),
      ),
      IconButton(
        tooltip: '刷新',
        onPressed: () {
          if (busy) return;
          _editing = false;
          _pendingPicture = '';
          _hasPendingPicture = false;
          _avatarIdentity = '';
          _identity = '';
          final void Function(String) refresh =
              getLatestHost()['loadUserProfile'];
          refresh(_loadId);
        },
        icon: const Icon(Icons.refresh),
      ),
    ];
  }

  return Scaffold(
    appBar: AppBar(
      title: const Text('个人信息'),
      actions: actions,
    ),
    body: Align(
      alignment: Alignment.topCenter,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _editing && !busy
                          ? () {
                              _avatarIdentity = key;
                              final void Function(String) pick =
                                  getLatestHost()['pickAndUploadAvatar'];
                              pick(_avatarId);
                              _requestRebuild(latest);
                            }
                          : null,
                      child: buildAvatar(
                        displayName,
                        _text(avatarSource),
                        _editing,
                        uploading,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_editing)
                            Row(
                              children: [
                                SizedBox(
                                  width: 72,
                                  child: TextField(
                                    controller: _surnameController,
                                    decoration: const InputDecoration(
                                      labelText: '姓',
                                    ),
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: '名',
                                    ),
                                    textInputAction: TextInputAction.done,
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              displayName,
                              style: const TextStyle(fontSize: 24),
                            ),
                          const SizedBox(height: 4),
                          Text(_value(profile['number'])),
                          if (_text(latest['schoolName']) != '') ...[
                            const SizedBox(height: 2),
                            Text(
                              _text(latest['schoolName']),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                          if (_saveIdentity == key && save['pending'] == true)
                            const Text('正在保存…'),
                          if (_saveIdentity == key && saved)
                            const Text('个人信息已保存'),
                          if (_saveIdentity == key &&
                              _text(save['error']) != '')
                            const Text(
                              '保存失败，请重试',
                              style: TextStyle(color: Colors.red),
                            ),
                          if (_avatarIdentity == key &&
                              avatar['pending'] == true)
                            const Text('正在上传头像…'),
                          if (_avatarIdentity == key &&
                              _text(avatar['error']) != '')
                            const Text(
                              '头像上传失败，请重试',
                              style: TextStyle(color: Colors.red),
                            ),
                          if (_avatarIdentity == key &&
                              avatarResponse is Map &&
                              avatarResponse['picture'] != null)
                            const Text('头像上传成功，保存后生效'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  _row('用户名', profile['userName']),
                  _row('学号', profile['number']),
                  _row('姓名', fullName),
                  _row('性别', gender),
                  _row('入学年份', profile['enterSchoolYear']),
                  _row('年级', profile['gradeName']),
                  _row('入学年级 ID', profile['enterSchoolYearGradeId']),
                  _row('班级', profile['className']),
                  _row('班级 ID', profile['classId']),
                  _row('证件类型', profile['credentialsType']),
                  _row('证件号码', profile['idNumber']),
                  _row('出生日期', profile['brithDay']),
                  _row('籍贯', profile['birthplace']),
                  _row('民族', profile['nation']),
                  _row('家庭住址', profile['homeAddress']),
                  _row('手机号', profile['mobile']),
                  _row('联系电话', profile['telephone']),
                  _row('学籍状态', profile['schoolRollState']),
                  _row('账号状态', profile['state'], divider: false),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _loading(Map<String, dynamic> host, {required bool pending}) => Scaffold(
      appBar: AppBar(
        title: const Text('个人信息'),
        actions: [
          IconButton(
            tooltip: '刷新',
            onPressed: () {
              if (pending) return;
              final void Function(String) refresh = host['loadUserProfile'];
              refresh(_loadId);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: const Center(child: Text('正在加载个人信息…')),
    );

Widget _incompatibleHost() => Scaffold(
      appBar: AppBar(title: const Text('个人信息')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('当前应用版本缺少个人信息插件接口，请更新应用后重新打开。'),
        ),
      ),
    );

Map _profile(Map host, Map load) {
  final Map Function(String) getResult = host['getProfileResult'];
  final save = getResult(_saveId);
  final response = save['response'];
  if (response is Map && response['saved'] == true && save['profile'] is Map) {
    return save['profile'] as Map;
  }
  final raw = load['profile'];
  return raw is Map ? raw : <String, dynamic>{};
}

Widget _row(String label, Object? value, {bool divider = true}) {
  return Column(
    children: [
      ListTile(
        dense: true,
        title: Text(label),
        trailing: Text(
          _value(value),
          textAlign: TextAlign.right,
        ),
      ),
      if (divider) Container(height: 1, color: const Color(0x1F000000)),
    ],
  );
}

String _value(dynamic value) {
  if (value == null || value == '') return '未填写';
  return '$value';
}

void _requestRebuild(Map<String, dynamic> host) {
  final void Function() request = host['requestPageRebuild'];
  request();
}

String _text(dynamic value) {
  if (value == null) return '';
  return '$value';
}

bool _hasHostApi(Map host, String name) {
  for (final key in host.keys) {
    if (key == name) return true;
  }
  return false;
}
