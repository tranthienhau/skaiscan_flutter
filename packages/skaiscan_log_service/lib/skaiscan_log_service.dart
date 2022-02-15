library skaiscan_log_service;

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

abstract class LogService {
  LogService([this.className]);

  final String? className;

  void info(Object message);

  void warning(Object message);

  void error(Object message, Object error, StackTrace? stackTrade);

  void debug(Object message);
}

class MyLogOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (int i = 0; i < event.lines.length; i++) {
      debugPrint(event.lines[i]);
    }
  }
}

class LoggerService extends LogService {
  LoggerService([String? className]) : super(className);

  var logger = Logger(
    filter: DevelopmentFilter(),
    // output: MyLogOutput(),
    printer: PrefixPrinter(PrettyPrinter()),
  );

  @override
  void debug(Object message) {
    logger.d('${className ?? 'LoggerLogService'}: $message');
  }

  @override
  void error(Object message, Object error, StackTrace? stackTrade) {
    logger.e('${className ?? 'LoggerLogService'}: $message', error, stackTrade);
  }

  @override
  void info(Object message) {
    logger.i('${className ?? 'LoggerLogService'} >>>>>>>>>>>>>>>>>>>>>>>>>');
    logger.i(message);
    logger.i('<<<<<<<<<<<<<<<<<<<<<<<<<<< ${className ?? 'LoggerLogService'}');
  }

  @override
  void warning(Object message) {
    logger.w('${className ?? 'LoggerLogService'}: $message');
  }
}
