import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CameraService {
  late CameraController _cameraController;

  CameraController get cameraController => _cameraController;

  late CameraDescription _cameraDescription;

  Stream<CameraImage> get cameraImageStream => _cameraStreamController.stream;

  CameraController get controller => _cameraController;
  late InputImageRotation _cameraRotation;

  InputImageRotation get cameraRotation => _cameraRotation;
  final StreamController<CameraImage> _cameraStreamController =
      StreamController<CameraImage>.broadcast();

  Future<void> startService(CameraDescription cameraDescription) async {
    _cameraDescription = cameraDescription;
    _cameraController = CameraController(
      _cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.bgra8888,
    );

    _cameraRotation =
        rotationIntToImageRotation(cameraDescription.sensorOrientation);

    await _cameraController.initialize();
    await _cameraController
        .lockCaptureOrientation(DeviceOrientation.portraitUp);
    // Next, initialize the controller. This returns a Future.
  }

  Future<void> startImageStream() {
    return _cameraController.startImageStream((image) async {
      _cameraStreamController.add(image);
    });
  }

  Future<void> stopImageStream() {
    return _cameraController.stopImageStream();
  }

  Future<XFile> takePicture() async {
    XFile file = await _cameraController.takePicture();
    return file;
  }

  Size getImageSize() {
    return Size(
      _cameraController.value.previewSize?.height ?? 0,
      _cameraController.value.previewSize?.width ?? 0,
    );
  }

  InputImageRotation rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.Rotation_90deg;
      case 180:
        return InputImageRotation.Rotation_180deg;
      case 270:
        return InputImageRotation.Rotation_270deg;
      default:
        return InputImageRotation.Rotation_0deg;
    }
  }

  Future<void> dispose() {
    return _cameraController.dispose();
  }
}
