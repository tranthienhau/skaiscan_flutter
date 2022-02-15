import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as imglib;
import 'package:skaiscan/services/image_converter.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class MLService {
  late Interpreter _interpreter;
  double threshold = 0.5;

   Uint8List? _predictedData;

  Uint8List? get predictedData => _predictedData;

  Future loadModel() async {
    late Delegate delegate;
    try {
      if (Platform.isAndroid) {
        delegate = GpuDelegateV2(
            options: GpuDelegateOptionsV2(
          // experimentalFlags: false,
          inferencePreference: TfLiteGpuInferenceUsage.fastSingleAnswer,
          inferencePriority1: TfLiteGpuInferencePriority.minLatency,
          inferencePriority2: TfLiteGpuInferencePriority.auto,
          inferencePriority3: TfLiteGpuInferencePriority.auto,
          isPrecisionLossAllowed: false,
        ));
      } else if (Platform.isIOS) {
        delegate = GpuDelegate(
          options: GpuDelegateOptions(
              allowPrecisionLoss: true,
              enableQuantization: true,
              waitType: TFLGpuDelegateWaitType.active),
        );
      }
      var interpreterOptions = InterpreterOptions()..addDelegate(delegate);

      _interpreter = await Interpreter.fromAsset('mobilefacenet.tflite',
          options: interpreterOptions);
      print('model loaded successfully');
    } catch (e) {
      print('Failed to load model.');
      print(e);
    }
  }

  // setCurrentPrediction(CameraImage cameraImage, Face face) {
  //   List<double> input = _preProcess(cameraImage, face);
  //
  //   input = input.reshape(<int>[1, 112, 112, 3]) as List<int>;
  //   List<int> output = List<int>.generate(1, (index) => List<int>.filled(192, 0) ) ;
  //
  //   _interpreter.run(input, output);
  //   output = output.reshape([192]);
  //
  //   _predictedData =   Uint8List.fromList(output);
  // }

  //
  // Float32List? _preProcess(CameraImage image, Face faceDetected) {
  //   imglib.Image? croppedImage = _cropFace(image, faceDetected);
  //
  //   if(croppedImage == null){
  //     return null;
  //   }
  //
  //   imglib.Image img = imglib.copyResizeCropSquare(croppedImage, 112);
  //
  //   Float32List imageAsList = imageToByteListFloat32(img);
  //   // imageAsList.buffer.asInt8List().toList()
  //   return imageAsList;
  // }

  // imglib.Image? _cropFace(CameraImage image, Face faceDetected) {
  //   imglib.Image? convertedImage = _convertCameraImage(image);
  //   double x = faceDetected.boundingBox.left - 10.0;
  //   double y = faceDetected.boundingBox.top - 10.0;
  //   double w = faceDetected.boundingBox.width + 10.0;
  //   double h = faceDetected.boundingBox.height + 10.0;
  //   if (convertedImage == null) {
  //     return null;
  //   }
  //
  //   return imglib.copyCrop(
  //       convertedImage, x.round(), y.round(), w.round(), h.round());
  // }

  imglib.Image? _convertCameraImage(CameraImage image) {
    var img = convertToImage(image);
    if (img != null) {
      var img1 = imglib.copyRotate(img, -90);
      return img1;
    }

    return null;
  }

  Float32List imageToByteListFloat32(imglib.Image image) {
    var convertedBytes = Float32List(1 * 112 * 112 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (imglib.getRed(pixel) - 128) / 128;
        buffer[pixelIndex++] = (imglib.getGreen(pixel) - 128) / 128;
        buffer[pixelIndex++] = (imglib.getBlue(pixel) - 128) / 128;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }

  double _euclideanDistance(List? e1, List? e2) {
    if (e1 == null || e2 == null) throw Exception("Null argument");

    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow((e1[i] - e2[i]), 2);
    }
    return sqrt(sum);
  }

  void setPredictedData(value) {
    _predictedData = value;
  }

  dispose() {}
}
