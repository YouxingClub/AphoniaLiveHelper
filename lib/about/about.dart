import 'package:flutter/material.dart';

// 关于窗口

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
      ),
      body: const Center(
        child: Column(
          children: [
            Text('Echo-Live-Rev 1.5.3 Forked by Sheep-realms'),
            Text('github.com/YouxingClub/Echo-Live-Rev'),
            Text('Youxing-Type-Controller 2.0.0 Beta Version Powered by AuraElicase'),
            Text('github.com/YouxingClub/Type-Controller')
          ],
        ),
      ),
    );
  }
}