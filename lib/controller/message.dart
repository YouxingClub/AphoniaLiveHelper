import 'package:flutter/material.dart';

class PrivateMessage {
  final String Time;
  final String Message;

  PrivateMessage({required this.Time, required this.Message});
}

class PrivateMessageWidget extends StatelessWidget {
  final PrivateMessage message;

  const PrivateMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.Time),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: SelectableText(message.Message),
            ),
          ],
        )
    );
  }
}