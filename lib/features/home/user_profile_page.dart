import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/storage/session_manager.dart';
import '../../core/network/api_exception.dart';
import '../../data/api/oss_api.dart';
import '../../data/api/user_profile_api.dart';
import '../../data/models/user_profile.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/user_avatar.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  UserProfile? _profile;
  Object? _error;
  bool _loading = true;
  bool _editing = false;
  bool _saving = false;
  bool _uploading = false;
  String? _pendingPicture;
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _surnameController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final session = SessionManager.instance.session;
    try {
      final profile = await UserProfileApi.getUserInfo(
        school: session.schoolCode,
        userId: session.userId,
      );
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _surnameController.text = profile.surname;
        _nameController.text = profile.name;
        _pendingPicture = null;
        _loading = false;
        _editing = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  String _value(String value) => value.trim().isEmpty ? '未填写' : value;

  void _beginEditing() {
    final profile = _profile;
    if (profile == null) return;
    _surnameController.text = profile.surname;
    _nameController.text = profile.name;
    setState(() => _editing = true);
  }

  void _cancelEditing() {
    setState(() {
      _editing = false;
      _pendingPicture = null;
      _surnameController.text = _profile?.surname ?? '';
      _nameController.text = _profile?.name ?? '';
    });
  }

  Future<void> _choosePicture() async {
    if (_uploading || _saving) return;
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.first;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) return;
    setState(() => _uploading = true);
    try {
      final session = SessionManager.instance.session;
      final url = await OssApi.uploadBytes(
        bytes: Uint8List.fromList(bytes),
        fileName: file.name,
        userId: session.userId,
        fc: 'manage_v2',
        mime: _mimeFor(file.name),
      );
      if (!mounted) return;
      setState(() => _pendingPicture = url);
      showToast(context, '头像上传成功，保存后生效');
    } catch (error) {
      if (mounted) showToast(context, errorText(error));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  String _mimeFor(String fileName) {
    return switch (fileName.split('.').last.toLowerCase()) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };
  }

  Future<void> _save() async {
    final profile = _profile;
    if (profile == null || _saving || _uploading) return;
    final surname = _surnameController.text.trim();
    final name = _nameController.text.trim();
    if (surname.isEmpty && name.isEmpty) {
      showToast(context, '姓和名不能同时为空');
      return;
    }
    setState(() => _saving = true);
    try {
      final session = SessionManager.instance.session;
      final picture = _pendingPicture ?? profile.pictrue;
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
      if (!mounted) return;
      setState(() {
        _profile = updated;
        _editing = false;
        _pendingPicture = null;
      });
      final account = SessionManager.instance.currentAccount;
      if (account != null) {
        await SessionManager.instance.editAccount(
          account,
          realName: updated.fullName,
          photo: updated.pictrue,
        );
      }
      if (mounted) showToast(context, '个人信息已保存');
    } catch (error) {
      if (mounted) showToast(context, errorText(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionManager.instance.session;
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人信息'),
        actions: [
          if (_editing) ...[
            IconButton(
              tooltip: '取消',
              onPressed: _saving || _uploading ? null : _cancelEditing,
              icon: const Icon(Icons.close),
            ),
            IconButton(
              tooltip: '保存',
              onPressed: _saving || _uploading ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
            ),
          ] else
            IconButton(
              tooltip: '编辑',
              onPressed: _loading ? null : _beginEditing,
              icon: const Icon(Icons.edit_outlined),
            ),
          IconButton(
            tooltip: '刷新',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : _buildContent(session),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 42),
            const SizedBox(height: 12),
            Text(
              _error.toString().replaceFirst('ApiException: ', ''),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('重新加载'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(dynamic session) {
    final profile = _profile!;
    final displayName = profile.fullName.isEmpty
        ? (profile.userName.isEmpty ? session.displayName : profile.userName)
        : profile.fullName;
    final rows = <({String label, String value})>[
      (label: '用户名', value: profile.userName),
      (label: '学号', value: profile.number),
      (label: '姓名', value: profile.fullName),
      (
        label: '性别',
        value: profile.gender == 1
            ? '男'
            : profile.gender == 2
            ? '女'
            : '未填写',
      ),
      (label: '入学年份', value: profile.enterSchoolYear),
      (label: '年级', value: profile.gradeName),
      (
        label: '入学年级 ID',
        value: profile.enterSchoolYearGradeId?.toString() ?? '',
      ),
      (label: '班级', value: profile.className),
      (label: '班级 ID', value: profile.classId?.toString() ?? ''),
      (label: '证件类型', value: profile.credentialsType?.toString() ?? ''),
      (label: '证件号码', value: profile.idNumber),
      (label: '出生日期', value: profile.brithDay ?? ''),
      (label: '籍贯', value: profile.birthplace),
      (label: '民族', value: profile.nation),
      (label: '家庭住址', value: profile.homeAddress),
      (label: '手机号', value: profile.mobile ?? ''),
      (label: '联系电话', value: profile.telephone),
      (label: '学籍状态', value: profile.schoolRollState?.toString() ?? ''),
      (label: '账号状态', value: profile.state?.toString() ?? ''),
    ];
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    InkWell(
                      onTap: _editing ? _choosePicture : null,
                      borderRadius: BorderRadius.circular(36),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          UserAvatar(
                            name: displayName,
                            photo: _pendingPicture ?? profile.pictrue,
                            apiBaseUrl: session.apiBaseUrl,
                            radius: 36,
                          ),
                          if (_editing)
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                shape: BoxShape.circle,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(22),
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          if (_uploading)
                            const SizedBox.square(
                              dimension: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
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
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          const SizedBox(height: 4),
                          Text(_value(profile.number)),
                          if (session.schoolName.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              session.schoolName,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
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
                  for (var index = 0; index < rows.length; index++) ...[
                    ListTile(
                      dense: true,
                      title: Text(rows[index].label),
                      trailing: Text(
                        _value(rows[index].value),
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    if (index != rows.length - 1) const Divider(height: 1),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
