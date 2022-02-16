import 'dart:async';

import 'package:skaiscan/skaiscan_app.dart';
import 'package:skaiscan/core/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

final Logger _logger = Logger();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  await Hive.initFlutter();
  setupLocator();

  BlocOverrides.runZoned(
    () {
      runZonedGuarded(
        () async {
          runApp(const SkaiscanApp());
        },
        onError,
      );
    },
    blocObserver: MyBlocObserver(),
  );
}

Future<void> onError(Object error, StackTrace stack) async {
  _logger.e('Application', error, stack);
  // Sentry.captureException(
  //   error,
  //   stackTrace: stack,
  // );
}

class MyBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    _logger.i('onCreate -- ${bloc.runtimeType}');
    super.onCreate(bloc);
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    _logger.i(
        'onEvent -- ${bloc.runtimeType}, Event: ${event.runtimeType}, message: ${event.toString()}');
    super.onEvent(bloc, event);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    _logger.i(
        'onEvent -- ${bloc.runtimeType}, CurrentState: {State: ${change.currentState}, message: ${change.currentState.toString()}}, '
        'NextState: {State: ${change.nextState}, message: ${change.nextState.toString()}}');
    super.onChange(bloc, change);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    _logger.i('onError -- ${bloc.runtimeType}, $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    _logger.i('onClose -- ${bloc.runtimeType}');
    super.onClose(bloc);
  }
}
