import 'dart:async';

import 'package:flutter/material.dart';
import 'package:skaiscan/all_file/all_file.dart';

class OutLineTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? initialValue;
  final Duration timerDuration;
  final bool? enabled;
  final bool obscureText;
  final bool autoFocus;
  final TextEditingController? controller;

  ///Callback onTextChanged is delay by [delay]
  final Duration delay;

  // Event
  final ValueChanged<String>? onChanged;
  final Function(bool hasFocus, String value)? onFocusChange;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final ValueChanged<String>? onFieldSubmitted;


  // Style Data
  final bool colorOnFill;
  final TextInputType? keyboardType;
  final bool showClear;
  final int? maxLines;
  final IconData? iconData;
  final EdgeInsetsGeometry? iconPadding;

  // Style
  final double? iconSize;
  final double radius;
  final double borderWidth;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsets? scrollPadding;
  final Color? backgroundColor;
  final TextStyle? hintStyle;
  final bool showBorder;

  final Widget? suffixIcon;

  const OutLineTextField({
    Key? key,
    this.iconData,
    this.scrollPadding,
    this.radius = Dimens.rad_S,
    this.hintText,
    this.validator,
    this.onSaved,
    this.onFieldSubmitted,
    this.showClear = false,
    this.obscureText = false,
    this.keyboardType,
    this.borderWidth = 1,
    this.contentPadding =
        const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
    this.labelText,
    this.colorOnFill = false,
    this.initialValue,
    this.onChanged,
    this.onFocusChange,
    this.backgroundColor,
    this.iconSize,
    this.timerDuration = const Duration(seconds: 1),
    this.maxLines = 1,
    this.iconPadding,
    this.hintStyle,
    this.showBorder = true,
    this.enabled,
    this.autoFocus = false,
    this.delay = const Duration(seconds: 0),
    this.controller,
    this.suffixIcon,
  }) : super(key: key);

  const OutLineTextField.big({
    Key? key,
    this.iconData,
    this.scrollPadding,
    this.radius = 16,
    this.hintText,
    this.validator,
    this.onSaved,
    this.onFieldSubmitted,
    this.showClear = false,
    this.obscureText = false,
    this.keyboardType,
    this.borderWidth = 1.5,
    this.contentPadding =
        const EdgeInsets.symmetric(vertical: 17, horizontal: 14),
    this.labelText,
    this.colorOnFill = true,
    this.initialValue,
    this.onChanged,
    this.onFocusChange,
    this.backgroundColor,
    this.iconSize,
    this.timerDuration = const Duration(seconds: 1),
    this.maxLines = 1,
    this.iconPadding,
    this.hintStyle,
    this.showBorder = true,
    this.enabled,
    this.autoFocus = false,
    this.suffixIcon,
    this.delay = const Duration(seconds: 0),
    this.controller,
  }) : super(key: key);

  @override
  _OutLineTextFieldState createState() => _OutLineTextFieldState();
}

class _OutLineTextFieldState extends State<OutLineTextField> {
  final FocusNode _fieldNode = FocusNode();

  TextEditingController? _controller;
  Timer? _debounce;

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(widget.delay, () {
      widget.onChanged?.call(_controller?.text ?? '');
    });
  }

  @override
  void initState() {
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);

    super.initState();
    _fieldNode.addListener(() {
      if (widget.onFocusChange != null) {
        widget.onFocusChange!(_fieldNode.hasFocus, _controller?.text ?? '');
      }
    });
    _controller?.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _fieldNode.dispose();
    if (widget.controller == null) {
      _controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color colorItem;
    if (_fieldNode.hasFocus) {
      colorItem = Theme.of(context).primaryColor;
    } else {
      colorItem = Theme.of(context).lightGrey();
    }

    return TextFormField(
      onFieldSubmitted: widget.onFieldSubmitted,
      enabled: widget.enabled,
      controller: _controller,
      focusNode: _fieldNode,
      maxLines: widget.maxLines,
      autofocus: widget.autoFocus,
      keyboardType: widget.keyboardType,
      // validator: widget.validator == null
      //     ? null
      //     : (value) {
      //         var rs = widget.validator!(value);
      //         if (rs != null) {
      //           _state = OutLineTextFieldState.NOT_VALID;
      //           setState(() {});
      //         } else {
      //           _state = OutLineTextFieldState.NORMAL;
      //           _validateEmpty();
      //         }
      //         return rs;
      //       },
      scrollPadding: widget.scrollPadding ?? const EdgeInsets.all(20.0),
      onSaved: widget.onSaved,
      obscureText: widget.obscureText,
      decoration: InputDecoration(
        contentPadding: widget.contentPadding,
        isDense: widget.contentPadding != null ? true : false,

        // Border
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(widget.radius),
          ),
          borderSide: widget.showBorder
              ? BorderSide(
                  color: colorItem,
                  width: widget.borderWidth,
                )
              : BorderSide.none,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(widget.radius),
          ),
          borderSide: widget.showBorder
              ? BorderSide(
                  color: colorItem,
                  width: widget.borderWidth,
                )
              : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(widget.radius),
          ),
          borderSide: widget.showBorder
              ? BorderSide(
                  color: colorItem,
                  width: widget.borderWidth + 0.5,
                )
              : BorderSide.none,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(widget.radius),
          ),
        ),
        filled: true,
        hintStyle:
            widget.hintStyle ?? TextStyle(color: Theme.of(context).hintColor),
        hintText: widget.hintText,
        labelText: widget.labelText,
        fillColor: widget.backgroundColor ?? Theme.of(context).canvasColor,
        // Icons
        prefixIcon: widget.iconData != null
            ? Padding(
                padding: widget.iconPadding ??
                    const EdgeInsets.only(left: 16, right: 10),
                child: Icon(
                  widget.iconData,
                  color: colorItem,
                  size: widget.iconSize ?? 24,
                ),
              )
            : null,
        // prefixIconConstraints: BoxConstraints(maxWidth: 62),
        suffixIcon: widget.suffixIcon,
        suffixIconConstraints: const BoxConstraints(maxWidth: 62),
      ),
    );
  }
}
