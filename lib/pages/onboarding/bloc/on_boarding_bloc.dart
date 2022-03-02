import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'on_boarding_event.dart';

part 'on_boarding_state.dart';

class OnBoardingBloc extends Bloc<OnBoardingEvent, OnBoardingState> {
  OnBoardingBloc() : super(const OnBoardingLoadSuccess(0)) {
    on<OnBoardingPageChanged>(_onPageChanged);
  }

  Future<void> _onPageChanged(
    OnBoardingPageChanged event,
    Emitter<OnBoardingState> emit,
  ) async {
    emit(OnBoardingLoadSuccess(event.pageIndex));
  }
}
