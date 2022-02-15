import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'styles/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
class ThemeProvider {
  ThemeProvider._();

  static const _lightFillColor = Colors.black;
  static const _darkFillColor = Colors.white;

  static final Color _lightFocusColor = Colors.black.withOpacity(0.12);

  static const Color _lightHintColor = Color(0xff929DAA);
  static const Color _lightDisableColor = Color(0xff929DAA);
  static const Color _lightBackgroundColor = Colors.white;
  static const Color _lightErrorColor = Color(0xffEB3B5B);
  static const Color _titleColor = Color(0xFF2C333A);

  static final Color _darkFocusColor = Colors.white.withOpacity(0.12);
  static ThemeData lightThemeData = themeData(lightColorScheme, _lightFocusColor);
  static ThemeData dartThemeData = themeData(darkColorScheme, _darkFocusColor);

  static ThemeData themeData(ColorScheme colorScheme, Color focusColor) {
    return ThemeData(
      colorScheme: colorScheme,
      textTheme: _textTheme,
      errorColor: _lightErrorColor,
      // Matches manifest.json colors and background color.
      primaryColor: colorScheme.primary,
      appBarTheme: AppBarTheme(
          color: colorScheme.background,
          elevation: 0,
          // titleTextStyle: ,
          iconTheme: const IconThemeData(color: _titleColor),
          brightness: colorScheme.brightness,
          centerTitle: true,
      ),
      iconTheme: const IconThemeData(color: _titleColor),
      canvasColor: colorScheme.background,
      scaffoldBackgroundColor: colorScheme.background,
      highlightColor: Colors.transparent,
      focusColor: focusColor,
      hintColor: _lightHintColor,
      disabledColor: _lightDisableColor,
      backgroundColor: _lightBackgroundColor,
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: colorScheme.background,
        titleTextStyle: _textTheme.headline6,
        contentTextStyle: _textTheme.bodyText1,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.secondary,
        selectedLabelStyle: _textTheme.bodyText1,
        selectedItemColor: colorScheme.primary,
        unselectedLabelStyle: _textTheme.bodyText1!.copyWith(color: _lightDisableColor),
        unselectedItemColor: _lightDisableColor,
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
          side: BorderSide(color: colorScheme.primary),
        ),
        buttonColor: colorScheme.primary,
        padding: const EdgeInsets.only(left: 16, right: 16),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color.alphaBlend(
          _lightFillColor.withOpacity(0.80),
          _darkFillColor,
        ),
        contentTextStyle: _textTheme.subtitle1!.apply(color: _darkFillColor),
      ),
    );
  }

  static ThemeData getTheme({bool isDarkMode = false}) {
    return ThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        backgroundColor: Colors.white,
        primaryColor:
            isDarkMode ? AppColors.darkPrimaryColor : AppColors.primaryColor,
        accentColor: isDarkMode ? AppColors.darkAccent : AppColors.accent,

        // Icon color
        iconTheme: isDarkMode
            ? const IconThemeData(color: AppColors.darkIcon)
            : const IconThemeData(color: AppColors.icon),
        primaryIconTheme: isDarkMode
            ? const IconThemeData(color: AppColors.darkPrimaryColor)
            : const IconThemeData(color: AppColors.primaryColor),
        // accentIconTheme: isDarkMode
        //     ? const IconThemeData(color: AppColors.darkAccent)
        //     : const IconThemeData(color: AppColors.accent),
        errorColor: isDarkMode ? AppColors.darkRed : AppColors.red,
        // Tab indicator color
        indicatorColor:
            isDarkMode ? AppColors.darkPrimaryColor : AppColors.primaryColor,

        // page background color
        scaffoldBackgroundColor:
            isDarkMode ? AppColors.darkScaffoldBg : AppColors.scaffoldBgColor,

        // Mainly used for Material background color
        canvasColor:
            isDarkMode ? AppColors.darkMaterialBg : AppColors.materialBg,

        // Card, BottomBar, AppBar use Surface
        cardTheme: CardTheme(
          shadowColor: isDarkMode ? AppColors.darkShadow : AppColors.shadow,
          color: isDarkMode ? AppColors.darkSurface : AppColors.surface,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0.0,
          color: isDarkMode ? AppColors.darkSurface : AppColors.surface,
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        bottomAppBarColor:
            isDarkMode ? AppColors.darkSurface : AppColors.surface,
        unselectedWidgetColor: isDarkMode
            ? AppColors.darkUnselectedItemColor
            : AppColors.unselectedItemColor,
        hintColor: isDarkMode ? AppColors.darkHint : AppColors.hint,
        fontFamily: 'SFProDisplay',
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: AppColors.primaryColor.withAlpha(70),
          selectionHandleColor: AppColors.primaryColor,
        ),
        // textTheme: AppTextStyle.getTextTheme(isDarkMode: isDarkMode),
        // primaryTextTheme: AppTextStyle.getTextTheme(isDarkMode: !isDarkMode),
        // accentTextTheme: AppTextStyle.getTextTheme(isDarkMode: true),
        // inputDecorationTheme: InputDecorationTheme(
        //   hintStyle:
        //       isDarkMode ? AppTextStyle.textHint : AppTextStyle.darkTextHint,
        // ),
        dividerColor: AppColors.line,
        dividerTheme: DividerThemeData(
          color: isDarkMode ? AppColors.darkLine : AppColors.line,
          space: 2,
          thickness: 1,
        ),
        cupertinoOverrideTheme: CupertinoThemeData(
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
    );
  }


  static  const ColorScheme lightColorScheme =  ColorScheme(
    primary: AppColors.primaryColor,
    primaryVariant: Color(0xFF117378),
    secondary: Colors.white,
    secondaryVariant: Color(0xFFFAFBFB),
    background: AppColors.background,
    surface: Color(0xFFFAFBFB),
    onBackground: Colors.white,
    error: _lightFillColor,
    onError: _lightFillColor,
    onPrimary: _lightFillColor,
    onSecondary: Color(0xFF322942),
    onSurface: Color(0xFF241E30),
    brightness: Brightness.light,
  );

  static  const ColorScheme darkColorScheme =  ColorScheme(
    primary: Color(0xFFFF8383),
    primaryVariant: Color(0xFF1CDEC9),
    secondary: Color(0xFF4D1F7C),
    secondaryVariant: Color(0xFF451B6F),
    background: Color(0xFF241E30),
    surface: Color(0xFF1F1929),
    onBackground: Color(0x0DFFFFFF),
    // White with 0.05 opacity
    error: _darkFillColor,
    onError: _darkFillColor,
    onPrimary: _darkFillColor,
    onSecondary: _darkFillColor,
    onSurface: _darkFillColor,
    brightness: Brightness.dark,
  );

  static const _regular = FontWeight.w400;
  static const _medium = FontWeight.w500;
  static const _semiBold = FontWeight.w600;
  static const _bold = FontWeight.w700;

  static final TextTheme _textTheme = TextTheme(
    ///appbar title

    headline3: GoogleFonts.roboto(fontWeight: _medium, fontSize: 60.0),
    headline5: GoogleFonts.roboto(fontWeight: _bold, fontSize: 24.0),
    headline6: GoogleFonts.roboto(fontWeight: _medium, fontSize: 21.0),
    caption: GoogleFonts.roboto(fontWeight: _semiBold, fontSize: 14.0),
    subtitle1: GoogleFonts.roboto(fontWeight: _medium, fontSize: 15.0),
    overline: GoogleFonts.roboto(fontWeight: _medium, fontSize: 13.0),
    bodyText1: GoogleFonts.roboto(fontWeight: _regular, fontSize: 17.0),
    subtitle2: GoogleFonts.roboto(fontWeight: _medium, fontSize: 13.0),
    bodyText2: GoogleFonts.roboto(fontWeight: _regular, fontSize: 14.0),
    button: GoogleFonts.roboto(fontWeight: _medium, fontSize: 17.0),
  );
}

