import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:logger/logger.dart';
import 'package:skaiscan_ffi/skaiscan_ffi.dart';
import 'package:skaiscan_ffi/src/native_cv_func.dart';


class NativeOpencv {
  static final NativeOpencv _instance = NativeOpencv._internal();

  factory NativeOpencv() {
    return _instance;
  }

  NativeOpencv._internal();

  final Logger logger = Logger();

  Future<NativeImage> createImageFromBytes(Uint8List bytes) async {
    Completer<Map<String, dynamic>?> _resultCompleter =
        Completer<Map<String, dynamic>?>();

    final port = ReceivePort();

    /// Spawning an isolate
    Isolate.spawn<Map<String, dynamic>>(
      _isolateCreateMatPointer,
      {
        'bytes': bytes,
        'sendPort': port.sendPort,
      },
      onError: port.sendPort,
      // onExit: port.sendPort,
    );

    port.listen((message) {
      if (_resultCompleter.isCompleted) {
        return;
      }

      if (message is Map<String, dynamic>) {
        _resultCompleter.complete(message);
        return;
      }

      _resultCompleter.complete(null);
    });

    final Map<String, dynamic>? result = await _resultCompleter.future;

    if (result == null) {
      throw Exception('Can not create cv:Mat pointer');
    }

    final Pointer matPointer = Pointer.fromAddress(result['matAddress']);

    final Pointer<Int32> byteLength =
        Pointer.fromAddress(result['byteLengthAddress']);

    final imageData = NativeImage(
      byteLength: byteLength,
      matPointer: matPointer,
    );

    logger.i('Complete create cv:Mat pointer');

    return imageData;
  }

  Future<void> dispose(NativeImage image) async {
    malloc.free(image.matPointer);
    malloc.free(image.byteLength);
  }

  Future<void> drawRect(NativeImage image, CvRectangle rect) async {
    Completer<Map<String, dynamic>?> _resultCompleter =
        Completer<Map<String, dynamic>?>();

    final port = ReceivePort();

    /// Spawning an isolate
    Isolate.spawn<Map<String, dynamic>>(
      _isolateDrawRectMatPointer,
      {
        'rect': rect,
        'sendPort': port.sendPort,
        'address': image.matPointer.address,
      },
      onError: port.sendPort,
      // onExit: port.sendPort,
    );

    port.listen((message) {
      if (_resultCompleter.isCompleted) {
        return;
      }

      if (message is Map<String, dynamic>) {
        _resultCompleter.complete(message);
        return;
      }

      _resultCompleter.complete(null);
    });

    final Map<String, dynamic>? result = await _resultCompleter.future;

    if (result == null) {
      throw Exception('Can not create cv:Mat pointer');
    }

    // final Pointer matPointer = Pointer.fromAddress(result['matAddress']);

    logger.i('Complete draw rect cv:Mat pointer');
  }

  Future<Uint8List> convertNativeImageToBytes(NativeImage image) async {
    // throw Exception('Not implemented yet');

    Completer<Map<String, dynamic>?> _resultCompleter =
        Completer<Map<String, dynamic>?>();

    final port = ReceivePort();

    /// Spawning an isolate
    Isolate.spawn<Map<String, dynamic>>(
      _convertMatPointerToBytes,
      {
        'lengthAddress': image.byteLength.address,
        'sendPort': port.sendPort,
        'matAddress': image.matPointer.address,
      },
      onError: port.sendPort,
      // onExit: port.sendPort,
    );

    port.listen((message) {
      if (_resultCompleter.isCompleted) {
        return;
      }

      if (message is Map<String, dynamic>) {
        _resultCompleter.complete(message);
        return;
      }

      _resultCompleter.complete(null);
    });

    final Map<String, dynamic>? result = await _resultCompleter.future;

    if (result == null) {
      throw Exception('Can not create cv:Mat pointer');
    }

    final Uint8List bytes = result['imageBytes'];

    return bytes;
  }

  Future<NativeImage> cloneImage(NativeImage image) {
    throw Exception('Not implemented yet');
  }

  Future<void> cropImage(NativeImage image, CvRectangle rect) async {}
}

void _convertMatPointerToBytes(Map<String, dynamic> data) {
  final int matPointerAddress = data['matAddress'];
  final int lengthAddress = data['lengthAddress'];
  final SendPort sendPort = data['sendPort'];

  final matPointer = Pointer.fromAddress(matPointerAddress);
  final Pointer<Int32> lengthPointer = Pointer.fromAddress(lengthAddress);

  Pointer<Uint8> imageBytesPointer = convertMatPointerToBytes(matPointer);
  Uint8List imageBytes = imageBytesPointer.asTypedList(lengthPointer.value);

  sendPort.send({'imageBytes': imageBytes});
}

void _isolateDrawRectMatPointer(Map<String, dynamic> data) {
  final int pointerAddress = data['address'];
  final SendPort sendPort = data['sendPort'];
  final CvRectangle rect = data['rect'];

  final matPointer = Pointer.fromAddress(pointerAddress);

  nativeDrawRect(matPointer, rect.x, rect.y, rect.width, rect.height);

  sendPort.send({'matAddress': matPointer.address});
}

void _isolateCreateMatPointer(Map<String, dynamic> data) {
  final Uint8List bytes = data['bytes'];
  final SendPort sendPort = data['sendPort'];
  Pointer<Uint8> pointerImage = _intListToArray(bytes);

  Pointer<Int32> imgByteLength = malloc.allocate<Int32>(sizeOf<Int32>());
  imgByteLength.value = bytes.length;
  final matPointer = createMatPointerFromBytes(pointerImage, imgByteLength);

  malloc.free(pointerImage);

  sendPort.send({
    'matAddress': matPointer.address,
    'byteLengthAddress': imgByteLength.address,
  });
}

Pointer<Uint8> _intListToArray(Uint8List list) {
  final Pointer<Uint8> ptr = malloc.allocate<Uint8>(list.length);
  for (var i = 0; i < list.length; i++) {
    ptr.elementAt(i).value = list[i];
  }
  return ptr;
}
