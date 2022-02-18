import 'package:flutter/material.dart';
import 'package:skaiscan/core/app.dart';

/// This class used to declare the colors that using on the app
class AppColors {
  AppColors._();

  static const error = Color(0xffEB3B5B);
  static const successColor = Color(0xff28A745);
  static const urlColor = Color(0xff2395FF);
  static const draftColor = Color(0xff828A9A);
  static const warningColor = Color(0xffFFC107);
  static const titleColor = Color(0xFF2C333A);
  static const badgeText = Colors.white;
  static const badgeBackground = Color(0xffFF2020);
  static const transparent = Color(0x00FFFFFF);
  static const List<Color> colorList = [
    Color(0xFFA6D3FC),
    Color(0xFFCAB3E9),
    Color(0xFF60C9C5),
    Color(0xFFF7C262),
    Color(0xFFFAAD91)
  ];

  static Color getAccentColor() {
    return App.isDarkMode ? darkAccent : accent;
  }

  static Color getLinkColor() {
    return App.isDarkMode ? darkLink : link;
  }

  static Color getDarkText() {
    return App.isDarkMode
        ? Colors.white.withOpacity(0.9)
        : Colors.black.withOpacity(0.9);
  }

  static Color getWarningColor() {
    return App.isDarkMode ? const Color(0xFFF7C262) : Colors.orange;
  }

  static Color getErrorColor() {
    return App.isDarkMode ? darkRed : red;
  }

  static Color getSuccessColor() {
    return App.isDarkMode ? Colors.lightGreen : Colors.green;
  }

  static Color getIconDark() {
    return App.isDarkMode ? icon : darkIcon;
  }

  static const Color loginGradientStart = Color(0xFFfbab66);
  static const Color loginGradientEnd = Color(0xFFf7418c);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: <Color>[loginGradientStart, loginGradientEnd],
    stops: <double>[0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const MaterialColor materialWhite = MaterialColor(
    0xFFFFFFFF,
    <int, Color>{
      50: Color(0xFFFFFFFF),
      100: Color(0xFFFFFFFF),
      200: Color(0xFFFFFFFF),
      300: Color(0xFFFFFFFF),
      400: Color(0xFFFFFFFF),
      500: Color(0xFFFFFFFF),
      600: Color(0xFFFFFFFF),
      700: Color(0xFFFFFFFF),
      800: Color(0xFFFFFFFF),
      900: Color(0xFFFFFFFF),
    },
  );

  static getTransparentGrey() {
    return Colors.grey[600]!.withOpacity(0.3);
  }

  /// The primary color. Apply for default button, appbar, title
  static const primaryColor = Color(0xFFFFB28A);
  static const primaryColor2 = Color(0xFFFFB28A);
  static const primaryLight= Color(0xFFF7D3C0);

  static const secondary1Color = Color(0xFFD1ECFA);
  static const secondary2Color = Color(0xFFD1ECFA);

  static const neutral1Color = Color(0xFFF2FAFE);
  static const neutral2Color = Color(0xFFF3F7FF);

  static const systemBlueColor = Color(0xFF007AFF);

  static const textColor = Color(0xFF424242);
  static const black = Colors.black;

  static const redAccentColor = Color(0xFFFC003C);
  static const greenAccentColor = Color(0xFF00E45B);
  static const yellowAccentColor = Color(0xFFFFE600);

  static const redBackgroundColor = Color(0xFFFFECF1);
  static const background = Color(0xFFFFFFFF);
  static const dotLine = Color(0xFFFFDF8B);
  static const Color grey = Color(0xFFF6F6F6);
  static const Color grey2 = Color(0xFF8EAFC2);
  static const Color grey3 = Color(0xFFD0E1EB);
  static const Color grey4 = Color(0xFFECF1F4);
  static const Color grey5 = Color(0xFFD5E1E8);
  static const Color grey6 = Color(0xFF19181A);
  static const Color grey7 = Color(0xFF1E1E1E);
  static const Color grey8 = Color(0xFFE8F4FA);
  static const Color lightGrey = Color(0xFFF8F7FA);
  static const Color separator = Color(0xFF545458);

  static const Color darkText = Color(0xFFFAFBFC);
  static const textButtonColor = Color(0xFFFFFFFF);

//   static const Color separator = Color(0xFFCED4D9);
//   static const Color iconBackground = Color(0xFFCFD0DA);
  static const Color accent = Color(0xfff8a954);
  static const Color darkAccent = Color(0xffd58d48);
  static const Color icon = Colors.white;
  static const Color darkIcon = Color(0xFF4D4D4D);
  static const Color darkPrimaryColor = Color(0xffFBFBFD);
  static const Color separator2 = Color(0xff545458);

//
//   static const Color shadowColor = Color(0xff698ABA);
//   static const Color appShadowColor = Color(0xff556395);
//   static const Color mainProfileColor = Color(0xff5141E1);
//   static const Color secondaryBackground = Color(0xffF7F7F8);
//   static const Color dash = Color(0xffA1A5AC);
//
//   static Color otpBackground = const Color(0xff8B8DA7).withAlpha(30);
//   static Color bottomSheetBackground = const Color.fromARGB(255, 45, 45, 45);
//
//   static const MaterialColor appMainSwatch = Colors.red;
//
//   // static const MaterialColor darkAppMainSwatch = materialWhite;
//
  static const Color shadow = Colors.black;
  static const Color darkShadow = Color(0xFF121212);

//   static const Color avatarShadow = Color(0xFF254E6B);
//
  static const Color surface = Color(0xffffffff);
  static const Color darkSurface = Color(0xFF363640);

//
  static const Color scaffoldBgColor = Color(0xffF6F6F8);
  static const Color darkScaffoldBg = Color(0xFF27272F);

//
  static const Color materialBg = Color(0xFFFFFFFF);
  static const Color darkMaterialBg = Color(0xFF27272F);

//
//   static const Color text = Color(0xFF393A4B);

//
//
//   static const Color darkTextGray = Color(0xFF666666);
//
//   static const Color errorBox = Color(0xFFEF5050);
//
  static const Color textHeading = Color(0xFF393A4B);
  static const Color darkTextHeading = Color(0xFF666666);

//
  static const Color bgGray = Color(0xFFF6F6F6);
  static const Color darkBgGray = Color(0xFF1F1F1F);

//
  static const Color line = Color(0xFFE3E3E3);
  static const Color darkLine = Color(0xFF3A3C3D);

//
  static const Color red = Color(0xFFFF4759);
  static const Color darkRed = Color(0xFFE03E4E);

//
  static const Color link = Color(0xFF00A5C7);
  static const Color darkLink = Color(0xFF00C6E8);

//
//   static const Color textDisabled = Color(0xFFD4E2FA);
//   static const Color darkTextDisabled = Color(0xFFCEDBF2);
//
  static const Color buttonDisabled = Color(0xFF96BBFA);
  static const Color darkButtonDisabled = Color(0xFF83A5E0);

//
  static const Color unselectedItemColor = Color(0xffececec);
  static const Color darkUnselectedItemColor = Color(0xFF4D4D4D);

//
  static const Color hint = Color(0xff777B7C);
  static const Color darkHint = Color(0xFF4D4D4D);

  static const Color selectColor = Color(0xFFC4C4C4);


  ///Acne colors
  static const Color papules = Color.fromARGB(255, 250, 224, 150);
  static const Color blackheads = Color.fromARGB(255, 243, 181, 145);
  static const Color pustules = Color.fromARGB(255, 215, 138, 136);
  static const Color whiteheads = Color.fromARGB(255, 165, 161, 236);
}
