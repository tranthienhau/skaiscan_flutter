import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:get_it/get_it.dart';
import 'package:google_vision_api/google_vision_api.dart';
import 'package:meta/meta.dart';
import 'package:skaiscan/services/acne_scan/acne_scan_service.dart';
import 'package:skaiscan/services/camera_service.dart';
import 'package:skaiscan/services/face_detection_service.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    CameraService? cameraService,
    FaceDetectorService? faceDetectorService,
    VisionApiClient? visionApiClient,
    AcneScanService? acneScanService,
  }) : super(
          HomeLoading(
            HomeData(
              allowScan: false,
              cameraDescriptionList: [],
            ),
          ),
        ) {
    _cameraService = cameraService ?? GetIt.I<CameraService>();
    _acneScanService = acneScanService ?? GetIt.I<AcneScanService>();
    _visionApiClient = visionApiClient ?? GetIt.I<VisionApiClient>();
    _faceDetectorService =
        faceDetectorService ?? GetIt.I<FaceDetectorService>();
    _faceDetectorService.initialize();
    on<HomeLoaded>(_onLoaded);
    _cameraStreamSubscription = _cameraService.cameraImageStream
        .listen((CameraImage cameraImage) async {
      await _completer?.future;

      _completer = Completer<void>();

      await _acneScanService.select(cameraImage);

      await _acneScanService.getAcneBytes();
      //
      // final List<Face> faces =
      //     await _faceDetectorService.getFacesFromImage(cameraImage);
      //
      // if (faces.isNotEmpty) {
      //   print(faces.first);
      // }
      //
      _completer?.complete();
    });
  }

  late CameraService _cameraService;
  late StreamSubscription _cameraStreamSubscription;
  late FaceDetectorService _faceDetectorService;
  late VisionApiClient _visionApiClient;
  late AcneScanService _acneScanService;
  Completer<void>? _completer;

  Future<void> _onLoaded(
    HomeLoaded event,
    Emitter<HomeState> emit,
  ) async {
    List<CameraDescription> cameras = await availableCameras();
    await _acneScanService.init();
    emit(
      HomeLoadSuccess(
        state.data.copyWith(
          cameraDescriptionList: cameras,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _cameraService.dispose();
    _cameraStreamSubscription.cancel();
    return super.close();
  }
}
