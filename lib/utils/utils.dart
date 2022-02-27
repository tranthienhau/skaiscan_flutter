import 'package:breakpoint/breakpoint.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skaiscan/core/app.dart';
import 'package:skaiscan/utils/extend/data_extend.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import 'package:timeago/timeago.dart';

enum FormatType { date, time, dateTime, dateMonth, monthYear, code }

class TimeUtils {
  static final formatSimpleDate = DateFormat('MM/dd/yyyy');
  static final formatSimpleDateTime = DateFormat('HH:mm MM/dd/yyyy');
  static final formatUserSimpleMonthDay = DateFormat('MMMMd');

  static String getTimeAgo({required DateTime datetime, String? locale}) {
    if (DateTime.now().difference(datetime).inDays > 7) {
      return getDisplayDateTime(DateTime.now());
    }

    timeAgo.setLocaleMessages(locale ?? 'en', AppEnShortMessages());
    return timeAgo.format(datetime, locale: locale);
  }

  static DateTime getCurrentDate() {
    return DateTime.now();
  }

  static String getCurrentDateAsStr() {
    return dateToStr(getCurrentDate());
  }

  static String dateToStr(DateTime? rs, {DateFormat? format}) {
    if (rs == null) return '';
    return format != null ? format.format(rs) : formatSimpleDate.format(rs);
  }

  static String dateTimeToStr(DateTime? rs, {DateFormat? format}) {
    if (rs == null) return '';
    return format != null ? format.format(rs) : formatSimpleDateTime.format(rs);
  }

  static DateTime toYearMonthDay(DateTime? rs) {
    return DateTime(rs?.year ?? 2021, rs?.month ?? 01, rs?.day ?? 01);
  }
}

class ViewUtils {
  static double getPercentWidth({
    required double percent,
    double? maxValue,
    BuildContext? context,
  }) {
    double rWidth;
    double preWidth = MediaQuery.of(context ?? App.overlayContext!).size.width;
    double preHeight =
        MediaQuery.of(context ?? App.overlayContext!).size.height;
    if (preWidth > preHeight) {
      rWidth = preHeight * percent;
    } else {
      rWidth = preWidth * percent;
    }

    if (maxValue != null) {
      return (rWidth >= maxValue) ? maxValue : rWidth;
    } else {
      return rWidth;
    }
  }

  static double getPercentHeight(
      {required double percent, double? maxValue, BuildContext? context}) {
    double rHeight;
    double preWidth = MediaQuery.of(context ?? App.overlayContext!).size.width;
    double preHeight =
        MediaQuery.of(context ?? App.overlayContext!).size.height;
    if (preWidth > preHeight) {
      rHeight = preWidth * percent;
    } else {
      rHeight = preHeight * percent;
    }

    if (maxValue != null) {
      return (rHeight >= maxValue) ? maxValue : rHeight;
    } else {
      return rHeight;
    }
  }

  static double getOffsetResponsive(
      double offsetDefault, BuildContext context) {
    final _breakpoint = Breakpoint.fromMediaQuery(context);
    switch (_breakpoint.window) {
      case WindowSize.xsmall:
        break;
      case WindowSize.small:
      case WindowSize.medium:
      case WindowSize.large:
      case WindowSize.xlarge:
        return offsetDefault * 1.5;
    }
    return offsetDefault;
  }

  static double getStatusBarHeight(BuildContext context) =>
      MediaQuery.of(context).padding.top;
}

class NumberUtils {
  static String formatToPattern(double pureNumber,
      {String? pattern = '#,###.#'}) {
    //todo: need put locale here
    final f = NumberFormat("#,###.#", "en_US");
    return f
        .format(pureNumber)
        .replaceAll(',', '@')
        .replaceAll(',', '.')
        .replaceAll('@', ',');
  }
}

class DateGroupUtils {
  static int diffDayWithNow(DateTime pureData) {
    final now = DateTime.now().clearTime();

    final pureDataFormat = pureData.clearTime();
    var diffDayCount = pureDataFormat.difference(now).inDays;
    return diffDayCount;
  }
}

String getDisplayDateTime(dynamic dateTime,
    {FormatType type = FormatType.date}) {
  if (dateTime == '' || dateTime == null) return '';
  DateTime dt = (dateTime is DateTime) ? dateTime : DateTime.parse(dateTime);

  switch (type) {
    case FormatType.date:
      return DateFormat('dd/MM/yyyy').format(dt);
    case FormatType.time:
      return DateFormat.Hm().format(dt);
    case FormatType.dateTime:
      return DateFormat('HH:mm dd-MM-yyyy').format(dt);
    // case FormatType.DATE_MONTH:
    //   return DateFormat('d, MMMM', S.delegate.).format(dt);
    // case FormatType.MONTH_YEAR:
    //   return DateFormat('MMMM, yyyy', appState.getLangLocale).format(dt);
    // case FormatType.CODE:
    //   return DateFormat('ddMMyyyy', appState.getLangLocale).format(dt);
    default:
      return DateFormat('HH:mm dd-MM-yyyy').format(dt);
  }
}

class AppEnShortMessages implements LookupMessages {
  @override
  String prefixAgo() => '';

  @override
  String prefixFromNow() => '';

  @override
  String suffixAgo() => '';

  @override
  String suffixFromNow() => '';

  @override
  String lessThanOneMinute(int seconds) => 'Just now';

  @override
  String aboutAMinute(int minutes) => '1m';

  @override
  String minutes(int minutes) => '${minutes}m';

  @override
  String aboutAnHour(int minutes) => '1h';

  @override
  String hours(int hours) => '${hours}h';

  @override
  String aDay(int hours) => '1d';

  @override
  String days(int days) => '${days}d';

  @override
  String aboutAMonth(int days) => '1mo';

  @override
  String months(int months) => '${months}mo';

  @override
  String aboutAYear(int year) => '1y';

  @override
  String years(int years) => '${years}y';

  @override
  String wordSeparator() => ' ';
}
