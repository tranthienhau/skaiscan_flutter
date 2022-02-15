part of 'home_bloc.dart';

class HomeData {
  final bool allowScan;

  HomeData(this.allowScan);
}

@immutable
abstract class HomeState {
  final HomeData data;

  const HomeState(this.data);
}

class HomeLoadSuccess extends HomeState {
  const HomeLoadSuccess(HomeData data) : super(data);
}
