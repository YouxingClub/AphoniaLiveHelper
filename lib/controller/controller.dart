import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:mime/mime.dart';
import 'package:type_controller/controller/emoticon_selector.dart';
import 'package:type_controller/main.dart';
import 'package:type_controller/static.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../native/libEchoLiveMsgAPIConvert.dart' as msgc;
import 'message.dart';


final TextEditingController _privateTextController = TextEditingController();
final TextEditingController _nameController = TextEditingController();

final dylib = ffi.DynamicLibrary.open("libEchoLiveMsgAPIConvert.dll");

WebSocketChannel? channel;

final List<PrivateMessage> _messages = [];
final ScrollController _scrollController = ScrollController();

String hexArgbToHexRgba(String hex) {
  // 去掉前缀#（如果有的话）
  hex = hex.replaceFirst('#', '');

  // 确保是8位（ARGB）
  if (hex.length == 8) {
    String a = hex.substring(0, 2);
    String r = hex.substring(2, 4);
    String g = hex.substring(4, 6);
    String b = hex.substring(6, 8);

    // 返回RGBA格式
    return '#$r$g$b$a'; // 将顺序调整为RGBA
  }
  throw const FormatException('Invalid hex color format');
}

Future<String?> getImageBase64(String path) async {
  var imageBytes = await File(path).readAsBytes();
  String b64Str = base64Encode(imageBytes);
  String mimeType = await lookupMimeType(path).toString();
  String res = 'data:$mimeType;base64,$b64Str';
  return res;
}


void _connectWS() {
  channel = WebSocketChannel.connect(
    Uri.parse('ws://127.0.0.1:$wsport/ws'),
  );
}

// Future<void> _playAudioInBackground() async {
//   await compute(vitstts, null); // 在后台线程播放音频
// }

void _sendHello() {
  var message = jsonEncode({
    'action': "hello",
    // 'target':
    'from': {
      'name': uuid,
      'uuid': uuid,
      'type': "server",
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    },
    'data': {
      'hidden': false,
    }
  });
  channel?.sink.add(message);
}

void _sendMessage() {
  try {
    if (_privateTextController.text.isEmpty) return;
    var a = _privateTextController.text.toNativeUtf8().cast<ffi.Char>();
    final result = msgc.NativeLibrary(dylib).generateMsgsC(a);
    String message = jsonEncode({
      'action': "message_data",
      // 'target':
      'from': {
        'name': uuid,
        'uuid': uuid,
        'type': "server",
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      'data': {
        'username': _nameController.text,
        // 'messages': [
        //   {
        //     'message': _privateTextController.text,
        //   }
        // ]
        'messages': [
          json.decode(result.cast<Utf8>().toDartString())
        ]
      }
    });
    channel?.sink.add(message);
  } catch (e) {
    print(e);
  }

}

Future<String?> selectFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    allowMultiple: false,
    type: FileType.custom,
    allowedExtensions: ['png', 'jpg', 'jpeg', 'bmp', 'webp'],
  );
  return result?.files[0].path;
}

void _addMessageToPrivateMessage(String msg) {
  var cursorPos = _privateTextController.selection.base.offset;
  String suiffix = _privateTextController.text.substring(cursorPos);
  String prefix = _privateTextController.text.substring(0, cursorPos);
  _privateTextController.text = prefix + msg + suiffix;
  _privateTextController.selection = TextSelection(
    baseOffset: cursorPos + msg.length,
    extentOffset: cursorPos + msg.length
  );
}

void _addEmojiBanner(String url) {
  var prefix = "[CHAT:Emoji,";
  prefix += url.substring(7);
  prefix += "]";
  _addMessageToPrivateMessage(prefix);
}

void _addImageBanner(String url) {
  var prefix = "[CHAT:Image,";
  prefix += url;
  prefix += "]";
  _addMessageToPrivateMessage(prefix);
}

void _addFormatBanner(String format) {
  var prefix = "[CHAT:Format,";
  prefix += format;
  prefix += "]";
  _addMessageToPrivateMessage(prefix);
}

void _addTypeSizeBanner(String size) {
  var prefix = "[CHAT:TypeSize,";
  prefix += size;
  prefix += "]";
  _addMessageToPrivateMessage(prefix);
}

