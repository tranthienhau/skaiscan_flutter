part of 'home_bloc.dart';

class HomeData {
  HomeData({
    required this.allowScan,
    required this.cameraDescriptionList,
    this.scanPercent = 0,
    this.captureBytes,
    // this.viewInsets = EdgeInsets.zero,
  });

  final bool allowScan;
  final List<CameraDescription> cameraDescriptionList;
  final int scanPercent;
  // final EdgeInsets viewInsets;
  final Uint8List? captureBytes;

  HomeData copyWith({
    bool? allowScan,
    Uint8List? captureBytes,
    List<CameraDescription>? cameraDescriptionList,
    int? scanPercent,
    // EdgeInsets? viewInsets,
  }) {
    return HomeData(
      allowScan: allowScan ?? this.allowScan,
      // viewInsets: viewInsets ?? this.viewInsets,
      captureBytes: captureBytes ?? this.captureBytes,
      scanPercent: scanPercent ?? this.scanPercent,
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

class HomeScanInProgress extends HomeState {
  const HomeScanInProgress(HomeData data) : super(data);
}

class HomeScanComplete extends HomeState {
  const HomeScanComplete({required HomeData data, required this.acneList})
      : super(data);
  final List<Acne> acneList;
}

class HomeScanFailure extends HomeState {
  const HomeScanFailure(HomeData data, this.error) : super(data);

  final String error;
}

class HomeLoadFailure extends HomeState {
  const HomeLoadFailure(HomeData data, this.error) : super(data);

  final String error;
}
