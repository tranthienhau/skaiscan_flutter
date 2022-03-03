abstract class SecureConfigService {
  Future<void> init();

  int? get loginCount;

  Future<void> setLoginCount(int value);

  Future<void> clear();
}
