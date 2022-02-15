import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:overlay_support/overlay_support.dart' hide Toast;
import 'package:skaiscan/all_file/all_file.dart';
import 'package:skaiscan/gen/assets.gen.dart';
import 'package:skaiscan/widgets/toast/ios_toast.dart';

class ToastUtils {
  static showShortTimeToast({
    required String msg,
    Color? backgroundColor,
  }) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: backgroundColor ?? Colors.black.withOpacity(0.4),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static OverlaySupportEntry? toastQueue;

  static OverlaySupportEntry? infinityToastQueue;

  static showToast( {BuildContext? context, required String msg}) {
    toastQueue?.dismiss();
    toastQueue = showOverlay(
      (_, t) {
        return Theme(
          data: Theme.of(context ?? App.overlayContext!),
          child: Opacity(
            opacity: t,
            child: IosStyleToast(
              msg: msg,
            ),
          ),
        );
      },
      key: const ValueKey('overlay_toast'),
    );
  }

  static showInfinityToast(
      {BuildContext? context, required String msg, Widget? icon}) {
    infinityToastQueue?.dismiss();

    infinityToastQueue = showOverlay(
      (_, t) {
        return Theme(
          data: Theme.of(context ?? App.overlayContext!),
          child: Opacity(
            opacity: t,
            child:  IosStyleToast(msg: msg, icon: icon,),
          ),
        );
      },
      duration: const Duration(days: 1),
      key: const ValueKey('overlay_infinity_toast'),
    );
  }

  static hidInfinityToast() {
    infinityToastQueue?.dismiss();
  }

// static show(String msg) {
//   showSimpleNotification(
//       MessageNotification(
//         subTitle: msg,
//       ),
//       background: Colors.transparent,
//       elevation: 0);
// }
//
// static done(String msg) {
//   showSimpleNotification(
//       MessageNotification(
//           subTitle: msg,
//           leading: Icon(
//             FontAwesomeIcons.solidCheckCircle,
//             color: AppColor.getSuccessColor(),
//           )),
//       background: Colors.transparent,
//       elevation: 0);
// }
//
// static error({String? msg, dynamic error}) {
//   if (error != null) {
//     print('error');
//     print(error);
//   }
//   print(StackTrace.current);
//
//   final String errMsg = msg ?? 'errorMsg'.tr;
//
//   showSimpleNotification(
//       MessageNotification(
//         subTitle: errMsg,
//         leading: Icon(
//           FontAwesomeIcons.exclamationCircle,
//           color: AppColor.getErrorColor(),
//         ),
//       ),
//       background: Colors.transparent,
//       elevation: 0);
// }
//
// static warning({String? msg}) {
//   showSimpleNotification(
//       MessageNotification(
//         subTitle: msg ?? 'errorMsg'.tr,
//         leading: Icon(
//           FontAwesomeIcons.exclamationTriangle,
//           color: AppColor.getWarningColor(),
//         ),
//       ),
//       background: Colors.transparent,
//       elevation: 0);
// }
}
