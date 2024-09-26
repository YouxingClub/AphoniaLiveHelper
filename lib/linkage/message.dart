
import 'package:flutter/material.dart';

class LinkageMessage {
  final String Name;
  final String Message;

  LinkageMessage({required this.Name, required this.Message});
}

class LinkageMessageWidget extends StatelessWidget {

  final LinkageMessage message;

  const LinkageMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.Name),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: SelectableText(message.Message),
            ),
          ]
      )
    );
  }
}