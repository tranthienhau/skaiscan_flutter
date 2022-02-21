import 'dart:async';
import 'dart:typed_data';


import 'package:image/image.dart' as imglib;

abstract class AcneScanService {
  Future<void> init();

  Future<void> select(Uint8List bytes);
  Future<void> selectCameraImage(imglib.Image image);

  Future<List<int>> getAllAcneList();

  Future<Uint8List> getAcneBytes();
}
