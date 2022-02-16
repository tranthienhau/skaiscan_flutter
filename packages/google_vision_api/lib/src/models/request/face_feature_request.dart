class FaceFeatureRequest {
  late final int maxResults;
  late final String type;

  FaceFeatureRequest({required this.maxResults, required this.type});

  FaceFeatureRequest.fromJson(Map<String, dynamic> json) {
    maxResults = json['maxResults'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['maxResults'] = maxResults;
    data['type'] = type;
    return data;
  }
}
