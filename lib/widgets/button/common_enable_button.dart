import 'package:flutter/material.dart';
import 'package:skaiscan/core/styles/app_button_style.dart';
import 'package:skaiscan/core/styles/app_colors.dart';
import 'package:skaiscan/core/styles/dimens.dart';
import 'package:skaiscan/widgets/btn.dart';


class CommonEnableButton extends StatelessWidget {
  const CommonEnableButton({Key? key,required this.child, this.onPressed}) : super(key: key);
  final VoidCallback? onPressed;
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return Btn.main(
        onPressed: onPressed,
        fontWeight: FontWeight.w400,
        fontSize: 16,
        padding: const EdgeInsets.all(16),
        style: AppButtonStyle.primaryStyle(context).copyWith(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimens.rad),
              ),
            ),
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) => AppColors.grey4,
            ),
            padding: MaterialStateProperty.resolveWith<EdgeInsets>(
                    (Set<MaterialState> states) => const EdgeInsets.all(16))),
        child: child
    );
  }
}