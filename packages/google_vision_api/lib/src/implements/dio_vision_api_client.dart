import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_vision_api/google_vision_api.dart';
import 'package:skaiscan_log_service/skaiscan_log_service.dart';

class DioVisionApiClient implements VisionApiClient {
  DioVisionApiClient({Dio? dio, LogService? logService}) {
    _dio = dio ?? Dio()
      ..transformer = IsolateTransformers();
    // _middleWareService = middleWareService ?? GetIt.I<MiddleWareService>();
    _logService = logService ?? LoggerService('DioVisionApiClient');
    if (kDebugMode) {
      // final dataLogger = Logger(level: Level.debug);
      // final dataLogger = logService ?? LoggerService('DioVisionApiClient');

      _dio.interceptors.add(
        InterceptorsWrapper(
          onError: (DioError error, ErrorInterceptorHandler handler) {
            final options = error.requestOptions;
            _logService.error(
                'DioApiClient Error',
                '''
Http error ${options.method}=========================================>
${options.baseUrl}${options.path}
Response ========================================================
${error.response}
Status code ========================================================
${error.response?.statusCode}
Headers ========================================================
${options.headers}
QueryParameters ================================================
${options.queryParameters}
Body ===========================================================
${options.data}
================================================================
''',
                null);

            return handler.next(error);
          },
          onResponse: (Response response, ResponseInterceptorHandler handler) {
            final options = response.requestOptions;
            _logService.info('''
Http Response ${options.method}=========================================>
${options.baseUrl}${options.path}
Headers ========================================================
${json.encode(options.headers)}
QueryParameters ================================================
${json.encode(options.queryParameters)}
Body ===========================================================
${options.data is Map ? json.encode(options.data) : options.data}
Response ========================================================
${response.data}
================================================================
''');

            return handler.next(response);
          },
          onRequest:
              (RequestOptions options, RequestInterceptorHandler handler) {
                _logService.info('''
Http ${options.method}=========================================>
${options.baseUrl}${options.path}
Headers ========================================================
${json.encode(options.headers)}
QueryParameters ================================================
${json.encode(options.queryParameters)}
Body ===========================================================
${options.data is Map ? json.encode(options.data) : options.data}
================================================================
''');
            return handler.next(options);
          },
        ),
      );
    }
  }

  late ApiConfig _config;
  late Dio _dio;
  late LogService _logService;

  @override
  ApiConfig get apiConfig => _config;

  @override
  Future<GoogleVisionResult<FaceAnnotation>> detectFaces(
      List<VisionRequest<FaceFeatureRequest>> requests) async {
    try {
      final requestData = {
        'requests': requests.map(
          (request) => request.toJson(),
        ).toList()
      };

      final response = await _dio.post<Map<String, dynamic>>(
        '/${_config.version}/images:annotate',
        queryParameters: {'key': _config.key},
        data: requestData,
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Can not get data');
      }

      return GoogleVisionResult<FaceAnnotation>.fromJson(data);
    } catch (e, stack) {
      _logService.error('DetectFace error', e.toString(), stack);
      throw _getException(e);
    }
  }

  @override
  void setApiConfig(ApiConfig appConfig) async {
    _config = appConfig;
    setup();
  }

  void setup() {
    _dio.options.baseUrl = _config.url ?? '';
    _dio.options.contentType = ContentType.json.toString();
    _dio.options.connectTimeout = 60 * 1000;
    _dio.options.receiveTimeout = 60 * 1000;
    _dio.options.sendTimeout = 60 * 1000;
    _dio.options.receiveDataWhenStatusError = true;

    // _dio.options.headers = {
    //   'Authorization': 'Bearer ${_config.token}',
    //   'User-Agent': 'Dart',
    //   'Accept-Language': _config.language
    // };
  }

  Exception _getException(error) {
    if (error is Exception) {
      if (error is DioError) {
        try {
          switch (error.type) {
            case DioErrorType.connectTimeout:
              return ApiExceptions.requestTimeout();
            case DioErrorType.sendTimeout:
              return ApiExceptions.sendTimeout();
            case DioErrorType.receiveTimeout:
              return ApiExceptions.sendTimeout();
            case DioErrorType.response:
              switch (error.response!.statusCode) {
                case 401:
                case 403:
                case 400:
                case 429:
                case 500:
                  return ApiBadRequestException.fromJson(
                      error.response!.data, error.response!.statusCode);
                case 404:
                  return ApiExceptions.notFound();
                case 503:
                  return ApiExceptions.serviceUnavailable();
                case 504:
                  return ApiExceptions.gatewayTimeOut();
                default:
                  return ApiExceptions.defaultE(
                      '${error.response!.statusCode}');
              }

            case DioErrorType.cancel:
              return ApiExceptions.requestCancelled();

            case DioErrorType.other:
              if (error.error is SocketException) {
                return ApiExceptions.socketException(error.error);
              }
              break;

            default:
              return ApiExceptions.defaultE('');
          }
        } catch (e) {
          return ApiExceptions.defaultE('');
        }
      } else if (error is SocketException) {
        return ApiExceptions.socketException(error);
      } else {
        return ApiExceptions.unexpectedError();
      }
    } else {
      if (error.toString().contains('is not subtype of')) {
        return ApiExceptions.unableToProcess();
      } else {
        return ApiExceptions.unexpectedError();
      }
    }
    return ApiExceptions.defaultE('');
  }
}
