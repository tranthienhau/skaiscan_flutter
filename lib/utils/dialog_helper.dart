import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skaiscan/all_file/import_styles.dart';
import 'package:skaiscan/core/app.dart';
import 'package:skaiscan/utils/extend/view_extend.dart';
import 'package:skaiscan/widgets/app_button.dart';
import 'package:skaiscan_localizations/skaiscan_localizations.dart';

enum DialogType {
  info,
  warning,
  error,
  success,
}

class DialogHelper {
  ///Use context from AppStylesProvider to change text style
  static Future<T?> showAppDialog<T>(BuildContext context,
      {required String title,
      required String content,
      DialogType type = DialogType.info,
      required Widget icon,
      List<Widget>? actions}) async {
    return showDialog<T?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              10.0.toVSizeBox(),
              icon,
              Text(
                title,
                style: Theme.of(context).dialogTitleStyle,
              ),
            ],
          ),
          content: Text(
            content,
            style: Theme.of(context).dialogMessageStyle,
          ),
          actions: actions ?? _getActions(context, type),
        );
      },
      useRootNavigator: false,
    );
  }

  static Widget _buildDialog({
    BuildContext? context,
    String? title,
    required String content,
    DialogType type = DialogType.info,
    required Widget icon,
    List<Widget>? actions,
    bool useExitButton = false,
    TextStyle? titleStyle,
    TextStyle? contentStyle,
  }) {
    BuildContext targetContext = context ?? App.overlayContext!;

    return Platform.isIOS
        ? CupertinoAlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                icon,
                20.0.toVSizeBox(),
                if (title != null)
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: titleStyle,
                  ),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(targetContext).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      content,
                      textAlign: TextAlign.center,
                      style: contentStyle,
                    ),
                  ),
                ],
              ),
            ),
            actions: actions ??
                [
                  SizedBox(
                      width: MediaQuery.of(targetContext).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _getActions(targetContext, type),
                      ))
                ])
        : AlertDialog(
            elevation: 0,
            insetPadding:
                const EdgeInsets.only(left: 16, right: 16, bottom: 100),
            buttonPadding: const EdgeInsets.only(left: 16, right: 16),
            titlePadding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
            title: SizedBox(
              width: MediaQuery.of(targetContext).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Visibility(
                      visible: useExitButton,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                              onTap: () {
                                Navigator.of(targetContext).pop(true);
                              },
                              child: const Padding(
                                padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                                child: Icon(
                                  Icons.close,
                                  size: 24,
                                ),
                              )),
                        ],
                      )),
                  icon,
                  20.0.toVSizeBox(),
                  if (title != null)
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: titleStyle,
                    ),
                ],
              ),
            ),
            content: SizedBox(
              width: MediaQuery.of(targetContext).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      content,
                      textAlign: TextAlign.center,
                      style: contentStyle,
                    ),
                  ),
                ],
              ),
            ),
            actions: actions ??
                [
                  SizedBox(
                      width: MediaQuery.of(targetContext).size.width,
                      child: Row(
                        children: _getActions(targetContext, type),
                      ))
                ]);
  }

  static Future<bool?> showInfo(
      {BuildContext? context,
      required String title,
      required String content,
      List<Widget>? actions,
      Widget? icon}) async {
    BuildContext targetContext = context ?? App.overlayContext!;

    return showDialog(
      context: targetContext,
      builder: (BuildContext context) {
        return _buildDialog(
          context: context,
          title: title,
          content: content,
          type: DialogType.info,
          icon: icon ??
              const Icon(
                Icons.error,
                color: AppColors.error,
                size: 50,
              ),
        );
      },
      useRootNavigator: false,
    );
  }

  static Future<bool?> showWarning({
    BuildContext? context,
    required String title,
    Color? titleColor = AppColors.warningColor,
    required String content,
    List<Widget>? actions,
    Widget? icon,
    bool useExitButton = false,
  }) async {
    BuildContext targetContext = context ?? App.overlayContext!;

    return showDialog(
      context: targetContext,
      builder: (BuildContext context) {
        return _buildDialog(
          context: context,
          title: title,
          content: content,
          useExitButton: useExitButton,
          type: DialogType.warning,
          icon: icon ??
              const Icon(
                Icons.warning,
                color: AppColors.warningColor,
                size: 50,
              ),
          actions: actions,
        );
      },
      useRootNavigator: false,
    );
  }

  static Future<bool?> showError({
    BuildContext? context,
    String? title,
    required String content,
    List<Widget>? actions,
    Widget? icon,
  }) async {
    BuildContext targetContext = context ?? App.overlayContext!;

    return showDialog(
      context: targetContext,
      builder: (BuildContext context) {
        return _buildDialog(
          context: context,
          title: title,
          content: content,
          type: DialogType.error,
          icon: icon ??
              const Icon(
                Icons.error,
                color: AppColors.error,
                size: 50,
              ),
        );
      },
      useRootNavigator: false,
    );
  }

  // static Future<bool?> showSuccess(
  //     {BuildContext? context,
  //     required String title,
  //     required String content,
  //     List<Widget>? actions,
  //     Widget? icon}) async {
  //   BuildContext targetContext = context ?? App.overlayContext!;
  //
  //   return showDialog(
  //     context: targetContext,
  //     builder: (BuildContext context) {
  //       return _buildDialog(
  //         context: context,
  //         title: title,
  //         content: content,
  //         type: DialogType.success,
  //         icon: icon ??
  //             Icon(
  //               Icons.check,
  //               // color: AppColors.success,
  //             ),
  //       );
  //     },
  //     useRootNavigator: false,
  //   );
  // }

  static Future<bool?> showConfirm({
    BuildContext? context,
    required String title,
    Color? titleColor,
    required String content,
    VoidCallback? onConfirmed,
    Color? confirmButtonColor,
  }) async {
    BuildContext targetContext = context ?? App.overlayContext!;

    return showDialog(
      context: targetContext,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 0,
          insetPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
          title: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(color: titleColor ?? AppColors.successColor),
          ),
          content: Text(
            content,
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(color: AppColors.textColor),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  backgroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 8,
                  ),
                  // borderColor: AppColors.borderButtonColor,
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Center(
                    child: Text(
                      S.of(context).cancel,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(color: AppColors.textColor, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                AppButton(
                  backgroundColor: confirmButtonColor ?? AppColors.successColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                  onPressed: onConfirmed,
                  child: Center(
                    child: Text(
                      S.of(context).confirm,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(color: AppColors.background, fontSize: 16),
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
      useRootNavigator: false,
    );
  }

  static Future<bool?> showAlertIosDialog({
    BuildContext? context,
    required String title,
    required String content,
    VoidCallback? onConfirmed,
    VoidCallback? onCanceled,
  }) {
    return showCupertinoDialog(
      context: context ?? App.overlayContext!,
      barrierDismissible: true,
      builder: (builder) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          CupertinoDialogAction(
            isDefaultAction: false,
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.systemBlueColor,
                fontWeight: FontWeight.w600,
                fontSize: Dimens.text_XSL,
              ),
            ),
            onPressed: () {
              onCanceled?.call();
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text(
              'Ok',
              style: TextStyle(
                color: AppColors.systemBlueColor,
                fontWeight: FontWeight.w600,
                fontSize: Dimens.text_XSL,
              ),
            ),
            onPressed: () {
              onConfirmed?.call();
            },
          ),
        ],
      ),
    );
  }

  static Future<bool?> showIosOptionDialog(BuildContext context,
      {String? title,
      String? content,
      TextStyle? titleTextStyle,
      TextStyle? contentTextStyle,
      VoidCallback? onNegative,
      VoidCallback? onPositive,
      TextStyle? btnTextStyle,
      String? negativeText,
      String? positiveText,
      ThemeData? themeData}) {
    return showCupertinoDialog(
      barrierDismissible: false,
      context: context,
      builder: (builder) => Theme(
        data: themeData ?? ThemeData.light(),
        child: CupertinoAlertDialog(
          title: title != null
              ? Text(
                  title,
                  style: titleTextStyle,
                )
              : null,
          content: content != null
              ? Text(
                  content,
                  style: contentTextStyle,
                )
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text(
                negativeText ?? 'Cancel',
                style: btnTextStyle ??
                    const TextStyle(
                      color: AppColors.systemBlueColor,
                      fontWeight: FontWeight.w900,
                      fontSize: Dimens.text_XSL,
                    ),
              ),
              onPressed: () {
                onNegative?.call();
              },
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text(
                positiveText ?? 'Ok',
                style: const TextStyle(
                  color: AppColors.systemBlueColor,
                  fontWeight: FontWeight.w900,
                  fontSize: Dimens.text_XSL,
                ),
              ),
              onPressed: () {
                onPositive?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  static List<Widget> _getActions(BuildContext context, DialogType type) {
    final ThemeData data = Theme.of(context);
    switch (type) {
      case DialogType.info:
        return <Widget>[
          Expanded(
            child: AppButton(
              borderRadius: Platform.isIOS ? 0 : 8,
              backgroundColor:
                  Platform.isIOS ? Colors.transparent : data.primaryColor,
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Center(
                child: Text(
                  S.of(context).ok,
                  style: data.textTheme.bodyText1!.copyWith(
                      color: Platform.isIOS
                          ? Theme.of(context).textColor()
                          : Theme.of(context).backgroundColor),
                ),
              ),
            ),
          )
        ];
      case DialogType.warning:
        return <Widget>[
          Expanded(
            child: AppButton(
              borderRadius: Platform.isIOS ? 0 : 8,
              backgroundColor:
                  Platform.isIOS ? Colors.transparent : data.primaryColor,
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Center(
                child: Text(
                  S.of(context).cancel,
                  style: data.textTheme.bodyText1!.copyWith(
                      color: Platform.isIOS
                          ? Theme.of(context).textColor()
                          : Theme.of(context).backgroundColor),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: AppButton(
              borderRadius: Platform.isIOS ? 0 : 8,
              backgroundColor:
                  Platform.isIOS ? Colors.transparent : data.primaryColor,
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Center(
                child: Text(
                  S.of(context).cancel,
                  style: data.textTheme.bodyText1!.copyWith(
                      color: Platform.isIOS
                          ? Theme.of(context).textColor()
                          : Theme.of(context).backgroundColor),
                ),
              ),
            ),
          ),
        ];
      case DialogType.error:
        return <Widget>[
          Expanded(
            child: AppButton(
              borderRadius: Platform.isIOS ? 0 : 8,
              backgroundColor:
                  Platform.isIOS ? Colors.transparent : data.primaryColor,
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Center(
                child: Text(
                  S.of(context).ok,
                  style: data.textTheme.bodyText1!.copyWith(
                      color: Platform.isIOS
                          ? Theme.of(context).textColor()
                          : Theme.of(context).backgroundColor),
                ),
              ),
            ),
          ),
        ];

      case DialogType.success:
        return <Widget>[
          Expanded(
            child: AppButton(
              borderRadius: Platform.isIOS ? 0 : 8,
              backgroundColor:
                  Platform.isIOS ? Colors.transparent : data.primaryColor,
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Center(
                child: Text(
                  S.of(context).ok,
                  style: data.textTheme.bodyText1!.copyWith(
                      color: Platform.isIOS
                          ? Theme.of(context).textColor()
                          : Theme.of(context).backgroundColor),
                ),
              ),
            ),
          ),
        ];

      default:
        return <Widget>[
          Expanded(
            child: AppButton(
              borderRadius: Platform.isIOS ? 0 : 8,
              backgroundColor:
                  Platform.isIOS ? Colors.transparent : data.primaryColor,
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Center(
                child: Text(
                  S.of(context).ok,
                  style: data.textTheme.bodyText1!.copyWith(
                      color: Platform.isIOS
                          ? Theme.of(context).textColor()
                          : Theme.of(context).backgroundColor),
                ),
              ),
            ),
          ),
        ];
    }
  }
}
