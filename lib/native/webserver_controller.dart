import 'dart:ffi';
import 'dart:isolate';

import '../static.dart';

final DynamicLibrary dylib = DynamicLibrary.open("webserver.dll");


// 定义函数指针
typedef StartServerC = Void Function();
typedef StartServerDart = void Function();
typedef StopServerC = Void Function();
typedef StopServerDart = void Function();

// 获取函数
final StartServerDart startServer = dylib
    .lookup<NativeFunction<StartServerC>>('StartWebServer')
    .asFunction();

final StopServerDart stopServer = dylib
    .lookup<NativeFunction<StopServerC>>('StopWebServer')
    .asFunction();

// 在Isolate中运行的函数
void startWebService(SendPort sendPort) {
  startServer();
  sendPort.send('echo-live-rev server is running');
}

void stopWebService(SendPort sendPort) {
  stopServer();
  sendPort.send("echo-live-rev server stopped");
}

Future<void> startServerIsolate() async {
  var receivePort = ReceivePort();

  await Isolate.spawn(
    startWebService,
    receivePort.sendPort,
  );
}

Future<void> stopServerIsolate() async {
  var receivePort = ReceivePort();

  try {
    await Isolate.spawn(
      stopWebService,
      receivePort.sendPort,
    );
  } catch (e) {
    print(e);
  }
  // var serverIsolate =
  receivePort.listen((message) {
    print(message);
    receivePort.close(); // 关闭监听
  });
}