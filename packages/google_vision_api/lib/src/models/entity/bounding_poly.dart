import 'package:google_vision_api/google_vision_api.dart';

class BoundingPoly {
  late final List<Vertices> verticesList;

  BoundingPoly({this.verticesList = const []});

  BoundingPoly.fromJson(Map<String, dynamic> json) {
    verticesList = <Vertices>[];
    if (json['vertices'] != null) {
      json['vertices'].forEach((v) {
        verticesList.add(Vertices.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['vertices'] = verticesList.map((v) => v.toJson()).toList();
    return data;
  }
}
