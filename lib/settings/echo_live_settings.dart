import 'package:flutter/material.dart';

// echolive设置

class EchoLiveSettingsPage extends StatefulWidget {
  const EchoLiveSettingsPage({super.key});

  // const MainApp({super.key});

  @override
  _EchoLiveSettingsPage createState() => _EchoLiveSettingsPage();
}

class _EchoLiveSettingsPage extends State<EchoLiveSettingsPage> {
  int _currentIndex = 0;

  // 定义不同的窗口内容
  final List<Widget> _windows = [
    const Center(child: Text('这是第1个窗口')),
    const Center(child: Text('这是第2个窗口')),
    const Center(child: Text('这是第3个窗口')),
    const Center(child: Text('这是第4个窗口')),
  ];

  final List<String> items = [
    '全局',
    '对话框',
    '历史记录',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 左右布局
      body: Row(
        children: [
          // 左侧固定边栏
          Container(
            width: 200,
            color: Colors.grey.withOpacity(0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return TextButton(
                        onPressed: () => {
                          setState(() {
                            _currentIndex = index;
                          })
                        },
                        style: TextButton.styleFrom(
                          fixedSize: const Size(200, 50),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero
                          ),
                          foregroundColor: Colors.black,
                        ),
                        child: Text(items[index]),
                      );
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: SizedBox(
              child: _windows[_currentIndex],
            ),
          ),
        ],
      ),
    );
  }
}
