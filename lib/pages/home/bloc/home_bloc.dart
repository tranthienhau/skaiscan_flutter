import 'dart:async';
import 'dart:math' as math;
import 'dart:math';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_vision_api/google_vision_api.dart';
import 'package:image/image.dart' as imglib;
import 'package:skaiscan/services/acne_scan/acne_scan_service.dart';
import 'package:skaiscan/services/camera_service.dart';
import 'package:skaiscan/utils/utils.dart';
import 'package:skaiscan_ffi/skaiscan_ffi.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    CameraService? cameraService,
    // FaceDetectorService? faceDetectorService,
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
    // _faceDetectorService =
    //     faceDetectorService ?? GetIt.I<FaceDetectorService>();
    // _faceDetectorService.initialize();
    on<HomeLoaded>(_onLoaded);
    on<HomeAcneScan>(_onAcneScan);
    on<HomeCameraFaceChecked>(_onCameraFaceChecked);
    _cameraStreamSubscription = _cameraService.cameraImageStream
        .listen((CameraImage cameraImage) async {
      if (_cameraCheckCompleter?.isCompleted ?? true) {
        // add(HomeCameraFaceChecked(cameraImage));
      }
    });
  }

  final _nativeOpencv = NativeOpencv();
  late CameraService _cameraService;
  late StreamSubscription _cameraStreamSubscription;

  // late FaceDetectorService _faceDetectorService;
  late VisionApiClient _visionApiClient;
  late AcneScanService _acneScanService;
  Completer<void>? _completer;
  Completer<void>? _cameraCheckCompleter;
  Rectangle<int>? _uiRectangle;

  Future<void> _onCameraFaceChecked(
    HomeCameraFaceChecked event,
    Emitter<HomeState> emit,
  ) async {
    if (!(_cameraCheckCompleter?.isCompleted ?? true)) {
      return;
    }

    _cameraCheckCompleter = Completer<void>();

    if (_uiRectangle != null) {
      ///calculate rectangle in camera
      final top = ViewUtils.getPercentHeight(percent: 0.1083);

      final screenWidth = ViewUtils.getPercentWidth(percent: 1.0);

      final screenHeight = ViewUtils.getPercentHeight(percent: 1.0);

      const left = 27;

      final size = screenWidth - left * 2;

      Alignment _resolvedAlignment =
          Alignment.center.resolve(TextDirection.ltr);

      final Size target = Size(screenWidth, screenHeight);

      final Size childSize = Size(event.cameraImage.width.toDouble(),
          event.cameraImage.height.toDouble());

      final FittedSizes sizes = applyBoxFit(BoxFit.cover, childSize, target);

      final double scaleX = sizes.destination.width / sizes.source.width;

      final double scaleY = sizes.destination.height / sizes.source.height;

      final Rect sourceRect =
          _resolvedAlignment.inscribe(sizes.source, Offset.zero & childSize);

      // final Rect destinationRect =
      //     _resolvedAlignment.inscribe(sizes.destination, Offset.zero & target);

      // double offsetLeft = left - destinationRect.left;
      // offsetLeft = offsetLeft < 0 ? 0 : offsetLeft;

      double targetLeft = sourceRect.left + left * (1 / scaleX);

      double targetRight = targetLeft + size * (1 / scaleX);

      double targetTop = sourceRect.top + top * (1 / scaleY);

      double targetBottom = targetTop + size * (1 / scaleY);

      _uiRectangle = Rectangle<int>(
        targetLeft.toInt(),
        targetTop.toInt(),
        (targetRight - targetLeft).toInt(),
        (targetBottom - targetTop).toInt(),
      );
    }

    final List<VisionRequest<FaceFeatureRequest>> requests = [
      VisionRequest<FaceFeatureRequest>(
        image: VisionImageRequest(content: ''),
        features: <FaceFeatureRequest>[
          FaceFeatureRequest(
            type: 'FACE_DETECTION',
            maxResults: 1,
          )
        ],
      )
    ];

    final GoogleVisionResult<FaceAnnotation> result =
        await _visionApiClient.detectFaces(requests);

    if (result.responses.isNotEmpty) {
      final faceAnnotations = result.responses.first.faceAnnotations;

      if (faceAnnotations.isNotEmpty) {
        final faceAnnotation = faceAnnotations.first;
        final boundingPoly = faceAnnotation.boundingPoly;

        if (boundingPoly != null && boundingPoly.verticesList.isNotEmpty) {
          int minX = -1;
          int maxX = -1;
          int minY = -1;
          int maxY = -1;

          for (final vertices in boundingPoly.verticesList) {
            final x = vertices.x;
            final y = vertices.y;

            if (minX == -1) {
              minX = x;
            } else if (minX > x) {
              minX = x;
            }

            if (maxX == -1) {
              maxX = x;
            } else if (maxX < x) {
              maxX = x;
            }

            if (minY == -1) {
              minY = y;
            } else if (minY > y) {
              minY = y;
            }

            if (maxY == -1) {
              maxY = y;
            } else if (maxY < y) {
              maxY = y;
            }
          }

          Rectangle<int> rectangle = Rectangle<int>(
            minX,
            minY,
            maxX - minX,
            maxY - minY,
          );
        }
      }
    }

    _cameraCheckCompleter?.complete();
  }

  Future<void> _onAcneScan(
    HomeAcneScan event,
    Emitter<HomeState> emit,
  ) async {
    await _completer?.future;

    _completer = Completer<void>();

    try {
      ///calculate rectangle in camera
      final top = ViewUtils.getPercentHeight(percent: 0.1083);

      final screenWidth = ViewUtils.getPercentWidth(percent: 1.0);

      final screenHeight = ViewUtils.getPercentHeight(percent: 1.0);

      const left = 27;

      final size = screenWidth - left * 2;

      final bytes = await event.file.readAsBytes();

      // String base64Image = base64Encode(bytes);

      final image = imglib.decodeImage(bytes)!;

      Alignment _resolvedAlignment =
          Alignment.center.resolve(TextDirection.ltr);

      final Size target = Size(screenWidth, screenHeight);

      final Size childSize =
          Size(image.width.toDouble(), image.height.toDouble());

      final FittedSizes sizes = applyBoxFit(BoxFit.cover, childSize, target);

      final double scaleX = sizes.destination.width / sizes.source.width;

      final double scaleY = sizes.destination.height / sizes.source.height;

      final Rect sourceRect =
          _resolvedAlignment.inscribe(sizes.source, Offset.zero & childSize);

      // final Rect destinationRect =
      //     _resolvedAlignment.inscribe(sizes.destination, Offset.zero & target);

      // double offsetLeft = left - destinationRect.left;
      // offsetLeft = offsetLeft < 0 ? 0 : offsetLeft;

      double targetLeft = sourceRect.left + left * (1 / scaleX);

      double targetRight = targetLeft + size * (1 / scaleX);

      double targetTop = sourceRect.top + top * (1 / scaleY);

      double targetBottom = targetTop + size * (1 / scaleY);

      final nativeImage = await _nativeOpencv.createImageFromBytes(bytes);

      emit(
        HomeScanInProgress(
          state.data.copyWith(scanPercent: 20),
        ),
      );

      await _nativeOpencv.drawRect(
        nativeImage,
        CvRectangle(
          width: (targetRight - targetLeft).toInt(),
          height: (targetBottom - targetTop).toInt(),
          x: targetLeft.toInt(),
          y: targetTop.toInt(),
        ),
      );

      emit(
        HomeScanInProgress(
          state.data.copyWith(scanPercent: 40),
        ),
      );

      final result = await _nativeOpencv.convertNativeImageToBytes(nativeImage);

      emit(
        HomeScanInProgress(
          state.data.copyWith(scanPercent: 60),
        ),
      );

      await _nativeOpencv.dispose(nativeImage);

      emit(
        HomeScanInProgress(
          state.data.copyWith(scanPercent: 100),
        ),
      );

      emit(HomeScanComplete(state.data.copyWith(scanPercent: 0), result));
    } catch (e, _) {
      emit(
        HomeScanFailure(state.data.copyWith(scanPercent: 0), e.toString()),
      );

      try {
        _cameraService.startImageStream();
      } catch (_) {}
    }

    _completer?.complete();
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
