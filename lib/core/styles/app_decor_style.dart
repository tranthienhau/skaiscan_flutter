import 'package:skaiscan/all_file/import_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppDecorStyle {
  static BoxDecoration bottomShadowDecor(
      {Color surfaceColor = Colors.transparent}) {
    return BoxDecoration(boxShadow: const <BoxShadow>[
      BoxShadow(color: Colors.grey, blurRadius: 1.0, offset: Offset(0.0, 1.0))
    ], color: surfaceColor);
  }

  static BoxDecoration topShadowDecor(
      {Color surfaceColor = Colors.transparent}) {
    return BoxDecoration(boxShadow: <BoxShadow>[
      BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 1.0,
          spreadRadius: 1.0,
          offset: Offset(0.0, -1.0))
    ], color: surfaceColor);
  }

  static BoxDecoration boxShadow(
      {double rad = 20,
      BorderRadiusGeometry? borderRadius,
      double spreadRadius = 1.8,
      double blurRadius = 1,
      double shadowOpacity = 0.18,
      Color? shadowColor,
      BoxShape? shape,
      Offset? offset,
      Color? surfaceColor}) {
    return BoxDecoration(
      color: surfaceColor ?? Colors.white,
      borderRadius: shape == BoxShape.circle
          ? null
          : borderRadius ?? BorderRadius.circular(rad),
      shape: shape ?? BoxShape.rectangle,
      boxShadow: [
        BoxShadow(
            color: shadowColor ?? Colors.grey.withOpacity(shadowOpacity),
            spreadRadius: spreadRadius,
            blurRadius: blurRadius,
            offset: offset ?? const Offset(0.0, 0.0)),
      ],
    );
  }

  static BoxDecoration borderPrimary(BuildContext context,
      {Color surfaceColor = Colors.transparent}) {
    return BoxDecoration(
        color: surfaceColor,
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: const BorderRadius.all(Radius.circular(Dimens.rad_S)));
  }

  static BoxDecoration borderWhiteBox(
    BuildContext context,
  ) {
    return BoxDecoration(
        borderRadius: BorderRadius.circular(Dimens.rad),
        color: Theme.of(context).canvasColor);
  }

// static Widget dividerCircle(BuildContext context) {
//   return DottedLine(
//     direction: Axis.horizontal,
//     lineLength: double.infinity,
//     lineThickness: 4.0,
//     dashLength: 4.0,
//     dashColor: Theme.of(context).unselectedWidgetColor,
//     dashRadius: 50.0,
//     dashGapLength: 6.0,
//     dashGapColor: Colors.transparent,
//     dashGapRadius: 0.0,
//   );
// }

// static BoxDecoration outlineBorderTopCorner(
//   BuildContext context,
// ) {
//   return BoxDecoration(
//       // border: Border.all(color: Colors.orange, width: 1),
//       color: AppColor.primary);
// }
//
// static BoxDecoration borderTopCorner(
//   BuildContext context,
// ) {
//   return BoxDecoration(
//       border: Border.all(color: Colors.grey.shade300,width: 1),
//       color: AppColors.secondary);
// }
//
// static BoxDecoration outlinePrice(BuildContext context) {
//   return BoxDecoration(
//       color: AppColors.getPriceColor(),
//       border: Border.all(color: AppColors.getPriceBorderColor()),
//       borderRadius: BorderRadius.all(Radius.circular(Dimens.rad_XXS)));
// }
}
