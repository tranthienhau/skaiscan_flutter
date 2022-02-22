import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:math';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// import 'package:google_vision_api/google_vision_api.dart';
import 'package:image/image.dart' as imglib;
import 'package:image/image.dart';
import 'package:skaiscan/services/acne_scan/acne_scan_service.dart';
import 'package:skaiscan/services/camera_service.dart';
import 'package:skaiscan/services/face_detection_service.dart';
import 'package:skaiscan/services/image_converter.dart';
import 'package:skaiscan/utils/utils.dart';
import 'package:skaiscan_ffi/skaiscan_ffi.dart';
import 'package:skaiscan_log_service/skaiscan_log_service.dart';

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
    // _mlService = mlService ?? MLService();
    // _faceDetectorService =
    //     faceDetectorService ?? GetIt.I<FaceDetectorService>();
    _faceDetectorService.initialize();
    on<HomeLoaded>(_onLoaded);
    on<HomeAcneScanned>(_onAcneScanned);
    on<HomeCameraFaceChecked>(_onCameraFaceChecked);
    _cameraStreamSubscription = _cameraService.cameraImageStream
        .listen((CameraImage cameraImage) async {
      _cameraImage = cameraImage;
      if (_cameraCheckCompleter?.isCompleted ?? true) {
        add(HomeCameraFaceChecked(cameraImage));
      }
    });
  }

  // final _lock = Lock();

  final _nativeOpencv = NativeOpencv();
  late CameraService _cameraService;
  late CameraImage _cameraImage;
  late StreamSubscription _cameraStreamSubscription;
  late LogService _logService;
  late FaceDetectorService _faceDetectorService;

  // late MLService _mlService;

  // late FaceDetectorService _faceDetectorService;
  // late VisionApiClient _visionApiClient;
  late AcneScanService _acneScanService;
  Completer<void>? _completer;
  Completer<void>? _cameraCheckCompleter;
  Rectangle<int>? _uiRectangle;

  Uint8List concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  Future<void> _onCameraFaceChecked(
    HomeCameraFaceChecked event,
    Emitter<HomeState> emit,
  ) async {
    if (!(_cameraCheckCompleter?.isCompleted ?? true)) {
      return;
    }

    _cameraCheckCompleter = Completer<void>();

    if (_uiRectangle == null) {
      _calculateCropRectInImage(
        event.cameraImage.height,
        event.cameraImage.width,
      );
    }

    try {
      // int rotation = Platform.isAndroid ? _cameraService.rotation : 0;

      final bytes = await _nativeOpencv.createImageFromCameraImageToBytes(
        yBytes: event.cameraImage.planes[0].bytes,
        uBytes: Platform.isAndroid ? event.cameraImage.planes[1].bytes : null,
        vBytes: Platform.isAndroid ? event.cameraImage.planes[2].bytes : null,
        isYUV: Platform.isAndroid,
        bytesPerRow:
            Platform.isAndroid ? event.cameraImage.planes[1].bytesPerRow : 0,
        bytesPerPixel: Platform.isAndroid
            ? event.cameraImage.planes[1].bytesPerPixel ?? 0
            : 0,
        width: event.cameraImage.width,
        height: event.cameraImage.height,
      );

      // final nativeImage = await _nativeOpencv.createImageFromCameraImageV2(
      //   yBytes: event.cameraImage.planes[0].bytes,
      //   uBytes: Platform.isAndroid ? event.cameraImage.planes[1].bytes : null,
      //   vBytes: Platform.isAndroid ? event.cameraImage.planes[2].bytes : null,
      //   isYUV: Platform.isAndroid,
      //   bytesPerRow:
      //       Platform.isAndroid ? event.cameraImage.planes[1].bytesPerRow : 0,
      //   bytesPerPixel: Platform.isAndroid
      //       ? event.cameraImage.planes[1].bytesPerPixel ?? 0
      //       : 0,
      //   width: event.cameraImage.width,
      //   height: event.cameraImage.height,
      // );

      // final nativeImage = await _nativeOpencv.createImageFromYUV420(
      //   yBytes: event.cameraImage.planes[0].bytes,
      //   //   uBytes: Platform.isAndroid ? event.cameraImage.planes[1].bytes : null,
      //   //   vBytes: Platform.isAndroid ? event.cameraImage.planes[2].bytes : null,
      //   bytesPerRow: event.cameraImage.planes[1].bytesPerRow,
      //   bytesPerPixel: event.cameraImage.planes[1].bytesPerPixel ?? 1,
      //   width: event.cameraImage.planes[0].bytesPerRow,
      //   height: event.cameraImage.height,
      // );

      // final bytes = await _nativeOpencv.convertNativeImageToBytes(nativeImage);

      emit(
        HomeScanComplete(
          state.data.copyWith(
            captureBytes: bytes,
          ),
        ),
      );
      // _nativeOpencv.release(nativeImage);

      _cameraCheckCompleter?.complete();

      return;

      final faces =
          await _faceDetectorService.getFacesFromImage(event.cameraImage);

      if (faces.isNotEmpty) {
        final face = faces.first;

        final isContain = _uiRectangle?.containsRectangle(
              Rectangle(face.left, face.top, face.width, face.height),
            ) ??
            false;

        if (isContain) {
          emit(
            HomeLoadSuccess(
              state.data.copyWith(allowScan: true),
            ),
          );
        } else {
          emit(
            HomeLoadSuccess(
              state.data.copyWith(
                allowScan: false,
              ),
            ),
          );
        }
      }

      // await _mlService.detectFace(flipOutputImage);

      //   event.cameraImage.height,
      // event.cameraImage.width,
      // _nativeOpencv.createImageFromBytes(event.cameraImage.planes[0].bytes);
      // stopwatch.stop();
      // print('native elapsed: ${stopwatch.elapsed.inMilliseconds}');
      // print(stopwatch.isRunning); // false
      // Duration elapsed = stopwatch.elapsed;

      // final receivePort = ReceivePort();

      // stopwatch = Stopwatch();
      // print(stopwatch.elapsedMilliseconds); // 0
      // print(stopwatch.isRunning); // false
      // stopwatch.start();
      // print(stopwatch.isRunning); //

      // await Isolate.spawn(
      //   _decodeIsolate,
      //   DecodeParam(
      //     image: event.cameraImage,
      //     sendPort: receivePort.sendPort,
      //   ),
      // );
      //
      // DecodeResult? decodeResult = await receivePort.first as DecodeResult?;
      //
      // if (decodeResult == null) {
      //   throw Exception('Can not convert camera image to dart image');
      // }
      // stopwatch.stop();
      // print('elapsed: ${stopwatch.elapsed.inMilliseconds}');
      // print(stopwatch.isRunning); // false
      // elapsed = stopwatch.elapsed;
      //
      // emit(
      //   HomeScanComplete(
      //     state.data.copyWith(
      //       captureBytes: decodeResult.bytes,
      //     ),
      //   ),
      // );

      // emit(
      //   HomeScanComplete(
      //     state.data.copyWith(
      //       scanPercent: 0,
      //       captureBytes: resultBytes,
      //     ),
      //   ),
      // );

      _cameraCheckCompleter?.complete();
      return;
    } catch (e, stack) {
      _logService.error('Detect face error', e.toString(), stack);
    }

    if (state.data.allowScan) {
      emit(
        HomeLoadSuccess(
          state.data.copyWith(allowScan: false),
        ),
      );
    }

    // try {
    //   await _cameraService.startImageStream();
    // } catch (_) {}

    _cameraCheckCompleter?.complete();
  }

  Future<void> _onAcneScanned(
    HomeAcneScanned event,
    Emitter<HomeState> emit,
  ) async {
    final bytes = await event.file.readAsBytes();

    // final image = imglib.decodeImage(bytes)!;
    await _acneScanService.select(bytes);
    final acneBytes = await _acneScanService.getAcneBytes();
  }

  Future<void> _onLoaded(
    HomeLoaded event,
    Emitter<HomeState> emit,
  ) async {
    try {
      List<CameraDescription> cameras = await availableCameras();

      // _visionApiClient.setApiConfig(ApiConfig(
      //   url: 'https://vision.googleapis.com',
      //   key: 'AIzaSyBOUAUQY1RRRqhR1vhXRDjZ3axMtvXUtbc',
      //   version: 'v1',
      // ));

      await _acneScanService.init();
      // await _mlService.loadModel();
      emit(
        HomeLoadSuccess(
          state.data.copyWith(
            cameraDescriptionList: cameras,
          ),
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

  void _calculateCropRectInImage(int originWidth, int originHeight) {
    ///calculate rectangle in camera
    final top = ViewUtils.getPercentHeight(percent: 0.1083) - 12;

    final screenWidth = ViewUtils.getPercentWidth(percent: 1.0);

    final screenHeight = ViewUtils.getPercentHeight(percent: 1.0);

    // const left = 27;
    const left = 15;

    final sizeX = screenWidth - left * 2;

    final sizeY = (screenWidth - left * 2) * 1.2 + 12;

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

    final Rect destinationRect =
        _resolvedAlignment.inscribe(sizes.destination, Offset.zero & target);

    // double offsetLeft = left - destinationRect.left;
    // offsetLeft = offsetLeft < 0 ? 0 : offsetLeft;

    double targetLeft = sourceRect.left + left * (1 / scaleX);

    double targetRight = targetLeft + sizeX * (1 / scaleX);

    double targetTop = sourceRect.top + top * (1 / scaleY);

    double targetBottom = targetTop + sizeY * (1 / scaleY);

    _uiRectangle = Rectangle<int>(
      targetLeft.toInt(),
      targetTop.toInt(),
      (targetRight - targetLeft).toInt(),
      (targetBottom - targetTop).toInt(),
    );
  }

  @override
  Future<void> close() {
    _cameraService.dispose();
    _cameraStreamSubscription.cancel();
    return super.close();
  }
}

class DecodeParam {
  final CameraImage image;
  final SendPort sendPort;

  DecodeParam({
    required this.image,
    required this.sendPort,
  });
}

class DecodeResult {
  final Uint8List bytes;
  final String base64Image;

  DecodeResult({required this.bytes, required this.base64Image});
}

void _decodeIsolate(DecodeParam param) {
  // final image = decodeImage(param.image)!;
  imglib.Image? image = convertToImage(param.image);
  // final resizeImage = copyResize(image);
  if (image == null) {
    param.sendPort.send(null);
    return;
  }

  final rotateImage = imglib.copyRotate(image, -90);
  final flipOutputImage = imglib.flipHorizontal(rotateImage);
  final pngBytes = Uint8List.fromList(encodePng(flipOutputImage));

  final base64Image = base64.encode(pngBytes);

  param.sendPort.send(DecodeResult(
    bytes: pngBytes,
    base64Image: base64Image,
  ));
}

class DecodeBase64Param {
  final Uint8List bytes;
  final SendPort sendPort;

  DecodeBase64Param({
    required this.bytes,
    required this.sendPort,
  });
}

void _base64decodeIsolate(DecodeBase64Param param) {
  final base64Image = base64.encode(param.bytes);

  param.sendPort.send(base64Image);
}
