import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:type_controller/static.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {

    // String name = "请登录";
    String liveAddr = "http://localhost:$wsport/echo-live/live";
    String historyAddr = "http://localhost:$wsport/echo-live/history";
    String settingsAddr = "http://localhost:$wsport/echo-live/settings";
    final Uri settingUri = Uri.parse(settingsAddr);

    Future<void> _launchUrl() async {
      if (!await launchUrl(settingUri)) {
        throw Exception('Could not launch $settingUri');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("祐星无声系直播助手配置链接，请使用浏览器源添加"),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(),
            ),
            Column(
              children: [
                const SizedBox(height: 50),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('文字消息组件地址：'),
                      SelectableText(liveAddr),
                      TextButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: liveAddr));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("已复制到剪贴板")),
                            );
                          },
                          child: const Text("复制")
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('历史记录组件地址：'),
                      SelectableText(historyAddr),
                      TextButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: historyAddr));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("已复制到剪贴板")),
                            );
                          },
                          child: const Text("复制")
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Echo-Live设置地址：'),
                      SelectableText(liveAddr),
                      TextButton(
                          onPressed: () {
                            _launchUrl();
                          },
                          child: const Text("打开")
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
              ]
            ),
            Expanded(
              child: Container(),
            ),
          ],
        )
      ),
    );
  }
}