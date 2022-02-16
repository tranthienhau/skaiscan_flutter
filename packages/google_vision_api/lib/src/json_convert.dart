import 'package:google_vision_api/google_vision_api.dart';

typedef ConvertJsonToObject = Function(Map<String, dynamic> json);
typedef ConvertObjectToJson = Map<String, dynamic> Function(dynamic object);

class JsonConvertGlobal {
  static late Map<Type, ConvertJsonToObject> configs;

  static T deserialize<T>(Map<String, dynamic> json) {
    if (configs[T] != null) {
      ConvertJsonToObject fun = configs[T]!;
      T result = fun(json);
      return result;
    }
    throw Exception('Convert from json to object type of $T is not config.');
  }
}

class JsonConvert<T> {
  JsonConvert({required this.configs, required this.serializeConfigs});

  final Map<Type, ConvertJsonToObject> configs;
  final Map<Type, ConvertObjectToJson> serializeConfigs;

  T deserialize<T>(Map<String, dynamic> json) {
    if (configs[T] != null) {
      ConvertJsonToObject fun = configs[T]!;
      T result = fun(json);
      return result;
    }
    throw Exception('Convert from json to object type of $T is not config.');
  }

  Map<String, dynamic> serialize(dynamic object) {
    if (serializeConfigs[object.runtimeType] != null) {
      ConvertObjectToJson fun = serializeConfigs[T]!;
      Map<String, dynamic> result = fun(object);
      return result;
    }
    throw Exception('Convert from json to object type of $T is not config.');
  }
}

/// Global jsonConvertObject
final JsonConvert googleVisionJsonConvert = JsonConvert(
  configs: {
    FaceFeatureRequest: (json) => FaceFeatureRequest.fromJson(json),
  },
  serializeConfigs: {
    FaceFeatureRequest: (object) {
      return (object as FaceFeatureRequest).toJson();
    }
  },

);
