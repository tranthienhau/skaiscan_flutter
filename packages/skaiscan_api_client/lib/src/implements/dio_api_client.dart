import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:skaiscan_api_client/skaiscan_api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:skaiscan_log_service/skaiscan_log_service.dart';
import 'package:logger/logger.dart';
import 'package:mime_type/mime_type.dart';

class DioApiClient extends ApiClient {
  DioApiClient({
    Dio? dio,
    LogService? logService,
  }) {
    _dio = dio ?? Dio()
      ..transformer = IsolateTransformers();
    // _middleWareService = middleWareService ?? GetIt.I<MiddleWareService>();

    if (kDebugMode) {
      final dataLogger = Logger(level: Level.debug);
      // final logger = logService ?? LoggerService('DioApiClient');

      _dio.interceptors.add(
        InterceptorsWrapper(
          onError: (DioError error, ErrorInterceptorHandler handler) {
            final options = error.requestOptions;
//             dataLogger.e(
//                 'DioApiClient Error',
//                 '''
// Http error ${options.method}=========================================>
// ${options.baseUrl}${options.path}
// Response ========================================================
// ${error.response}
// Status code ========================================================
// ${error.response?.statusCode}
// Headers ========================================================
// ${options.headers}
// QueryParameters ================================================
// ${options.queryParameters}
// Body ===========================================================
// ${options.data}
// ================================================================
// ''',
//                 null);
            dataLogger.e(
                'Http error ${options.method}=========================================>');
            dataLogger.e('${options.baseUrl}${options.path}');
            dataLogger.e(
                'Headers ========================================================');
            dataLogger.e(options.headers);
            dataLogger.e(
                'QueryParameters ========================================================');
            dataLogger.e(options.queryParameters);
            dataLogger.e(
                'Body ========================================================');
            dataLogger.e(options.data);
            dataLogger.e(
                'Status ========================================================');
            dataLogger.e('${error.response?.statusCode}');
            dataLogger.e('Error =================================');
            dataLogger.e(error.response);
            dataLogger.e('<==========================================');

            return handler.next(error);
          },
          onResponse: (Response response, ResponseInterceptorHandler handler) {
            final options = response.requestOptions;

            dataLogger.i(
                'Http Response ${options.method}=========================================>');
            dataLogger.i('${options.baseUrl}${options.path}');
            dataLogger.i(
                'Headers ========================================================');
            dataLogger.i(options.headers);
            dataLogger.i(
                'QueryParameters ========================================================');
            dataLogger.i(options.queryParameters);
            dataLogger.i(
                'Body ========================================================');
            dataLogger.i(options.data);
            dataLogger.i(
                'Response ========================================================');
            dataLogger.i(response.data);
            dataLogger
                .i('<=====================================================');

            return handler.next(response);
          },
          onRequest:
              (RequestOptions options, RequestInterceptorHandler handler) {
            dataLogger.i('''
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

  @override
  ApiConfig get apiConfig => _config;

  @override
  void setApiConfig(ApiConfig appConfig) {
    _config = appConfig;
    setup();
  }

  @override
  void config(ApiConfig config) async {
    _config = config;
    setup();
  }

  void setup() {
    _dio.options.baseUrl = _config.url ?? '';
    _dio.options.contentType = ContentType.json.toString();
    _dio.options.connectTimeout = 60 * 1000;
    _dio.options.receiveTimeout = 60 * 1000;
    _dio.options.sendTimeout = 60 * 1000;
    _dio.options.receiveDataWhenStatusError = true;

    _dio.options.headers = {
      'Authorization': 'Bearer ${_config.token}',
      'User-Agent': 'Dart',
      'Accept-Language': _config.language
    };
  }

  @override
  Future<T?> httpGet<T>(
    String path, {
    Map<String, dynamic>? parameters,
    CancelToken? cancelToken,
    bool catchDefaultException = true,
    bool checkMiddleWare = true,
  }) async {
    try {
      final Response<T> result = await _middleWareExecute<T>(
        requestMethod: () {
          return _get<T>(path,
              parameters: parameters, cancelToken: cancelToken);
        },
        checkMiddleWare: checkMiddleWare,
      );

      return result.data;
    } catch (e) {
      throw _getException(e);
    }
  }

  Future<Response<T>> _get<T>(
    String path, {
    Map<String, dynamic>? parameters,
    CancelToken? cancelToken,
  }) async {
    final Response<T> result = await _dio.get<T>(
      path,
      queryParameters: parameters,
      cancelToken: cancelToken,
    );
    return result;
  }

  @override
  Future<T?> httpPost<T>(
    String path, {
    dynamic data,
    Options? options,
    Map<String, dynamic>? parameters,
    CancelToken? cancelToken,
    bool catchDefaultException = true,
    bool checkMiddleWare = true,
  }) async {
    try {
      final Response<T> result = await _middleWareExecute<T>(
        requestMethod: () {
          return _post<T>(path,
              options: options,
              data: data,
              parameters: parameters,
              cancelToken: cancelToken);
        },
        checkMiddleWare: checkMiddleWare,
      );

      return result.data;
    } catch (e) {
      if (catchDefaultException) {
        throw _getException(e);
      }
      rethrow;
    }
  }

  Future<Response<T>> _middleWareExecute<T>({
    required Future<Response<T>> Function() requestMethod,
    bool checkMiddleWare = true,
  }) async {
    try {
      return requestMethod.call();
    } catch (e) {
      // if (e is DioError) {
      //   if (checkMiddleWare) {
      //     final check = await _middleWareService.completeApi(
      //         e.response?.statusCode ?? 0, this);
      //
      //     if (check) {
      //       return requestMethod.call();
      //     }
      //   }
      // }
      throw e;
    }
  }

  Future<Response<T>> _post<T>(
    String path, {
    dynamic data,
    Options? options,
    Map<String, dynamic>? parameters,
    CancelToken? cancelToken,
  }) async {
    Response<T> result = await _dio.post<T>(
      path,
      data: data,
      queryParameters: parameters,
      cancelToken: cancelToken,
      options: options,
    );
    return result;
  }

  @override
  Future<T?> httpPatch<T>(
    String path, {
    dynamic data,
    Options? options,
    Map<String, dynamic>? parameters,
    CancelToken? cancelToken,
    bool catchDefaultException = true,
    bool checkMiddleWare = true,
  }) async {
    try {
      final Response<T> result = await _middleWareExecute<T>(
        requestMethod: () {
          return _dio.patch<T>(
            path,
            data: data,
            queryParameters: parameters,
            cancelToken: cancelToken,
            options: options,
          );
        },
        checkMiddleWare: checkMiddleWare,
      );

      return result.data;
    } catch (e) {
      if (catchDefaultException) {
        throw _getException(e);
      }
      rethrow;
    }
  }

  @override
  Future<T?> httpPut<T>(
    String path, {
    String? url,
    Map<String, dynamic>? parameters,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    bool catchDefaultException = true,
    bool checkMiddleWare = true,
  }) async {
    try {
      Dio dio = Dio();
      final Response<T> response = await _middleWareExecute<T>(
        requestMethod: () async {
          Response<T> response;
          if (url != null) {
            response = await dio.put<T>(url,
                queryParameters: parameters, data: data, options: options);
          } else {
            response = await _dio.put<T>(path,
                queryParameters: parameters, data: data, options: options);
          }
          return response;
        },
        checkMiddleWare: checkMiddleWare,
      );

      return response.data;
    } catch (e) {
      throw _getException(e);
    }
  }

  @override
  Future<T?> httpDelete<T>(
    String path, {
    dynamic data,
    Options? options,
    Map<String, dynamic>? parameters,
    CancelToken? cancelToken,
    bool catchDefaultException = true,
    bool checkMiddleWare = true,
  }) async {
    try {
      final Response<T> response = await _middleWareExecute<T>(
        requestMethod: () {
          return _dio.delete(
            path,
            data: data,
            queryParameters: parameters,
            cancelToken: cancelToken,
            options: options,
          );
        },
        checkMiddleWare: checkMiddleWare,
      );

      return response.data;
    } catch (e, _) {
      if (catchDefaultException) {
        throw _getException(e);
      }
      rethrow;
    }
  }

  @override
  Future<T?> uploadFile<T>(
    String path,
    File file, {
    String key = 'file',
    Map<String, dynamic>? param,
    bool checkMiddleWare = true,
  }) async {
    try {
      final String fileName = file.path.split('/').last;

      String? mimeType = mime(fileName);
      MediaType? contentType;
      if (mimeType != null) {
        final subTypes = mimeType.split('/');
        contentType = MediaType(subTypes.first, subTypes.last);
      }

      final Map<String, dynamic> base = <String, dynamic>{
        key: MultipartFile.fromFileSync(
          file.path,
          filename: fileName.toLowerCase(),
          contentType: contentType,
        ),
      };

      if (param != null) {
        base.addAll(param);
      }
      final FormData formData = FormData.fromMap(base);

      final Response<T> response = await _middleWareExecute<T>(
        requestMethod: () {
          return _dio.post<T>(path, data: formData);
        },
        checkMiddleWare: checkMiddleWare,
      );

      return response.data;
    } on DioError catch (e) {
      throw _getException(e);
    }
  }

  @override
  Future<T?> uploadFileBytes<T>(
    String path,
    Uint8List bytes, {
    String key = 'file',
    String? fileName,
    Map<String, dynamic>? param,
    bool checkMiddleWare = true,
  }) async {
    try {
      String? mimeType = mime(fileName);
      MediaType? contentType;
      if (mimeType != null) {
        final subTypes = mimeType.split('/');
        contentType = MediaType(subTypes.first, subTypes.last);
      }

      final Map<String, dynamic> base = <String, dynamic>{
        key: MultipartFile.fromBytes(
          bytes,
          filename: fileName,
          contentType: contentType,
        ),
      };

      if (param != null) {
        base.addAll(param);
      }

      final FormData formData = FormData.fromMap(base);

      final Response<T> response = await _middleWareExecute<T>(
        requestMethod: () {
          return _dio.put<T>(path, data: formData);
        },
        checkMiddleWare: checkMiddleWare,
      );
      return response.data;
    } on DioError catch (e) {
      throw _getException(e);
    }
  }

  @override
  Future<T?> uploadFiles<T>(
    String path,
    List<File> files, {
    String key = 'files',
    Map<String, dynamic>? param,
    bool checkMiddleWare = true,
  }) async {
    try {
      final List<MultipartFile> multipartFiles = [];
      for (final File file in files) {
        final String fileName = file.path.split('/').last;

        String? mimeType = mime(fileName);
        MediaType? contentType;
        if (mimeType != null) {
          final subTypes = mimeType.split('/');
          contentType = MediaType(subTypes.first, subTypes.last);
        }
        final MultipartFile multipartFile = MultipartFile.fromFileSync(
            file.path,
            filename: fileName,
            contentType: contentType);
        multipartFiles.add(multipartFile);
      }

      final Map<String, dynamic> base = <String, dynamic>{key: multipartFiles};

      if (param != null) {
        base.addAll(param);
      }

      final FormData formData = FormData.fromMap(base);

      final Response<T> response = await _middleWareExecute<T>(
        requestMethod: () {
          return _dio.post<T>(path, data: formData);
        },
        checkMiddleWare: checkMiddleWare,
      );

      return response.data;
    } on DioError catch (e) {
      throw _getException(e);
    }
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
