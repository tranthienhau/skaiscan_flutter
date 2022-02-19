import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:math';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_vision_api/google_vision_api.dart';
import 'package:image/image.dart' as imglib;
import 'package:image/image.dart';
import 'package:skaiscan/services/acne_scan/acne_scan_service.dart';
import 'package:skaiscan/services/camera_service.dart';
import 'package:skaiscan/services/image_converter.dart';
import 'package:skaiscan/utils/utils.dart';
import 'package:skaiscan_ffi/skaiscan_ffi.dart';
import 'package:skaiscan_log_service/skaiscan_log_service.dart';
import 'package:synchronized/synchronized.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    CameraService? cameraService,
    // FaceDetectorService? faceDetectorService,
    VisionApiClient? visionApiClient,
    AcneScanService? acneScanService,
    LogService? logService,
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
    _logService = logService ?? LoggerService('HomeBloc');
    // _faceDetectorService =
    //     faceDetectorService ?? GetIt.I<FaceDetectorService>();
    // _faceDetectorService.initialize();
    on<HomeLoaded>(_onLoaded);
    on<HomeAcneScanned>(_onAcneScanned);
    on<HomeCameraFaceChecked>(_onCameraFaceChecked);
    _cameraStreamSubscription = _cameraService.cameraImageStream
        .listen((CameraImage cameraImage) async {
      if (_cameraCheckCompleter?.isCompleted ?? true) {
        add(HomeCameraFaceChecked(cameraImage));
      }
    });
  }

  final _lock = Lock();

  final _nativeOpencv = NativeOpencv();
  late CameraService _cameraService;
  late StreamSubscription _cameraStreamSubscription;
  late LogService _logService;

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

    if (_uiRectangle == null) {
      _calculateCropRectInImage(
        event.cameraImage.height,
        event.cameraImage.width,
      );
    }

    try {
      final receivePort = ReceivePort();

      await Isolate.spawn(
        _decodeIsolate,
        DecodeParam(
          image: event.cameraImage,
          sendPort: receivePort.sendPort,
        ),
      );

      Stopwatch stopwatch = Stopwatch();
      print(stopwatch.elapsedMilliseconds); // 0
      print(stopwatch.isRunning); // false
      stopwatch.start();
      print(stopwatch.isRunning); // true

      final bytes = event.cameraImage.planes[0].bytes;

      imglib.Image? image = convertToImage(event.cameraImage);

      if (image == null) {
        throw Exception('Can not convert image');
      }

      final pngBytes = imglib.encodePng(image);
      await _nativeOpencv.rotate90CounterClockwiseFlipResize(
        bytes: Uint8List.fromList(pngBytes),
        flip: 1,
        resizeWidth: -1,
        resizeHeight: -1,
      );

      // _nativeOpencv.createImageFromBytes(event.cameraImage.planes[0].bytes);
      stopwatch.stop();
      print('elapsed: ${stopwatch.elapsed.inMilliseconds}');
      print(stopwatch.isRunning); // false
      Duration elapsed = stopwatch.elapsed;

      DecodeResult? decodeResult = await receivePort.first as DecodeResult?;

      if (decodeResult == null) {
        throw Exception('Can not convert camera image to dart image');
      }

      //
      // emit(
      //   HomeScanComplete(
      //     state.data.copyWith(
      //       captureBytes: decodeResult.bytes,
      //     ),
      //   ),
      // );

      final List<VisionRequest<FaceFeatureRequest>> requests = [
        VisionRequest<FaceFeatureRequest>(
          image: VisionImageRequest(content: decodeResult.base64Image),
          features: <FaceFeatureRequest>[
            FaceFeatureRequest(
              type: 'FACE_DETECTION',
              maxResults: 1,
            )
          ],
        )
      ];

      stopwatch = Stopwatch();
      print(stopwatch.elapsedMilliseconds); // 0
      print(stopwatch.isRunning); // false
      stopwatch.start();
      print(stopwatch.isRunning); // tr

      final GoogleVisionResult<FaceAnnotation> result =
          await _visionApiClient.detectFaces(requests);

      stopwatch.stop();
      print('elapsed: ${stopwatch.elapsed.inMilliseconds}');
      print(stopwatch.isRunning); // false
      elapsed = stopwatch.elapsed;

      if (result.responses.isNotEmpty) {
        final faceAnnotations = result.responses.first.faceAnnotations;

        if (faceAnnotations.isNotEmpty) {
          final faceAnnotation = faceAnnotations.first;
          final fdBoundingPoly = faceAnnotation.fdBoundingPoly;

          if (fdBoundingPoly != null &&
              fdBoundingPoly.verticesList.isNotEmpty) {
            int minX = -1;
            int maxX = -1;
            int minY = -1;
            int maxY = -1;

            for (final vertices in fdBoundingPoly.verticesList) {
              final x = vertices.x;
              final y = vertices.y;

              if (x == null || y == null) {
                throw Exception('Can not find boundingPoly in face');
              }

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

            final intersection = _uiRectangle?.intersection(rectangle);

            final isContain =
                _uiRectangle?.containsRectangle(rectangle) ?? false;

            if (isContain && !state.data.allowScan) {
              emit(
                HomeLoadSuccess(
                  state.data.copyWith(allowScan: true),
                ),
              );

              _cameraCheckCompleter?.complete();

              return;
            }

            //
            // NativeImage nativeImage =
            //     await _nativeOpencv.createImageFromBytes(decodeResult.bytes);
            //
            // await _nativeOpencv.drawRect(
            //   nativeImage,
            //   CvRectangle(
            //     y: rectangle.top,
            //     x: rectangle.left,
            //     height: rectangle.height,
            //     width: rectangle.width,
            //   ),
            // );
            //
            // await _nativeOpencv.drawRect(
            //   nativeImage,
            //   CvRectangle(
            //     y: regionRectangle.top,
            //     x: regionRectangle.left,
            //     height: regionRectangle.height,
            //     width: regionRectangle.width,
            //   ),
            // );
            //
            // final resultBytes =
            //     await _nativeOpencv.convertNativeImageToBytes(nativeImage);
            //
            // await _nativeOpencv.release(nativeImage);

          }
        }
      }
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
    print('compelte');
    // await _completer?.future;
    //
    // _completer = Completer<void>();
    //
    //
    // try {
    //   ///calculate rectangle in camera
    //   final top = ViewUtils.getPercentHeight(percent: 0.1083);
    //
    //   final screenWidth = ViewUtils.getPercentWidth(percent: 1.0);
    //
    //   final screenHeight = ViewUtils.getPercentHeight(percent: 1.0);
    //
    //   const left = 27;
    //
    //   final size = screenWidth - left * 2;
    //
    //
    //   // String base64Image = base64Encode(bytes);
    //
    //
    //
    //   Alignment _resolvedAlignment =
    //       Alignment.center.resolve(TextDirection.ltr);
    //
    //   final Size target = Size(screenWidth, screenHeight);
    //
    //   final Size childSize =
    //       Size(image.width.toDouble(), image.height.toDouble());
    //
    //   final FittedSizes sizes = applyBoxFit(BoxFit.cover, childSize, target);
    //
    //   final double scaleX = sizes.destination.width / sizes.source.width;
    //
    //   final double scaleY = sizes.destination.height / sizes.source.height;
    //
    //   final Rect sourceRect =
    //       _resolvedAlignment.inscribe(sizes.source, Offset.zero & childSize);
    //
    //   // final Rect destinationRect =
    //   //     _resolvedAlignment.inscribe(sizes.destination, Offset.zero & target);
    //
    //   // double offsetLeft = left - destinationRect.left;
    //   // offsetLeft = offsetLeft < 0 ? 0 : offsetLeft;
    //
    //   double targetLeft = sourceRect.left + left * (1 / scaleX);
    //
    //   double targetRight = targetLeft + size * (1 / scaleX);
    //
    //   double targetTop = sourceRect.top + top * (1 / scaleY);
    //
    //   double targetBottom = targetTop + size * (1 / scaleY);
    //
    //   final nativeImage = await _nativeOpencv.createImageFromBytes(bytes);
    //
    //   emit(
    //     HomeScanInProgress(
    //       state.data.copyWith(
    //         scanPercent: 20,
    //         captureBytes: bytes,
    //       ),
    //     ),
    //   );
    //
    //   await _nativeOpencv.drawRect(
    //     nativeImage,
    //     CvRectangle(
    //       width: (targetRight - targetLeft).toInt(),
    //       height: (targetBottom - targetTop).toInt(),
    //       x: targetLeft.toInt(),
    //       y: targetTop.toInt(),
    //     ),
    //   );
    //
    //   emit(
    //     HomeScanInProgress(
    //       state.data.copyWith(
    //         scanPercent: 40,
    //         captureBytes: bytes,
    //       ),
    //     ),
    //   );
    //
    //   final result = await _nativeOpencv.convertNativeImageToBytes(nativeImage);
    //
    //   emit(
    //     HomeScanInProgress(
    //       state.data.copyWith(
    //         scanPercent: 60,
    //         captureBytes: bytes,
    //       ),
    //     ),
    //   );
    //
    //   await _nativeOpencv.dispose(nativeImage);
    //
    //   emit(
    //     HomeScanInProgress(
    //       state.data.copyWith(
    //         scanPercent: 100,
    //         captureBytes: bytes,
    //       ),
    //     ),
    //   );
    //
    //   emit(HomeScanComplete(
    //       state.data.copyWith(
    //         scanPercent: 0,
    //         captureBytes: bytes,
    //       ),
    //       result));
    // } catch (e, _) {
    //   final data = state.data;
    //
    //   final newData = HomeData(
    //     cameraDescriptionList: data.cameraDescriptionList,
    //     allowScan: data.allowScan,
    //     captureBytes: null,
    //     scanPercent: 0,
    //   );
    //   emit(HomeScanFailure(newData, e.toString()));
    //
    //   try {
    //     _cameraService.startImageStream();
    //   } catch (_) {}
    // }
    //
    // _completer?.complete();
  }

  Future<void> _onLoaded(
    HomeLoaded event,
    Emitter<HomeState> emit,
  ) async {
    List<CameraDescription> cameras = await availableCameras();

    _visionApiClient.setApiConfig(ApiConfig(
      url: 'https://vision.googleapis.com',
      key: 'AIzaSyBOUAUQY1RRRqhR1vhXRDjZ3axMtvXUtbc',
      version: 'v1',
    ));

    await _acneScanService.init();

    emit(
      HomeLoadSuccess(
        state.data.copyWith(
          cameraDescriptionList: cameras,
        ),
      ),
    );
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
    final top = ViewUtils.getPercentHeight(percent: 0.1083);

    final screenWidth = ViewUtils.getPercentWidth(percent: 1.0);

    final screenHeight = ViewUtils.getPercentHeight(percent: 1.0);

    const left = 27;

    final sizeX = screenWidth - left * 2;

    final sizeY = (screenWidth - left * 2) * 1.2;

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
