import 'dart:ffi';

import 'package:flutter/material.dart';

class NativeMaskColorData extends Struct {
  @Int32()
  external int index;

  @Int32()
  external int red;

  @Int32()
  external int blue;

  @Int32()
  external int green;
}

class MaskColorData {
  final int index;

  final Color color;

  const MaskColorData({
    required this.index,
    required this.color,
  });

  MaskColorData copyWith({
    int? index,
    Color? color,
  }) {
    return MaskColorData(
      index: index ?? this.index,
      color: color ?? this.color,
    );
  }
}