Locale? _deviceLocale;

Locale? get deviceLocale => _deviceLocale;

set deviceLocale(Locale? locale) {
  _deviceLocale ??= locale;
}

/// Contain application option. Example is themeMode, locale
class AppOptions {
  const AppOptions({this.themeMode, double? textScaleFactor, Locale? locale})
      : _textScaleFactor = textScaleFactor,
        _locale = locale;

  /// Theme mode of app. light, dark or follow by system.
  final ThemeMode? themeMode;

  /// Text scale factor. System, small, normal, lart
  final double? _textScaleFactor;
  final Locale? _locale;

  Locale? get locale => _locale ?? deviceLocale;

  double? textScaleFactor(BuildContext context, {bool useSentinel = false}) {
    if (_textScaleFactor == -1) {
      return useSentinel ? -1 : MediaQuery.of(context).textScaleFactor;
    } else {
      return _textScaleFactor;
    }
  }

  AppOptions copyWith({
    ThemeMode? themeMode,
    double? textScaleFactor,
    Locale? locale,
  }) {
    return AppOptions(
      themeMode: themeMode ?? this.themeMode,
      textScaleFactor: textScaleFactor ?? _textScaleFactor,
      locale: locale ?? this.locale,
    );
  }

  static AppOptions? of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_ModelBindingScope>()!;
    return scope.modelBindingState.currentModel;
  }

  static void update(BuildContext context, AppOptions newModel) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_ModelBindingScope>()!;
    scope.modelBindingState.updateModel(newModel);
  }
}

/// Scope using Inherited widget.
class _ModelBindingScope extends InheritedWidget {
  const _ModelBindingScope({
    Key? key,
    required this.modelBindingState,
    required Widget child,
  }) : super(key: key, child: child);

  final _ModelBindingState modelBindingState;

  @override
  bool updateShouldNotify(_ModelBindingScope oldWidget) => true;
}

/// Model binding using for app. Wrap it out of MaterialApp
class ModelBinding extends StatefulWidget {
  const ModelBinding({
    Key? key,
    this.initialModel = const AppOptions(),
    this.child,
  }) : super(key: key);

  final AppOptions initialModel;
  final Widget? child;

  @override
  _ModelBindingState createState() => _ModelBindingState();
}

class _ModelBindingState extends State<ModelBinding> {
  AppOptions? currentModel;

  @override
  void initState() {
    super.initState();
    currentModel = widget.initialModel;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updateModel(AppOptions newModel) {
    if (newModel != currentModel) {
      setState(() {
        currentModel = newModel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ModelBindingScope(
      modelBindingState: this,
      child: widget.child!,
    );
  }
}

class ApplyTextOptions extends StatelessWidget {
  const ApplyTextOptions({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final options = AppOptions.of(context);
    final textScaleFactor = options?.textScaleFactor(context) ??
        MediaQuery.of(context).textScaleFactor;

    final Widget widget = MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: textScaleFactor,
      ),
      child: child,
    );

    return widget;
  }
}
