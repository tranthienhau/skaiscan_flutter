import 'dart:ffi';

class CvRectangle {
  final int x;
  final int y;
  final int width;
  final int height;

  const CvRectangle({
    required this.x,
    required this.y,
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
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}

