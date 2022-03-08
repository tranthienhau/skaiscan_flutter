import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:image/image.dart' as imglib;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'acne_scan_service.dart';

class TfAcneScanService implements AcneScanService {
  Float32List? _float32Bytes;
  late Interpreter _interpreter;
  final _outputSize = 512;
  Delegate? _delegate;
  InterpreterOptions? _interpreterOptions;

  @override
  Future<void> init() async {
    ///Load model
    final options = InterpreterOptions();
    options.threads = 4;
    _interpreterOptions = options;
    if (Platform.isAndroid) {
      try {
        _interpreter = await Interpreter.fromAsset('model/model_quant.tflite',
            options: options);
      } catch (e, stackTrace) {
        // _interpreter = await Interpreter.fromAsset('model/model_quant.tflite',
        //     options: options);

        await FirebaseCrashlytics.instance.recordError(
          e, stackTrace,
          reason: 'Can not load model',
          // Pass in 'fatal' argument
          fatal: true,
        );

        throw Exception('Can not load model!.');
      }
    } else {
      try {
        _interpreter = await Interpreter.fromAsset('model/model_quant.tflite',
            options: options);
        // Delegate delegate = GpuDelegate(
        //   options: GpuDelegateOptions(
        //     enableQuantization: false,
        //     allowPrecisionLoss: false,
        //     waitType: TFLGpuDelegateWaitType.active,
        //   ),
        // );
        //
        // final interpreterOptions = InterpreterOptions()..addDelegate(delegate);
        // interpreterOptions.threads = 4;
        //
        // _interpreter = await Interpreter.fromAsset('model/model_fpn512.tflite',
        //     options: interpreterOptions);
        // // _interpreter = await Interpreter.fromAsset('model/model_quant.tflite',
        // //     options: interpreterOptions);
        //
        // _delegate = delegate;

      } catch (e, stackTrace) {
        ///Load model
        _interpreter = await Interpreter.fromAsset('model/model_quant.tflite',
            options: options);
        await FirebaseCrashlytics.instance.recordError(
          e, stackTrace,
          reason: 'Can not load model',
          // Pass in 'fatal' argument
          fatal: true,
        );
      }
    }
  }

  @override
  Future<void> loadSmallModel() async {
    ///Load model
    final options = InterpreterOptions();
    options.threads = 4;

    _interpreter = await Interpreter.fromAsset('model/model_quant.tflite',
        options: options);
  }

  @override
  Future<Uint8List> getAcneBytes() async {
    final float32Bytes = _float32Bytes;

    if (float32Bytes == null) {
      throw Exception('Can not convert camera image to bytes');
    }

    List inputReshape =
        float32Bytes.reshape(<int>[1, _outputSize, _outputSize, 3]);

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
      // onError:
    );

    Uint8List? bytes = await port.first as Uint8List?;

    if (bytes == null) {
      return Uint8List.fromList(<int>[]);
    }

    return bytes;
  }

  @override
  Future<void> select(Uint8List bytes) async {
    final image = imglib.decodeImage(bytes);

    if (image == null) {
      throw Exception('Can not convert camera image to bytes');
    }

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

  @override
  Future<void> dispose() async {
    _interpreter.close();
    _delegate?.delete();
    _interpreterOptions?.delete();
  }
}

void _isolateAcneScan(Map<String, dynamic> data) {
  final input = data['input'];

  final int interpreterTransformAddress = data['interpreter'];

  final SendPort sendPort = data['sendPort'];

  final inputSize = data['inputSize'];

  final inputs = <Object>[input];

  Interpreter interpreterTransform =
      Interpreter.fromAddress(interpreterTransformAddress);

  final outputs = <int, Object>{};

  final outputData = [
    List.generate(
      inputSize,
      (index) => List.generate(
        inputSize,
        (index) => 0,
      ),
    ),
  ];

  outputs[0] = outputData;

  interpreterTransform.runForMultipleInputs(inputs, outputs);

  int unitValue = 72057594037927936;

  final flatten = outputData.flatten();

  final List<int> normalArray =
      flatten.map<int>((index) => (index / unitValue).toInt()).toList();

  sendPort.send(Uint8List.fromList(normalArray));
}
