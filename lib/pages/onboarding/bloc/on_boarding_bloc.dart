import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'on_boarding_event.dart';

part 'on_boarding_state.dart';

class OnBoardingBloc extends Bloc<OnBoardingEvent, OnBoardingState> {
  OnBoardingBloc() : super(const OnBoardingLoadSuccess(0)) {
    _timer = Timer.periodic(const Duration(milliseconds: 3000), (Timer timer) {
      add(OnBoardingPageAutoChanged());
    });

    on<OnBoardingPageChanged>(_onPageChanged);
    on<OnBoardingPageAutoChanged>(_onPageAutoChanged);
  }

  late Timer _timer;

  Future<void> _onPageChanged(
    OnBoardingPageChanged event,
    Emitter<OnBoardingState> emit,
  ) async {
    emit(OnBoardingLoadSuccess(event.pageIndex));
  }

  Future<void> _onPageAutoChanged(
    OnBoardingPageAutoChanged event,
    Emitter<OnBoardingState> emit,
  ) async {
    int page = (state.pageIndex + 1) % state.pageCount;

    emit(OnBoardingPageChangeSuccess(page));
  }

  @override
  Future<void> close() {
    _timer.cancel();
    return super.close();
  }
}
