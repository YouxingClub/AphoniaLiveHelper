import 'package:flutter/material.dart';

class LinkageSettingsPage extends StatefulWidget {
  const LinkageSettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _LinkageSettingsPage();
}

class _LinkageSettingsPage extends State<LinkageSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('联动设置'),
      ),
      body: const Center(
        child: Text(''),
      ),
    );
  }
}