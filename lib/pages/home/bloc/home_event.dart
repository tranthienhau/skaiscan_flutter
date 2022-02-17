part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class HomeScanEnabled extends HomeEvent {}

class HomeCameraFaceChecked extends HomeEvent {
  final CameraImage cameraImage;

  HomeCameraFaceChecked(this.cameraImage);
}

class HomeAcneScan extends HomeEvent {
  final XFile file;

  HomeAcneScan(this.file);
}

class HomeLoaded extends HomeEvent {}
