
import 'dart:async';

import 'package:flutter/services.dart';

class SkaiscanFfi {
  static const MethodChannel _channel = MethodChannel('skaiscan_ffi');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
