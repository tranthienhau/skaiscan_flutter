class VisionImageRequest {
  late final String content;

  VisionImageRequest({required this.content});

  VisionImageRequest.fromJson(Map<String, dynamic> json) {
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['content'] = content;
    return data;
  }
}
