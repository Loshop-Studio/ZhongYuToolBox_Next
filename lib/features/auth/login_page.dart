import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/storage/session_manager.dart';
import '../../data/models/account.dart';
import '../../shared/widgets/common.dart';
import 'account_tile.dart';

/// 登录页：已添加账号列表 + 添加账号
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final SessionManager _session = SessionManager.instance;
  String? _switchingId;

  @override
  void initState() {
    super.initState();
    _session.addListener(_onChanged);
  }

  @override
  void dispose() {
    _session.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _switch(Account account) async {
    if (_switchingId != null) return;
    setState(() => _switchingId = account.id);
    try {
      final ok = await _session.autoLoginFor(account);
      if (!mounted) return;
      if (ok) {
        context.go('/home');
      } else {
        showToast(context, _session.lastError ?? '登录失败，请检查账号密码');
      }
    } finally {
      if (mounted) setState(() => _switchingId = null);
    }
  }

  Future<void> _showAccountActions(Account account, {Offset? anchor}) async {
    await showAccountActions(context, account, anchor: anchor);
  }

  @override
  Widget build(BuildContext context) {
    final accounts = _session.accounts;
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/add-account'),
            icon: const Icon(Icons.add),
            label: const Text('添加账号'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // 内容不满屏时竖直居中，超出时可滚动
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 72),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 84,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: accounts.isEmpty
                        ? EmptyView(
                            icon: Icons.account_circle_outlined,
                            text: '还没有添加账号\n添加后每次打开应用都会自动登录',
                            action: FilledButton.icon(
                              onPressed: () => context.push('/add-account'),
                              icon: const Icon(Icons.add),
                              label: const Text('添加账号'),
                            ),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final account in accounts)
                                AccountTile(
                                  account: account,
                                  active:
                                      _session.currentAccount?.id ==
                                          account.id &&
                                      _session.isLoggedIn,
                                  busy: _switchingId == account.id,
                                  onTap: () => _switch(account),
                                  onMore: (position) => _showAccountActions(
                                    account,
                                    anchor: position,
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: FilledButton.icon(
                                  onPressed: _switchingId == null
                                      ? () => context.push('/add-account')
                                      : null,
                                  icon: const Icon(Icons.add),
                                  label: const Text('添加账号'),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Card(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    '本工具用于快捷查看中育账号资源，与中育智慧（无锡）数字技术有限公司及其关联公司无关。'
                                    '开发：Loshop。账号信息仅保存在本机，如遇问题请加 QQ 群 1067807011。',
                                    style: TextStyle(fontSize: 12, height: 1.6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
          // 右下角文字按钮
          Positioned(
            right: 8,
            bottom: 4,
            child: SafeArea(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => context.push('/about'),
                    child: const Text('关于'),
                  ),
                  TextButton(
                    onPressed: () => context.push('/settings'),
                    child: const Text('设置'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
