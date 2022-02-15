import 'package:flutter/material.dart';
import 'package:skaiscan/all_file/all_file.dart';

enum BtnType { primary, outline,ghost }

class Btn extends StatelessWidget {
  // Data
  final Widget? child;
  final String? text;
  final bool loading;

  // Style
  final BtnType? btnType;
  final EdgeInsetsGeometry? padding;
  final ButtonStyle? style;

  // Text Style
  final FontWeight? fontWeight;
  final double? fontSize;

  // Action
  final VoidCallback? onPressed;

  const Btn({
    Key? key,
    this.btnType,
    this.padding,
    this.child,
    this.text,
    this.loading = false,
    this.style,
    this.fontWeight,
    this.fontSize,
    this.onPressed,
  }) : super(key: key);

  // const Btn.big({
  //   Key? key,
  //   this.child,
  //   this.text,
  //   this.padding = const EdgeInsets.all(16),
  //   this.loading = false,
  //   this.btnType,
  //   this.style,
  //   this.fontWeight = FontWeight.w700,
  //   this.fontSize = 14,
  //   this.matchParent = false,
  //   this.onPressed,
  // }) : super(key: key);

  const Btn.main({
    Key? key,
    this.child,
    this.text,
    this.padding = const EdgeInsets.all(16),
    this.loading = false,
    this.btnType = BtnType.primary,
    this.style,
    this.fontWeight = FontWeight.w700,
    this.fontSize = 14,
    this.onPressed,
  }) : super(key: key);

  const Btn.outline({
    Key? key,
    this.child,
    this.text,
    this.padding = const EdgeInsets.all(16),
    this.loading = false,
    this.btnType = BtnType.outline,
    this.style,
    this.fontWeight = FontWeight.w700,
    this.fontSize = 14,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final childWidget = text == null
        ? child
        : text?.text
            .size(fontSize)
            .fontWeight(fontWeight ?? FontWeight.w400)
            .make();

    // Style
    final ButtonStyle finalStyle;
    if (style != null) {
      finalStyle = style!;
    } else {
      switch (btnType) {
        case BtnType.primary:
        case null:
          finalStyle = AppButtonStyle.primaryStyle(
            context,
            props: BtnStyleProps(
              padding: padding,
            ),
          );
          break;
        case BtnType.ghost:
          finalStyle = AppButtonStyle.ghostStyle(context,
              props: BtnStyleProps(padding: padding));
          break;
        case BtnType.outline:
          finalStyle = AppButtonStyle.outlineStyle(context,
              props: BtnStyleProps(padding: padding),

          );
          break;
      }
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: finalStyle,
      child: childWidget,
    );
  }
}
