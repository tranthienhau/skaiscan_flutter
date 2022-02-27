import 'package:google_vision_api/src/json_convert.dart';

class VisionResponse<T> {
  late final List<T> faceAnnotations;

  VisionResponse({required this.faceAnnotations});

  VisionResponse.fromJson(Map<String, dynamic> json) {
    faceAnnotations = <T>[];
    if (json['faceAnnotations'] != null) {
      json['faceAnnotations'].forEach((item) {
        faceAnnotations.add(googleVisionJsonConvert.deserialize<T>(item));
      });
    }
  }
}
