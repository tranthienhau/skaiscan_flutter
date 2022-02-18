part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class HomeScanEnabled extends HomeEvent {}

class HomeCameraFaceChecked extends HomeEvent {
  final CameraImage cameraImage;

  HomeCameraFaceChecked(this.cameraImage);
}



class HomeAcneScanned extends HomeEvent {
  final XFile file;

  HomeAcneScanned(this.file);
}

class HomeLoaded extends HomeEvent {}
