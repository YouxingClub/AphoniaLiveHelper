import 'package:flutter/material.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _AccountSettingsPage();
}

class _AccountSettingsPage extends State<AccountSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('账号设置'),
      ),
      body: const Center(
        child: Text('暂无需账号登录'),
      ),
    );
  }
}