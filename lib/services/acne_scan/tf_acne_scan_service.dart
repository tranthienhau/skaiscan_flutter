import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;
import 'package:skaiscan/services/image_converter.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'acne_scan_service.dart';

class TfAcneScanService implements AcneScanService {
  late imglib.Image _image;
  Float32List? _float32Bytes;
  late Interpreter interpreter;
  final _outputSize = 512;

  @override
  Future<void> init() async {
    ///Load model
    final options = InterpreterOptions();
    options.threads = 2;
    // options.useNnApiForAndroid = true;

    interpreter = await Interpreter.fromAsset(
      'model/model_quant.tflite',
      options: options,
    );

    // Tensor tensor = interpreter.getOutputTensor(0);
    // final outputTensor =
    // Tensor(tfLiteInterpreterGetOutputTensor(_interpreter, index));
    print('complete');
  }

  @override
  Future<Uint8List> getAcneBytes() async {
    final float32Bytes = _float32Bytes;

    if (float32Bytes == null) {
      throw Exception('Can not convert camera image to bytes');
    }

    final outputData = [
      List.generate(
        _outputSize,
        (index) => List.generate(
          _outputSize,
          (index) => List.generate(3, (index) => 0.0),
        ),
      ),
    ];

    float32Bytes.reshape(<int>[1, 512, 512, 3]);

    Completer<Uint8List> _resultCompleter = Completer<Uint8List>();

    ///create receiport to get response
    final port = ReceivePort();
    Isolate.spawn<Map<String, dynamic>>(
      _isolateAcneScan,
      {
        'input': float32Bytes,
        'inputSize': 512,
        'interpreter': interpreter.address,
        'originImage': _image,
        'output': outputData,
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
  Future<void> select(CameraImage cameraImage) async {
    final image = convertToImage(cameraImage);

    if (image == null) {
      throw Exception('Can not convert camera image to bytes');
    }
    _image = image;

    final resizeImage = imglib.copyResize(image, width: 512, height: 512);

    final convertedBytes = Float32List(1 * 512 * 512 * 3);
    final buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (int i = 0; i < 512; i++) {
      for (int j = 0; j < 512; j++) {
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
  final output = data['output'];
  final int interpreterTransformAddress = data['interpreter'];
  final SendPort sendPort = data['sendPort'];
  final inputSize = data['inputSize'];

  final originImage = data['originImage'];
  final inputs = <Object>[input];
  Interpreter interpreterTransform =
      Interpreter.fromAddress(interpreterTransformAddress);

  final outputs = <int, Object>{};

  outputs[0] = output;

  interpreterTransform.runForMultipleInputs(inputs, outputs);

  final outputImage = _convertArrayToImage(output, inputSize);

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
