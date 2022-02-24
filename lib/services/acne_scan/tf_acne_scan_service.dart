import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as imglib;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'acne_scan_service.dart';

const OUT_PUT_SIZE = 512;

class TfAcneScanService implements AcneScanService {
  // late imglib.Image _image;
  Float32List? _float32Bytes;
  late Interpreter _interpreter;
  final _outputSize = OUT_PUT_SIZE;

  @override
  Future<void> init() async {
    ///Load model
    final options = InterpreterOptions();
    options.threads = 4;
    // options.useNnApiForAndroid = true;
    // options.useMetalDelegateForIOS = true;

    if (Platform.isAndroid) {
      // _interpreter = await Interpreter.fromAsset('model/model_quant.tflite',
      //     options: options);
      try {
        Delegate delegate = GpuDelegateV2(
            options: GpuDelegateOptionsV2(
          isPrecisionLossAllowed: true,
          inferencePreference: TfLiteGpuInferenceUsage.fastSingleAnswer,
          inferencePriority1: TfLiteGpuInferencePriority.maxPrecision,
          inferencePriority2: TfLiteGpuInferencePriority.auto,
          inferencePriority3: TfLiteGpuInferencePriority.auto,
        ));

        final interpreterOptions = InterpreterOptions()..addDelegate(delegate);
        interpreterOptions.threads = 4;
        interpreterOptions.useNnApiForAndroid = false;
        _interpreter = await Interpreter.fromAsset('model/model_fpn512.tflite',
            options: interpreterOptions);
      } catch (e) {
        _interpreter = await Interpreter.fromAsset('model/model_fpn512.tflite',
            options: options);
      }

    } else {
      try {
        Delegate delegate = GpuDelegate(
          options: GpuDelegateOptions(
            enableQuantization: false,
            allowPrecisionLoss: false,
            waitType: TFLGpuDelegateWaitType.active,
          ),
        );
        final interpreterOptions = InterpreterOptions()..addDelegate(delegate);

        _interpreter = await Interpreter.fromAsset('model/model_fpn512.tflite',
            options: interpreterOptions);
      } catch (e) {
        _interpreter = await Interpreter.fromAsset('model/model_unet.tflite',
            options: options);
      }
    }
  }

  @override
  Future<Uint8List> getAcneBytes() async {
    final float32Bytes = _float32Bytes;

    if (float32Bytes == null) {
      throw Exception('Can not convert camera image to bytes');
    }

    List inputReshape =
        float32Bytes.reshape(<int>[1, _outputSize, _outputSize, 3]);

    // final outputData = [
    //   List.generate(
    //     _outputSize,
    //     (index) => List.generate(
    //       _outputSize,
    //       (index) => 0,
    //     ),
    //   ),
    // ];
    // Completer<List<int>> _resultCompleter = Completer<List<int>>();

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
      // onError: port.sendPort,
      onExit: port.sendPort,
    );

    List<int>? bytes = (await port.first as List?)?.cast<int>();

    if (bytes == null) {
      return Uint8List.fromList([]);
    }
    Uint8List resultBytes = Uint8List.fromList(bytes);
    return resultBytes;
  }

  @override
  Future<void> select(Uint8List bytes) async {
    final image = imglib.decodeImage(bytes);

    if (image == null) {
      throw Exception('Can not convert camera image to bytes');
    }

    // _image = image;

    final resizeImage =
        imglib.copyResize(image, width: _outputSize, height: _outputSize);

    final convertedBytes = Float32List(1 * _outputSize * _outputSize * 3);
    final buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (int i = 0; i < _outputSize; i++) {
      for (int j = 0; j < _outputSize; j++) {
        final pixel = resizeImage.getPixel(j, i);
        buffer[pixelIndex++] = (imglib.getRed(pixel) - 0) / 255.0;
        buffer[pixelIndex++] = (imglib.getGreen(pixel) - 0) / 255.0;
        buffer[pixelIndex++] = (imglib.getBlue(pixel) - 0) / 255.0;
      }
    }

    _float32Bytes = convertedBytes.buffer.asFloat32List();
  }

  @override
  Future<void> selectImage(imglib.Image image) async {
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

  final int interpreterTransformAddress = data['interpreter'];

  final SendPort sendPort = data['sendPort'];

  final inputSize = data['inputSize'];

  // final output = data['output'];

  final inputs = <Object>[input];

  Interpreter interpreterTransform =
      Interpreter.fromAddress(interpreterTransformAddress);

  final outputs = <int, Object>{};
  //
  // final outputData = [
  //   List.generate(
  //     inputSize,
  //     (index) => List.generate(
  //       inputSize,
  //       (index) => List.generate(5, (index) => 0.0),
  //     ),
  //   ),
  // ];

  final outputData = [
    List.generate(
      inputSize,
      (index) => List.generate(
        inputSize,
        (index) => 0,
      ),
    ),
  ];

  // TensorBuffer outPutBuffer = TensorBuffer.createFixedSize(
  //     <int>[1, inputSize, inputSize], TfLiteType.uint8);

  outputs[0] = outputData;

  interpreterTransform.runForMultipleInputs(inputs, outputs);

  // final outputArray = _convertOutputToBytesArray(outputData);

  int unitValue = 72057594037927936;

  // final List<List<int>> outputArray = output as List<List<dynamic>>;

  final flatten = outputData.flatten();

  final List<int> normalArray =
      flatten.map<int>((index) => (index / unitValue).toInt()).toList();

  sendPort.send(normalArray);
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

      result.add(index);
    }
  }

  return result;
}
