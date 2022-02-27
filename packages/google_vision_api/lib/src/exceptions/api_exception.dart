import 'dart:io';


import 'package:google_vision_api/google_vision_api.dart';
import 'package:skaiscan_localizations/skaiscan_localizations.dart';

/// get error from server
class ApiBadRequestException implements Exception {
  ApiBadRequestException({this.error, this.data, this.statusCode});

  factory ApiBadRequestException.fromJson(dynamic json, [int? code]) {
    if (json['error'] is Map) {
      return ApiBadRequestException(
        statusCode: code,
        error: ApiExceptionError.fromError(json['error']),
        data: json['error'],
      );
    } else if (json['data'] is Map) {
      return ApiBadRequestException(
        statusCode: code,
        error: ApiExceptionError.fromData(json['data']),
        data: json['data'],
      );
    } else if (json['message'] is String) {
      return ApiBadRequestException(
        statusCode: code,
        error: ApiExceptionError.fromData(json),
        data: json,
      );
    } else {
      return ApiBadRequestException(
        error: null,
        data: json,
        statusCode: code,
      );
    }
  }

  Map<String, dynamic>? data;
  ApiExceptionError? error;
  int? statusCode;

  @override
  String toString() {
    return error?.toString() ?? 'Server error';
  }
}

class ApiExceptions implements Exception {
  ApiExceptions.unableToProcess() {
    _prefix = '';
    _message = S.current.network_badRequest;
  }

  ApiExceptions.unexpectedError() {
    _prefix = '';
    _message = S.current.network_default('');
  }

  ApiExceptions.noInternetConnection() {
    _prefix = '';
    _message = S.current.network_noInternetConnection;
  }

  ApiExceptions.socketException([SocketException? errorCode]) {
    _prefix = '';

    if (errorCode?.osError?.errorCode == 104) {
      _message =
          '${S.current.network_cannotConnectServer}. Code: 104. Message: ${errorCode!.osError!.message}';
    } else if (errorCode?.osError?.errorCode == 110) {
      _message =
          '${S.current.network_connectTakeALongTime}. Code 110. Message: ${errorCode!.osError!.message}';
    } else if (errorCode?.osError?.errorCode == 113) {
      _message =
          '${S.current.network_cannotConnectServer}. Code 113. Message: ${errorCode!.osError!.message}';
    } else if (errorCode?.osError?.errorCode == 7) {
      _message = S.current.network_noInternetConnection;
    } else {
      _message =
          '${S.current.network_unknownError}. Code ${errorCode!.osError!.errorCode}. Message: ${errorCode.osError!.message}';
    }
  }

  ApiExceptions.requestTimeout() {
    _message = S.current.network_requestTimeout;
  }

  ApiExceptions.gatewayTimeOut() {
    _message = S.current.network_sendTimeout;
  }

  ApiExceptions.sendTimeout() {
    _message = S.current.network_sendTimeout;
  }

  ApiExceptions.defaultE(String message) {
    _message = S.current.network_default(message);
  }

  ApiExceptions.badRequest({required dynamic json}) {
    if (json is Map) {
      _message = _getErrorMessageFromJson(json);
    } else {
      _message = S.current.network_badRequest;
    }
  }

  ApiExceptions.unauthorisedRequest(
      {required dynamic json, required int serverCode}) {
    code = serverCode;

    if (serverCode == 401) {
      _message = S.current.network_authorisedRequest;
    }
    if (serverCode == 403) {
      if (json is Map) {
        _message = _getErrorMessageFromJson(json);
      } else {
        _message = S.current.accountNotAssociate;
      }
    }
  }

  ApiExceptions.notFound() {
    _message = S.current.network_notFound;
  }

  ApiExceptions.internalServerError({required dynamic json, int? code}) {
    if (json is Map) {
      _message = _getErrorMessageFromJson(json, code);
    } else {
      _message = S.current.network_internalServerError;
    }
  }

  ApiExceptions.serviceUnavailable() {
    _message = S.current.network_serviceUnavailable;
  }

  ApiExceptions.requestCancelled() {
    _message = S.current.network_requestCancelled;
  }

  String? _prefix;
  String? _message;
  int? code;
  dynamic innerException;

  @override
  String toString() => '${_prefix ?? ''}$_message';

  String? _getErrorMessageFromJson(Map json, [int? code]) {
    String? message = '';

    if (json['error'] != null) {
      if (json['error'] is Map) {
        final ApiBadRequestException innerException =
            ApiBadRequestException.fromJson(json['error'], code);
        innerException.statusCode = code;
        message = innerException.error!.message;
      } else {
        message = json['error'];
      }
    }

    return message;
  }
}
