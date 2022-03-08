import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:skaiscan/core/locator.dart';
import 'package:skaiscan/skaiscan_app.dart';

final Logger _logger = Logger();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  setupLocator();
  // Initialize Firebase.
  await Firebase.initializeApp();
  // if (kDebugMode) {
  //   await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  // }

  BlocOverrides.runZoned(
    () {
      runZonedGuarded(
        () async {
          FlutterError.onError =
              FirebaseCrashlytics.instance.recordFlutterError;

          runApp(const SkaiscanApp());
        },
        onError,
      );
    },
    blocObserver: MyBlocObserver(),
  );
}

Future<void> onError(Object error, StackTrace stack) async {
  if (kDebugMode) {
    _logger.e('Application', error, stack);
  } else {
    FirebaseCrashlytics.instance.recordError(error, stack);
  }
}

class MyBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    if (kDebugMode) {
      _logger.i('onCreate -- ${bloc.runtimeType}');
    }

    super.onCreate(bloc);
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    if (kDebugMode) {
      _logger.i(
          'onEvent -- ${bloc.runtimeType}, Event: ${event.runtimeType}, message: ${event.toString()}');
    }

    super.onEvent(bloc, event);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    if (kDebugMode) {
      _logger.i(
          'onEvent -- ${bloc.runtimeType}, CurrentState: {State: ${change.currentState}, message: ${change.currentState.toString()}}, '
          'NextState: {State: ${change.nextState}, message: ${change.nextState.toString()}}');
    }

    super.onChange(bloc, change);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      _logger.i('onError -- ${bloc.runtimeType}, $error');
    }

    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    if (kDebugMode) {
      _logger.i('onClose -- ${bloc.runtimeType}');
    }

    super.onClose(bloc);
  }
}
