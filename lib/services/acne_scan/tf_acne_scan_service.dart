import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as imglib;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'acne_scan_service.dart';

const OUT_PUT_SIZE = 1024;

class TfAcneScanService implements AcneScanService {
  late imglib.Image _image;
  Float32List? _float32Bytes;
  late Interpreter _interpreter;
  final _outputSize = OUT_PUT_SIZE;

  @override
  Future<void> init() async {
    ///Load model
    final options = InterpreterOptions();
    options.threads = 2;
    // options.useNnApiForAndroid = true;

    // _interpreter =
    //     await Interpreter.fromAsset('model/model_1024.tflite', options: options);
    // Tensor inputTensor = _interpreter.getInputTensor(0);
    // Tensor outputTensor = _interpreter.getOutputTensor(0);

    // final gpuDelegateV2 = GpuDelegateV2(
    //     options: GpuDelegateOptionsV2(
    //   // isPrecisionLossAllowed: false,
    //   // TfLiteGpuInferenceUsage.fastSingleAnswer,
    //   // TfLiteGpuInferencePriority.minLatency,
    //   // TfLiteGpuInferencePriority.auto,
    //   // TfLiteGpuInferencePriority.auto,
    // ));

    // var interpreterOptions = InterpreterOptions()..addDelegate(gpuDelegateV2);
    // _interpreter = await Interpreter.fromAsset('model/model2.tflite',
    //     options: options);

    // Tensor tensor = interpreter.getOutputTensor(0);
    // final outputTensor =
    // Tensor(tfLiteInterpreterGetOutputTensor(_interpreter, index));
  }

  @override
  Future<Uint8List> getAcneBytes() async {
    final float32Bytes = _float32Bytes;

    if (float32Bytes == null) {
      throw Exception('Can not convert camera image to bytes');
    }

    // final outputData = [
    //   List.generate(
    //     _outputSize,
    //     (index) => List.generate(
    //       _outputSize,
    //       (index) => List.generate(3, (index) => 0.0),
    //     ),
    //   ),
    // ];

    List inputReshape =
        float32Bytes.reshape(<int>[1, _outputSize, _outputSize, 3]);

    // final recognitions = await Tflite.runModelOnBinary(
    //     binary: float32Bytes.buffer.asUint8List(),// required
    //     // numResults: 6,    // defaults to 5
    //     // threshold: 0.05,  // defaults to 0.1
    //     // asynch: true      // defaults to true
    // );
    //

    // return Uint8List.fromList([]);
    Completer<Uint8List> _resultCompleter = Completer<Uint8List>();

    ///create receiport to get response
    final port = ReceivePort();
    Isolate.spawn<Map<String, dynamic>>(
      _isolateAcneScan,
      {
        'input': inputReshape,
        'inputSize': _outputSize,
        'interpreter': _interpreter.address,
        'originImage': _image,
        // 'output': outputData,
        'sendPort': port.sendPort,
      },
      onError: port.sendPort,
      onExit: port.sendPort,
    );

    late Uint8List bytes;
    port.listen((message) {
      ///ensure not call more than one times
      if (_resultCompleter.isCompleted) {
        return;
      }

      if (message is Uint8List) {
        bytes = message;
        _resultCompleter.complete(message);
      }
    });

    await _resultCompleter.future;

    return bytes;
    // return float32Bytes.buffer.asUint8List();
  }

  @override
  Future<List<int>> getAllAcneList() {
    // TODO: implement getAllAcneList
    throw UnimplementedError();
  }

  @override
  Future<void> select(Uint8List bytes) async {
    final image = imglib.decodeImage(bytes);

    if (image == null) {
      throw Exception('Can not convert camera image to bytes');
    }

    _image = image;

    final resizeImage =
        imglib.copyResize(image, width: _outputSize, height: _outputSize);

    final convertedBytes = Float32List(1 * _outputSize * _outputSize * 3);
    final buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (int i = 0; i < _outputSize; i++) {
      for (int j = 0; j < _outputSize; j++) {
        final pixel = resizeImage.getPixel(j, i);
        buffer[pixelIndex++] = (imglib.getRed(pixel) - 0) / 255;
        buffer[pixelIndex++] = (imglib.getGreen(pixel) - 0) / 255;
        buffer[pixelIndex++] = (imglib.getBlue(pixel) - 0) / 255;
      }
    }

    _float32Bytes = convertedBytes.buffer.asFloat32List();
  }

  @override
  Future<void> selectCameraImage(imglib.Image image) async {
    final resizeImage =
        imglib.copyResize(image, width: _outputSize, height: _outputSize);

    final convertedBytes = Float32List(1 * _outputSize * _outputSize * 3);
    final buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (int i = 0; i < _outputSize; i++) {
      for (int j = 0; j < _outputSize; j++) {
        final pixel = resizeImage.getPixel(j, i);
        buffer[pixelIndex++] = (imglib.getRed(pixel) - 0) / 255;
        buffer[pixelIndex++] = (imglib.getGreen(pixel) - 0) / 255;
        buffer[pixelIndex++] = (imglib.getBlue(pixel) - 0) / 255;
      }
    }

    _float32Bytes = convertedBytes.buffer.asFloat32List();
  }
}

void _isolateAcneScan(Map<String, dynamic> data) {
  final input = data['input'];
  // final output = data['output'];

  final int interpreterTransformAddress = data['interpreter'];

  final SendPort sendPort = data['sendPort'];

  final inputSize = data['inputSize'];

  final originImage = data['originImage'];

  // final inputData = [
  //   List.generate(
  //     512,
  //         (index) => List.generate(
  //           512,
  //           (index) => List.generate(3, (index) => 0.0),
  //     ),
  //   ),
  // ];

  final inputs = <Object>[input];

  Interpreter interpreterTransform =
      Interpreter.fromAddress(interpreterTransformAddress);

  final outputs = <int, Object>{};

  final outputData = [
    List.generate(
      inputSize,
      (index) => List.generate(
        inputSize,
        (index) => List.generate(5, (index) => 0.0),
      ),
    ),
  ];

  outputs[0] = outputData;

  interpreterTransform.runForMultipleInputs(inputs, outputs);

  final outputImage = _convertArrayToImage(outputData, inputSize);

  final rotateOutputImage = imglib.copyRotate(outputImage, 90);

  final flipOutputImage = imglib.flipHorizontal(rotateOutputImage);

  final resultImage = imglib.copyResize(
    flipOutputImage,
    width: originImage.width,
    height: originImage.height,
  );

  final imageBytes = imglib.encodeJpg(resultImage);

  sendPort.send(imageBytes);
}

imglib.Image _convertArrayToImage(
    List<List<List<List<double>>>> imageArray, int inputSize) {
  imglib.Image image = imglib.Image.rgb(inputSize, inputSize);
  for (int x = 0; x < imageArray[0].length; x++) {
    for (int y = 0; y < imageArray[0][0].length; y++) {
      final r = (imageArray[0][x][y][0] * 255).toInt();
      final g = (imageArray[0][x][y][1] * 255).toInt();
      final b = (imageArray[0][x][y][2] * 255).toInt();
      image.setPixelRgba(x, y, r, g, b);
    }
  }

  return image;
}
