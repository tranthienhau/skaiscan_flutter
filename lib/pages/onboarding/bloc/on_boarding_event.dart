part of 'on_boarding_bloc.dart';

@immutable
abstract class OnBoardingEvent {}

class OnBoardingPageChanged extends OnBoardingEvent {
  final int pageIndex;

  OnBoardingPageChanged(this.pageIndex);
}

class OnBoardingPageAutoChanged extends OnBoardingEvent {}
