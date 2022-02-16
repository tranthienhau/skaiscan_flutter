part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class HomeScanEnabled extends HomeEvent {}

class HomeCameraFaceDetected extends HomeEvent {}

class HomeLoaded extends HomeEvent {}
