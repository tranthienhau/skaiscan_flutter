import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skaiscan_ffi/skaiscan_ffi.dart';

void main() {
  const MethodChannel channel = MethodChannel('skaiscan_ffi');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await SkaiscanFfi.platformVersion, '42');
  });
}
