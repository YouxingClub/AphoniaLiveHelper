import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:type_controller/linkage/joinroom.dart';
import 'package:type_controller/linkage/message.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

import '../static.dart';

final TextEditingController _linkageTextController = TextEditingController();
final TextEditingController _nameController = TextEditingController();
final FocusNode _linkageNameFocusNode = FocusNode();

String linkServerName = "未连接服务器";
WebSocketChannel? channel;
WebSocketChannel? linkageChannel;

final List<LinkageMessage> _messages = [];
final ScrollController _scrollController = ScrollController();

bool tempPrivateMode = false;

class Member {
  final String uuid;
  String name;

  Member(this.uuid, this.name);
}

List<Member> members = [];

Color pickerColor = const Color.fromARGB(255, 0, 0, 0);
Color currentColor = const Color.fromARGB(255, 0, 0, 0);

void _addOrUpdateMember(String uuid, String name) {
  final index = members.indexWhere((member) => member.uuid == uuid);
  if (index != -1) {
    // 更新成员的名称
    members[index].name = name;
  } else {
    // 添加新成员
    members.add(Member(uuid, name));
  }
}

// 移除成员
void _removeMember(String uuid) {
  members.removeWhere((member) => member.uuid == uuid);
}


void _connectWS() {
  channel = WebSocketChannel.connect(
    Uri.parse('ws://127.0.0.1:$wsport/ws'),
  );
}

void _connectLinkServer(String url) {
  linkageChannel = WebSocketChannel.connect(
    Uri.parse(url),
  );
  if (linkageChannel != null) {
    print("链接成功");

  } else {
    print("链接失败");
  }
}

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
  var message = jsonEncode({
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
      'messages': [
        {
          'message': {
            "text": _linkageTextController.text,
            "style": {
              "color": "#${currentColor.toHexString().substring(2)}"
            }
          },
        }
      ]
    }
  });
  channel?.sink.add(message);
  if (!tempPrivateMode) {
    if (linkageChannel != null) {
      linkageChannel?.sink.add(message);
    }
  }
}

void _sendJoin() {
  var message = jsonEncode({
    'action': "join_member",
    // 'target':
    'from': {
      'name': uuid,
      'uuid': uuid,
      'type': "server",
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    },
    'data': {
      'username': _nameController.text,
    }
  });
  if (linkageChannel != null) {
    linkageChannel?.sink.add(message);
  }
}

void _sendNameChange() {
  var message = jsonEncode({
    'action': "change_name",
    // 'target':
    'from': {
      'name': uuid,
      'uuid': uuid,
      'type': "server",
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    },
    'data': {
      'username': _nameController.text
    }
  });
  if (linkageChannel != null) {
    linkageChannel?.sink.add(message);
  }
}

void _sendLeave() {
  var message = jsonEncode({
    'action': "leave_member",
    // 'target':
    'from': {
      'name': uuid,
      'uuid': uuid,
      'type': "server",
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    },
    'data': {
      'username': _nameController.text
    }
  });
  if (linkageChannel != null) {
    linkageChannel?.sink.add(message);
  }
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
        _linkageTextController.clear();
      }
  );
}

_hotkeyDispose() async {
  await hotKeyManager.unregister(_sendMsgHotkey);
}

class LinkagePage extends StatefulWidget {
  const LinkagePage({super.key});

  @override
  State<StatefulWidget> createState() => LinkagePageState();
}

class LinkagePageState extends State<LinkagePage> {

