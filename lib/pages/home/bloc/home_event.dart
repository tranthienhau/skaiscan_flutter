part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class HomeScanEnabled extends HomeEvent {}

class HomeCameraFaceChecked extends HomeEvent {
  final CameraImage cameraImage;

  HomeCameraFaceChecked(this.cameraImage);
}

class HomeAcneScanned extends HomeEvent {}

class HomeLoaded extends HomeEvent {}
