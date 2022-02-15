import 'package:flutter/material.dart';
import 'package:skaiscan/all_file/import_styles.dart';
import 'package:skaiscan/widgets/btn.dart';

class CommonOutlineButton extends StatelessWidget {
  const CommonOutlineButton({Key? key, required this.text, this.onPressed}) : super(key: key);
  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Btn.outline(
      onPressed: onPressed,
      text: text,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      padding: const EdgeInsets.all(16),
      style: AppButtonStyle.outlineStyle(context).copyWith(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) => AppColors.materialWhite,
          ),
          padding: MaterialStateProperty.resolveWith<EdgeInsets>(
              (Set<MaterialState> states) => const EdgeInsets.all(16))),
    );
  }
}
