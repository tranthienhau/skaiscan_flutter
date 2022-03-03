import 'package:hive/hive.dart';

import 'secure_config_service.dart';

class SecureStorageService implements SecureConfigService {
  late Box _box;
  int? _loginCount;

  /// Whether the secure storage service is initialized.
  bool _isInitialized = false;

  @override
  Future<void> init() async {
    if (_isInitialized) {
      return;
    }
    _box = await Hive.openBox('secureStorage');
    _isInitialized = true;
  }

  @override
  int? get loginCount =>
      _loginCount ??= _box.get('loginCount', defaultValue: 0);

  @override
  Future<void> setLoginCount(int value) async {
    _loginCount = value;
    await _box.put('loginCount', value);
  }

  @override
  Future<void> clear() async {
    await _box.put('loginCount', null);
  }
}
