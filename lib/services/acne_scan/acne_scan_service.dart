import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';

abstract class AcneScanService {
  Future<void> init();

  Future<void> select(CameraImage image);

  Future<List<int>> getAllAcneList();

  Future<Uint8List> getAcneBytes();
}
