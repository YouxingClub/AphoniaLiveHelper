import 'package:flutter/material.dart';

class EditorSettingsPage extends StatefulWidget {
  const EditorSettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _EditorSettingsPage();
}

class _EditorSettingsPage extends State<EditorSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑器设置'),
      ),
      body: const Center(
        child: Text(''),
      ),
    );
  }
}