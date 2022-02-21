class AnchorOption {
  final int inputSizeWidth;
  final int inputSizeHeight;
  final double minScale;
  final double maxScale;
  final double anchorOffsetX;
  final double anchorOffsetY;
  final int numLayers;
  late final List<int> featureMapWidth;
  late final List<int> featureMapHeight;
  late final List<int> strides;
  final List<double> aspectRatios;
  final bool reduceBoxesInLowestLayer;
  final double interpolatedScaleAspectRatio;
  final bool fixedAnchorSize;

  AnchorOption({
    this.inputSizeWidth = 0,
    this.inputSizeHeight = 0,
    this.minScale = 0,
    this.maxScale = 0,
    this.anchorOffsetX = 0,
    this.anchorOffsetY = 0,
    this.numLayers = 0,
    this.featureMapWidth = const [],
    this.featureMapHeight = const [],
    this.strides = const [],
    this.aspectRatios = const [],
    this.reduceBoxesInLowestLayer = false,
    this.interpolatedScaleAspectRatio = 0,
    this.fixedAnchorSize = false,
  });

  int get stridesSize {
    return strides.length;
  }

  int get featureMapHeightSize {
    return featureMapHeight.length;
  }

  int get featureMapWidthSize {
    return featureMapWidth.length;
  }
}

class Anchor {
  final double xCenter;
  final double yCenter;
  final double h;
  final double w;

  Anchor(this.xCenter, this.yCenter, this.h, this.w);
}
