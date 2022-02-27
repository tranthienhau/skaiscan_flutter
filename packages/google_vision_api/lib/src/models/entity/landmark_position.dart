class LandmarkPosition {
  double? x;
  double? y;
  double? z;

  LandmarkPosition({this.x, this.y, this.z});

  LandmarkPosition.fromJson(Map<String, dynamic> json) {
    x = json['x'];
    y = json['y'];
    z = json['z'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['x'] = x;
    data['y'] = y;
    data['z'] = z;
    return data;
  }
}
