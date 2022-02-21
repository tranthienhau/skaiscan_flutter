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

  Future<void> release(NativeImage image) async {
    malloc.free(image.matPointer);
    malloc.free(image.byteLength);
  }

  Future<void> drawRect(NativeImage image, CvRectangle rect) async {
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
    );

    final result = await port.first as Map<String, dynamic>?;

    if (result == null) {
      throw Exception('Can not create cv:Mat pointer');
    }

    logger.i('Complete draw rect cv:Mat pointer');
  }

  Future<Uint8List> convertNativeImageToBytes(NativeImage image) async {
    final port = ReceivePort();

    /// Spawning an isolate
    Isolate.spawn<Map<String, dynamic>>(
      _isolateConvertMatPointerToBytes,
      {
        'lengthAddress': image.byteLength.address,
        'sendPort': port.sendPort,
        'matAddress': image.matPointer.address,
      },
      onError: port.sendPort,
      // onExit: port.sendPort,
    );

    final Uint8List? bytes = await port.first as Uint8List?;

    if (bytes == null) {
      throw Exception('Can not create cv:Mat pointer');
    }

    return bytes;
  }

  Future<NativeImage> cloneImage(NativeImage image) {
    throw Exception('Not implemented yet');
  }

  Future<Uint8List> rotate90CounterClockwiseFlipResize({
    required Uint8List bytes,
    required int flip,
    required int resizeWidth,
    required int resizeHeight,
  }) async {
    final port = ReceivePort();

    /// Spawning an isolate
    Isolate.spawn<Map<String, dynamic>>(
      _isolateRotate90CounterClockwiseFlipResize,
      {
        'bytes': bytes,
        'flip': flip,
        'resizeWidth': resizeWidth,
        'resizeHeight': resizeHeight,
        'sendPort': port.sendPort,
      },
      onError: port.sendPort,
      // onExit: port.sendPort,
    );

    final Uint8List? resultBytes = await port.first as Uint8List?;

    if (resultBytes == null) {
      throw Exception('Can not create cv:Mat pointer');
    }

    return resultBytes;
  }

  Future<Uint8List> getBytesYUV420({
    required Uint8List yBytes,
    required Uint8List uBytes,
    required Uint8List vBytes,
    required int bytesPerRow,
    required int bytesPerPixel,
    required int width,
    required int height,
  }) async {
    final port = ReceivePort();

    /// Spawning an isolate
    Isolate.spawn<Map<String, dynamic>>(
      _isolateCreateMatFromYUV420,
      {
        'yBytes': yBytes,
        'uBytes': uBytes,
        'vBytes': vBytes,
        'bytesPerRow': bytesPerRow,
        'bytesPerPixel': bytesPerPixel,
        'width': width,
        'height': height,
        'sendPort': port.sendPort,
      },
      onError: port.sendPort,
      // onExit: port.sendPort,
    );

    final Uint8List? resultBytes = await port.first as Uint8List?;

    if (resultBytes == null) {
      throw Exception('Can not create cv:Mat pointer');
    }

    return resultBytes;
  }

// Future<void> cropImage(NativeImage image, CvRectangle rect) async {}

}

void _isolateCreateMatFromYUV420(Map<String, dynamic> data) {
  final Uint8List yBytes = data['yBytes'];
  final Uint8List uBytes = data['uBytes'];
  final Uint8List vBytes = data['vBytes'];
  final int bytesPerRow = data['bytesPerRow'];
  final int bytesPerPixel = data['bytesPerPixel'];
  final int width = data['width'];
  final int height = data['height'];
  final SendPort sendPort = data['sendPort'];

  Pointer<Uint8> p = malloc.allocate(yBytes.length);
  Pointer<Uint8> p1 = malloc.allocate(uBytes.length);
  Pointer<Uint8> p2 = malloc.allocate(vBytes.length);

  Uint8List pointerList = p.asTypedList(yBytes.length);
  Uint8List pointerList1 = p1.asTypedList(uBytes.length);
  Uint8List pointerList2 = p2.asTypedList(vBytes.length);
  pointerList.setRange(0, yBytes.length, yBytes);
  pointerList1.setRange(0, uBytes.length, uBytes);
  pointerList2.setRange(0, vBytes.length, vBytes);

  Pointer<Uint8> imgP =
      createMatFromYUV420(p, p1, p2, bytesPerRow, bytesPerPixel, width, height);

  Uint8List imgData = imgP.asTypedList(width * height);

  sendPort.send(imgData);
}

void _isolateRotate90CounterClockwiseFlipResize(Map<String, dynamic> data) {
  final Uint8List bytes = data['bytes'];
  final int flip = data['flip'];
  final int resizeWidth = data['resizeWidth'];
  final int resizeHeight = data['resizeHeight'];

  final SendPort sendPort = data['sendPort'];

  Pointer<Uint8> pointerImage = _intListToArray(bytes);

  Pointer<Int32> flipPointer = malloc.allocate<Int32>(sizeOf<Int32>());

  flipPointer.value = flip;

  Pointer<Int32> resizeWidthPointer = malloc.allocate<Int32>(sizeOf<Int32>());

  resizeWidthPointer.value = resizeWidth;

  Pointer<Int32> resizeHeightPointer = malloc.allocate<Int32>(sizeOf<Int32>());

  resizeHeightPointer.value = resizeHeight;

  Pointer<Int32> imgByteLength = malloc.allocate<Int32>(sizeOf<Int32>());

  Pointer<Uint8> resultPointer = nativeRotate90CounterClockwiseFlipResizeBytes(
    pointerImage,
    imgByteLength,
    flipPointer,
    resizeWidthPointer,
    resizeHeightPointer,
  );

  Uint8List imageBytes = resultPointer.asTypedList(imgByteLength.value);

  final copyBytes = Uint8List.fromList(imageBytes);

  malloc.free(pointerImage);

  malloc.free(imgByteLength);

  malloc.free(flipPointer);

  malloc.free(resizeWidthPointer);

  malloc.free(resizeHeightPointer);

  malloc.free(resultPointer);

  sendPort.send(copyBytes);
}

void _isolateConvertMatPointerToBytes(Map<String, dynamic> data) {
  final int matPointerAddress = data['matAddress'];
  final SendPort sendPort = data['sendPort'];

  final matPointer = Pointer.fromAddress(matPointerAddress);

  Pointer<Int32> imgByteLength = malloc.allocate<Int32>(sizeOf<Int32>());

  Pointer<Uint8> imageBytesPointer =
      convertMatPointerToBytes(matPointer, imgByteLength);

  Uint8List imageBytes = imageBytesPointer.asTypedList(imgByteLength.value);

  malloc.free(imgByteLength);
  malloc.free(imageBytesPointer);

  sendPort.send(imageBytes);
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
