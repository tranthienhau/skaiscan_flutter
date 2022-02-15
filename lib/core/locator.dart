import 'package:get_it/get_it.dart';
import 'package:skaiscan/core/app_config.dart';
import 'package:skaiscan/core/styles/app_style_config.dart';
import 'package:skaiscan/services/camera_service.dart';
import 'package:skaiscan/services/face_detection_service.dart';

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
}

/// Register the service that it is dependent on other services.
void _setupDependentService() {
  GetIt.I.registerLazySingleton<FaceDetectorService>(
    () => FaceDetectorService(),
  );


  GetIt.I.registerLazySingleton<CameraService>(
    () => CameraService(),
  );
}

/// All Api services are registered here.
void _setupDependentApi() {}
