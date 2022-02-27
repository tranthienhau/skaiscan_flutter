class OptionsFace {
  late final int numClasses;
  late final int numBoxes;
  late final int numCoords;
  late final int keypointCoordOffset;
  final List<int> ignoreClasses;
  final double scoreClippingThresh;
  late final double minScoreThresh;
  final int numKeypoints;
  final int numValuesPerKeypoint;
  final int boxCoordOffset;
  final double xScale;
  final double yScale;
  final double wScale;
  final double hScale;
  final bool applyExponentialOnBoxSize;
  final bool reverseOutputOrder;
  final bool sigmoidScore;
  final bool flipVertically;

  OptionsFace({
    this.numClasses = 0,
    this.numBoxes = 0,
    this.numCoords = 0,
    this.keypointCoordOffset = 0,
    this.ignoreClasses = const [],
    this.scoreClippingThresh = 0,
    this.minScoreThresh = 0,
    this.numKeypoints = 0,
    this.numValuesPerKeypoint = 2,
    this.boxCoordOffset = 0,
    this.xScale = 0.0,
    this.yScale = 0.0,
    this.wScale = 0.0,
    this.hScale = 0.0,
    this.applyExponentialOnBoxSize = false,
    this.reverseOutputOrder = true,
    this.sigmoidScore = true,
    this.flipVertically = false,
  });
}

class Detection {
  final double score;
  final int classID;
  final double xMin;
  final double yMin;
  final double width;
  final double height;

  Detection(
    this.score,
    this.classID,
    this.xMin,
    this.yMin,
    this.width,
    this.height,
  );
}
