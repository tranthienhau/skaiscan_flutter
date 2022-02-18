import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:logger/logger.dart';
import 'package:skaiscan_ffi/skaiscan_ffi.dart';

class NativeSkaiscan {
  static final NativeSkaiscan _instance = NativeSkaiscan._internal();

  factory NativeSkaiscan() {
    return _instance;
  }

  NativeSkaiscan._internal();

  final Logger logger = Logger();

  Future<Pointer> _createNativeMaskColorPoiter(List<MaskColorData> maskColors) async {
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

  // Future<NativeImage> applyMask(NativeImage mask, NativeImage origin, List<MaskColorData> maskColors) async {
  //
  //
  // }
}

void _isolateApplyMask(Map<String, dynamic> data) {
  final int maskAddress = data['maskAddress'];
  final int originAddress = data['originAddress'];

  final SendPort sendPort = data['sendPort'];

  final maskPointer = Pointer.fromAddress(maskAddress);

  final originPointer = Pointer.fromAddress(originAddress);

  Pointer<Int32> imgByteLength = malloc.allocate<Int32>(sizeOf<Int32>());

  // sendPort.send({
  //   'matAddress': matPointer.address,
  //   'byteLengthAddress': imgByteLength.address,
  // });
}
