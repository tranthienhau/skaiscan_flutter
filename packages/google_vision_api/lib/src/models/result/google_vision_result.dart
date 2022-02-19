import 'package:google_vision_api/google_vision_api.dart';

class GoogleVisionResult<T> {
  late final List<VisionResponse<T>> responses;

  GoogleVisionResult({required this.responses});

  GoogleVisionResult.fromJson(Map<String, dynamic> json) {
    responses = <VisionResponse<T>>[];
    if (json['responses'] != null) {
      json['responses'].forEach((item) {
        responses.add(VisionResponse<T>.fromJson(item));
      });
    }
  }
}
