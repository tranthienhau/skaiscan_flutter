import 'package:get_it/get_it.dart';
import 'package:skaiscan/core/app_config.dart';
import 'package:skaiscan/core/styles/app_style_config.dart';
import 'package:skaiscan/services/acne_scan/acne_scan_service.dart';
import 'package:skaiscan/services/acne_scan/tf_acne_scan_service.dart';
import 'package:skaiscan/services/camera_service.dart';
import 'package:skaiscan/services/config_service/secure_config_service.dart';
import 'package:skaiscan/services/config_service/secure_storage_service.dart';

/// Setup services locator
/// Must call this function before the [startApp] is called.
void setupLocator() {
  _setupInDependentService();
  _setupDependentService();
  _setupDependentApi();
}

/// Register the services that it is not dependent on any services.
void _setupInDependentService() {
  GetIt.I.registerLazySingleton<AppStyleConfig>(() => AppStyleConfig());
  GetIt.I.registerLazySingleton<AppConfig>(() => AppConfig());
  GetIt.I
      .registerLazySingleton<SecureConfigService>(() => SecureStorageService());
}

/// Register the service that it is dependent on other services.
void _setupDependentService() {
  // GetIt.I.registerLazySingleton<FaceDetectorService>(
  //   () => FaceDetectorService(),
  // );

  GetIt.I.registerLazySingleton<CameraService>(
    () => CameraService(),
  );

  GetIt.I.registerLazySingleton<AcneScanService>(
    () => TfAcneScanService(),
  );
}

/// All Api services are registered here.
void _setupDependentApi() {
  // GetIt.I.registerLazySingleton<VisionApiClient>(
  //   () => DioVisionApiClient(),
  // );
}