  void _addMessage(LinkageMessage message) {
    setState(() {
      _messages.insert(0, message);
    });
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void showJoinRoomDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return JoinRoom();
      },
    ).then((serverName) {
      if (serverName != null) {
        linkServerName = serverName;
        _connectLinkServer(serverName);
        _sendJoin();
        linkageChannel?.stream.listen((rmessage) {
          setState(() {
            channel?.sink.add(rmessage);
            var message = jsonDecode(rmessage);
            if (message['action'] == "hello") {
              return;
            }
            if (message['action'] == "join_member") {
              _addOrUpdateMember(message['from']['uuid'], message['data']['username']);
              return;
            }
            if (message['action'] == "change_name") {
              _addOrUpdateMember(message['from']['uuid'], message['data']['username']);
              return;
            }

            if (message['action'] == "leave_member") {
              _removeMember(message['from']['uuid']);
              return;
            }
            var name = message['data']['username'];
            var mesg = message['data']['messages'][0]['message']['text'];
            var linkmsgdata = LinkageMessage(Name: name, Message: mesg);
            _messages.insert(0, linkmsgdata);
            _scrollController.animateTo(
              0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        });
      }
    });
  }

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  void showColorPickerDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("选择文字颜色"),
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
    );
  }
  
  void _changeText() {
    if (_linkageNameFocusNode.hasFocus) {

    } else {
      setState(() {
        _sendNameChange();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _connectWS();
    _sendHello();
    _sendJoin();
    _hotkeyInit();
    // channel?.stream.listen((rmessage) {
    //   setState(() {
    //     var message = jsonDecode(rmessage);
    //     if (message['action'] == "hello") {
    //       return;
    //     }
    //     var name = message['data']['username'];
    //     var mesg = message['data']['messages'][0]['message'];
    //     var linkmsgdata = LinkageMessage(Name: name, Message: mesg);
    //     _messages.insert(0, linkmsgdata);
    //     _scrollController.animateTo(
    //       0.0,
    //       duration: Duration(milliseconds: 300),
    //       curve: Curves.easeOut,
    //     );
    //   });
    // });
    // _nameController.addListener(_changeText);
    _linkageNameFocusNode.addListener(_changeText);
  }

  @override
  void dispose() {
    _sendLeave();
    channel?.sink.close();
    linkageChannel?.sink.close();
    _hotkeyDispose();
    // _nameController.removeListener(_changeText);
    _linkageNameFocusNode.removeListener(_changeText);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                AppBar(
                  title: const Text("房间信息"),
                  backgroundColor: Colors.white,
                  actions: [
                    IconButton(onPressed: () {
                      showJoinRoomDialog(context);
                    }, icon: const Icon(Icons.add)),
                  ],
                ),
                Expanded(child: Container()),
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
              flex: 4,
              child: Column(
                children: [
                  AppBar(
                    title: Text(linkServerName),
                    backgroundColor: Colors.white,
                  ),
                  const Divider(
                    color: Colors.grey,
                    height: 1,
                    thickness: 1,
                    indent: 0,
                    endIndent: 0,
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              AppBar(
                                title: const Text("联动讯息"),
                                backgroundColor: Colors.white,
                              ),
                              Expanded(
                                child: ListView.builder(
                                  controller: _scrollController,
                                  reverse: true,
                                  itemCount: _messages.length,
                                  itemBuilder: (context, index) {
                                    return LinkageMessageWidget(message: _messages[index]);
                                  },
                                ),
                              ),
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
                            flex: 3,
                            child: Row(
                              children: [
                                Expanded(
                                    child: Column(
                                  children: [
                                    AppBar(
                                      title: const Text("房间成员"),
                                      backgroundColor: Colors.white,
                                    ),
                                    Expanded(
                                        child: ListView.builder(
                                            itemCount: members.length,
                                            itemBuilder: (context, index) {
                                              return ListTile(
                                                title: Text(members[index].name)
                                              );
                                            }
                                        )
                                    )
                                  ],
                                ))
                              ],
                            ))
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
                              padding: EdgeInsets.zero,
                              iconSize: 35,
                              icon: const Icon(Icons.face),
                              onPressed: () {},
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 35,
                              icon: const Icon(Icons.photo),
                              onPressed: () {},
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 35,
                              icon: const Icon(Icons.color_lens),
                              onPressed: () {
                                showColorPickerDialog(context);
                              },
                            ),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Tooltip(
                                  message: tempPrivateMode ? "临时私密模式：你的消息不会发送到其他直播间" : "公开模式：你的消息会发送到其他直播间",
                                  child: Switch(
                                      inactiveTrackColor: Colors.white,
                                      activeTrackColor: Colors.blue,
                                      value: tempPrivateMode,
                                      onChanged: (value) {
                                        setState(() {
                                          tempPrivateMode = value;
                                        });
                                      }
                                  ),
                                ),
                                Positioned(
                                  left: tempPrivateMode? 30 : 10,
                                  child: Icon(
                                    tempPrivateMode ? Icons.person : Icons.public,
                                    color: tempPrivateMode ? Colors.blue : Colors.white,
                                    size: 20,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      TextField(
                        controller: _linkageTextController,
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              focusNode: _linkageNameFocusNode,
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
                              // _addMessage(LinkageMessage(Name: _nameController.text, Message: _linkageTextController.text)),
                              _sendMessage(),
                              _linkageTextController.clear()
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
              ))
        ],
      ),
    );
  }
}
