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

    final imageData = NativeImage(matPointer: matPointer);

    logger.i('Complete create cv:Mat pointer');

    return imageData;
  }

  Future<void> release(NativeImage image) async {
    malloc.free(image.matPointer);
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
        // 'lengthAddress': image.byteLength.address,
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

  // Future<Uint32List> convertBytesRGBAFromYUV420({
  //   required Uint8List yBytes,
  //   required Uint8List uBytes,
  //   required Uint8List vBytes,
  //   required int bytesPerRow,
  //   required int bytesPerPixel,
  //   required int width,
  //   required int height,
  // }) async {
  //   final port = ReceivePort();
  //
  //   /// Spawning an isolate
  //   Isolate.spawn<Map<String, dynamic>>(
  //     _isolateConvertYUV420ToRBGA,
  //     {
  //       'yBytes': yBytes,
  //       'uBytes': uBytes,
  //       'vBytes': vBytes,
  //       'bytesPerRow': bytesPerRow,
  //       'bytesPerPixel': bytesPerPixel,
  //       'width': width,
  //       'height': height,
  //       'sendPort': port.sendPort,
  //     },
  //     onError: port.sendPort,
  //     // onExit: port.sendPort,
  //   );
  //
  //   final int? address = await port.first as int?;
  //
  //   if (address == null) {
  //     throw Exception('Can not create cv:Mat pointer');
  //   }
  //
  //   Pointer<Uint32> imgP = Pointer<Uint32>.fromAddress(address);
  //
  //   Uint32List imgData = imgP.asTypedList((width * height));
  //
  //   // Image img = imglib.Image.fromBytes(_savedImage.height, _savedImage.planes[0].bytesPerRow, imgData);
  //
  //   return imgData;
  // }

  Future<NativeImage> createImageFromYUV420({
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

    final int? address = await port.first as int?;

    if (address == null) {
      throw Exception('Can not create cv:Mat pointer');
    }

    final Pointer matPointer = Pointer.fromAddress(address);

    final imageData = NativeImage(matPointer: matPointer);

    return imageData;
  }

  Future<NativeImage> createImageFromCameraImage({
    required Uint8List yBytes,
    required Uint8List? uBytes,
    required Uint8List? vBytes,
    required bool isYUV,
    required int width,
    required int height,
    required int rotation,
  }) async {
    final port = ReceivePort();

    /// Spawning an isolate
    Isolate.spawn<Map<String, dynamic>>(
      _isolateConvertCameraImageToMat,
      {
        'yBytes': yBytes,
        'uBytes': uBytes,
        'vBytes': vBytes,
        'rotation': rotation,
        'isYUV': isYUV,
        'width': width,
        'height': height,
        'sendPort': port.sendPort,
      },
      onError: port.sendPort,
      // onExit: port.sendPort,
    );

    final int? address = await port.first as int?;

    if (address == null) {
      throw Exception('Can not create cv:Mat pointer');
    }

    final Pointer matPointer = Pointer.fromAddress(address);

    final imageData = NativeImage(matPointer: matPointer);

    return imageData;
  }

  //
  // Future<NativeImage> createImageFromCameraImageV2({
  //   required Uint8List yBytes,
  //   required Uint8List? uBytes,
  //   required Uint8List? vBytes,
  //   required int bytesPerRow,
  //   required int bytesPerPixel,
  //   required int width,
  //   required int height,
  //   required bool isYUV,
  // }) async {
  //   final port = ReceivePort();
  //
  //   /// Spawning an isolate
  //   Isolate.spawn<Map<String, dynamic>>(
  //     _isolateConvertCameraImageToMatV2,
  //     {
  //       'yBytes': yBytes,
  //       'uBytes': uBytes,
  //       'vBytes': vBytes,
  //       'isYUV': isYUV,
  //       'bytesPerRow': bytesPerRow,
  //       'bytesPerPixel': bytesPerPixel,
  //       'width': width,
  //       'height': height,
  //       'sendPort': port.sendPort,
  //     },
  //     onError: port.sendPort,
  //     // onExit: port.sendPort,
  //   );
  //
  //   final int? address = await port.first as int?;
  //
  //   if (address == null) {
  //     throw Exception('Can not create cv:Mat pointer');
  //   }
  //
  //   final Pointer matPointer = Pointer.fromAddress(address);
  //
  //   final imageData = NativeImage(matPointer: matPointer);
  //
  //   return imageData;
  // }

  Future<Uint8List> convertCameraImageToBytes({
    required Uint8List yBytes,
    required Uint8List? uBytes,
    required Uint8List? vBytes,
    required int bytesPerRow,
    required int bytesPerPixel,
    required int width,
    required int height,
    required bool isYUV,
  }) async {
    final port = ReceivePort();

    /// Spawning an isolate
    Isolate.spawn<Map<String, dynamic>>(
      _isolateConvertCameraImageToBytes,
      {
        'yBytes': yBytes,
        'uBytes': uBytes,
        'vBytes': vBytes,
        'isYUV': isYUV,
        'bytesPerRow': bytesPerRow,
        'bytesPerPixel': bytesPerPixel,
        'width': width,
        'height': height,
        'sendPort': port.sendPort,
      },
      onError: port.sendPort,
      // onExit: port.sendPort,
    );

    final result = await port.first;
    if (result is Uint8List) {
      return result;
    }

    // if (result is List) {
    //   return Uint8List.fromList(
    //       result.map<int>((item) => int.parse(item.toString())).toList());
    // }

    throw Exception('Exception: $result');
    // final Uint8List bytes = await port.first as Uint8List;

    // return bytes;
  }

  Future<Uint8List> convertCameraImageToJpgBytes({
    required Uint8List yBytes,
    required Uint8List? uBytes,
    required Uint8List? vBytes,
    required int bytesPerRow,
    required int bytesPerPixel,
    required int width,
    required int height,
    required bool isYUV,
  }) async {
    final port = ReceivePort();

    /// Spawning an isolate
    Isolate.spawn<Map<String, dynamic>>(
      _isolateConvertCameraImageToJpgBytes,
      {
        'yBytes': yBytes,
        'uBytes': uBytes,
        'vBytes': vBytes,
        'isYUV': isYUV,
        'bytesPerRow': bytesPerRow,
        'bytesPerPixel': bytesPerPixel,
        'width': width,
        'height': height,
        'sendPort': port.sendPort,
      },
      onError: port.sendPort,
      // onExit: port.sendPort,
    );

    final result = await port.first;
    if (result is Uint8List) {
      return result;
    }

    throw Exception('Exception: $result');
  }

  Future<Uint8List> cropImageBytes({
    required Uint8List bytes,
    required CvRectangle rect,
  }) async {
    final port = ReceivePort();

    /// Spawning an isolate
    Isolate.spawn<Map<String, dynamic>>(
      _isolateCropImageBytes,
      {
        'bytes': bytes,
        'left': rect.left,
        'top': rect.top,
        'width': rect.width,
        'height': rect.height,
        'sendPort': port.sendPort,
      },
      onError: port.sendPort,
      // onExit: port.sendPort,
    );

    final Uint8List resultBytes = await port.first as Uint8List;

    return resultBytes;
  }

  Future<Uint8List> cropImageJpgBytes({
    required Uint8List bytes,
    required CvRectangle rect,
  }) async {
    final port = ReceivePort();

    /// Spawning an isolate
    Isolate.spawn<Map<String, dynamic>>(
      _isolateCropImageJpgBytes,
      {
        'bytes': bytes,
        'left': rect.left,
        'top': rect.top,
        'width': rect.width,
        'height': rect.height,
        'sendPort': port.sendPort,
      },
      onError: port.sendPort,
      // onExit: port.sendPort,
    );

    final Uint8List resultBytes = await port.first as Uint8List;

    return resultBytes;
  }
}

void _isolateCropImageBytes(Map<String, dynamic> data) {
  final Uint8List bytes = data['bytes'];
  final int left = data['left'];
  final int top = data['top'];
  final int width = data['width'];
  final int height = data['height'];
  final SendPort sendPort = data['sendPort'];

  Pointer<Uint8> pointerBytes = _intListToArray(bytes);

  Pointer<Int32> lengthPtr = malloc.allocate<Int32>(sizeOf<Int32>());

  lengthPtr.value = bytes.length;

  final imageBytesPointer =
      cropImageBytes(pointerBytes, lengthPtr, left, top, width, height);

  Uint8List imageBytes = imageBytesPointer.asTypedList(lengthPtr.value);

  final copyBytes = Uint8List.fromList(imageBytes);

  malloc.free(pointerBytes);
  malloc.free(lengthPtr);
  malloc.free(imageBytesPointer);

  sendPort.send(copyBytes);
}

void _isolateCropImageJpgBytes(Map<String, dynamic> data) {
  final Uint8List bytes = data['bytes'];
  final int left = data['left'];
  final int top = data['top'];
  final int width = data['width'];
  final int height = data['height'];
  final SendPort sendPort = data['sendPort'];

  Pointer<Uint8> pointerBytes = _intListToArray(bytes);

  Pointer<Int32> lengthPtr = malloc.allocate<Int32>(sizeOf<Int32>());

  lengthPtr.value = bytes.length;

  final imageBytesPointer =
  cropImageJpgBytes(pointerBytes, lengthPtr, left, top, width, height);

  Uint8List imageBytes = imageBytesPointer.asTypedList(lengthPtr.value);

  final copyBytes = Uint8List.fromList(imageBytes);

  malloc.free(pointerBytes);
  malloc.free(lengthPtr);
  malloc.free(imageBytesPointer);

  sendPort.send(copyBytes);
}

void _isolateConvertCameraImageToBytes(Map<String, dynamic> data) {
  final Uint8List yBytes = data['yBytes'];
  final Uint8List? uBytes = data['uBytes'];
  final Uint8List? vBytes = data['vBytes'];
  final int bytesPerRow = data['bytesPerRow'];
  final int bytesPerPixel = data['bytesPerPixel'];
  final bool isYUV = data['isYUV'];
  final int width = data['width'];
  final int height = data['height'];
  final SendPort sendPort = data['sendPort'];

  Uint8List copyYBytes = Uint8List.fromList(yBytes);
  Pointer<Uint8> yPoiter = malloc.allocate(copyYBytes.length);

  Uint8List pointerList = yPoiter.asTypedList(copyYBytes.length);

  pointerList.setRange(0, copyYBytes.length, copyYBytes);

  Pointer<Uint8> uPointer =
      uBytes != null ? malloc.allocate(uBytes.length) : nullptr;
  Pointer<Uint8> vPointer =
      vBytes != null ? malloc.allocate(vBytes.length) : nullptr;

  if (isYUV) {
    Uint8List pointerUList = uPointer.asTypedList(uBytes!.length);
    Uint8List pointerVList = vPointer.asTypedList(vBytes!.length);
    pointerUList.setRange(0, uBytes.length, uBytes);
    pointerVList.setRange(0, vBytes.length, vBytes);
  }
  Pointer<Int32> bytesLengthPtr = malloc.allocate<Int32>(sizeOf<Int32>());

  Pointer<Uint8> matPtr = converCameraImageToMatV3(yPoiter, uPointer, vPointer,
      bytesLengthPtr, isYUV, bytesPerRow, bytesPerPixel, width, height);

  Uint8List imageBytes = matPtr.asTypedList(bytesLengthPtr.value);

  final copyBytes = Uint8List.fromList(imageBytes);

  if (isYUV) {
    malloc.free(uPointer);
    malloc.free(vPointer);
  }

  malloc.free(yPoiter);
  malloc.free(bytesLengthPtr);
  malloc.free(matPtr);

  sendPort.send(copyBytes);
}

void _isolateConvertCameraImageToJpgBytes(Map<String, dynamic> data) {
  final Uint8List yBytes = data['yBytes'];
  final Uint8List? uBytes = data['uBytes'];
  final Uint8List? vBytes = data['vBytes'];
  final int bytesPerRow = data['bytesPerRow'];
  final int bytesPerPixel = data['bytesPerPixel'];
  final bool isYUV = data['isYUV'];
  final int width = data['width'];
  final int height = data['height'];
  final SendPort sendPort = data['sendPort'];

  Uint8List copyYBytes = Uint8List.fromList(yBytes);
  Pointer<Uint8> yPoiter = malloc.allocate(copyYBytes.length);

  Uint8List pointerList = yPoiter.asTypedList(copyYBytes.length);

  pointerList.setRange(0, copyYBytes.length, copyYBytes);

  Pointer<Uint8> uPointer =
      uBytes != null ? malloc.allocate(uBytes.length) : nullptr;
  Pointer<Uint8> vPointer =
      vBytes != null ? malloc.allocate(vBytes.length) : nullptr;

  if (isYUV) {
    Uint8List pointerUList = uPointer.asTypedList(uBytes!.length);
    Uint8List pointerVList = vPointer.asTypedList(vBytes!.length);
    pointerUList.setRange(0, uBytes.length, uBytes);
    pointerVList.setRange(0, vBytes.length, vBytes);
  }
  Pointer<Int32> bytesLengthPtr = malloc.allocate<Int32>(sizeOf<Int32>());

  Pointer<Uint8> matPtr = converCameraImageToJpgBytes(
      yPoiter,
      uPointer,
      vPointer,
      bytesLengthPtr,
      isYUV,
      bytesPerRow,
      bytesPerPixel,
      width,
      height);

  Uint8List imageBytes = matPtr.asTypedList(bytesLengthPtr.value);

  final copyBytes = Uint8List.fromList(imageBytes);

  if (isYUV) {
    malloc.free(uPointer);
    malloc.free(vPointer);
  }

  malloc.free(yPoiter);
  malloc.free(bytesLengthPtr);
  malloc.free(matPtr);

  sendPort.send(copyBytes);
}

void _isolateConvertCameraImageToMat(Map<String, dynamic> data) {
  final Uint8List yBytes = data['yBytes'];
  final Uint8List? uBytes = data['uBytes'];
  final Uint8List? vBytes = data['vBytes'];
  final int rotation = data['rotation'];
  final bool isYUV = data['isYUV'];

  final int width = data['width'];
  final int height = data['height'];
  final SendPort sendPort = data['sendPort'];

  final ySize = yBytes.lengthInBytes;
  final uSize = uBytes?.lengthInBytes ?? 0;
  final vSize = vBytes?.lengthInBytes ?? 0;

  var totalSize = ySize + uSize + vSize;

  Pointer<Uint8> imageBuffer = malloc.allocate<Uint8>(totalSize);

  Uint8List bytes = imageBuffer.asTypedList(totalSize);

  bytes.setAll(0, yBytes);

  if (isYUV) {
    // Swap u&v buffer for opencv
    bytes.setAll(ySize, vBytes!);
    bytes.setAll(ySize + vSize, uBytes!);
  }

  Pointer<Void> matPtr =
      converCameraImageToMat(imageBuffer, isYUV, rotation, width, height);
  malloc.free(imageBuffer);
  sendPort.send(matPtr.address);
}

// void _isolateConvertYUV420ToRBGA(Map<String, dynamic> data) {
//   final Uint8List yBytes = data['yBytes'];
//   final Uint8List uBytes = data['uBytes'];
//   final Uint8List vBytes = data['vBytes'];
//   final int bytesPerRow = data['bytesPerRow'];
//   final int bytesPerPixel = data['bytesPerPixel'];
//   final int width = data['width'];
//   final int height = data['height'];
//   final SendPort sendPort = data['sendPort'];
//
//   Pointer<Uint8> p = malloc.allocate(yBytes.length);
//   Pointer<Uint8> p1 = malloc.allocate(uBytes.length);
//   Pointer<Uint8> p2 = malloc.allocate(vBytes.length);
//
//   Uint8List pointerList = p.asTypedList(yBytes.length);
//   Uint8List pointerList1 = p1.asTypedList(uBytes.length);
//   Uint8List pointerList2 = p2.asTypedList(vBytes.length);
//   pointerList.setRange(0, yBytes.length, yBytes);
//   pointerList1.setRange(0, uBytes.length, uBytes);
//   pointerList2.setRange(0, vBytes.length, vBytes);
//
//   Pointer<Uint32> imgP = nativeConvertYUV420ToRBGA(
//       p, p1, p2, bytesPerRow, bytesPerPixel, width, height);
//
//   // Uint8List imgData = imgP.asTypedList(width * height);
//
//   sendPort.send(imgP.address);
// }

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

  Pointer<Void> matPtr =
      createMatFromYUV420(p, p1, p2, bytesPerRow, bytesPerPixel, width, height);

  // Uint8List imgData = imgP.asTypedList(width * height);
  malloc.free(p);
  malloc.free(p1);
  malloc.free(p2);
  sendPort.send(matPtr.address);
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
  // final int lengthAddress = data['lengthAddress'];

  final matPointer = Pointer.fromAddress(matPointerAddress);

  Pointer<Int32> imgByteLength = malloc.allocate<Int32>(sizeOf<Int32>());
  // Pointer<Int32> imgByteLength = Pointer<Int32>.fromAddress(lengthAddress);

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

  nativeDrawRect(matPointer, rect.left, rect.top, rect.width, rect.height);

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
  malloc.free(imgByteLength);

  sendPort.send({
    'matAddress': matPointer.address,
    // 'byteLengthAddress': imgByteLength.address,
  });
}

Pointer<Uint8> _intListToArray(Uint8List list) {
  final Pointer<Uint8> ptr = malloc.allocate<Uint8>(list.length);
  for (var i = 0; i < list.length; i++) {
    ptr.elementAt(i).value = list[i];
  }
  return ptr;
}
