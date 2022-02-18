import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:skaiscan/all_file/all_file.dart';
import 'package:skaiscan/model/acne.dart';

import '../utils.dart';

final oCcy = NumberFormat.currency(locale: "vi_VN", symbol: "₫");

const _vietnamese = 'aAeEoOuUiIdDyY';
final _vietnameseRegex = <RegExp>[
  RegExp(r'à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ'),
  RegExp(r'À|Á|Ạ|Ả|Ã|Â|Ầ|Ấ|Ậ|Ẩ|Ẫ|Ă|Ằ|Ắ|Ặ|Ẳ|Ẵ'),
  RegExp(r'è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ'),
  RegExp(r'È|É|Ẹ|Ẻ|Ẽ|Ê|Ề|Ế|Ệ|Ể|Ễ'),
  RegExp(r'ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ'),
  RegExp(r'Ò|Ó|Ọ|Ỏ|Õ|Ô|Ồ|Ố|Ộ|Ổ|Ỗ|Ơ|Ờ|Ớ|Ợ|Ở|Ỡ'),
  RegExp(r'ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ'),
  RegExp(r'Ù|Ú|Ụ|Ủ|Ũ|Ư|Ừ|Ứ|Ự|Ử|Ữ'),
  RegExp(r'ì|í|ị|ỉ|ĩ'),
  RegExp(r'Ì|Í|Ị|Ỉ|Ĩ'),
  RegExp(r'đ'),
  RegExp(r'Đ'),
  RegExp(r'ỳ|ý|ỵ|ỷ|ỹ'),
  RegExp(r'Ỳ|Ý|Ỵ|Ỷ|Ỹ')
];

extension DataExtendNum on num? {
  String toPrice({String? symbol}) {
    if (this == null) return '';

    if (symbol != null) {
      return NumberFormat.currency(locale: "vi_VN", symbol: symbol)
          .format(this);
    }
    return oCcy.format(this);
  }

  num convertIfInt() {
    if (this == null) return 0;
    if (isInteger(this!)) {
      return this!.toInt();
    } else {
      return num.parse((this!.toStringAsFixed(2)));
    }
  }

  bool isInteger(num value) => value is int || value == value.roundToDouble();
}

extension StringEtensions on String {
  int get attachmentValue {
    switch (this) {
      case 'png':
      case 'jpg':
      case 'jpeg':
        return 0;
      case 'zip':
      case 'doc':
      case 'docx':
      case 'xlsx':
      case 'pptx':
      case 'rar':
        return 1;
      case 'txt':
        return 2;
    }
    return 0;
  }

  String get fileName {
    if (split('.').last == 'jpg') {
      return 'image/' + "jpeg";
    } else {
      return 'image/' + split('.').last;
    }
  }
}

extension DataExtendString on String? {
  int get attachmentValue {
    switch (this) {
      case 'png':
      case 'jpg':
      case 'jpeg':
        return 0;
      case 'zip':
      case 'doc':
      case 'docx':
      case 'xlsx':
      case 'pptx':
      case 'rar':
        return 1;
      case 'txt':
        return 2;
    }
    return 0;
  }

  String? capitalizeOnly() {
    if (isNullOrEmpty()) return null;
    return this
        ?.split(RegExp(r"\n"))
        .map((e) => e.capitalizeFirstOnly())
        .join('\n')
        .split(' ')
        .map((e) => e.capitalizeFirstOnly())
        .join(' ');
  }

  String? capitalizeFirstOnly() {
    if (isNullOrEmpty()) return null;
    return this![0].toUpperCase() + this!.substring(1);
  }

  String? unsigned() {
    if (isNullOrEmpty()) return this;

    var result = this;
    for (var i = 0; i < _vietnamese.length; ++i) {
      result = result?.replaceAll(_vietnameseRegex[i], _vietnamese[i]);
    }
    return result;
  }

  String? unsignedLower() {
    return unsigned()?.toLowerCase();
  }

  String get toPrice => oCcy.format(this);

  bool isNullOrEmpty() => this == null || this?.trim() == '';

  bool validateMobile() {
    if (isNullOrEmpty()) {
      return false;
    }

    String pattern = r'(^(09|03|07|08|05)+[0-9]{8}$)';
    RegExp regExp = RegExp(pattern);

    if (!regExp.hasMatch(this!)) {
      return false;
    }
    return true;
  }

  dynamic emailValidator() {
    Pattern pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern.toString());
    if (!regex.hasMatch(this!) || isNullOrEmpty()) {
      return 'Enter valid email';
    } else {
      return null;
    }
  }

  String getDate() {
    return this?.substring(0, 10).split('-').reversed.join('/') ?? '';
  }

  String getDatetime() {
    String date = this?.substring(0, 10) ?? '';
    String time = this?.substring(11, 19) ?? '';
    var dateTime =
        DateFormat("yyyy-MM-dd HH:mm:ss").parse(date + ' ' + time, true);
    var dateLocal = dateTime.toLocal();
    return dateLocal.toString().substring(0, 16);
  }
}

extension RangeExtension on int {
  List<int> toNum(int maxInclusive, {int step = 1}) =>
      [for (int i = this; i <= maxInclusive; i += step) i];
}

extension AcneExtension on Acne {
  Color get color {
    switch (this) {
      case Acne.papules:
        return AppColors.papules;
      case Acne.blackheads:
        return AppColors.blackheads;
      case Acne.pustules:
        return AppColors.pustules;
      case Acne.whiteheads:
        return AppColors.whiteheads;
    }
  }

  String get name {
    switch (this) {
      case Acne.papules:
        return 'Закрытые Комедоны';
      case Acne.blackheads:
        return 'Открытые камедоны';
      case Acne.pustules:
        return 'Папулы';
      case Acne.whiteheads:
        return 'Пустулы';
    }
  }
}

extension DateTimeExtensions on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  DateTime clearTime() {
    return DateTime(year, month, day);
  }

  String get dateGroupName {
    final now = DateTime.now().clearTime();

    final pureDataFormat = clearTime();
    var diffDayCount = pureDataFormat.difference(now).inDays;
    if (diffDayCount == 0) {
      return 'Today';
    }

    if (diffDayCount < 0) {
      return 'Overdue';
    }

    return TimeUtils.dateToStr(pureDataFormat);
  }
}
