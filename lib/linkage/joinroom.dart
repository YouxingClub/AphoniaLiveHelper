import 'package:flutter/material.dart';

class JoinRoom extends StatelessWidget {
  JoinRoom({super.key});

  final TextEditingController _linkServerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('加入服务器'),
      content: TextField(
        controller: _linkServerController,
        decoration: const InputDecoration(
          hintText: '请输入服务器名称',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_linkServerController.text);
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}