import 'package:google_vision_api/google_vision_api.dart';

class Landmark {
  String? type;
  LandmarkPosition? position;

  Landmark({this.type, this.position});

  Landmark.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    position = json['position'] != null
        ? LandmarkPosition.fromJson(json['position'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['position'] = position?.toJson();
    return data;
  }
}
