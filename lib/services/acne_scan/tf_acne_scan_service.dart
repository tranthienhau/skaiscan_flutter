import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as imglib;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'acne_scan_service.dart';

const OUT_PUT_SIZE = 512;

class TfAcneScanService implements AcneScanService {
  late imglib.Image _image;
  Float32List? _float32Bytes;
  late Interpreter _interpreter;
  final _outputSize = OUT_PUT_SIZE;

  @override
  Future<void> init() async {
    ///Load model
    final options = InterpreterOptions();
    options.threads = 4;
    // options.useNnApiForAndroid = true;

    if (Platform.isAndroid) {
      try {
        Delegate delegate = GpuDelegateV2(
            options: GpuDelegateOptionsV2(
          isPrecisionLossAllowed: false,
          inferencePreference: TfLiteGpuInferenceUsage.fastSingleAnswer,
          inferencePriority1: TfLiteGpuInferencePriority.maxPrecision,
          inferencePriority2: TfLiteGpuInferencePriority.auto,
          inferencePriority3: TfLiteGpuInferencePriority.auto,
        ));
        final interpreterOptions = InterpreterOptions()..addDelegate(delegate);

        _interpreter = await Interpreter.fromAsset('model/model_512.tflite',
            options: interpreterOptions);
      } catch (e) {
        _interpreter = await Interpreter.fromAsset('model/unet_model.tflite',
            options: options);
      }

      // _interpreter = await Interpreter.fromAsset('model/unet_model.tflite',
      //     options: options);
    } else {
      try {
        Delegate delegate = GpuDelegate(
          options: GpuDelegateOptions(
            enableQuantization: true,
            allowPrecisionLoss: true,
            waitType: TFLGpuDelegateWaitType.active,
          ),
        );
        final interpreterOptions = InterpreterOptions()..addDelegate(delegate);

        _interpreter = await Interpreter.fromAsset('model/model_512.tflite',
            options: interpreterOptions);
      } catch (e) {
        _interpreter = await Interpreter.fromAsset('model/unet_model.tflite',
            options: options);
      }
    }

    // try {
    //   _interpreter = await Interpreter.fromAsset('model/unet_model.tflite',
    //       options: options);
    //   // _interpreter = await Interpreter.fromAsset('model/model_1024.tflite',
    //   //     options: options);
    // } catch (e, _) {
    //   _interpreter = await Interpreter.fromAsset('model/unet_model.tflite',
    //       options: options);
    // }

    // Tensor tensor = _interpreter.getOutputTensor(0);
    print('Load model success');
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
        // 'originImage': _image,
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

    _image = image.clone();

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

  @override
  int get outPutSize => _outputSize;
}

void _isolateAcneScan(Map<String, dynamic> data) {
  final input = data['input'];
  // final output = data['output'];

  final int interpreterTransformAddress = data['interpreter'];

  final SendPort sendPort = data['sendPort'];

  final inputSize = data['inputSize'];

  // final originImage = data['originImage'];

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

  // final List<List<List<double>>> outputData = [
  //   List.generate(
  //     inputSize,
  //     (index) => List.generate(1024, (index) => 0.0),
  //   ),
  // ];

  // final List<List<List<List<double>>>> outputData = [
  //   List.generate(
  //     inputSize,
  //         (index) => List.generate(1024, (index) => 0.0),
  //   ),
  // ];

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

  final outputArray = _convertOutputToBytesArray(outputData);

  final byteArray = Uint8List.fromList(outputArray);

  sendPort.send(byteArray);
}

List<int> _convertOutputToBytesArray(
    List<List<List<List<double>>>> imageArray) {
  List<int> result = [];
  for (int x = 0; x < imageArray[0].length; x++) {
    for (int y = 0; y < imageArray[0][0].length; y++) {
      double max = 0;
      int index = 0;
      for (int z = 0; z < imageArray[0][0][0].length; z++) {
        final value = imageArray[0][0][0][z];

        if (max < value) {
          max = value;
          index = z;
        }
      }

      // double value = ((4 - index) / 4) * 255;
      // result.add(value.toInt());

      result.add(index);
    }
  }

  return result;
}

imglib.Image _convertOutputArrayToImage(
    List<List<List<List<double>>>> imageArray, int inputSize) {
  imglib.Image image = imglib.Image.rgb(inputSize, inputSize);
  for (int x = 0; x < imageArray[0].length; x++) {
    for (int y = 0; y < imageArray[0][0].length; y++) {
      double max = 0;
      int index = 0;
      for (int z = 0; z < imageArray[0][0][0].length; z++) {
        final value = imageArray[0][0][0][z];

        if (max < value) {
          max = value;
          index = z;
        }
      }

      image.setPixelRgba(x, y, index, index, index);

      // rgba[i + 0] = input[j];
      // rgba[i + 1] = input[j];
      // rgba[i + 2] = input[j];
      // rgba[i + 3] = 255;

      // final r = (imageArray[0][x][y][0] * 255).toInt();
      // final g = (imageArray[0][x][y][1] * 255).toInt();
      // final b = (imageArray[0][x][y][2] * 255).toInt();
      // image.setPixelRgba(x, y, r, g, b);
    }
  }

  return image;
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
