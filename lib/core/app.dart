import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class App {
  App._();

  static final Logger _logger = Logger();

  static GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();

  static BuildContext? get overlayContext =>
      navigationKey.currentState?.overlay?.context;

  static Future<dynamic> pushNamed(String routeName, [Object? params]) {
    _logger.d("navigateTo $routeName with ${params ?? ''}");
    return navigationKey.currentState!.pushNamed(routeName, arguments: params);
  }

  static Future<dynamic> popAndPushNamed(String routeName, [Object? params]) {
    _logger.d("navigateTo $routeName with ${params ?? ''}");
    return navigationKey.currentState!.popAndPushNamed(routeName, arguments: params);
  }

  static Future<dynamic> pushReplacementNamed(String routeName,
      [Object? params]) {
    _logger.d("navigateAndReplaceTo $routeName with ${params ?? ''}");
    return navigationKey.currentState!
        .pushReplacementNamed(routeName, arguments: params);
  }

  static Future<dynamic> pushNamedAndPopUntil(String routeName,
      [Object? params, String? popRouteName]) {
    _logger.d("navigateAndPopUntil $popRouteName with ${params ?? ''}");

    return navigationKey.currentState!.pushNamedAndRemoveUntil(
        routeName, (Route<dynamic> route) => false,
        arguments: params);
  }

  static bool canPop() {
    return navigationKey.currentState!.canPop();
  }

  static void pop({dynamic result}) {
    if (navigationKey.currentState!.canPop()) {
      navigationKey.currentState!.pop(result);
      _logger.d('pop to last route');
    } else {
      _logger.d('can"t pop');
    }
  }

  static void popUntilRoute({dynamic result, required String route}) {
    return navigationKey.currentState!.popUntil(ModalRoute.withName(route));
  }

  static bool get isDarkMode {
    final ThemeData theme = Theme.of(App.overlayContext!);
    return theme.brightness == Brightness.dark;
  }
}
