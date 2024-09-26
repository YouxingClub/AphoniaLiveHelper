import 'dart:convert';
import 'dart:io';

class _LogSink implements IOSink {
  final IOSink _originalSink;
  final IOSink _fileSink;

  @override
  Encoding encoding;

  _LogSink(this._originalSink, this._fileSink)
      : encoding = _originalSink.encoding;

  @override
  void write(Object? obj) {
    _originalSink.write(obj);
    _fileSink.write(obj);
  }

  @override
  void writeln([Object? obj = '']) {
    _originalSink.writeln(obj);
    _fileSink.writeln(obj);
  }

  @override
  void writeAll(Iterable objects, [String separator = '']) {
    _originalSink.writeAll(objects, separator);
    _fileSink.writeAll(objects, separator);
  }

  @override
  void writeCharCode(int charCode) {
    _originalSink.writeCharCode(charCode);
    _fileSink.writeCharCode(charCode);
  }

  @override
  void add(List<int> data) {
    _originalSink.add(data);
    _fileSink.add(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _originalSink.addError(error, stackTrace);
    _fileSink.addError(error, stackTrace);
  }

  @override
  Future<void> close() async {
    // 确保两个 sink 都被关闭，并等待它们完成
    await _originalSink.close();
    await _fileSink.close();
  }

  @override
  Future<void> flush() async {
    await _originalSink.flush();
    await _fileSink.flush();
  }

  @override
  Future<void> get done async {
    await _originalSink.done;
    await _fileSink.done;
  }

  @override
  Future addStream(Stream<List<int>> stream) {
    // TODO: implement addStream
    throw UnimplementedError();
  }
}