void _addFontColorBanner(String color) {
  var prefix = "[CHAT:FontColor,hex,";
  prefix += color;
  prefix += "]";
  _addMessageToPrivateMessage(prefix);
}

void _addBgColorBanner(String color) {
  var prefix = "[CHAT:BgColor,hex,";
  prefix += color;
  prefix += "]";
  _addMessageToPrivateMessage(prefix);
}

void _openEmojiPicker(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('选择表情'),
        content: const SizedBox(
          width: 800,
          child: EmojiSelectorPage(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 关闭弹窗
            },
            child: const Text('关闭'),
          ),
        ],
      );
    }).then((selectedEmoji) {
      if (selectedEmoji != null) {
        _addEmojiBanner(selectedEmoji);
      }
  });
}

HotKey _sendMsgHotkey = HotKey(
  key: PhysicalKeyboardKey.enter,
  modifiers: [HotKeyModifier.control],
  scope: HotKeyScope.inapp,
);

_hotkeyInit() async {
  await hotKeyManager.unregisterAll();
  await hotKeyManager.register(
    _sendMsgHotkey,
    keyDownHandler: (hotKey) {
      _sendMessage();
      _privateTextController.clear();
    }
  );
}

_hotkeyDispose() async {
  await hotKeyManager.unregister(_sendMsgHotkey);
}

// 单人控制窗口
class ControllerPage extends StatefulWidget {
  const ControllerPage({super.key});

  @override
  State<StatefulWidget> createState() => ControllerPageState();
}

class ControllerPageState extends State<ControllerPage> {

