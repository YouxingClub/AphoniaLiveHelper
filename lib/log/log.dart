import 'package:flutter/material.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<StatefulWidget> createState() => _LogPage();
}

class _LogPage extends State<LogPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('程序日志'),
      ),
      body: const Center(
        child: Text(''),
      ),
    );
  }
}