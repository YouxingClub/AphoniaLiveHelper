import 'package:flutter/material.dart';

class FloatSettingsPage extends StatefulWidget {
  const FloatSettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _FloatSettingsPage();
}

class _FloatSettingsPage extends State<FloatSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('悬浮窗设置'),
      ),
      body: const Center(
        child: Text(''),
      ),
    );
  }
}