  void _addMessage(PrivateMessage message) {
    setState(() {
      _messages.insert(0, message);
    });
    _scrollController.animateTo(
        0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  Color pickerColor = const Color.fromARGB(255, 0, 0, 0);
  Color currentColor = const Color.fromARGB(255, 0, 0, 0);

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  void showColorPickerDialog(BuildContext context, bool bg) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("选择颜色"),
            content: SingleChildScrollView(
              child: MaterialPicker(
                pickerColor: pickerColor,
                onColorChanged: changeColor,
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('确定'),
                onPressed: () {
                  setState(() => currentColor = pickerColor);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
    ).then((value) {
      if (bg) {
        _addBgColorBanner(hexArgbToHexRgba(currentColor.toHexString()));
      } else {
        _addFontColorBanner(hexArgbToHexRgba(currentColor.toHexString()));
      }
    });
  }

  @override
  void initState() {
    _connectWS();
    _sendHello();
    _hotkeyInit();
    super.initState();
    channel?.stream.listen((rmessage) {
      setState(() {
        var now = DateTime.now();
        var message = jsonDecode(rmessage);
        if (message['action'] == "hello") {
          return;
        }
        // var name = message['data']['username'];
        var mesg = "";
        for (var i in message['data']['messages'][0]['message']) {
          mesg += i['text'];
        }
        var linkmsgdata = PrivateMessage(Time: now.toString(), Message: mesg);
        _messages.insert(0, linkmsgdata);
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
  }

  @override
  void dispose() {
    channel?.sink.close();
    _hotkeyDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          AppBar(
                            title: const Text("历史记录"),
                            backgroundColor: Colors.white,
                            toolbarHeight: 40,
                            titleTextStyle: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          const Divider(
                            color: Colors.grey,
                            height: 1,
                            thickness: 1,
                            indent: 0,
                            endIndent: 0,
                          ),
                          Expanded(
                              child: ListView.builder(
                                controller: _scrollController,
                                reverse: true,
                                itemCount: _messages.length,
                                itemBuilder: (context, index) {
                                  return PrivateMessageWidget(message: _messages[index]);
                                },
                              )
                          ),
                          const SizedBox(
                            height: 20,
                          )
                        ],
                      )),
                  const VerticalDivider(
                    color: Colors.grey,
                    width: 1,
                    thickness: 1,
                    indent: 0,
                    endIndent: 0,
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          AppBar(
                            title: const Text("快捷回复（未实装）"),
                            backgroundColor: Colors.white,
                            actions: [
                              IconButton(
                                  onPressed: () => {}, icon: const Icon(Icons.add)),
                            ],
                            toolbarHeight: 40,
                            titleTextStyle: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          const Divider(
                            color: Colors.grey,
                            height: 1,
                            thickness: 1,
                            indent: 0,
                            endIndent: 0,
                          ),
                          const SizedBox(
                            height: 20,
                          )
                        ],
                      )),
                ],
              ),
            ),
            const Divider(
              color: Colors.grey,
              height: 1,
              thickness: 1,
              indent: 0,
              endIndent: 0,
            ),
            Column(
              children: [
                BottomAppBar(
                  color: Colors.transparent,
                  height: 45,
                  padding: const EdgeInsets.all(1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        tooltip: "选择表情",
                        padding: EdgeInsets.zero,
                        iconSize: 35,
                        icon: const Icon(Icons.face),
                        onPressed: () => _openEmojiPicker(context),
                      ),
                      // IconButton(
                      //   tooltip: "选择图片",
                      //   padding: EdgeInsets.zero,
                      //   iconSize: 35,
                      //   icon: const Icon(Icons.photo),
                      //   onPressed: () {
                      //     Future<String?> filePath = selectFile();
                      //     filePath.then((value) {
                      //       if (value != null) {
                      //         _addImageBanner(value);
                      //       }
                      //     });
                      //   },
                      // ),
                      IconButton(
                        tooltip: "加粗",
                        padding: EdgeInsets.zero,
                        iconSize: 35,
                        icon: const Icon(Icons.format_bold),
                        onPressed: () => _addFormatBanner("Boldface"),
                      ),
                      IconButton(
                        tooltip: "斜体",
                        padding: EdgeInsets.zero,
                        iconSize: 35,
                        icon: const Icon(Icons.format_italic),
                        onPressed: () => _addFormatBanner("Italics"),
                      ),
                      IconButton(
                        tooltip: "下划线",
                        padding: EdgeInsets.zero,
                        iconSize: 35,
                        icon: const Icon(Icons.format_underline),
                        onPressed: () => _addFormatBanner("Underline"),
                      ),
                      IconButton(
                        tooltip: "删除线",
                        padding: EdgeInsets.zero,
                        iconSize: 35,
                        icon: const Icon(Icons.format_strikethrough),
                        onPressed: () => _addFormatBanner("Strikethrough"),
                      ),
                      IconButton(
                        tooltip: "着重号",
                        padding: EdgeInsets.zero,
                        iconSize: 35,
                        icon: const Icon(Icons.highlight),
                        onPressed: () => _addFormatBanner("Emphasis"),
                      ),
                      PopupMenuButton(
                        tooltip: "字体大小",
                        icon: const Icon(Icons.format_size),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: "extra-small",
                            child: Text("特小号"),
                          ),
                          const PopupMenuItem(
                            value: "small",
                            child: Text("小号"),
                          ),
                          const PopupMenuItem(
                            value: "middle",
                            child: Text("中号"),
                          ),
                          const PopupMenuItem(
                            value: "large",
                            child: Text("大号"),
                          ),
                          const PopupMenuItem(
                            value: "extra-large",
                            child: Text("特大号"),
                          ),
                        ],
                        onSelected: (value) {
                          _addTypeSizeBanner(value);
                        },
                      ),
                      IconButton(
                        tooltip: "字体颜色",
                        padding: EdgeInsets.zero,
                        iconSize: 35,
                        icon: const Icon(Icons.format_color_text),
                        onPressed: () => showColorPickerDialog(context, false),
                      ),
                      IconButton(
                        tooltip: "背景颜色",
                        padding: EdgeInsets.zero,
                        iconSize: 35,
                        icon: const Icon(Icons.format_color_fill),
                        onPressed: () => showColorPickerDialog(context, true),
                      ),
                      IconButton(
                        tooltip: "重置格式",
                        padding: EdgeInsets.zero,
                        iconSize: 35,
                        icon: const Icon(Icons.format_clear),
                        onPressed: () => _addFormatBanner("Reset"),
                      ),
                    ],
                  ),
                ),
                TextField(
                  controller: _privateTextController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(10),
                    // border: OutlineInputBorder(),
                    hintText: '聊天内容', // 提示文本
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          contentPadding: EdgeInsets.all(10),
                          hintText: '名字', // 提示文本
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: () => {
                        _sendMessage(),
                        _privateTextController.clear()
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(10),
                        fixedSize: const Size(150, 40),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                      ),
                      child: const Text("发送"),
                    ),
                    const SizedBox(width: 5),
                  ],
                ),
                const SizedBox(height: 5),
              ],
            ),
          ],
        ));
  }
}
