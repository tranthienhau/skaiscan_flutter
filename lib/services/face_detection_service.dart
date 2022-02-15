import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:skaiscan/services/camera_service.dart';

class FaceDetectorService {
  FaceDetectorService({CameraService? cameraService}) {
    _cameraService = cameraService ?? GetIt.I<CameraService>();
  }

  late CameraService _cameraService;

  late FaceDetector _faceDetector;

  FaceDetector get faceDetector => _faceDetector;

  void initialize() {
    _faceDetector = GoogleMlKit.vision.faceDetector(
      const FaceDetectorOptions(
        mode: FaceDetectorMode.accurate,
      ),
    );
  }

  Future<List<Face>> getFacesFromImage(CameraImage image) async {
    InputImageData _firebaseImageMetadata = InputImageData(
      imageRotation: _cameraService.cameraRotation,
      inputImageFormat: InputImageFormatMethods.fromRawValue(image.format.raw)!,
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
    return faces;
  }

  dispose() {
    _faceDetector.close();
  }
}
