import 'package:skaiscan/core/app.dart';
import 'package:skaiscan/core/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

extension ThemeColorExtend on ThemeData {
  Color onPrimary() {
    return primaryTextTheme.bodyText2!.color!;
  }

  Color onAccent() {
    return primaryTextTheme.bodyText2!.color!;
  }

  Color lightGrey() {
    return hintColor.withOpacity(0.6);
  }

  Color textColor() {
    return App.isDarkMode ? Colors.white : Colors.black;
  }

  Color noorMatchColor() {
    return App.isDarkMode ? Colors.black : Colors.white;
  }

  Color darkText() {
    return App.isDarkMode ? Colors.white : Colors.black;
  }

  Color focusColor() {
    return App.isDarkMode ? Colors.white : Colors.red;
  }
}

extension ThemeTextStyleExtend on ThemeData {
  TextStyle get contentTextStyle {
    final bodyText2 = textTheme.bodyText2?.copyWith(
      color: AppColors.grey,
    );

    return App.isDarkMode
        ? const TextStyle(
            color: AppColors.grey,
          )
        : const TextStyle(
            color: AppColors.grey,
          );
  }

  TextStyle get titleTextStyle {
    final bodyText1 = textTheme.bodyText1?.copyWith(
      color: AppColors.grey,
    );

    return App.isDarkMode
        ? const TextStyle(
            color: AppColors.grey,
          )
        : const TextStyle(
            color: AppColors.grey,
          );
  }

  TextStyle? get headerTextStyle {
    final headline6 = textTheme.headline6
        ?.copyWith(color: textColor(), fontWeight: FontWeight.bold);

    return headline6;
  }

  TextStyle get smallTextStyle {
    final headline6 = textTheme.headline6?.copyWith(
      color: AppColors.grey,
    );

    return App.isDarkMode
        ? const TextStyle(
            color: AppColors.grey,
          )
        : const TextStyle(
            color: AppColors.grey,
          );
  }

  TextStyle get dialogTitleStyle {
    return App.isDarkMode
        ? const TextStyle(
            color: AppColors.darkText,
          )
        : const TextStyle(
            color: AppColors.darkText,
          );
  }

  TextStyle get dialogMessageStyle {
    return App.isDarkMode
        ? const TextStyle(
            color: AppColors.darkText,
          )
        : const TextStyle(
            color: AppColors.darkText,
          );
  }

  TextStyle get normalStyle {
    return App.isDarkMode
        ? const TextStyle(
            color: AppColors.darkText,
          )
        : const TextStyle(
            color: AppColors.darkText,
          );
  }

  TextStyle get hintStyle {
    return App.isDarkMode
        ? const TextStyle(
            color: AppColors.darkText,
          )
        : const TextStyle(
            color: AppColors.darkText,
          );
  }
}
