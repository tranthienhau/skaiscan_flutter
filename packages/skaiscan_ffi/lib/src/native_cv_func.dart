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

final Pointer<Uint8> Function(Pointer mat, Pointer<Int32>)
    convertMatPointerToBytes = nativeLib
        .lookup<
            NativeFunction<
                Pointer<Uint8> Function(
                    Pointer mat, Pointer<Int32>)>>('convert_mat_to_bytes')
        .asFunction();

final Pointer<Void> Function(Pointer<Uint8> img, Pointer<Int32> imgLengthBytes)
    createMatPointerFromBytes = nativeLib
        .lookup<
            NativeFunction<
                Pointer<Void> Function(Pointer<Uint8>,
                    Pointer<Int32>)>>('create_mat_pointer_from_bytes')
        .asFunction();

final Pointer<Uint8> Function(
        Pointer<Uint8> img,
        Pointer<Int32> imgLengthBytes,
        Pointer<Int32> flip,
        Pointer<Int32> resizeWidth,
        Pointer<Int32> resizeHeight)
    nativeRotate90CounterClockwiseFlipResizeBytes = nativeLib
        .lookup<
                NativeFunction<
                    Pointer<Uint8> Function(Pointer<Uint8>, Pointer<Int32>,
                        Pointer<Int32>, Pointer<Int32>, Pointer<Int32>)>>(
            'rotate_90_counter_clockwise_flip_resize_bytes')
        .asFunction();

final Pointer<Void> Function(
        Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, int, int, int, int)
    createMatFromYUV420 = nativeLib
        .lookup<
            NativeFunction<
                Pointer<Void> Function(
                    Pointer<Uint8>,
                    Pointer<Uint8>,
                    Pointer<Uint8>,
                    Int32,
                    Int32,
                    Int32,
                    Int32)>>('create_mat_from_yuv')
        .asFunction();

// final Pointer<Uint32> Function(
//         Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, int, int, int, int)
//     nativeConvertYUV420ToRBGA = nativeLib
//         .lookup<
//             NativeFunction<
//                 Pointer<Uint32> Function(
//                     Pointer<Uint8>,
//                     Pointer<Uint8>,
//                     Pointer<Uint8>,
//                     Int32,
//                     Int32,
//                     Int32,
//                     Int32)>>('convert_yuv_to_rbga_bytes')
//         .asFunction();

final Pointer<Void> Function(
        Pointer<Uint8> bytes, bool isYUV, int rotation, int width, int height)
    converCameraImageToMat = nativeLib
        .lookup<
            NativeFunction<
                Pointer<Void> Function(Pointer<Uint8>, Bool, Int32, Int32,
                    Int32)>>('convert_camera_image_to_mat')
        .asFunction();

// final Pointer<Void> Function(
//     Pointer<Uint8> bytes, bool isYUV, int rotation, int width, int height)
// converCameraImageToMat = nativeLib
//     .lookup<
//     NativeFunction<
//         Pointer<Void> Function(Pointer<Uint8>, Bool, Int32, Int32,
//             Int32)>>('convert_camera_image_to_mat')
//     .asFunction();
//
// create_mat_from_bgra_bytes

// final Pointer<Void> Function(Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>,
//         bool, int, int, int, int) converCameraImageToMatV2 =
//     nativeLib
//         .lookup<
//             NativeFunction<
//                 Pointer<Void> Function(
//                     Pointer<Uint8>,
//                     Pointer<Uint8>,
//                     Pointer<Uint8>,
//                     Bool,
//                     Int32,
//                     Int32,
//                     Int32,
//                     Int32)>>('convert_camera_image_to_mat_v2')
//         .asFunction();
final Pointer<Uint8> Function(Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>,
        Pointer<Int32>, bool, int, int, int, int) converCameraImageToMatV3 =
    nativeLib
        .lookup<
            NativeFunction<
                Pointer<Uint8> Function(
                    Pointer<Uint8>,
                    Pointer<Uint8>,
                    Pointer<Uint8>,
                    Pointer<Int32>,
                    Bool,
                    Int32,
                    Int32,
                    Int32,
                    Int32)>>('convert_camera_image_to_mat_v3')
        .asFunction();

final Pointer<Uint8> Function(Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>,
    Pointer<Int32>, bool, int, int, int, int) converCameraImageToJpgBytes =
nativeLib
    .lookup<
    NativeFunction<
        Pointer<Uint8> Function(
            Pointer<Uint8>,
            Pointer<Uint8>,
            Pointer<Uint8>,
            Pointer<Int32>,
            Bool,
            Int32,
            Int32,
            Int32,
            Int32)>>('convert_camera_image_to_bytes_jpg')
    .asFunction();

final Pointer Function(Pointer<Uint8> bytes, int width, int height)
    converRBGABytesToMat = nativeLib
        .lookup<NativeFunction<Pointer Function(Pointer<Uint8>, Int32, Int32)>>(
            'create_mat_from_bgra_bytes')
        .asFunction();

final Pointer<Uint8> Function(Pointer<Uint8>, Pointer<Int32>, int, int, int, int)
    cropImageBytes = nativeLib
        .lookup<
            NativeFunction<
                Pointer<Uint8> Function(Pointer<Uint8>, Pointer<Int32>, Int32,
                    Int32, Int32, Int32)>>('crop_image_bytes')
        .asFunction();

final Pointer<Uint8> Function(Pointer<Uint8>, Pointer<Int32>, int, int, int, int)
cropImageJpgBytes = nativeLib
    .lookup<
    NativeFunction<
        Pointer<Uint8> Function(Pointer<Uint8>, Pointer<Int32>, Int32,
            Int32, Int32, Int32)>>('crop_image_jpg_bytes')
    .asFunction();