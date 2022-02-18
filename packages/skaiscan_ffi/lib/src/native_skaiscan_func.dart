import 'dart:ffi';

import 'package:skaiscan_ffi/src/native_cv_func.dart';

typedef _ApplyMaskColorPointerFunc = Pointer Function(
    Pointer maskPointer, Pointer originPointer);

typedef _CApplyMaskColorPointerFunc = Pointer Function(
    Pointer maskPointer, Pointer originPointer);

final _ApplyMaskColorPointerFunc nativeDrawRect = nativeLib
    .lookup<NativeFunction<_CApplyMaskColorPointerFunc>>(
        'apply_acne_mask_color')
    .asFunction();

typedef _CreateMaskColorDataFunc = Pointer Function(
    Pointer maskPointer, Pointer originPointer);
