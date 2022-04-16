import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:math';
import 'dart:typed_data';

import 'package:aws_s3_upload/aws_s3_upload.dart';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// import 'package:google_vision_api/google_vision_api.dart';
import 'package:image/image.dart' as imglib;
import 'package:skaiscan/core/app.dart';
import 'package:skaiscan/model/acne.dart';
import 'package:skaiscan/services/acne_scan/acne_scan_service.dart';
import 'package:skaiscan/services/camera_service.dart';
import 'package:skaiscan/services/face_detection_service.dart';
import 'package:skaiscan/utils/utils.dart';
import 'package:skaiscan_ffi/skaiscan_ffi.dart';
import 'package:skaiscan_log_service/skaiscan_log_service.dart';
import 'package:uuid/uuid.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    CameraService? cameraService,
    // FaceDetectorService? faceDetectorService,
    // VisionApiClient? visionApiClient,
    AcneScanService? acneScanService,
    LogService? logService,
    // MLService? mlService,
    FaceDetectorService? faceDetectorService,
  }) : super(
          HomeLoading(
            HomeData(
              allowScan: false,
              cameraDescriptionList: [],
            ),
          ),
        ) {
    _faceDetectorService = faceDetectorService ?? FaceDetectorService();
    _cameraService = cameraService ?? GetIt.I<CameraService>();
    _acneScanService = acneScanService ?? GetIt.I<AcneScanService>();
    // _visionApiClient = visionApiClient ?? GetIt.I<VisionApiClient>();
    _logService = logService ?? LoggerService('HomeBloc');
    _faceDetectorService.initialize();
    on<HomeLoaded>(_onLoaded);
    on<HomeAcneScanned>(_onAcneScanned);
    on<HomeCameraFaceChecked>(_onCameraFaceChecked);

    _cameraStreamSubscription = _cameraService.cameraImageStream
        .listen((CameraImage cameraImage) async {
      /// Check scan task is handling
      if (!(_scanCompleter?.isCompleted ?? true)) {
        return;
      }

      _cameraImage = cameraImage;

      /// Check other task is handing
      if (_cameraCheckCompleter?.isCompleted ?? true) {
        add(HomeCameraFaceChecked(cameraImage));
      }
    });
  }

  final _nativeOpencv = NativeOpencv();
  final _nativeSkaiscan = NativeSkaiscan();
  late CameraService _cameraService;
  late CameraImage _cameraImage;
  late StreamSubscription _cameraStreamSubscription;
  late LogService _logService;
  late FaceDetectorService _faceDetectorService;
  late AcneScanService _acneScanService;
  Completer<void>? _scanCompleter;
  Completer<void>? _cameraCheckCompleter;
  Rectangle<int>? _uiRectangle;

  /// Check face is in correct view
  Future<void> _onCameraFaceChecked(
    HomeCameraFaceChecked event,
    Emitter<HomeState> emit,
  ) async {
    /// Cancel current task when other task is handling
    if (!(_cameraCheckCompleter?.isCompleted ?? true)) {
      return;
    }

    /// Lock task to handle in synchronization
    _cameraCheckCompleter = Completer<void>();

    ///Convert UI rect to image rect
    _uiRectangle ??= _calculateCropRectInImage(
      Platform.isAndroid ? event.cameraImage.height : event.cameraImage.width,
      Platform.isAndroid ? event.cameraImage.width : event.cameraImage.height,
    );

    try {
      /// Get list face from camera image
      final faces =
          await _faceDetectorService.getFacesFromImage(event.cameraImage);

      _logService.info('Face ${faces.length}');

      ///Check if face list is isNotEmpty
      if (faces.isNotEmpty) {
        ///Get first rect face that is contained by [_uiRectangle]
        for (final face in faces) {
          ///check face is contain
          final isContain = _uiRectangle?.containsRectangle(
                Rectangle(face.left, face.top, face.width, face.height),
              ) ??
              false;

          if (isContain) {
            /// Update UI to enable scan button
            emit(
              HomeLoadSuccess(
                state.data.copyWith(allowScan: true, scanPercent: 0),
              ),
            );
            _cameraCheckCompleter?.complete();
            return;
          }
        }

        /// Update UI to disable scan button
        emit(
          HomeLoadSuccess(state.data.copyWith(allowScan: false)),
        );
        _cameraCheckCompleter?.complete();
        return;
      }
    } catch (e, stack) {
      _logService.error('Detect face error', e.toString(), stack);
    }

    /// Update UI to disable scan button
    if (state.data.allowScan) {
      emit(
        HomeLoadSuccess(
          state.data.copyWith(allowScan: false),
        ),
      );
    }

    /// Complete task
    _cameraCheckCompleter?.complete();
  }

  /// Scan acne from camera image
  Future<void> _onAcneScanned(
    HomeAcneScanned event,
    Emitter<HomeState> emit,
  ) async {
    /// Lock task to handle in synchronization
    if (!(_scanCompleter?.isCompleted ?? true)) {
      return;
    }

    _scanCompleter = Completer<void>();

    try {
      await _cameraService.stopImageStream();

      final cameraImage = _cameraImage;

      final data = state.data;

      /// Convert camera image to bytes
      final bytes = await _nativeOpencv.convertCameraImageToBytes(
        yBytes: cameraImage.planes[0].bytes,
        uBytes: Platform.isAndroid ? cameraImage.planes[1].bytes : null,
        vBytes: Platform.isAndroid ? cameraImage.planes[2].bytes : null,
        isYUV: Platform.isAndroid,
        bytesPerRow: Platform.isAndroid ? cameraImage.planes[1].bytesPerRow : 0,
        bytesPerPixel:
            Platform.isAndroid ? cameraImage.planes[1].bytesPerPixel ?? 0 : 0,
        width: cameraImage.width,
        height: cameraImage.height,
      );

      ///Update progress to 10% for UI
      emit(HomeScanInProgress(data.copyWith(scanPercent: 10)));

      final image = imglib.decodeImage(bytes);

      if (image == null) {
        _scanCompleter?.complete();

        emit(HomeScanFailure(
            state.data, 'Can not scan acne. Please try again!'));
        return;
      }

      ///Update progress to 20% for UI
      emit(HomeScanInProgress(data.copyWith(scanPercent: 20)));

      /// Feed camera image to [_acneScanService] to get acne mask
      await _acneScanService.selectImage(image);

      ///Update progress to 40% for UI
      emit(HomeScanInProgress(data.copyWith(scanPercent: 40)));

      late Uint8List result;
      try {
        /// Get scan acne mask
        result = await _acneScanService.getAcneBytes();
      } catch (e) {
        await _acneScanService.loadSmallModel();
        result = await _acneScanService.getAcneBytes();
      }

      ///Update progress to 70% for UI
      emit(HomeScanInProgress(data.copyWith(scanPercent: 60)));

      /// Apply color for acne mask
      Uint8List finalResult = await _nativeSkaiscan.applyAcneMaskColorV2(
        maskBytes: Uint8List.fromList(result),
        originBytes: bytes,
        maskHeight: _acneScanService.outPutSize,
        maskWidth: _acneScanService.outPutSize,
        originHeight: cameraImage.height,
        originWidth: cameraImage.width,
      );

      ///Filter to get only value different 0, 0-> background
      // final acneListFilter = result.toSet().where((element) => element != 0);

      ///Convert filter array to acne list
      /// 1 -> papules
      /// 2 -> blackheads
      /// 3 -> pustules
      /// 4 -> whiteheads
      // const acneListResult = Acne.values;

      ///Crop image with UI rect
      final rect = _uiRectangle;
      if (rect != null) {
        ///Update progress to 80% for UI
        emit(HomeScanInProgress(data.copyWith(scanPercent: 80)));

        finalResult = await _nativeOpencv.cropImageBytes(
          bytes: finalResult,
          rect: CvRectangle(
            left: rect.left,
            top: rect.top,
            width: rect.width,
            height: rect.height,
          ),
        );
      }

      const uuid = Uuid();

      // try {
      //   await AwsS3.uploadBytes(
      //     bytes: imglib.encodeJpg(image),
      //     accessKey: 'AKIASTXIMYTMY4CZ37ZO',
      //     bucket: 'skaiscan-collect',
      //     fileName: '${uuid.v1()}.jpeg',
      //     secretKey: 'hh7l5aV6hyt0L5CmDDbBTXSCe2VlAkjaa6N/OGRC',
      //     // acl: ,
      //     destDir: '',
      //     region: 'eu-central-1',
      //   );
      // } catch (e, stack) {
      //   _logService.error('Failed upload image', e.toString(), stack);
      // }

      ///Update progress to 100% for UI and complete scan
      emit(
        HomeScanComplete(
          data: state.data.copyWith(
            captureBytes: finalResult,
            scanPercent: 100,
            allowScan: false,
          ),
          acneList: Acne.values,
        ),
      );
    } catch (e, stack) {
      _logService.error('HomeScanFailure', e.toString(), stack);
      emit(HomeScanFailure(state.data, e.toString()));
    }

    _cameraService.startImageStream();
    _scanCompleter?.complete();
  }

  Future<void> _onLoaded(
    HomeLoaded event,
    Emitter<HomeState> emit,
  ) async {
    try {
      if (state.data.cameraDescriptionList.isNotEmpty) {
        return;
      }

      /// Get all available cameras
      List<CameraDescription> cameras = await availableCameras();

      ///Init acne scan service
      await _acneScanService.init();

      emit(
        HomeLoadSuccess(
          state.data.copyWith(cameraDescriptionList: cameras),
        ),
      );
    } catch (e, stack) {
      emit(
        HomeLoadFailure(
          state.data,
          e.toString(),
        ),
      );

      _logService.error('HomeLoadFailure', e.toString(), stack);
    }
  }

  /// Apply box fit algorithm to convert crop rectangle from UI view to Camera image
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

  ///Calculate rectangle from UI to crop rectangle in image
  Rectangle<int> _calculateCropRectInImage(int originWidth, int originHeight) {
    const offsetX = 15;
    const offsetY = 15;

    double originTop = ViewUtils.getPercentHeight(percent: 0.08) + 10;
    if (originTop < 60) {
      originTop = 60;
    }

    ///calculate rectangle in camera
    final top =
        originTop + MediaQuery.of(App.overlayContext!).padding.top - offsetY;

    final screenWidth = ViewUtils.getPercentWidth(percent: 1.0);

    final screenHeight = ViewUtils.getPercentHeight(percent: 1.0);

    const left = 27 - offsetX;

    final sizeX = screenWidth - left * 2;

    final sizeY = (screenWidth - left * 2) * 1.2 + offsetY;

    Alignment _resolvedAlignment = Alignment.center.resolve(TextDirection.ltr);

    final Size target = Size(screenWidth, screenHeight);

    // final Size childSize = Size(event.cameraImage.width.toDouble(),
    //     event.cameraImage.height.toDouble());
    final Size childSize =
        Size(originWidth.toDouble(), originHeight.toDouble());

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

    double targetRight = targetLeft + sizeX * (1 / scaleX);

    double targetTop = sourceRect.top + top * (1 / scaleY);

    double targetBottom = targetTop + sizeY * (1 / scaleY);

    return Rectangle<int>(
      targetLeft.toInt(),
      targetTop.toInt(),
      (targetRight - targetLeft).toInt(),
      (targetBottom - targetTop).toInt(),
    );
  }

  @override
  Future<void> close() {
    _cameraService.dispose();
    _faceDetectorService.dispose();
    _acneScanService.dispose();
    _cameraStreamSubscription.cancel();
    return super.close();
  }
}
