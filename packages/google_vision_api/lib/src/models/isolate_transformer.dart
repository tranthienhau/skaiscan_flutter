import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class IsolateTransformers extends DefaultTransformer {
  IsolateTransformers() : super(jsonDecodeCallback: _parseJson);
}

// Must be top-level function
dynamic _parseAndDecode(String response) {
  return jsonDecode(response);
}

dynamic _parseJson(String text) {
  return compute(_parseAndDecode, text);
}
