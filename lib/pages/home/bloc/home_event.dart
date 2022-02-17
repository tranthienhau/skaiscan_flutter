part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class HomeScanEnabled extends HomeEvent {}

class HomeCameraFaceDetected extends HomeEvent {}

class HomeAcneScan extends HomeEvent {
  final XFile file;

  HomeAcneScan(this.file);
}

class HomeLoaded extends HomeEvent {}
