import 'dart:ffi';

class CvRectangle {
  final int left;
  final int top;
  final int width;
  final int height;

  const CvRectangle({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  CvRectangle copyWith({
    int? x,
    int? y,
    int? width,
    int? height,
  }) {
    return CvRectangle(
      left: x ?? this.left,
      top: y ?? this.top,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}

