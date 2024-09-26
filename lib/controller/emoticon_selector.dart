import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class EmojiSelectorPage extends StatefulWidget {
  const EmojiSelectorPage({super.key});

  @override
  _EmojiSelectorPageState createState() => _EmojiSelectorPageState();
}

class _EmojiSelectorPageState extends State<EmojiSelectorPage> {
  List<String> folders = []; // 存储表情包文件夹名称
  List<File> emojiImages = []; // 存储当前文件夹中的表情包文件
  String selectedFolder = ''; // 当前选择的文件夹
  Directory? emoticonDirectory; // 表情包目录

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
        .where((file) => file.path.endsWith('.png') || file.path.endsWith('.jpg'))
        .toList();

    setState(() {
      emojiImages = images;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      crossAxisCount: 4, // 网格列数
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: emojiImages.length,
                    itemBuilder: (context, index) {
                      // 表情包图片
                      final emoji = emojiImages[index];
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
                                Navigator.of(context).pop(emoji.path);
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
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
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
