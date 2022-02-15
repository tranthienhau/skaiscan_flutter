import 'package:flutter/material.dart';
import 'package:skaiscan/core/styles/app_colors.dart';
import 'package:skaiscan/core/styles/app_text_style.dart';

import 'dimens.dart';

class BtnStyleProps {
  final EdgeInsetsGeometry? padding;
  final double? radius;

  BtnStyleProps({this.padding, this.radius});
}

class AppButtonStyle {
  static const double defaultRadius = 30;

  static ButtonStyle primaryStyle(
    BuildContext context, {
    BtnStyleProps? props,
  }) {
    return ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            props?.radius ?? defaultRadius,
          ),
        ),
      ),
      padding: props?.padding != null
          ? MaterialStateProperty.resolveWith<EdgeInsetsGeometry>(
              (Set<MaterialState> states) => props!.padding!,
            )
          : null,
      foregroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) => Theme.of(context).backgroundColor,
      ),
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) => states.contains(MaterialState.disabled)
            ? Theme.of(context).unselectedWidgetColor
            : Theme.of(context).primaryColor,
      ),

      // overlayColor: MaterialStateColor.resolveWith(
      //     (states) => Theme.of(context).primaryColor.withOpacity(0.2)),
    );
  }

  static ButtonStyle redAccentStyle(
    BuildContext context, {
    BtnStyleProps? props,
  }) {
    return ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            props?.radius ?? defaultRadius,
          ),
        ),
      ),
      padding: props?.padding != null
          ? MaterialStateProperty.resolveWith<EdgeInsetsGeometry>(
              (Set<MaterialState> states) => props!.padding!,
            )
          : null,
      foregroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) => Theme.of(context).backgroundColor,
      ),
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) => states.contains(MaterialState.disabled)
            ? Theme.of(context).unselectedWidgetColor
            : AppColors.redAccentColor,
      ),

      // overlayColor: MaterialStateColor.resolveWith(
      //     (states) => Theme.of(context).primaryColor.withOpacity(0.2)),
    );
  }

  static ButtonStyle ghostStyle(BuildContext context, {BtnStyleProps? props}) {
    return ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
      ),
      padding: props?.padding != null
          ? MaterialStateProperty.resolveWith<EdgeInsetsGeometry>(
              (Set<MaterialState> states) => props!.padding!,
            )
          : null,

      foregroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) => Theme.of(context).primaryColor,
      ),
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) => states.contains(MaterialState.disabled)
            ? Theme.of(context).unselectedWidgetColor
            : Theme.of(context).backgroundColor,
      ),

      // overlayColor: MaterialStateColor.resolveWith(
      //     (states) => Theme.of(context).primaryColor.withOpacity(0.2)),
    );
  }

  static ButtonStyle textStyle(BuildContext context) {
    return ButtonStyle(
      foregroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) => Theme.of(context).primaryColor,
      ),
      overlayColor: MaterialStateColor.resolveWith(
          (states) => Theme.of(context).primaryColor.withOpacity(0.1)),
    );
  }

  static ButtonStyle whiteStyle(BuildContext context) {
    return ButtonStyle(
      foregroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) => Theme.of(context).backgroundColor,
      ),
      overlayColor: MaterialStateColor.resolveWith(
          (states) => Theme.of(context).backgroundColor.withOpacity(0.1)),
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) => states.contains(MaterialState.disabled)
            ? Theme.of(context).unselectedWidgetColor
            : Theme.of(context).backgroundColor,
      ),
      elevation: MaterialStateProperty.all<double>(0),
    );
  }

  static ButtonStyle textStyleAccent(BuildContext context) {
    return ButtonStyle(
      foregroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) => Theme.of(context).colorScheme.secondary,
      ),
      overlayColor: MaterialStateColor.resolveWith(
          (states) => Theme.of(context).colorScheme.secondary.withOpacity(0.1)),
    );
  }

  static ButtonStyle outlineStyleColor(BuildContext context, Color color) {
    return ButtonStyle(
      foregroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) => color,
      ),
      shape: MaterialStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.rad_XS),
          side: BorderSide(
              width: 1, color: Theme.of(context).unselectedWidgetColor))),
      overlayColor:
          MaterialStateColor.resolveWith((states) => color.withOpacity(0.1)),
    );
  }

  static ButtonStyle outlineStyle(
    BuildContext context, {
    Color? borderColor,
    Color? textColor,
    Color? backgroundColor,
    double? radius,
    double? elevation,
    BtnStyleProps? props,
  }) {
    return ButtonStyle(
      foregroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) =>
            textColor ?? Theme.of(context).primaryColor,
      ),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius ?? Dimens.elevation_L),
          side: BorderSide(
              width: 1, color: borderColor ?? Theme.of(context).primaryColor),
        ),
      ),
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) => states.contains(MaterialState.disabled)
            ? Theme.of(context).unselectedWidgetColor
            : backgroundColor ?? Theme.of(context).backgroundColor,
      ),
      overlayColor: MaterialStateColor.resolveWith(
        (states) =>
            textColor?.withOpacity(0.1) ??
            Theme.of(context).primaryColor.withOpacity(0.1),
      ),
      shadowColor: MaterialStateColor.resolveWith(
        (states) =>
            textColor?.withOpacity(0.1) ??
            Theme.of(context).primaryColor.withOpacity(0.1),
      ),
      elevation: elevation != null
          ? MaterialStateProperty.all<double>(elevation)
          : null,
      padding: props?.padding != null
          ? MaterialStateProperty.resolveWith<EdgeInsetsGeometry>(
              (Set<MaterialState> states) => props!.padding!,
            )
          : null,
    );
  }

  static ButtonStyle colorStyle(BuildContext context, Color color) {
    return ButtonStyle(
      foregroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) => Theme.of(context).primaryColor,
      ),
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) => states.contains(MaterialState.disabled)
            ? Theme.of(context).unselectedWidgetColor
            : color,
      ),
      overlayColor: MaterialStateColor.resolveWith((states) => Colors.white10),
    );
  }

  static ButtonStyle primaryWhiteStyle(BuildContext context) {
    return TextButton.styleFrom(
      primary: Theme.of(context).primaryColor,
      backgroundColor: Colors.white,
    );
  }

  static ButtonStyle accentStyle(BuildContext context,
      {BorderRadiusGeometry? borderRadius}) {
    return ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(Dimens.rad_S),
      )),
      foregroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) => Theme.of(context).primaryColor,
      ),
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) => states.contains(MaterialState.disabled)
            ? Theme.of(context).unselectedWidgetColor
            : Theme.of(context).colorScheme.secondary,
      ),
      overlayColor: MaterialStateColor.resolveWith((states) => Colors.white10),
    );
  }

  static ButtonStyle lightGrey(BuildContext context) {
    return TextButton.styleFrom(
        primary: Colors.grey[700],
        backgroundColor: Colors.grey[600]!.withOpacity(0.3),
        onSurface: Colors.grey);
  }

  static ButtonStyle filterCleanStyle(BuildContext context,
      {BorderRadiusGeometry? borderRadius}) {
    return ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(Dimens.rad_XXXXL),
        )),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) => Theme.of(context).primaryColor),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) => states.contains(MaterialState.disabled)
              ? AppColors.neutral1Color
              : AppColors.neutral1Color,
        ),
        overlayColor:
            MaterialStateColor.resolveWith((states) => Colors.white10),
        elevation: MaterialStateProperty.resolveWith((states) => 0.0),
    );
  }

  static ButtonStyle overDueStyle(BuildContext context,
      {BorderRadiusGeometry? borderRadius}) {
    return filterCleanStyle(context).copyWith(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) =>
          states.contains(MaterialState.disabled)
              ? AppColors.redBackgroundColor
              : AppColors.redBackgroundColor,
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) => AppColors.redAccentColor)
    );
  }
}
