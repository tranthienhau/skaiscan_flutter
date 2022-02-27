import 'package:google_vision_api/google_vision_api.dart';

class FaceAnnotation {
  BoundingPoly? boundingPoly;
  BoundingPoly? fdBoundingPoly;
  List<Landmark>? landmarks;
  double? rollAngle;
  double? panAngle;
  double? tiltAngle;
  double? detectionConfidence;
  double? landmarkingConfidence;
  String? joyLikelihood;
  String? sorrowLikelihood;
  String? angerLikelihood;
  String? surpriseLikelihood;
  String? underExposedLikelihood;
  String? blurredLikelihood;
  String? headwearLikelihood;

  FaceAnnotation({
    this.boundingPoly,
    this.fdBoundingPoly,
    this.landmarks,
    this.rollAngle,
    this.panAngle,
    this.tiltAngle,
    this.detectionConfidence,
    this.landmarkingConfidence,
    this.joyLikelihood,
    this.sorrowLikelihood,
    this.angerLikelihood,
    this.surpriseLikelihood,
    this.underExposedLikelihood,
    this.blurredLikelihood,
    this.headwearLikelihood,
  });

  FaceAnnotation.fromJson(Map<String, dynamic> json) {
    boundingPoly = json['boundingPoly'] != null
        ? BoundingPoly.fromJson(json['boundingPoly'])
        : null;
    fdBoundingPoly = json['fdBoundingPoly'] != null
        ? BoundingPoly.fromJson(json['fdBoundingPoly'])
        : null;

    if (json['landmarks'] != null) {
      landmarks = <Landmark>[];
      json['landmarks'].forEach((v) {
        landmarks!.add(Landmark.fromJson(v));
      });
    }

    rollAngle = json['rollAngle'];
    panAngle = json['panAngle'];
    tiltAngle = json['tiltAngle'];
    detectionConfidence = json['detectionConfidence'];
    landmarkingConfidence = json['landmarkingConfidence'];
    joyLikelihood = json['joyLikelihood'];
    sorrowLikelihood = json['sorrowLikelihood'];
    angerLikelihood = json['angerLikelihood'];
    surpriseLikelihood = json['surpriseLikelihood'];
    underExposedLikelihood = json['underExposedLikelihood'];
    blurredLikelihood = json['blurredLikelihood'];
    headwearLikelihood = json['headwearLikelihood'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['boundingPoly'] = boundingPoly?.toJson();
    data['fdBoundingPoly'] = fdBoundingPoly?.toJson();
    data['landmarks'] = landmarks?.map((v) => v.toJson()).toList();
    data['rollAngle'] = rollAngle;
    data['panAngle'] = panAngle;
    data['tiltAngle'] = tiltAngle;
    data['detectionConfidence'] = detectionConfidence;
    data['landmarkingConfidence'] = landmarkingConfidence;
    data['joyLikelihood'] = joyLikelihood;
    data['sorrowLikelihood'] = sorrowLikelihood;
    data['angerLikelihood'] = angerLikelihood;
    data['surpriseLikelihood'] = surpriseLikelihood;
    data['underExposedLikelihood'] = underExposedLikelihood;
    data['blurredLikelihood'] = blurredLikelihood;
    data['headwearLikelihood'] = headwearLikelihood;
    return data;
  }
}
