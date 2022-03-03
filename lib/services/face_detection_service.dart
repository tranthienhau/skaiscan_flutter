import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:isolate_handler/isolate_handler.dart';
import 'package:skaiscan/services/camera_service.dart';

class FaceRectangle {
  final int left;
  final int top;
  final int width;
  final int height;

  const FaceRectangle({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  Map<String, dynamic> toMap() {
    return {
      'left': left,
      'top': top,
      'width': width,
      'height': height,
    };
  }

  factory FaceRectangle.fromMap(Map<String, dynamic> map) {
    return FaceRectangle(
      left: map['left'] as int,
      top: map['top'] as int,
      width: map['width'] as int,
      height: map['height'] as int,
    );
  }
}

class FaceDetectorService {
  FaceDetectorService({CameraService? cameraService}) {
    _cameraService = cameraService ?? GetIt.I<CameraService>();
  }

  late CameraService _cameraService;
  late IsolateHandler _isolateManager;
  late FaceDetector _faceDetector;

  late Completer<List<FaceRectangle>> _isolateCompleter;
  late Completer<void> _isolateCloseCompleter;

  FaceDetector get faceDetector => _faceDetector;

  // final bool _useIsolate = Platform.isAndroid;
  final bool _useIsolate = false;

  void initialize() {
    if (_useIsolate) {
      _isolateManager = IsolateHandler();
      _isolateManager.spawn<dynamic>(
        _isolateFaceDetection,
        name: 'isolateFaceDetection',
        onReceive: communicationFromIsolate,
        // onInitialized: () => isolates.send("test", to: "isolate"),
      );
    } else {
      _faceDetector = GoogleMlKit.vision.faceDetector(
        const FaceDetectorOptions(
            mode: FaceDetectorMode.accurate, minFaceSize: 0.5),
      );
    }
  }

  void communicationFromIsolate(dynamic data) {
    if (data is Map) {
      switch (data['message']) {
        case 'close':
          _isolateCloseCompleter.complete();
          break;
        case 'detect':
          final dataList = data['data'] as List;
          final rectList =
              dataList.map((json) => FaceRectangle.fromMap(json)).toList();

          _isolateCompleter.complete(rectList);
          break;
        default:
          _isolateCompleter.complete(<FaceRectangle>[]);
          break;
      }
    } else {
      _isolateCompleter.complete(<FaceRectangle>[]);
    }

    // We will no longer be needing the isolate, let's dispose of it.
    // isolates.kill('isolate');
  }

  Future<List<FaceRectangle>> getFacesFromImage(CameraImage image) async {
    if (_useIsolate) {
      _isolateCompleter = Completer<List<FaceRectangle>>();

      _isolateManager.send(
        {
          'imageRotation': _cameraService.cameraRotation.rawValue,
          'bytes': image.planes[0].bytes,
          'format': image.format.raw,
          'width': image.width,
          'height': image.height,
          'message': 'detect',
        },
        to: 'isolateFaceDetection',
      );
      final result = await _isolateCompleter.future;
      return result;
    } else {
      InputImageData _firebaseImageMetadata = InputImageData(
        imageRotation: _cameraService.cameraRotation,
        inputImageFormat:
            InputImageFormatMethods.fromRawValue(image.format.raw)!,
        size: Size(image.width.toDouble(), image.height.toDouble()),
        planeData: image.planes.map(
          (Plane plane) {
            return InputImagePlaneMetadata(
              bytesPerRow: plane.bytesPerRow,
              height: plane.height,
              width: plane.width,
            );
          },
        ).toList(),
      );

      InputImage _firebaseVisionImage = InputImage.fromBytes(
        bytes: image.planes[0].bytes,
        inputImageData: _firebaseImageMetadata,
      );

      List<Face> faces = await _faceDetector.processImage(_firebaseVisionImage);
      final rectList = faces
          .map((face) => FaceRectangle(
                height: face.boundingBox.height.toInt(),
                width: face.boundingBox.width.toInt(),
                top: face.boundingBox.top.toInt(),
                left: face.boundingBox.left.toInt(),
              ))
          .toList();

      // print('Face: ${rectList.length}');
      return rectList;
    }
  }

  Future<void> dispose() async {
    if (_useIsolate) {
      _isolateCloseCompleter = Completer<void>();
      _isolateManager.send(
        {'message': 'close'},
        to: 'isolateFaceDetection',
      );
      await _isolateCloseCompleter.future;
      _isolateManager.kill("isolateFaceDetection");
    } else {
      _faceDetector.close();
    }
  }
}

void _isolateFaceDetection(Map<String, dynamic> context) {
  // Calling initialize from the entry point with the context is
  // required if communication is desired. It returns a messenger which
  // allows listening and sending information to the main isolate.
  final messenger = HandledIsolate.initialize(context);

  final faceDetector = GoogleMlKit.vision
      .faceDetector(const FaceDetectorOptions(mode: FaceDetectorMode.accurate));

  Map<int, InputImageRotation> values = {
    0: InputImageRotation.Rotation_0deg,
    90: InputImageRotation.Rotation_90deg,
    180: InputImageRotation.Rotation_180deg,
    270: InputImageRotation.Rotation_270deg,
  };

  // Triggered every time data is received from the main isolate.
  messenger.listen((data) async {
    final mapData = data as Map<String, dynamic>;

    switch (mapData['message']) {
      case 'close':
        await faceDetector.close();
        messenger.send({'data': [], 'message': mapData['message']});

        break;
      case 'detect':
        final Uint8List bytes = mapData['bytes'];
        final dynamic format = mapData['format'];
        final int rotation = mapData['imageRotation'];
        final int width = mapData['width'];
        final int height = mapData['height'];

        // final InputImageRotation imageRotation = mapData['imageRotation'];
        InputImageData _firebaseImageMetadata = InputImageData(
          imageRotation: values[rotation]!,
          inputImageFormat: InputImageFormatMethods.fromRawValue(format)!,
          size: Size(width.toDouble(), height.toDouble()),
          planeData: null,
          // planeData: image.planes.map(
          //   (Plane plane) {
          //     return InputImagePlaneMetadata(
          //       bytesPerRow: plane.bytesPerRow,
          //       height: plane.height,
          //       width: plane.width,
          //     );
          //   },
          // ).toList(),
        );

        InputImage _firebaseVisionImage = InputImage.fromBytes(
          bytes: bytes,
          inputImageData: _firebaseImageMetadata,
        );

        try {
          List<Face> faces =
              await faceDetector.processImage(_firebaseVisionImage);

          // print('face: ${faces.length}');

          final faceRectList = faces
              .map((face) => FaceRectangle(
                    left: face.boundingBox.left.toInt(),
                    top: face.boundingBox.top.toInt(),
                    width: face.boundingBox.width.toInt(),
                    height: face.boundingBox.height.toInt(),
                  ).toMap())
              .toList();

          messenger.send({'data': faceRectList, 'message': mapData['message']});
        } catch (e) {
          messenger.send({'data': [], 'message': mapData['message']});
        }

        break;
    }

    // messenger.send(++count);
  });
}
