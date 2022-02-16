part of 'home_bloc.dart';

class HomeData {
  HomeData({required this.allowScan,required this.cameraDescriptionList});

  final bool allowScan;
  List<CameraDescription> cameraDescriptionList;

  HomeData copyWith({
    bool? allowScan,
    List<CameraDescription>? cameraDescriptionList,
  }) {
    return HomeData(
      allowScan: allowScan ?? this.allowScan,
      cameraDescriptionList:
          cameraDescriptionList ?? this.cameraDescriptionList,
    );
  }
}

@immutable
abstract class HomeState {
  final HomeData data;

  const HomeState(this.data);
}

class HomeLoading extends HomeState {
  const HomeLoading(HomeData data) : super(data);
}

class HomeLoadSuccess extends HomeState {
  const HomeLoadSuccess(HomeData data) : super(data);
}
