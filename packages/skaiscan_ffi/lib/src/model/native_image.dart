import 'dart:ffi';

class NativeImage {
  final Pointer matPointer;
  final Pointer<Int32> byteLength;

  const NativeImage({
    required this.matPointer,
    required this.byteLength,
  });
}
