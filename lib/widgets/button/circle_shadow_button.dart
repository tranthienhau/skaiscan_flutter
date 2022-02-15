import 'package:flutter/material.dart';
import 'package:skaiscan/all_file/import_styles.dart';

class CircleShadowButton extends StatelessWidget {
  const CircleShadowButton({
    Key? key,
    this.size = 40,
    this.backgroundColor = Colors.transparent,
    required this.child,
    this.onPressed,
  }) : super(key: key);

  final double size;
  final Color backgroundColor;
  final Widget child;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorStyle.boxShadow(),
      child: ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: Material(
            color: backgroundColor,
            child: IconButton(
              icon: child,
              padding: EdgeInsets.zero,
              onPressed: onPressed,
            ),
          ),
        ),
      ),
    );
  }
}
