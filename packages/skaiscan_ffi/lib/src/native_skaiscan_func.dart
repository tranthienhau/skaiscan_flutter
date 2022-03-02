import 'dart:ffi';

import 'package:skaiscan_ffi/src/native_cv_func.dart';

typedef _ApplyMaskColorPointerFunc = Pointer<Uint8> Function(
    Pointer<Uint8> maskPointer, Pointer originPointer, Pointer<Int32>, int, int);

typedef _CApplyMaskColorPointerFunc = Pointer<Uint8> Function(
    Pointer<Uint8> maskPointer, Pointer originPointer, Pointer<Int32>, Int32, Int32);

final _ApplyMaskColorPointerFunc applyAcneMaskColor = nativeLib
    .lookup<NativeFunction<_CApplyMaskColorPointerFunc>>(
        'apply_acne_mask_color')
    .asFunction();

typedef _ConvertMaskToColorFunc = Pointer<Uint8> Function(
    Pointer<Uint8> maskPointer, Pointer<Int32>, int, int);

typedef _CConvertMaskToColorFunc = Pointer<Uint8> Function(
    Pointer<Uint8> maskPointer, Pointer<Int32>, Int32, Int32);

final _ConvertMaskToColorFunc convertMaskToColor = nativeLib
    .lookup<NativeFunction<_CConvertMaskToColorFunc>>(
    'convert_mask_to_color')
    .asFunction();



typedef _ApplyAcneMaskColorFunc = Pointer<Uint8> Function(
    Pointer<Uint8> maskPointer, Pointer<Uint8> originPointer, Pointer<Int32>, int, int ,int, int);

typedef _CApplyAcneMaskColorFunc = Pointer<Uint8> Function(
    Pointer<Uint8> maskPointer, Pointer<Uint8> originPointer, Pointer<Int32>, Int32, Int32, Int32, Int32);

final _ApplyAcneMaskColorFunc applyAcneMaskColorV2 = nativeLib
    .lookup<NativeFunction<_CApplyAcneMaskColorFunc>>(
    'apply_acne_mask_color_v2')
    .asFunction();