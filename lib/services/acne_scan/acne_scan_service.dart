import 'dart:async';
import 'dart:typed_data';

import 'package:image/image.dart' as imglib;

abstract class AcneScanService {
  Future<void> init();

  Future<void> loadSmallModel();

  int get outPutSize;

  Future<void> select(Uint8List bytes);

  Future<void> selectImage(imglib.Image image);

  Future<Uint8List> getAcneBytes();
}
