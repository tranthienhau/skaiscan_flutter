import 'package:flutter/services.dart';

Future<String> getFileData( String path)  {
  return rootBundle.loadString(path);
}