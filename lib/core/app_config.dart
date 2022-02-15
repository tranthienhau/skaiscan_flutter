import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppConfig {
  AppConfig({Locale? locale, ThemeMode? themeMode, double? textScale}) {
    _textScale = textScale ?? 0;
    _locale = locale ?? const Locale('vi');
    _themeMode = themeMode ?? ThemeMode.light;
  }

  Locale? _locale;
  double? _textScale;
  ThemeMode? _themeMode;

  Locale get locale => _locale ??= const Locale('vi');

  double? get textScale => _textScale;

  ThemeMode get themeMode => _themeMode ??= ThemeMode.system;
}
