import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';

abstract class AcneScanService {
  Future<void> init();

  Future<void> select(Uint8List bytes);

  Future<List<int>> getAllAcneList();

  Future<Uint8List> getAcneBytes();
}
