import 'dart:typed_data';

import 'package:skaiscan/model/acne.dart';

class AcneScanArgs {
  final List<Acne> acneList;
  final Uint8List scanBytes;

  AcneScanArgs({
    required this.acneList,
    required this.scanBytes,
  });
}
