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
//
//   static const Color bgGray_ = Color(0xFFE6E6E6);
//   static const Color darkBgGray_ = Color(0xFF242526);
//
//   static const Color bgGrayPriceBorder = Color(0xFFBBBBBB);
//   static const Color darkBgGrayPriceBorder = Color(0xFFBBBBBB);
//
//   static const Color bgGrayPrice = Color(0xFFFAFAFA);
//   static const Color darkBgGrayPrice = Color(0xFFFAFAFA);
//
//   static const Color basePrice = Color(0xFFCA1C26);
//   static const Color darkBasePrice = Color(0xFFCA1C26);
//
//   static const Color baseDiscount = Color(0xFF919191);
//   static const Color darkBaseDiscount = Color(0xFF919191);
//
//   static const Color h2 = Color(0xFF16796F);
//   static const Color darkH2 = Color(0xFF16796F);
//
//   static const Color lightTag = Color(0xFFFBFAF9);
//   static const Color darkTag = Color(0xFFFBFAF9);
//
//   static const Color lightBorderTag = Color(0xFFEFEFEF);
//   static const Color darkBorderTag = Color(0xFFEFEFEF);
//
//   static const Color lightTextTag = Color(0xFF8E8B87);
//   static const Color darkTextTag = Color(0xFF8E8B87);
//   static const Color lightFreeshipBanner = Color(0xFF0A947C);
//   static const Color darkFreeshipBanner = Color(0xFF0A947C);
  static const Color selectColor = Color(0xFFC4C4C4);
//
//   // static Color get primary => Get.App.isDarkMode ? darkAppMain : appMain;
//   //
//   // static Color get secondary => Get.App.isDarkMode ? darkLine : line;
//   //
//   // static Color get onPrimary => Get.App.isDarkMode ? darkSurface : surface;
//   //
//   // static Color get headingColor => Get.App.isDarkMode ? darkH2 : h2;
//   //
//   // static Color get tag => Get.App.isDarkMode ? darkTag : lightTag;
//
// /*  Other color declare here.*/
//   static const error = Color(0xffEB3B5B);
//   static const successColor = Color(0xff28A745);
//   static const urlColor = Color(0xff2395FF);
//   static const draftColor = Color(0xff828A9A);
//   static const warningColor = Color(0xffFFC107);
//   static const titleColor = Color(0xFF2C333A);
//   static const firstColorGradient = Color(0xFFFF9425);
//   static const secondColorGradient = Color(0xFFFF9425);
//   static const thirdColorGradient = Color(0xFFFF6720);
//   static const borderButtonColor = Color(0xFFE9EDF2);

//   static const borderTextFieldColor = Color(0xffe9edf2);
//   static const iconColor = Color(0xFF929DAA);
//   static const textDefaultColor = Color(0xFF929DAA);
//
//   static const underlineBorderOTPColor = Color(0xFFCDD3DB);
//   static const dialogError = Color(0xFFFF6720);
//   static const dialogSuccess = Color(0xFF28A745);
//   static const success = Color(0xFF28A745);
//   static const dialogWarning = Color(0xFFFFC107);
//   static const Color infoColor = Color(0xff17A2B8);
//
//   static const searchIconColors = Color(0xFF212121);
//   static const searchBackground = Color(0xffF8F9FB);
//   static const secondBackground = Color(0xffF8F9FB);
//
//   static const searchClear = Color(0xffA7B2BF);
//   static const searchDivide = Color(0xff6B7280);
//   static const shadowCardColor = Color.fromRGBO(65, 20, 0, 0.16);
//   static const textOrderColor = Color(0xFF6B7280);
//   static const hintColor = Color(0xffCDD3DB);
//
//   static const mainUserInfo = Color(0xff888993);
//
//   ///color close button filter drawer
//   static const closeDrawer = Color(0xFF707070);
//
//   ///english language color
//   static const english = Color(0xff2b82d3);
//
//   static const badgeText = Colors.white;
//   static const badgeBackground = Color(0xffFF2020);
//   static const cardColor = Color(0xFFFFFFFF);
//   static const backgroundBlurColor = Color(0xFFF8F9FB);
//   static const threeDots = Color(0xFFDADADA);
//   static const borderContainerBorder = Colors.grey;
//
//   ///delivered order color
//   static const delivered = Color(0xFF28A745);
//
//   ///delivering order color
//   static const delivering = Color(0xFFFFC107);
//
//   ///canceled order color
//   static const canceled = Color(0xFFEB3B5B);
//
//   ///approved order color
//   static const approved = Color(0xff2395FF);
//
//   ///pending order color
//   static const pending = Color(0xFF828A9A);
//
//   ///filter selected order color
//   static const filterSelectedColor = Color(0xFFFFECE4);
//
//   ///filter reset button
//   static const resetButton = Color(0xFFF0F1F3);
//
//   ///title of app state
//   static const appStateTitle = Color(0xff131D26);
//
//   ///color of barcode in home page
//   static const barcodeOpacity = Color(0xffFFBC91);
//
//   ///color of underline in loading order in home page
//   static const underlineColor = Color(0xffE4E5E8);
//
//   ///color use for skimmer
//   static const skimmerBaseColor = Color(0xffF2F2F2);
//   static const matchPaging = Color(0xffA1A5AC);
//
//   ///color use for highlight skimmer
//   static const skimmerHighlightColor = Color(0xffFBFBFB);
//   static const otpCountDown = Color(0xff52d185);
//   static const otpAlmostExpired = Color(0xfff64746);
//
//   static const Color violet = Color(0xff5141E1);
//   static const Color lightBlue = Color(0xff71CBE9);
//   static const Color teal = Color(0xff26CFBD);
//   static const Color yellow = Color(0xffE1A141);
//   static const Color mainCamera = Color(0xffADADAD);
//   static const Color religion = Color(0xff90D8F0);
//   static const Color language = Color(0xff0075F9);
//   static const Color online = Color(0xff53D185);
//   static const Color offline = Color(0xFFF74646);
//   static const Color backgroundPercentProfile = Color(0xFFEAEEF2);
//
//   static const Color paymentFirstGradient = Color(0xffFFDAD7);
//   static const Color paymentSecondGradient = Color(0xffFFFFFF);
//
//   static const backgroundReplyMessageColor = Color(0xFFF8F8F8);
//
//   static const timeMessageColor = Color(0xFFA7B2BF);
//
//   static const shopBackgroundMessageColor = Color(0xFFF0F1F3);
}
