import 'dart:ffi';
import 'dart:io';

///link to native library
final DynamicLibrary nativeLib = Platform.isAndroid
    ? DynamicLibrary.open("libnative-lib.so")
    : DynamicLibrary.process();

typedef _DrawRectMatPointerFunc = Pointer Function(
    Pointer, int x, int y, int width, int height);

typedef _CDrawRectMatPointerFunc = Pointer Function(
    Pointer, Int32 x, Int32 y, Int32 width, Int32 height);

final _DrawRectMatPointerFunc nativeDrawRect = nativeLib
    .lookup<NativeFunction<_CDrawRectMatPointerFunc>>('draw_rectangle')
    .asFunction();

final Pointer<Uint8> Function(Pointer mat)
    convertMatPointerToBytes = nativeLib
        .lookup<
            NativeFunction<
                Pointer<Uint8> Function(
                    Pointer mat)>>('convert_mat_to_bytes')
        .asFunction();

final Pointer<Void> Function(Pointer<Uint8> img, Pointer<Int32> imgLengthBytes)
    createMatPointerFromBytes = nativeLib
        .lookup<
            NativeFunction<
                Pointer<Void> Function(Pointer<Uint8>,
                    Pointer<Int32>)>>('create_mat_pointer_from_bytes')
        .asFunction();
