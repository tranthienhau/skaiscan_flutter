import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:logger/logger.dart';
import 'package:skaiscan_ffi/skaiscan_ffi.dart';
import 'package:skaiscan_ffi/src/native_skaiscan_func.dart';

class NativeSkaiscan {
  static final NativeSkaiscan _instance = NativeSkaiscan._internal();

  factory NativeSkaiscan() {
    return _instance;
  }

  NativeSkaiscan._internal();

  final Logger logger = Logger();

  Future<Pointer> _createNativeMaskColorPoiter(
      List<MaskColorData> maskColors) async {
    final Pointer<Pointer<NativeMaskColorData>> pointerPointer =
        malloc.allocate(maskColors.length * sizeOf<NativeMaskColorData>());

    for (int i = 0; i < maskColors.length; i++) {
      final maskColor = maskColors[i];
      final element = pointerPointer.elementAt(0).value.ref;
      element.index = maskColor.index;
      element.red = maskColor.color.red;
      element.blue = maskColor.color.blue;
      element.green = maskColor.color.green;
    }

    return pointerPointer;
  }

  Future<Uint8List> applyAcneMaskColor({
    required Uint8List maskBytes,
    required NativeImage origin,
    required int width,
    required int height,
  }) async {
    final port = ReceivePort();

    /// Spawning an isolate
    Isolate.spawn<Map<String, dynamic>>(
      _isolateApplyAcneMaskColor,
      {
        // 'lengthAddress': image.byteLength.address,
        'sendPort': port.sendPort,
        'width': width,
        'height': height,
        'maskBytes': maskBytes,
        'originAddress': origin.matPointer.address,
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

  Future<Uint8List> applyAcneMaskColorV2({
    required Uint8List maskBytes,
    required Uint8List originBytes,
    required int originWidth,
    required int originHeight,
    required int maskWidth,
    required int maskHeight,
  }) async {
    final port = ReceivePort();

    /// Spawning an isolate
    Isolate.spawn<Map<String, dynamic>>(
      _isolateApplyAcneMaskColorV2,
      {
        'sendPort': port.sendPort,
        'originWidth': originWidth,
        'originHeight': originHeight,
        'maskWidth': maskWidth,
        'maskHeight': maskHeight,
        'maskBytes': maskBytes,
        'originBytes': originBytes,
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

  Future<Uint8List> applyAcneMaskColorJpg({
    required Uint8List maskBytes,
    required Uint8List originBytes,
    required int originWidth,
    required int originHeight,
    required int maskWidth,
    required int maskHeight,
  }) async {
    final port = ReceivePort();

    /// Spawning an isolate
    Isolate.spawn<Map<String, dynamic>>(
      _isolateApplyAcneMaskColorJpg,
      {
        'sendPort': port.sendPort,
        'originWidth': originWidth,
        'originHeight': originHeight,
        'maskWidth': maskWidth,
        'maskHeight': maskHeight,
        'maskBytes': maskBytes,
        'originBytes': originBytes,
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

  Future<Uint8List> convertMaskToColor({
    required Uint8List maskBytes,
    required int width,
    required int height,
  }) async {
    final port = ReceivePort();

    /// Spawning an isolate
    Isolate.spawn<Map<String, dynamic>>(
      _isolateConvertMaskToColor,
      {
        // 'lengthAddress': image.byteLength.address,
        'sendPort': port.sendPort,
        'width': width,
        'height': height,
        'maskBytes': maskBytes,
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

  Future<Uint8List> threshHoldAcneMaskBytes({
    required Uint8List maskBytes,
    required int width,
    required int height,
  }) async {
    final port = ReceivePort();

    /// Spawning an isolate
    Isolate.spawn<Map<String, dynamic>>(
      _isolateThreshHoldAcneMaskBytes,
      {
        // 'lengthAddress': image.byteLength.address,
        'sendPort': port.sendPort,
        'maskBytes': maskBytes,
        'maskWidth': width,
        'maskHeight': height,
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

  Future<int> threshHoldAcneIndexMaskBytesToMat({
    required Uint8List maskBytes,
    required int width,
    required int height,
    required int index,
  }) async {
    final port = ReceivePort();

    /// Spawning an isolate
    Isolate.spawn<Map<String, dynamic>>(
      _isolateThreshHoldAcneIndexMaskBytesToMat,
      {
        'sendPort': port.sendPort,
        'maskBytes': maskBytes,
        'width': width,
        'height': height,
        'index': index,
      },
      onError: port.sendPort,
      // onExit: port.sendPort,
    );

    final int? matAddress = await port.first as int?;

    if (matAddress == null) {
      throw Exception('Can not create cv:Mat pointer');
    }

    return matAddress;
  }
}

void _isolateThreshHoldAcneMaskBytes(Map<String, dynamic> data) {
  final Uint8List maskBytes = data['maskBytes'];
  final SendPort sendPort = data['sendPort'];
  final int maskWidth = data['maskWidth'];
  final int maskHeight = data['maskHeight'];
  final maskPointer = _intListToArray(maskBytes);

  Pointer<Int32> imgByteLength = malloc.allocate<Int32>(sizeOf<Int32>());

  Pointer<Uint8> resultPtr = threshHoldAcneMaskBytes(
      maskPointer, imgByteLength, maskWidth, maskHeight);

  // for (int i = 0; i < imgByteLength.value; i++) {
  //   int value = resultPtr.elementAt(i).value;
  //
  //   if (value > 0) {
  //     print(value);
  //   }
  // }

  Uint8List imageBytes = resultPtr.asTypedList(imgByteLength.value);

  Uint8List copyBytes = Uint8List.fromList(imageBytes);

  malloc.free(imgByteLength);
  malloc.free(maskPointer);
  malloc.free(resultPtr);

  sendPort.send(copyBytes);
}
// threshHoldAcneIndexMaskBytesToMat

void _isolateThreshHoldAcneIndexMaskBytesToMat(Map<String, dynamic> data) {
  final Uint8List maskBytes = data['maskBytes'];

  final int width = data['width'];
  final int height = data['height'];
  final int index = data['index'];

  final SendPort sendPort = data['sendPort'];

  final maskPointer = _intListToArray(maskBytes);

  // Pointer<Int32> imgByteLength = malloc.allocate<Int32>(sizeOf<Int32>());

  Pointer resultPtr =
      threshHoldAcneIndexMaskBytesToMat(maskPointer, width, height, index);

  // Uint8List imageBytes = resultPtr.asTypedList(imgByteLength.value);

  // Uint8List copyBytes = Uint8List.fromList(imageBytes);

  // malloc.free(imgByteLength);
  malloc.free(maskPointer);
  // malloc.free(resultPtr);

  sendPort.send(resultPtr.address);
}

void _isolateConvertMaskToColor(Map<String, dynamic> data) {
  final Uint8List maskBytes = data['maskBytes'];

  final int width = data['width'];
  final int height = data['height'];

  final SendPort sendPort = data['sendPort'];

  final maskPointer = _intListToArray(maskBytes);

  Pointer<Int32> imgByteLength = malloc.allocate<Int32>(sizeOf<Int32>());

  Pointer<Uint8> resultPtr =
      convertMaskToColor(maskPointer, imgByteLength, width, height);

  Uint8List imageBytes = resultPtr.asTypedList(imgByteLength.value);

  Uint8List copyBytes = Uint8List.fromList(imageBytes);

  malloc.free(imgByteLength);
  malloc.free(maskPointer);
  malloc.free(resultPtr);

  sendPort.send(copyBytes);
}

void _isolateApplyAcneMaskColorJpg(Map<String, dynamic> data) {
  final Uint8List maskBytes = data['maskBytes'];
  final Uint8List originBytes = data['originBytes'];
  final int originWidth = data['originWidth'];
  final int originHeight = data['originHeight'];
  final int maskWidth = data['maskWidth'];
  final int maskHeight = data['maskHeight'];

  final SendPort sendPort = data['sendPort'];

  final maskPointer = _intListToArray(maskBytes);
  final originPointer = _intListToArray(originBytes);

  Pointer<Int32> imgByteLength = malloc.allocate<Int32>(sizeOf<Int32>());

  imgByteLength.value = originBytes.length;

  Pointer<Uint8> resultPtr = applyAcneMaskColorJpg(maskPointer, originPointer,
      imgByteLength, maskWidth, maskHeight, originWidth, originHeight);

  Uint8List imageBytes = resultPtr.asTypedList(imgByteLength.value);

  Uint8List copyBytes = Uint8List.fromList(imageBytes);

  malloc.free(imgByteLength);
  malloc.free(maskPointer);
  malloc.free(resultPtr);
  malloc.free(originPointer);

  sendPort.send(copyBytes);
}

void _isolateApplyAcneMaskColorV2(Map<String, dynamic> data) {
  final Uint8List maskBytes = data['maskBytes'];
  final Uint8List originBytes = data['originBytes'];
  final int originWidth = data['originWidth'];
  final int originHeight = data['originHeight'];
  final int maskWidth = data['maskWidth'];
  final int maskHeight = data['maskHeight'];

  final SendPort sendPort = data['sendPort'];

  final maskPointer = _intListToArray(maskBytes);
  final originPointer = _intListToArray(originBytes);

  Pointer<Int32> imgByteLength = malloc.allocate<Int32>(sizeOf<Int32>());

  imgByteLength.value = originBytes.length;

  Pointer<Uint8> resultPtr = applyAcneMaskColorV2(maskPointer, originPointer,
      imgByteLength, maskWidth, maskHeight, originWidth, originHeight);

  Uint8List imageBytes = resultPtr.asTypedList(imgByteLength.value);

  Uint8List copyBytes = Uint8List.fromList(imageBytes);

  malloc.free(imgByteLength);
  malloc.free(maskPointer);
  malloc.free(resultPtr);
  malloc.free(originPointer);

  sendPort.send(copyBytes);
}

void _isolateApplyAcneMaskColor(Map<String, dynamic> data) {
  final Uint8List maskBytes = data['maskBytes'];
  final int originAddress = data['originAddress'];
  final int width = data['width'];
  final int height = data['height'];
  final SendPort sendPort = data['sendPort'];

  final maskPointer = _intListToArray(maskBytes);

  final originPointer = Pointer.fromAddress(originAddress);

  Pointer<Int32> imgByteLength = malloc.allocate<Int32>(sizeOf<Int32>());

  Pointer<Uint8> resultPtr = applyAcneMaskColor(
      maskPointer, originPointer, imgByteLength, width, height);

  Uint8List imageBytes = resultPtr.asTypedList(imgByteLength.value);

  Uint8List copyBytes = Uint8List.fromList(imageBytes);
  malloc.free(imgByteLength);
  malloc.free(maskPointer);
  malloc.free(resultPtr);
  sendPort.send(copyBytes);
}

Pointer<Uint8> _intListToArray(Uint8List list) {
  final Pointer<Uint8> ptr = malloc.allocate<Uint8>(list.length);
  for (var i = 0; i < list.length; i++) {
    ptr.elementAt(i).value = list[i];
  }
  return ptr;
}
