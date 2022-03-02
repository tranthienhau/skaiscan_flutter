part of 'on_boarding_bloc.dart';

@immutable
abstract class OnBoardingState {
  final int pageIndex;
  final int pageCount;

  const OnBoardingState(this.pageIndex, {this.pageCount = 2});
}

class OnBoardingLoadSuccess extends OnBoardingState {
  const OnBoardingLoadSuccess(int pageIndex) : super(pageIndex);
}
