// import 'dart:ffi';
// import 'dart:io';
// import 'dart:math';
// import 'dart:typed_data';
//
// import 'package:camera/camera.dart';
//
// // import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:image/image.dart' as imglib;
// import 'package:skaiscan/services/image_converter.dart';
// import 'package:skaiscan/services/model/anchor_option.dart';
// import 'package:skaiscan/services/model/options_face.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// // import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
//
// extension FloatArrayFill on Array<Float> {
//   void fillFromList(List<double> list) {
//     for (var i = 0; i < list.length; i++) {
//       this[i] = list[i];
//     }
//   }
// }
//
// class MLService {
//   late Interpreter _interpreter;
//   double threshold = 0.5;
//
//   Uint8List? _predictedData;
//   late ImageProcessor _imageProcessor;
//
//   Uint8List? get predictedData => _predictedData;
//
//   Future loadModel() async {
//     late Delegate delegate;
//     try {
//       if (Platform.isAndroid) {
//         // delegate = GpuDelegateV2(
//         //     options: GpuDelegateOptionsV2(
//         //   // experimentalFlags: false,
//         //   inferencePreference: TfLiteGpuInferenceUsage.fastSingleAnswer,
//         //   inferencePriority1: TfLiteGpuInferencePriority.minLatency,
//         //   inferencePriority2: TfLiteGpuInferencePriority.auto,
//         //   inferencePriority3: TfLiteGpuInferencePriority.auto,
//         //   isPrecisionLossAllowed: false,
//         // ));
//       } else if (Platform.isIOS) {
//         delegate = GpuDelegate(
//           options: GpuDelegateOptions(
//               allowPrecisionLoss: true,
//               enableQuantization: true,
//               waitType: TFLGpuDelegateWaitType.active),
//         );
//       }
//
//       final options = InterpreterOptions();
//       options.threads = 2;
//       // var interpreterOptions = InterpreterOptions()..addDelegate(delegate);
//
//       _interpreter = await Interpreter.fromAsset(
//           'model/face_detection_front.tflite',
//           options: options);
//       // NormalizeOp normalizeInput = NormalizeOp(127.5, 127.5);
//
//       // List<int> inputShape = _interpreter.getInputTensor(0).shape;
//       // _imageProcessor = ImageProcessorBuilder()
//       //     .add(ResizeOp(
//       //         inputShape[1], inputShape[2], ResizeMethod.NEAREST_NEIGHBOUR))
//       //     .add(normalizeInput)
//       //     .build();
//
//       print('model loaded successfully');
//     } catch (e) {
//       print('Failed to load model.');
//       print(e);
//     }
//   }
//
//   Future<void> detectFace(imglib.Image image) async {
//     // TensorImage tensorImage = TensorImage.fromImage(image);
//     // tensorImage = _imageProcessor.process(tensorImage);
//
//     TensorBuffer output0 = TensorBuffer.createFixedSize(
//         _interpreter.getOutputTensor(0).shape,
//         _interpreter.getOutputTensor(0).type);
//     TensorBuffer output1 = TensorBuffer.createFixedSize(
//         _interpreter.getOutputTensor(1).shape,
//         _interpreter.getOutputTensor(1).type);
//
//     // final inputData = [
//     //   List.generate(
//     //     128,
//     //         (index) => List.generate(
//     //           128,
//     //           (index) => List.generate(3, (index) => 0.0),
//     //     ),
//     //   ),
//     // ];
//
//     final modelContentImage = imglib.copyResize(image, width: 128, height: 128);
//
//     final modelContentInput =
//         _imageToByteListUInt8(modelContentImage, 128, 0, 255);
//
//     final inputs = [modelContentInput];
//
//     // final inputs = <Object>[inputData];
//
//     Map<int, ByteBuffer> outputs = {0: output0.buffer, 1: output1.buffer};
//
//     // _interpreter.runForMultipleInputs([tensorImage.buffer], outputs);
//
//     _interpreter.runForMultipleInputs(inputs, outputs);
//
//     List<double> regression = output0.getDoubleList();
//
//     List<double> classificators = output1.getDoubleList();
//   }
//
//   Uint8List _imageToByteListUInt8(
//     imglib.Image image,
//     int inputSize,
//     double mean,
//     double std,
//   ) {
//     final convertedBytes = Float32List(1 * inputSize * inputSize * 3);
//     final buffer = Float32List.view(convertedBytes.buffer);
//     int pixelIndex = 0;
//
//     for (int i = 0; i < inputSize; i++) {
//       for (int j = 0; j < inputSize; j++) {
//         var pixel = image.getPixel(j, i);
//         buffer[pixelIndex++] = (imglib.getRed(pixel) - mean) / std;
//         buffer[pixelIndex++] = (imglib.getGreen(pixel) - mean) / std;
//         buffer[pixelIndex++] = (imglib.getBlue(pixel) - mean) / std;
//       }
//     }
//     return convertedBytes.buffer.asUint8List();
//   }
//
//   List<Detection> convertToDetections(
//       List<double> rawBoxes,
//       List<Anchor> anchors,
//       List<double> detectionScores,
//       List<int> detectionClasses,
//       OptionsFace options) {
//     List<Detection> _outputDetections = [];
//     for (int i = 0; i < options.numBoxes; i++) {
//       if (detectionScores[i] < options.minScoreThresh) continue;
//       int boxOffset = 0;
//       Array<Float> boxData = decodeBox(rawBoxes, i, anchors, options);
//       Detection detection = convertToDetection(
//           boxData[boxOffset + 0],
//           boxData[boxOffset + 1],
//           boxData[boxOffset + 2],
//           boxData[boxOffset + 3],
//           detectionScores[i],
//           detectionClasses[i],
//           options.flipVertically);
//       _outputDetections.add(detection);
//     }
//     return _outputDetections;
//   }
//
//   List<Anchor> getAnchors(AnchorOption options) {
//     List<Anchor> _anchors = [];
//     if (options.stridesSize != options.numLayers) {
//       print('strides_size and num_layers must be equal.');
//       return [];
//     }
//     int layerID = 0;
//     while (layerID < options.stridesSize) {
//       List<double> anchorHeight = [];
//       List<double> anchorWidth = [];
//       List<double> aspectRatios = [];
//       List<double> scales = [];
//
//       int lastSameStrideLayer = layerID;
//       while (lastSameStrideLayer < options.stridesSize &&
//           options.strides[lastSameStrideLayer] == options.strides[layerID]) {
//         double scale = options.minScale +
//             (options.maxScale - options.minScale) *
//                 1.0 *
//                 lastSameStrideLayer /
//                 (options.stridesSize - 1.0);
//         if (lastSameStrideLayer == 0 && options.reduceBoxesInLowestLayer) {
//           aspectRatios.add(1.0);
//           aspectRatios.add(2.0);
//           aspectRatios.add(0.5);
//           scales.add(0.1);
//           scales.add(scale);
//           scales.add(scale);
//         } else {
//           for (int i = 0; i < options.aspectRatios.length; i++) {
//             aspectRatios.add(options.aspectRatios[i]);
//             scales.add(scale);
//           }
//
//           if (options.interpolatedScaleAspectRatio > 0.0) {
//             double scaleNext = 0.0;
//             if (lastSameStrideLayer == options.stridesSize - 1) {
//               scaleNext = 1.0;
//             } else {
//               scaleNext = options.minScale +
//                   (options.maxScale - options.minScale) *
//                       1.0 *
//                       (lastSameStrideLayer + 1) /
//                       (options.stridesSize - 1.0);
//             }
//             scales.add(sqrt(scale * scaleNext));
//             aspectRatios.add(options.interpolatedScaleAspectRatio);
//           }
//         }
//         lastSameStrideLayer++;
//       }
//       for (int i = 0; i < aspectRatios.length; i++) {
//         double ratioSQRT = sqrt(aspectRatios[i]);
//         anchorHeight.add(scales[i] / ratioSQRT);
//         anchorWidth.add(scales[i] * ratioSQRT);
//       }
//       int featureMapHeight = 0;
//       int featureMapWidth = 0;
//       if (options.featureMapHeightSize > 0) {
//         featureMapHeight = options.featureMapHeight[layerID];
//         featureMapWidth = options.featureMapWidth[layerID];
//       } else {
//         int stride = options.strides[layerID];
//         featureMapHeight = (1.0 * options.inputSizeHeight / stride).ceil();
//         featureMapWidth = (1.0 * options.inputSizeWidth / stride).ceil();
//       }
//
//       for (int y = 0; y < featureMapHeight; y++) {
//         for (int x = 0; x < featureMapWidth; x++) {
//           for (int anchorID = 0; anchorID < anchorHeight.length; anchorID++) {
//             double xCenter =
//                 (x + options.anchorOffsetX) * 1.0 / featureMapWidth;
//             double yCenter =
//                 (y + options.anchorOffsetY) * 1.0 / featureMapHeight;
//             double w = 0;
//             double h = 0;
//             if (options.fixedAnchorSize) {
//               w = 1.0;
//               h = 1.0;
//             } else {
//               w = anchorWidth[anchorID];
//               h = anchorHeight[anchorID];
//             }
//             _anchors.add(Anchor(xCenter, yCenter, h, w));
//           }
//         }
//       }
//       layerID = lastSameStrideLayer;
//     }
//     return _anchors;
//   }
//
//   List<Detection> process({
//     required OptionsFace options,
//     required List<double> rawScores,
//     required List<double> rawBoxes,
//     required List<Anchor> anchors,
//   }) {
//     List<double> detectionScores = [];
//     List<int> detectionClasses = [];
//
//     int boxes = options.numBoxes;
//     for (int i = 0; i < boxes; i++) {
//       int classId = -1;
//       double maxScore = double.minPositive;
//       for (int scoreIdx = 0; scoreIdx < options.numClasses; scoreIdx++) {
//         double score = rawScores[i * options.numClasses + scoreIdx];
//         if (options.sigmoidScore) {
//           if (options.scoreClippingThresh > 0) {
//             if (score < -options.scoreClippingThresh) {
//               score = -options.scoreClippingThresh;
//             }
//             if (score > options.scoreClippingThresh) {
//               score = options.scoreClippingThresh;
//             }
//             score = 1.0 / (1.0 + exp(-score));
//             if (maxScore < score) {
//               maxScore = score;
//               classId = scoreIdx;
//             }
//           }
//         }
//       }
//       detectionClasses.add(classId);
//       detectionScores.add(maxScore);
//     }
//     List<Detection> detections = convertToDetections(
//         rawBoxes, anchors, detectionScores, detectionClasses, options);
//     return detections;
//   }
//
//   Array<Float> decodeBox(
//       List<double> rawBoxes, int i, List<Anchor> anchors, OptionsFace options) {
//     Array<Float> boxData =
//         Array<Float>.multi(List.generate(options.numCoords, (i) => 0));
//
//     int boxOffset = i * options.numCoords + options.boxCoordOffset;
//     double yCenter = rawBoxes[boxOffset];
//     double xCenter = rawBoxes[boxOffset + 1];
//     double h = rawBoxes[boxOffset + 2];
//     double w = rawBoxes[boxOffset + 3];
//     if (options.reverseOutputOrder) {
//       xCenter = rawBoxes[boxOffset];
//       yCenter = rawBoxes[boxOffset + 1];
//       w = rawBoxes[boxOffset + 2];
//       h = rawBoxes[boxOffset + 3];
//     }
//
//     xCenter = xCenter / options.xScale * anchors[i].w + anchors[i].xCenter;
//     yCenter = yCenter / options.yScale * anchors[i].h + anchors[i].yCenter;
//
//     if (options.applyExponentialOnBoxSize) {
//       h = exp(h / options.hScale) * anchors[i].h;
//       w = exp(w / options.wScale) * anchors[i].w;
//     } else {
//       h = h / options.hScale * anchors[i].h;
//       w = w / options.wScale * anchors[i].w;
//     }
//
//     double yMin = yCenter - h / 2.0;
//     double xMin = xCenter - w / 2.0;
//     double yMax = yCenter + h / 2.0;
//     double xMax = xCenter + w / 2.0;
//
//     boxData[0] = yMin;
//     boxData[1] = xMin;
//     boxData[2] = yMax;
//     boxData[3] = xMax;
//
//     if (options.numKeypoints > 0) {
//       for (int k = 0; k < options.numKeypoints; k++) {
//         int offset = i * options.numCoords +
//             options.keypointCoordOffset +
//             k * options.numValuesPerKeypoint;
//         double keyPointY = rawBoxes[offset];
//         double keyPointX = rawBoxes[offset + 1];
//
//         if (options.reverseOutputOrder) {
//           keyPointX = rawBoxes[offset];
//           keyPointY = rawBoxes[offset + 1];
//         }
//         boxData[4 + k * options.numValuesPerKeypoint] =
//             keyPointX / options.xScale * anchors[i].w + anchors[i].xCenter;
//
//         boxData[4 + k * options.numValuesPerKeypoint + 1] =
//             keyPointY / options.yScale * anchors[i].h + anchors[i].yCenter;
//       }
//     }
//     return boxData;
//   }
//
//   Detection convertToDetection(double boxYMin, double boxXMin, double boxYMax,
//       double boxXMax, double score, int classID, bool flipVertically) {
//     double _yMin;
//     if (flipVertically) {
//       _yMin = 1.0 - boxYMax;
//     } else {
//       _yMin = boxYMin;
//     }
//     return Detection(score, classID, boxXMin, _yMin, (boxXMax - boxXMin),
//         (boxXMax - boxYMin));
//   }
//
//   // List<Detection> origNms(List<Detection> detections, double threshold) {
//   //   if (detections.isEmpty) return [];
//   //   List<double> x1 = [];
//   //   List<double> x2 = [];
//   //   List<double> y1 = [];
//   //   List<double> y2 = [];
//   //   List<double> s = [];
//   //
//   //   for (final detection in detections) {
//   //     x1.add(detection.xMin);
//   //     x2.add(detection.xMin + detection.width);
//   //     y1.add(detection.yMin);
//   //     y2.add(detection.yMin + detection.height);
//   //     s.add(detection.score);
//   //   }
//   //
//   //   Array<Float> _x1 =   Array<Float>.multi([x1.length]);
//   //   _x1.fillFromList(x1);
//   //
//   //   Array<Float> _x2 =  Array<Float>.multi([x2.length]);
//   //   _x2.fillFromList(x2);
//   //   // DoubleArray _
//   //   Array<Float> _y1 = Array<Float>.multi([y1.length]);
//   //   Array<Float> _y2 =   Array<Float>.multi([y2.length]);
//   //
//   //   Array<Float> area = (_x2 - _x1) * (_y2 - _y1);
//   //   List<double> I = _quickSort(s);
//   //   List<int> positions = [];
//   //   I.forEach((element) {
//   //     positions.add(s.indexOf(element));
//   //   });
//   //
//   //   List<int> ind0 = positions.sublist(positions.length - 1, positions.length);
//   //   List<int> ind1 = positions.sublist(0, positions.length - 1);
//   //
//   //   List<int> pick = [];
//   //   while (I.length > 0) {
//   //     Array xx1 = _maximum(_itemIndex(_x1, ind0)[0], _itemIndex(_x1, ind1));
//   //     Array yy1 = _maximum(_itemIndex(_y1, ind0)[0], _itemIndex(_y1, ind1));
//   //     Array xx2 = _maximum(_itemIndex(_x2, ind0)[0], _itemIndex(_x2, ind1));
//   //     Array yy2 = _maximum(_itemIndex(_y2, ind0)[0], _itemIndex(_y2, ind1));
//   //     Array w = _maximum(0.0, xx2 - xx1);
//   //     Array h = _maximum(0.0, yy2 - yy1);
//   //     Array inter = w * h;
//   //     Array o = inter /
//   //         (_sum(_itemIndex(area, ind0)[0], _itemIndex(area, ind1)) - inter);
//   //     pick.add(ind0[0]);
//   //     I = o.where((element) => element <= threshold).toList();
//   //   }
//   //   return [detections[pick[0]]];
//   // }
//   //
//   // Array _sum(double a, Array b) {
//   //   List<double> _temp = [];
//   //   b.forEach((element) {
//   //     _temp.add(a + element);
//   //   });
//   //   return new Array(_temp);
//   // }
//   //
//   // Array<Float> _maximum(double value, Array<Float> itemIndex) {
//   //
//   //   List<double> _temp = [];
//   //   itemIndex.forEach((element) {
//   //     if (value > element)
//   //       _temp.add(value);
//   //     else
//   //       _temp.add(element);
//   //   });
//   //   return new Array(_temp);
//   // }
//   //
//   // Array<Float> _itemIndex(Array<Float> item, List<int> positions) {
//   //   List<double> _temp = [];
//   //   for (var element in positions) {
//   //     _temp.add(item[element]);
//   //   }
//   //
//   //   final result = Array<Float>.multi([_temp.length]);
//   //   result.fillFromList(_temp);
//   //   return result;
//   // }
//   //
//   // List<double> _quickSort(List<double> a) {
//   //   if (a.length <= 1) {
//   //     return a;
//   //   }
//   //
//   //   var pivot = a[0];
//   //   var less = <double>[];
//   //   var more = <double>[];
//   //   var pivotList = <double>[];
//   //
//   //   for (final i in a) {
//   //     if (i.compareTo(pivot) < 0) {
//   //       less.add(i);
//   //     } else if (i.compareTo(pivot) > 0) {
//   //       more.add(i);
//   //     } else {
//   //       pivotList.add(i);
//   //     }
//   //   }
//   //
//   //   less = _quickSort(less);
//   //   more = _quickSort(more);
//   //
//   //   less.addAll(pivotList);
//   //   less.addAll(more);
//   //   return less;
//   // }
//   // setCurrentPrediction(CameraImage cameraImage, Face face) {
//   //   List<double> input = _preProcess(cameraImage, face);
//   //
//   //   input = input.reshape(<int>[1, 112, 112, 3]) as List<int>;
//   //   List<int> output = List<int>.generate(1, (index) => List<int>.filled(192, 0) ) ;
//   //
//   //   _interpreter.run(input, output);
//   //   output = output.reshape([192]);
//   //
//   //   _predictedData =   Uint8List.fromList(output);
//   // }
//   //
//   //
//   // Float32List? _preProcess(CameraImage image, Face faceDetected) {
//   //   imglib.Image? croppedImage = _cropFace(image, faceDetected);
//   //
//   //   if(croppedImage == null){
//   //     return null;
//   //   }
//   //
//   //   imglib.Image img = imglib.copyResizeCropSquare(croppedImage, 112);
//   //
//   //   Float32List imageAsList = imageToByteListFloat32(img);
//   //   // imageAsList.buffer.asInt8List().toList()
//   //   return imageAsList;
//   // }
//   //
//   // imglib.Image? _cropFace(CameraImage image, Face faceDetected) {
//   //   imglib.Image? convertedImage = _convertCameraImage(image);
//   //   double x = faceDetected.boundingBox.left - 10.0;
//   //   double y = faceDetected.boundingBox.top - 10.0;
//   //   double w = faceDetected.boundingBox.width + 10.0;
//   //   double h = faceDetected.boundingBox.height + 10.0;
//   //   if (convertedImage == null) {
//   //     return null;
//   //   }
//   //
//   //   return imglib.copyCrop(
//   //       convertedImage, x.round(), y.round(), w.round(), h.round());
//   // }
//
//   imglib.Image? _convertCameraImage(CameraImage image) {
//     var img = convertToImage(image);
//     if (img != null) {
//       var img1 = imglib.copyRotate(img, -90);
//       return img1;
//     }
//
//     return null;
//   }
//
//   Float32List imageToByteListFloat32(imglib.Image image) {
//     var convertedBytes = Float32List(1 * 112 * 112 * 3);
//     var buffer = Float32List.view(convertedBytes.buffer);
//     int pixelIndex = 0;
//
//     for (var i = 0; i < 112; i++) {
//       for (var j = 0; j < 112; j++) {
//         var pixel = image.getPixel(j, i);
//         buffer[pixelIndex++] = (imglib.getRed(pixel) - 128) / 128;
//         buffer[pixelIndex++] = (imglib.getGreen(pixel) - 128) / 128;
//         buffer[pixelIndex++] = (imglib.getBlue(pixel) - 128) / 128;
//       }
//     }
//     return convertedBytes.buffer.asFloat32List();
//   }
//
//   double _euclideanDistance(List? e1, List? e2) {
//     if (e1 == null || e2 == null) throw Exception("Null argument");
//
//     double sum = 0.0;
//     for (int i = 0; i < e1.length; i++) {
//       sum += pow((e1[i] - e2[i]), 2);
//     }
//     return sqrt(sum);
//   }
//
//   void setPredictedData(value) {
//     _predictedData = value;
//   }
//
//   dispose() {}
// }
