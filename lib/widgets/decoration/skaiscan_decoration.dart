import 'dart:ui';

import 'package:flutter/widgets.dart';

class SkaiscanDottedDecoration extends Decoration {
  final SkaiscanLinePosition linePosition;
  final SkaiscanShape shape;
  final Color color;
  final BorderRadius? borderRadius;
  final List<int> dash;
  final double strokeWidth;
  final int divideSpace;

  const SkaiscanDottedDecoration( {
    this.divideSpace = 4,
    this.shape = SkaiscanShape.line,
    this.linePosition = SkaiscanLinePosition.bottom,
    this.color = const Color(0xFF9E9E9E),
    this.borderRadius,
    this.dash = const <int>[5, 5],
    this.strokeWidth = 1,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _DottedDecotatorPainter(
        shape, linePosition, color, borderRadius, dash, strokeWidth,divideSpace);
  }
}

class _DottedDecotatorPainter extends BoxPainter {
  SkaiscanLinePosition linePosition;
  SkaiscanShape shape;
  Color color;
  BorderRadius? borderRadius;
  List<int> dash;
  double strokeWidth;
  final int divideSpace;
  _DottedDecotatorPainter(this.shape, this.linePosition, this.color,
      this.borderRadius, this.dash, this.strokeWidth, this.divideSpace) {
    borderRadius = borderRadius ?? BorderRadius.circular(0);
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    Path outPath = Path();
    if (shape == SkaiscanShape.line) {
      if (linePosition == SkaiscanLinePosition.left) {
        outPath.moveTo(offset.dx, offset.dy);
        outPath.lineTo(offset.dx, offset.dy + configuration.size!.height);
      } else if (linePosition == SkaiscanLinePosition.top) {
        outPath.moveTo(offset.dx, offset.dy);
        outPath.lineTo(offset.dx + configuration.size!.width, offset.dy);
      } else if (linePosition == SkaiscanLinePosition.right) {
        outPath.moveTo(offset.dx + configuration.size!.width, offset.dy);
        outPath.lineTo(offset.dx + configuration.size!.width,
            offset.dy + configuration.size!.height);
      } else {
        outPath.moveTo(offset.dx, offset.dy + configuration.size!.height);
        outPath.lineTo(offset.dx + configuration.size!.width,
            offset.dy + configuration.size!.height);
      }
    } else if (shape == SkaiscanShape.box) {
      RRect rect = RRect.fromLTRBAndCorners(
        offset.dx,
        offset.dy,
        offset.dx + configuration.size!.width,
        offset.dy + configuration.size!.height,
        bottomLeft: borderRadius!.bottomLeft,
        bottomRight: borderRadius!.bottomRight,
        topLeft: borderRadius!.topLeft,
        topRight: borderRadius!.topRight,
      );
      outPath.addRRect(rect);
    } else if (shape == SkaiscanShape.circle) {
      outPath.addOval(Rect.fromLTWH(offset.dx, offset.dy,
          configuration.size!.width, configuration.size!.height));
    }

    PathMetrics metrics = outPath.computeMetrics(forceClosed: false);
    Path drawPath = Path();

    for (PathMetric me in metrics) {
      double totalLength = me.length;
      int index = -1;

      for (double start = 0; start < totalLength;) {
        double to = start + dash[(++index) % dash.length];
        to = to > totalLength ? totalLength : to;
        bool isEven = index % divideSpace == 0;
        if (isEven) {
          drawPath.addPath(
              me.extractPath(start, to, startWithMoveTo: true), Offset.zero);
        }
        start = to;
      }
    }

    canvas.drawPath(
        drawPath,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth);
  }
}

enum SkaiscanLinePosition { left, top, right, bottom }
enum SkaiscanShape { line, box, circle }
