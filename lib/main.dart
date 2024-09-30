import 'dart:math';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:type_controller/about/about.dart';
import 'package:type_controller/controller/controller.dart';
import 'package:type_controller/home/home.dart';
import 'package:type_controller/linkage/linkage.dart';
import 'package:type_controller/log/log.dart';
import 'package:type_controller/settings/config_file.dart';
import 'package:type_controller/settings/echo_live_settings.dart';
import 'package:type_controller/settings/editor_settings.dart';
import 'package:type_controller/settings/emoticon_manager.dart';
import 'package:type_controller/settings/float_settings.dart';
import 'package:type_controller/settings/linkage_settings.dart';
import 'package:type_controller/static.dart';
import 'package:uuid/uuid.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:ui' as ui;
import 'dart:ffi';
import 'dart:isolate';

import 'native/webserver_controller.dart';

// 创建一个ReceivePort用于接收来自Isolate的消息

void uuidGen() {
  uuid = const Uuid().v4();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 必须加上这一行。
  await windowManager.ensureInitialized();
  await hotKeyManager.unregisterAll();
  configJson = await readConfigFile();
  wsport = configJson['Controller']['WSServerPort'];
  doWhenWindowReady(() {
    const initialSize = ui.Size(1280, 720);
    const minsize = ui.Size(400, 400);
    appWindow.minSize = minsize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = "祐星无声系直播助手";
    appWindow.show();
  });

  // WindowOptions windowOptions = const WindowOptions(
  //     size: ui.Size(1280, 720),
  //     center: true,
  //     skipTaskbar: false,
  //     title: "祐星无声系直播助手");
  // windowManager.waitUntilReadyToShow(windowOptions, () async {
  //   await windowManager.show();
  //   await windowManager.focus();
  // });
  runApp(const MaterialApp(
    home: MainPage(),
  ));


}

final closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: const Color(0xFF805306),
    iconMouseOver: Colors.white);

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  // const MainApp({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WindowListener{
  @override
  void initState() {
    super.initState();
    wsport = configJson['Controller']['WSServerPort'];
    windowManager.addListener(this);
    startServerIsolate();
    uuidGen();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    stopServerIsolate();
    super.dispose();
  }

  @override
  void onWindowFocus() {
    // Make sure to call once.
    setState(() {});
    // do something
  }

  @override
  void onWindowResize() {
    setState(() {});
  }

  @override
  void onWindowClose() async {
    // 在窗口关闭时执行 Go 服务器的关闭逻辑
    print("Window is closing, shutting down server...");
    // stopServerIsolate();
    // serverIsolate.kill();
    stopServer();
    // 确保窗口真的可以关闭
    windowManager.destroy();
  }

  int _currentIndex = 0;

  // 定义不同的窗口内容
  final List<Widget> _windows = [
    const Center(child: HomePage()),
    const Center(child: ControllerPage()),
    const Center(child: LinkagePage()),
    const Center(child: LogPage()),
    const Center(child: EditorSettingsPage()),
    const Center(child: EchoLiveSettingsPage()),
    const Center(child: LinkageSettingsPage()),
    const Center(child: FloatSettingsPage()),
    const Center(child: EmojiManagerPage()),
    const Center(child: AboutPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: "SourceHanSerifCN-Regular",
        scaffoldBackgroundColor: Colors.grey.shade50,
      ),
      home: Scaffold(
        // 左右浮动布局界面
        body: Row(
          children: [
            Container(
              width: 60, // 左侧宽度可以根据需求调整
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  // logo
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: const FlutterLogo(size: 40),
                  ),
                  // 按钮1
                  IconButton(
                    onPressed: () => setState(() {
                      _currentIndex = 0;
                    }),
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.home,
                        key: ValueKey<int>(_currentIndex == 0 ? 1 : 0),
                        color: _currentIndex == 0 ? Colors.blue : Colors.black,
                        size: 30,
                      ),
                    ),
                    tooltip: "首页",
                    iconSize: 30,
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      _currentIndex = 1;
                    }),
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.edit,
                        key: ValueKey<int>(_currentIndex == 1 ? 1 : 0),
                        color: _currentIndex == 1 ? Colors.blue : Colors.black,
                        size: 30,
                      ),
                    ),
                    tooltip: "编辑器",
                    iconSize: 30,
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      _currentIndex = 2;
                    }),
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.people,
                        key: ValueKey<int>(_currentIndex == 2 ? 1 : 0),
                        color: _currentIndex == 2 ? Colors.blue : Colors.black,
                        size: 30,
                      ),
                    ),
                    tooltip: "联动模式",
                    iconSize: 30,
                  ),
                  // IconButton(
                  //   onPressed: () => setState(() {
                  //     _currentIndex = 3;
                  //   }),
                  //   icon: AnimatedSwitcher(
                  //     duration: const Duration(milliseconds: 300),
                  //     child: Icon(
                  //       Icons.history,
                  //       key: ValueKey<int>(_currentIndex == 3 ? 1 : 0),
                  //       color: _currentIndex == 3 ? Colors.blue : Colors.black,
                  //       size: 30,
                  //     ),
                  //   ),
                  //   tooltip: '日志记录',
                  //   iconSize: 30,
                  // ),
                  // 按钮2
                  PopupMenuButton<int>(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.settings,
                        key: ValueKey<int>(_currentIndex >= 4 ? 1 : 0),
                        color: _currentIndex >= 4 ? Colors.blue : Colors.black,
                        size: 30,
                      ),
                    ),
                    tooltip: "设置",
                    iconSize: 30,
                    offset: const Offset(50, 0), // 弹出菜单相对于按钮的位置
                    onSelected: (value) async {
                      switch (value) {
                        case 1:
                          setState(() {
                            _currentIndex = 4;
                          });
                          break;
                        case 2:
                          setState(() {
                            _currentIndex = 5;
                          });
                          break;
                        case 3:
                          setState(() {
                            _currentIndex = 6;
                          });
                          break;
                        case 4:
                          setState(() {
                            _currentIndex = 7;
                          });
                          break;
                        case 5:
                          setState(() {
                            _currentIndex = 8;
                          });
                          break;
                        case 6:
                          setState(() {
                            _currentIndex = 9;
                          });
                          break;
                        default:
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<int>>[
                      PopupMenuItem<int>(
                        value: 1,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            '编辑器设置',
                            key: ValueKey<int>(_currentIndex == 4 ? 1 : 0),
                            style: TextStyle(
                              color: _currentIndex == 4
                                  ? Colors.blue
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      PopupMenuItem<int>(
                        value: 2,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            'Echo Live设置',
                            key: ValueKey<int>(_currentIndex == 5 ? 1 : 0),
                            style: TextStyle(
                              color: _currentIndex == 5
                                  ? Colors.blue
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      // PopupMenuItem<int>(
                      //   value: 3,
                      //   child: AnimatedSwitcher(
                      //     duration: const Duration(milliseconds: 300),
                      //     child: Text(
                      //       '联动设置',
                      //       key: ValueKey<int>(_currentIndex == 6 ? 1 : 0),
                      //       style: TextStyle(
                      //         color: _currentIndex == 6
                      //             ? Colors.blue
                      //             : Colors.black,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // PopupMenuItem<int>(
                      //   value: 4,
                      //   child: AnimatedSwitcher(
                      //     duration: const Duration(milliseconds: 300),
                      //     child: Text(
                      //       '悬浮窗设置',
                      //       key: ValueKey<int>(_currentIndex == 7 ? 1 : 0),
                      //       style: TextStyle(
                      //         color: _currentIndex == 7
                      //             ? Colors.blue
                      //             : Colors.black,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      PopupMenuItem<int>(
                        value: 5,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            '表情包管理',
                            key: ValueKey<int>(_currentIndex == 8 ? 1 : 0),
                            style: TextStyle(
                              color: _currentIndex == 8
                                  ? Colors.blue
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      PopupMenuItem<int>(
                        value: 6,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            '关于',
                            key: ValueKey<int>(_currentIndex == 9 ? 1 : 0),
                            style: TextStyle(
                              color: _currentIndex == 9
                                  ? Colors.blue
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                  // 可以继续添加更多按钮或其他控件
                ],
              ),
            ),
            const VerticalDivider(
              color: Colors.grey,
              width: 1,
              thickness: 1,
              indent: 0,
              endIndent: 0,
            ),
            Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: 30,
                      child: MoveWindow(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            MinimizeWindowButton(colors: closeButtonColors,),
                            MaximizeWindowButton(colors: closeButtonColors,),
                            CloseWindowButton(colors: closeButtonColors,),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      // 一个空白界面等待放置元素
                      flex: 1,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: SizedBox(
                          child: _windows[_currentIndex],
                        ),
                      ),
                    ),
                  ],
                )
            )
          ],
        ),
      ),
    );
  }
}
