import 'package:flutter/material.dart';
import 'package:type_controller/native/webserver_controller.dart';
import 'package:type_controller/settings/config_file.dart';

import '../static.dart';

class EditorSettingsPage extends StatefulWidget {
  const EditorSettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _EditorSettingsPage();
}

class _EditorSettingsPage extends State<EditorSettingsPage> {

  final _formKey = GlobalKey<FormState>();

  _readConfig() async {
    configJson = await readConfigFile();
  }

  _writeConfig() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      wsport = configJson['Controller']['WSServerPort'];
      stopServerIsolate();
      startServerIsolate();
      await updateConfigFile(configJson);
    }
  }

  @override
  void initState() {
    super.initState();
    _readConfig();
  }

  @override
  void dispose() {
    super.dispose();
    _writeConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('编辑器配置')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'WSServerPort'),
                initialValue: configJson['Controller']['WSServerPort'].toString(),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入端口';
                  }
                  return null;
                },
                onSaved: (value) {
                  configJson['Controller']['WSServerPort'] = int.tryParse(value!);
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _writeConfig,
                child: Text('保存配置'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}