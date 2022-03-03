import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:skaiscan/services/config_service/secure_config_service.dart';

part 'application_event.dart';

part 'application_state.dart';

class ApplicationBloc extends Bloc<ApplicationEvent, ApplicationState> {
  ApplicationBloc({SecureConfigService? secureConfigService})
      : super(ApplicationLoading()) {
    _secureConfigService =
        secureConfigService ?? GetIt.I<SecureConfigService>();
    on<ApplicationLoaded>(_onLoaded);
  }

  late SecureConfigService _secureConfigService;

  Future<void> _onLoaded(
    ApplicationEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    await _secureConfigService.init();

    int loginCount = _secureConfigService.loginCount ?? 0;

    if (loginCount > 0) {
      _secureConfigService.setLoginCount(loginCount + 1);
      emit(ApplicationIntroduceLoadSuccess());

      return;
    }

    _secureConfigService.setLoginCount(loginCount + 1);
    emit(ApplicationOnBoardingLoadSuccess());
  }
}
