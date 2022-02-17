import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_vision_api/google_vision_api.dart';
import 'package:image/image.dart' as imglib;
import 'package:skaiscan/services/acne_scan/acne_scan_service.dart';
import 'package:skaiscan/services/camera_service.dart';
import 'package:skaiscan/services/face_detection_service.dart';
import 'package:skaiscan/utils/utils.dart';
import 'package:skaiscan_ffi/skaiscan_ffi.dart';

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
    on<HomeAcneScan>(_onAcneScan);
    // _cameraStreamSubscription = _cameraService.cameraImageStream
    //     .listen((CameraImage cameraImage) async {
    //
    // });
  }

  final _nativeOpencv = NativeOpencv();
  late CameraService _cameraService;
  late StreamSubscription _cameraStreamSubscription;
  late FaceDetectorService _faceDetectorService;
  late VisionApiClient _visionApiClient;
  late AcneScanService _acneScanService;
  Completer<void>? _completer;

  Future<void> _onAcneScan(
    HomeAcneScan event,
    Emitter<HomeState> emit,
  ) async {
    // await _completer?.future;

    _completer = Completer<void>();

    ///calculate rectangle in camera
    final top = ViewUtils.getPercentHeight(percent: 0.1083);

    final screenWidth = ViewUtils.getPercentWidth(percent: 1.0);
    final screenHeight = ViewUtils.getPercentHeight(percent: 1.0);

    const left = 27;

    final size = screenWidth - left * 2;

    final right = left + size;

    final bottom = top + size;

    // print('width ${cameraImage.width}, height: ${cameraImage.height}');

    // imglib.Image image = imglib.Image.;

    final bytes = await event.file.readAsBytes();

    final image = imglib.decodeImage(bytes)!;

    // final scaleX = image.width / size;
    //
    // final scaleY = image.height / size;
    //
    // final scaleTop = top * scaleY;
    //
    // final scaleLeft = left * scaleX;
    //
    // final scaleSizeX = size * scaleX;
    //
    // final scaleSizeY = size * scaleY;
    //
    // final scaleRight = scaleLeft + scaleSizeX;
    //
    // final scaleBottom = scaleTop + scaleSizeY;


    Alignment _resolvedAlignment = Alignment.center.resolve(TextDirection.ltr);
    // final Size childSize = Size(screenWidth, screenHeight);
    final Size target = Size(screenWidth, screenHeight);
    // final Size target = Size(image.width.toDouble(), image.height.toDouble());
    final Size childSize =
        Size(image.width.toDouble(), image.height.toDouble());
    final FittedSizes sizes = applyBoxFit(BoxFit.cover, childSize, target);
    final double scaleX = sizes.destination.width / sizes.source.width;
    final double scaleY = sizes.destination.height / sizes.source.height;
    final Rect sourceRect =
        _resolvedAlignment.inscribe(sizes.source, Offset.zero & childSize);
    final Rect destinationRect =
        _resolvedAlignment.inscribe(sizes.destination, Offset.zero & target);

    // double offsetLeft = left - destinationRect.left;
    // offsetLeft = offsetLeft < 0 ? 0 : offsetLeft;

    double targetLeft = sourceRect.left + left * scaleX;

    double targetRight = targetLeft + size * scaleX;

    double targetTop = sourceRect.top + top * scaleY;

    double targetBottom = targetTop + size * scaleY;

    final nativeImage = await _nativeOpencv.createImageFromBytes(bytes);

    await _nativeOpencv.drawRect(
      nativeImage,
      CvRectangle(
        width: (targetRight - targetLeft).toInt(),
        height: (targetBottom - targetTop).toInt(),
        x: targetLeft.toInt(),
        y: targetTop.toInt(),
      ),
    );

    final result = await _nativeOpencv.convertNativeImageToBytes(nativeImage);

    await _nativeOpencv.dispose(nativeImage);

    emit(HomeScanComplete(state.data, result));

    // _completer?.complete();
  }

  FittedSizes applyBoxFit(BoxFit fit, Size inputSize, Size outputSize) {
    if (inputSize.height <= 0.0 ||
        inputSize.width <= 0.0 ||
        outputSize.height <= 0.0 ||
        outputSize.width <= 0.0) {
      return const FittedSizes(Size.zero, Size.zero);
    }

    Size sourceSize, destinationSize;
    switch (fit) {
      case BoxFit.fill:
        sourceSize = inputSize;
        destinationSize = outputSize;
        break;
      case BoxFit.contain:
        sourceSize = inputSize;
        if (outputSize.width / outputSize.height >
            sourceSize.width / sourceSize.height) {
          destinationSize = Size(
              sourceSize.width * outputSize.height / sourceSize.height,
              outputSize.height);
        } else {
          destinationSize = Size(outputSize.width,
              sourceSize.height * outputSize.width / sourceSize.width);
        }
        break;
      case BoxFit.cover:
        if (outputSize.width / outputSize.height >
            inputSize.width / inputSize.height) {
          sourceSize = Size(inputSize.width,
              inputSize.width * outputSize.height / outputSize.width);
        } else {
          sourceSize = Size(
              inputSize.height * outputSize.width / outputSize.height,
              inputSize.height);
        }
        destinationSize = outputSize;
        break;
      case BoxFit.fitWidth:
        sourceSize = Size(inputSize.width,
            inputSize.width * outputSize.height / outputSize.width);
        destinationSize = Size(outputSize.width,
            sourceSize.height * outputSize.width / sourceSize.width);
        break;
      case BoxFit.fitHeight:
        sourceSize = Size(
            inputSize.height * outputSize.width / outputSize.height,
            inputSize.height);
        destinationSize = Size(
            sourceSize.width * outputSize.height / sourceSize.height,
            outputSize.height);
        break;
      case BoxFit.none:
        sourceSize = Size(math.min(inputSize.width, outputSize.width),
            math.min(inputSize.height, outputSize.height));
        destinationSize = sourceSize;
        break;
      case BoxFit.scaleDown:
        sourceSize = inputSize;
        destinationSize = inputSize;
        final double aspectRatio = inputSize.width / inputSize.height;
        if (destinationSize.height > outputSize.height) {
          destinationSize =
              Size(outputSize.height * aspectRatio, outputSize.height);
        }
        if (destinationSize.width > outputSize.width) {
          destinationSize =
              Size(outputSize.width, outputSize.width / aspectRatio);
        }
        break;
    }

    return FittedSizes(sourceSize, destinationSize);
  }

  Future<void> _onLoaded(
    HomeLoaded event,
    Emitter<HomeState> emit,
  ) async {
    List<CameraDescription> cameras = await availableCameras();

    // await _acneScanService.init();

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
