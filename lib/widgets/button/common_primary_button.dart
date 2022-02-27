import 'package:flutter/material.dart';
import 'package:skaiscan/all_file/import_styles.dart';
import 'package:skaiscan/widgets/btn.dart';

class CommonPrimaryButton extends StatelessWidget {
  const CommonPrimaryButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);
  final VoidCallback? onPressed;
  final EdgeInsets padding;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Btn.main(
      onPressed: onPressed,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      padding: padding,
      style: AppButtonStyle.primaryStyle(context).copyWith(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.rad_XXL),
          ),
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) => AppColors.primaryColor,
        ),
        padding: MaterialStateProperty.resolveWith<EdgeInsets>(
          (Set<MaterialState> states) => padding,
        ),
      ),
      child: child,
    );
  }
}
