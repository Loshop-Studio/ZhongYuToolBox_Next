import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/session_manager.dart';
import '../../shared/widgets/common.dart';

/// 竖向居中 + 内容超高时可滚动
Widget _centeredBody({required Widget child}) {
  return LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight - 44),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: child,
          ),
        ),
      ),
    ),
  );
}

/// 第一步：选择学校
class AddAccountSchoolPage extends StatefulWidget {
  const AddAccountSchoolPage({super.key});

  @override
  State<AddAccountSchoolPage> createState() => _AddAccountSchoolPageState();
}

class _AddAccountSchoolPageState extends State<AddAccountSchoolPage> {
  final SessionManager _session = SessionManager.instance;
  final TextEditingController _codeController = TextEditingController();
  String _selected = 'sxz';
  bool _loading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    final code = _selected == 'other' ? _codeController.text.trim() : _selected;
    if (code.isEmpty) {
      showToast(context, '请输入学校代码');
      return;
    }
    setState(() => _loading = true);
    var schoolName = _presetName(code);
    try {
      final discover = await _session.discoverSchool(code);
      final lower = discover.name.toLowerCase();
      if (lower.isNotEmpty &&
          lower != 'unknown' &&
          lower != code.toLowerCase()) {
        schoolName = discover.name;
      }
    } catch (_) {
      // 发现失败不阻塞，交给登录步骤给出明确错误
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    if (!mounted) return;
    context.push(
      '/add-account/credential?code=${Uri.encodeComponent(code)}'
      '&name=${Uri.encodeComponent(schoolName)}',
    );
  }

  String _presetName(String code) {
    for (final preset in AppConfig.schoolPresets) {
      if (preset.code == code && preset.name.isNotEmpty) return preset.name;
    }
    return code.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('添加账号')),
      body: _centeredBody(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _StepHeader(step: 1, title: '选择学校'),
            Card(
              child: Column(
                children: [
                  for (final preset in AppConfig.schoolPresets)
                    RadioListTile<String>(
                      value: preset.code,
                      groupValue: _selected,
                      onChanged: (value) => setState(() => _selected = value!),
                      title: Text(preset.displayName),
                      subtitle: Text('学校代码 ${preset.code}'),
                    ),
                  RadioListTile<String>(
                    value: 'other',
                    groupValue: _selected,
                    onChanged: (value) => setState(() => _selected = value!),
                    title: const Text('其它学校'),
                    subtitle: const Text('输入学校代码，通过学校发现服务自动匹配'),
                  ),
                ],
              ),
            ),
            if (_selected == 'other') ...[
              const SizedBox(height: 16),
              AppTextField(
                controller: _codeController,
                label: '学校代码',
                hint: '例如 sxz',
                autofocus: true,
                onSubmitted: (_) => _next(),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _next,
              child: _loading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('下一步'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 第二步：输入用户名密码
class AddAccountCredentialPage extends StatefulWidget {
  const AddAccountCredentialPage({
    super.key,
    required this.schoolCode,
    required this.schoolName,
  });

  final String schoolCode;
  final String schoolName;

  @override
  State<AddAccountCredentialPage> createState() =>
      _AddAccountCredentialPageState();
}

class _AddAccountCredentialPageState extends State<AddAccountCredentialPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await SessionManager.instance.login(
        schoolCode: widget.schoolCode,
        schoolName: widget.schoolName,
        userName: _userController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      showToast(context, '登录成功');
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      showToast(context, errorText(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('添加账号')),
      body: _centeredBody(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _StepHeader(step: 2, title: '输入账号密码'),
            Card(
              child: ListTile(
                leading: const Icon(Icons.school_outlined),
                title: Text('${widget.schoolName}（${widget.schoolCode}）'),
              ),
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _userController,
              label: '用户名',
              hint: '输入用户名',
              autofocus: true,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _passwordController,
              label: '密码',
              hint: '输入密码',
              obscure: _obscure,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _login(),
              suffix: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('登录'),
            ),
            const SizedBox(height: 16),
            Text(
              '账号密码只保存在本机数据目录，用于下次打开应用时自动登录。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step, required this.title});

  final int step;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text('$step')),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
