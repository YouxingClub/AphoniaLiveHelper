import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

Directory configDir = Directory("config");

var _SimpleConfigJson = """
{
    "Controller": {
        "WSServerPort": 4005,
        "name": "未命名"
    },
    "Linkage":{
        "GlobalColor": "#000000",
        "name": "未命名",
        "ServerList": [
            {
                "Address": "localhost"
            }
        ]
    }
}
""";

createConfigDir() async {
  if (!configDir.existsSync()) {
    await configDir.create();
  }
}

createConfigFile() async {
  var filePath = File("${configDir.path}/TypeControllerConfig.json");
  await filePath.create();
  if (await filePath.exists()) {
    filePath.writeAsString(_SimpleConfigJson);
  }
}

updateConfigFile(dynamic configJson) async {
  var filePath = File("${configDir.path}/TypeControllerConfig.json");
  var configJsonStr = json.encode(configJson);
  print(configJsonStr);
  if (await filePath.exists()) {
    await filePath.writeAsString(configJsonStr);
  } else {
    await createConfigDir();
    await createConfigFile();
    await updateConfigFile(configJson);
  }
}

readConfigFile() async {
  var filePath = File("${configDir.path}/TypeControllerConfig.json");
  if (filePath.existsSync()) {
    var configJsonStr = await filePath.readAsString();
    return json.decode(configJsonStr.toString());
  } else {
    await createConfigDir();
    await createConfigFile();
    var configJsonStr = await filePath.readAsString();
    return json.decode(configJsonStr.toString());
  }
}