import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'application_event.dart';

part 'application_state.dart';

class ApplicationBloc extends Bloc<ApplicationEvent, ApplicationState> {
  ApplicationBloc() : super(ApplicationInitial()) {
    on<ApplicationLoaded>(_onLoaded);
  }

  Future<void> _onLoaded(
    ApplicationEvent event,
    Emitter<ApplicationState> emit,
  ) async {}
}
