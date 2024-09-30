import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class EmojiManagerPage extends StatefulWidget {
  const EmojiManagerPage({super.key});

  @override
  _EmojiManagerPageState createState() => _EmojiManagerPageState();
}

class _EmojiManagerPageState extends State<EmojiManagerPage> {
  List<String> folders = []; // 存储表情包文件夹名称
  List<File> emojiImages = []; // 存储当前文件夹中的表情包文件
  String selectedFolder = ''; // 当前选择的文件夹
  Directory? emoticonDirectory; // 表情包目录
  TextEditingController newNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeDirectory();
  }

  // 初始化表情包目录
  Future<void> _initializeDirectory() async {
    final Directory dir = Directory("assets/emoticons"); // 使用assets/emoticons目录

    if (!await dir.exists()) {
      print("Emoticons directory does not exist.");
      return;
    }

    setState(() {
      emoticonDirectory = dir;
    });

    _loadFolders();
  }

  // 加载emoticons文件夹下的子文件夹
  Future<void> _loadFolders() async {
    if (emoticonDirectory == null) return;
    final List<FileSystemEntity> entities = emoticonDirectory!.listSync();

    // 筛选出所有子文件夹
    final List<String> folderNames = entities
        .whereType<Directory>()
        .map((entity) => path.basename(entity.path))
        .toList();

    setState(() {
      folders = folderNames;
      if (folders.isNotEmpty) {
        selectedFolder = folders[0];
        _loadEmojisForFolder(selectedFolder);
      }
    });
  }

  // 加载特定文件夹中的表情包图片
  Future<void> _loadEmojisForFolder(String folderName) async {
    final Directory folder = Directory(path.join(emoticonDirectory!.path, folderName));
    if (!await folder.exists()) return;

    final List<FileSystemEntity> entities = folder.listSync();

    // 筛选出图片文件
    final List<File> images = entities
        .whereType<File>()
        .where((file) => file.path.endsWith('.png') || file.path.endsWith('.jpg') || file.path.endsWith('.webp') || file.path.endsWith('.bmp'))
        .toList();

    setState(() {
      emojiImages = images;
    });
  }

  // 显示放大的表情包图片
  void _showZoomedImage(File emoji) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop(); // 点击图片关闭对话框
            },
            child: Container(
              constraints: const BoxConstraints.expand(), // 强制铺满整个对话框
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(20), // 允许边缘外移
                minScale: 0.8, // 最小缩放比例
                maxScale: 10.0, // 最大缩放比例
                child: Image.file(
                  emoji,
                  fit: BoxFit.contain, // 完整显示图片
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 显示修改表情包属性的弹窗
  void _showEditDialog(File emoji) {
    newNameController.text = emoji.path.substring(emoji.parent.path.length + 1);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("修改表情包属性"),
          content: TextField(
            controller: newNameController,
            decoration: InputDecoration(labelText: "修改名称"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("取消"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("保存"),
              onPressed: () {
                emoji.renameSync('${emoji.parent.path}/${newNameController.text}');
                _loadEmojisForFolder(emoji.parent.path.substring(emoji.parent.parent.path.length + 1));
                // 保存属性修改逻辑
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // 删除表情包
  void _deleteEmoji(File emoji) {
    setState(() {
      emoji.deleteSync(); // 删除文件
      emojiImages.remove(emoji); // 更新UI
    });
  }

  // 右键点击时显示菜单
  void _showContextMenu(BuildContext context, Offset position, File emoji) async {
    final selected = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      items: [
        const PopupMenuItem<String>(
          value: 'edit',
          child: Text('修改'),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Text('删除'),
        ),
      ],
      elevation: 8.0,
    );

    // 根据用户选择执行相应操作
    if (selected == 'edit') {
      _showEditDialog(emoji); // 调用修改弹窗
    } else if (selected == 'delete') {
      _deleteEmoji(emoji); // 调用删除功能
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('表情包管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // 添加表情包逻辑，可以弹出文件选择框上传表情包
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // 左边的文件夹标题
                Container(
                  width: 150,
                  color: Colors.grey[200],
                  child: ListView.builder(
                    itemCount: folders.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(folders[index]),
                        onTap: () {
                          setState(() {
                            selectedFolder = folders[index];
                            _loadEmojisForFolder(selectedFolder);
                          });
                        },
                        selected: selectedFolder == folders[index],
                      );
                    },
                  ),
                ),
                // 右边的表情包图片网格
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6, // 网格列数
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: emojiImages.length + 1, // 第一个位置为加号
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // 第一个位置显示加号
                        return GestureDetector(
                          onTap: () {
                            // 添加表情包的逻辑
                          },
                          child: Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.add, size: 50),
                          ),
                        );
                      } else {
                        // 表情包图片
                        final emoji = emojiImages[index - 1];
                        bool isHovered = false; // 用来追踪是否鼠标悬停

                        return StatefulBuilder(
                          builder: (context, setState) {
                            return MouseRegion(
                              onEnter: (event) {
                                setState(() {
                                  isHovered = true;
                                });
                              },
                              onExit: (event) {
                                setState(() {
                                  isHovered = false;
                                });
                              },
                              child: GestureDetector(
                                onTap: () {
                                  _showZoomedImage(emoji); // 点击放大图片
                                },
                                onSecondaryTapDown: (details) {
                                  // 获取点击位置，并显示右键菜单
                                  _showContextMenu(context, details.globalPosition, emoji);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isHovered ? Colors.grey.withOpacity(0.5) : Colors.transparent, // 鼠标悬停时显示背景
                                    borderRadius: BorderRadius.circular(8), // 圆角效果
                                    border: Border.all(color: Colors.grey, width: 1),
                                  ),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Image.file(emoji), // 图片展示
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        path.basenameWithoutExtension(emoji.path), // 显示图片名称
                                        style: const TextStyle(fontSize: 14),
                                        overflow: TextOverflow.ellipsis, // 处理名称过长的情况
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
