import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CameraService {
  late CameraController _cameraController;

  CameraController get cameraController => _cameraController;

  late CameraDescription _cameraDescription;

  late InputImageRotation _cameraRotation;

  InputImageRotation get cameraRotation => _cameraRotation;

  Stream<CameraImage> get cameraImageStream => _cameraStreamController.stream;

  CameraController get controller => _cameraController;

  final StreamController<CameraImage> _cameraStreamController =
      StreamController<CameraImage>.broadcast();

  Future<void> startService(CameraDescription cameraDescription) async {
    _cameraDescription = cameraDescription;
    _cameraController = CameraController(
      _cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    // sets the rotation of the image
    _cameraRotation = rotationIntToImageRotation(
      _cameraDescription.sensorOrientation,
    );

    await _cameraController.initialize();

    // Next, initialize the controller. This returns a Future.
  }

  void startImageStream() {
    _cameraController.startImageStream((image) async {
      _cameraStreamController.add(image);
    });
  }

  void stopImageStream() {
    _cameraController.stopImageStream();
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

  Future<void> dispose() {
    return _cameraController.dispose();
  }
}
