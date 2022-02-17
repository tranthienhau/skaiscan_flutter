import 'package:google_vision_api/google_vision_api.dart';

class ApiConfig {
  ApiConfig({
    this.url,
    this.key,
    this.version,
  });

  String? url;
  String? key;
  String? version;

  ApiConfig copyWith({
    String? url,
    String? key,
    String? version,
  }) {
    return ApiConfig(
      key: key ?? this.key,
      url: url ?? this.url,
      version: version ?? this.version,
    );
  }
}

abstract class VisionApiClient {
  void setApiConfig(ApiConfig appConfig);

  ApiConfig get apiConfig;

  Future<GoogleVisionResult<FaceAnnotation>> detectFaces(List<VisionRequest<FaceFeatureRequest>> requests);
}
