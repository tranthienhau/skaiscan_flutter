import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class ApiConfig {
  ApiConfig({
    this.url,
    this.token,
    this.version,
    this.language,
    this.refreshToken,
  });

  String? url;
  String? token;
  String? refreshToken;
  String? version;
  String? language;

  ApiConfig copyWith({
    String? url,
    String? token,
    String? version,
    String? language,
    String? refreshToken,
  }) {
    return ApiConfig(
      token: token ?? this.token,
      url: url ?? this.url,
      version: version ?? this.version,
      language: language ?? this.language,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}

abstract class ApiClient {
  void setApiConfig(ApiConfig appConfig);

  ApiConfig get apiConfig;

  Future<T?> httpGet<T>(
    String path, {
    Map<String, dynamic>? parameters,
    CancelToken? cancelToken,
    bool catchDefaultException = true,
    bool checkMiddleWare = true,
  });

  Future<T?> httpPost<T>(
    String path, {
    dynamic data,
    CancelToken? cancelToken,
    bool catchDefaultException = true,
    bool checkMiddleWare = true,
  });

  Future<T?> httpPatch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? parameters,
    CancelToken? cancelToken,
    bool catchDefaultException = true,
    bool checkMiddleWare = true,
  });

  Future<T?> httpPut<T>(
    String path, {
    String? url,
    Map<String, dynamic>? parameters,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    bool catchDefaultException = true,
    bool checkMiddleWare = true,
  });

  Future<T?> httpDelete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? parameters,
    CancelToken? cancelToken,
    bool catchDefaultException = true,
    bool checkMiddleWare = true,
  });

  ///[key] key of file in form data
  Future<T?> uploadFile<T>(
    String path,
    File file, {
    String key = 'Attachment',
    Map<String, dynamic>? param,
    bool checkMiddleWare = true,
  });

  ///[key] key of file in form data
  Future<T?> uploadFileBytes<T>(
    String path,
    Uint8List bytes, {
    String key = 'Attachment',
    String? fileName,
    Map<String, dynamic>? param,
    bool checkMiddleWare = true,
  });

  ///[key] key of file in form data
  Future<T?> uploadFiles<T>(
    String path,
    List<File> files, {
    String key = 'Attachment',
    Map<String, dynamic>? param,
    bool checkMiddleWare = true,
  });

  void config(ApiConfig config);
}
