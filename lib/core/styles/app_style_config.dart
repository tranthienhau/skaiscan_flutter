import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppStyleConfig {
  AppStyleConfig({Locale? locale, ThemeMode? themeMode, double? textScale}) {
    _textScale = textScale ?? 0;
    _locale = locale ?? const Locale('en', 'US');
    _themeMode = themeMode ?? ThemeMode.light;
  }

  Locale? _locale;
  double? _textScale;
  ThemeMode? _themeMode;

  Locale get locale => _locale ??= const Locale('en', 'US');

  double? get textScale => _textScale;

  ThemeMode get themeMode => _themeMode ??= ThemeMode.system;
}
