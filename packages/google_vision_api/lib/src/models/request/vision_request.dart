import 'package:google_vision_api/google_vision_api.dart';
import 'package:google_vision_api/src/json_convert.dart';

class VisionRequest<T> {
  late final VisionImageRequest image;
  late final List<T> features;

  VisionRequest({required this.image, required this.features});

  VisionRequest.fromJson(Map<String, dynamic> json) {
    image = VisionImageRequest.fromJson(json['image']);

    features = <T>[];
    if (json['features'] != null) {
      json['features'].forEach((item) {
        features.add(googleVisionJsonConvert.deserialize<T>(item));
      });
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image.toJson(),
      'features': features.map(
        (feature) => googleVisionJsonConvert.serialize(feature),
      ).toList(),
    };
  }
}
