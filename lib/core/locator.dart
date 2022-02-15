import 'package:skaiscan/all_file/all_file.dart';

/// Setup services locator
/// Must call this function before the [startApp] is called.
void setupLocator() {
  _setupInDependentService();
  _setupDependentService();
  _setupDependentApi();
}

/// Register the services that it is not dependent on any services.
void _setupInDependentService() {}

/// Register the service that it is dependent on other services.
void _setupDependentService() {}

/// All Api services are registered here.
void _setupDependentApi() {}
