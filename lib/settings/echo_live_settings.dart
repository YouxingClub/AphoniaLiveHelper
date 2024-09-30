import 'package:flutter/material.dart';

// echolive设置

class EchoLiveSettingsPage extends StatefulWidget {
  const EchoLiveSettingsPage({super.key});

  // const MainApp({super.key});

  @override
  _EchoLiveSettingsPage createState() => _EchoLiveSettingsPage();
}

class _EchoLiveSettingsPage extends State<EchoLiveSettingsPage> {
  int _selectedIndex = 0;

  // 配置项
  final List<String> _sections = [
    '全局',
    'Echo',
    'Echo-Live',
    '历史记录',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('配置页面')),
      body: Row(
        children: [
          // 左侧菜单
          Container(
            width: 200, // 设置菜单宽度
            child: NavigationRail(
              extended: true,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: _sections.map((section) {
                return NavigationRailDestination(
                  icon: Icon(Icons.add_circle_outline),
                  label: Text(section),
                );
              }).toList(),
            ),
          ),

          // 右侧内容
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                // 全局设置页面
                _buildGlobalSettingsPage(),
                // Echo 设置页面
                _buildEchoSettingsPage(),
                // EchoLive 设置页面
                _buildEchoLiveSettingsPage(),
                // 历史设置页面
                _buildHistorySettingsPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalSettingsPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField(
            decoration: InputDecoration(labelText: '全局主题'),
            items: ['vanilla', 'bubble', 'glass', 'void'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {},
          ),
          Text("控制对话框、历史记录等面向观众展示的界面主题。关于可用的主题请见帮助文档。\n为了主题样式的表现正常，请在 OBS 选中对话框（包括历史记录在内的其他前台页面），右键，在弹出菜单中找到 “混合方式”，选择 “关闭 sRGB”。"),
          SwitchListTile(
            title: Text('启用全局主题脚本'),
            value: false,
            onChanged: (value) {},
          ),
          Text("一些高级效果可能需要启用主题脚本才能正常使用。目前所有预制主题均不包含脚本。\n脚本中可以执行任意代码，请谨慎安装需要您启用脚本的第三方主题。")
        ],
      ),
    );
  }

  Widget _buildEchoSettingsPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: '打印速度'),
            keyboardType: TextInputType.number,
          ),
          SwitchListTile(
            title: Text('启用HTML过滤器'),
            value: true,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  Widget _buildEchoLiveSettingsPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("主题样式"),
            DropdownButtonFormField(
              decoration: InputDecoration(labelText: '对话框主题'),
              items: ['vanilla', 'bubble', 'glass', 'void'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: Text('启用主题脚本'),
              value: false,
              onChanged: (value) {},
            ),
            Text("打字音效"),
            SwitchListTile(
              title: Text('启用打字音效'),
              value: false,
              onChanged: (value) {},
            ),
            DropdownButtonFormField(
              decoration: InputDecoration(labelText: '音效名称'),
              items: ['typewriter', 'typewriter_loop', 'sys001', 'sys002', 'sys003', 'enter'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {},
            ),
            TextFormField(
              decoration: InputDecoration(labelText: '音效音量'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: '音效播放速度'),
              keyboardType: TextInputType.number,
            ),
            Text("新对话入场音效"),
            SwitchListTile(
              title: Text('启用新对话入场音效'),
              value: false,
              onChanged: (value) {},
            ),
            DropdownButtonFormField(
              decoration: InputDecoration(labelText: '音效名称'),
              items: ['typewriter', 'typewriter_loop', 'sys001', 'sys002', 'sys003', 'enter'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {},
            ),
            TextFormField(
              decoration: InputDecoration(labelText: '音效音量'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: '音效播放速度'),
              keyboardType: TextInputType.number,
            ),
            Text("字符打印动效"),
            DropdownButtonFormField(
              decoration: InputDecoration(labelText: '动效名称'),
              items: ['none', 'fade-in', 'move-in-up', 'move-in-down', 'blur-in'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {},
            ),
            TextFormField(
              decoration: InputDecoration(labelText: '动效用时'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: '动效规模乘数'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField(
              decoration: InputDecoration(labelText: '动效时间曲线'),
              items: ['ease', 'linear', 'ease-in', 'ease-out', 'ease-in-out', 'cubic-bezier(0.12, 0, 0.39, 0)', 'cubic-bezier(0.61, 1, 0.88, 1)'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {},
            ),
            Text("隐去与显现动画"),
            SwitchListTile(
              title: Text('闲置时自动隐去'),
              value: false,
              onChanged: (value) {},
            ),
            TextFormField(
              decoration: InputDecoration(labelText: '闲置等候时间'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: '长文本等候时间补偿率'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: '隐去动画用时'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: '显现动画用时'),
              keyboardType: TextInputType.number,
            ),
            Text("图片"),
            SwitchListTile(
              title: Text('启用图片'),
              value: false,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: Text('允许 Data URL 和相对地址'),
              value: false,
              onChanged: (value) {},
            ),
            TextFormField(
              decoration: InputDecoration(labelText: '默认最大图片尺寸'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildHistorySettingsPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text("主题样式"),
          DropdownButtonFormField(
            decoration: InputDecoration(labelText: '历史记录主题'),
            items: ['vanilla', 'bubble', 'glass', 'void'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {},
          ),
          SwitchListTile(
            title: Text('启用历史主题脚本'),
            value: true,
            onChanged: (value) {},
          ),
          Text("布局"),
          SwitchListTile(
            title: Text('历史记录倒序排列'),
            value: true,
            onChanged: (value) {},
          ),
          SwitchListTile(
            title: Text('历史记录布局左右翻转'),
            value: true,
            onChanged: (value) {},
          ),
          SwitchListTile(
            title: Text('显示说话人'),
            value: true,
            onChanged: (value) {},
          ),
          SwitchListTile(
            title: Text('显示发送时间'),
            value: true,
            onChanged: (value) {},
          ),
          Text("消息"),
          SwitchListTile(
            title: Text('去除连续的重复消息'),
            value: true,
            onChanged: (value) {},
          ),
          SwitchListTile(
            title: Text('隐藏最新的历史记录'),
            value: true,
            onChanged: (value) {},
          ),
          SwitchListTile(
            title: Text('对话框隐去时显示最新的历史记录'),
            value: true,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }
}
