import 'package:flutter/material.dart';
import 'package:skaiscan/core/app.dart';
import 'package:skaiscan/core/styles/app_colors.dart';
import 'package:skaiscan/core/styles/app_text_style.dart';
import 'package:skaiscan/utils/extend/data_extend.dart';
import 'package:skaiscan/utils/extend/view_extend.dart';

import 'calendar_helper.dart';

Future<void> showCalendar({
  BuildContext? context,
  required Function(DateTime) onSelectedDate,
  DateTime? selectedDate,
}) async {
  await showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      context: context ?? App.overlayContext!,
      builder: (BuildContext context) {
        return _AppCalendar(
          onSelectedDate: onSelectedDate,
          selectedDate: selectedDate,
        );
      });
}

class _AppCalendar extends StatefulWidget {
  const _AppCalendar(
      {Key? key, required this.onSelectedDate, this.selectedDate})
      : super(key: key);

  ///callback Selected DateTime
  final Function(DateTime) onSelectedDate;

  ///Selected DateTime to init date
  final DateTime? selectedDate;

  @override
  _AppCalendarState createState() => _AppCalendarState();
}

class _AppCalendarState extends State<_AppCalendar> {
  late DateTime _currentDateTime;

  ///selected DateTime when click
  late DateTime _selectedDateTime;

  ///List datetime in calendar
  List<Calendar>? _sequentialDates;

  ///selected year when click
  int? midYear;

  ///init view
  CalendarViews _currentView = CalendarViews.dates;
  final List<String> _weekDays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
  final List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  String? swipeDirection;

  @override
  void initState() {
    super.initState();
    final date = widget.selectedDate ?? DateTime.now();
    _currentDateTime = DateTime(date.year, date.month);

    _selectedDateTime = DateTime(date.year, date.month, date.day);
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      setState(() => _getCalendar());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        swipeDirection = details.delta.dx < 0 ? 'left' : 'right';
      },
      onPanEnd: (details) {
        if (swipeDirection == null) {
          return;
        }
        if (swipeDirection == 'left') {
          if (_selectedDateTime.compareTo(_currentDateTime) != -1) {
            _handleSwipeDate(true);
          }
        }
        if (swipeDirection == 'right') {
          _handleSwipeDate(false);
          // if (_currentDateTime.compareTo(
          //         _selectedDateTime.subtract(const Duration(days: 30))) !=
          //     -1) {
          //
          // }
        }
      },
      child: SafeArea(
        child: Center(
          child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(10),
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: (_currentView == CalendarViews.dates)
                  ? _buildDatesView()
                  : (_currentView == CalendarViews.months)
                      ? _buildMonthsList()
                      : _buildYearsView(midYear ?? _currentDateTime.year)),
        ),
      ),
    );
  }

  // dates view
  Widget _buildDatesView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        // header

        Center(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(16),
            child: Text(
              '${_monthNames[_currentDateTime.month - 1]} ${_currentDateTime.year}',
              style: Theme.of(context).normalStyle.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
        ),

        const Divider(
          color: Colors.white,
        ),
        20.toVSizeBox(),
        Flexible(child: _buildCalendarBody()),
      ],
    );
  }

  ///swipe left or right(last month or next month)
  void _handleSwipeDate(bool next) {
    if (_currentView == CalendarViews.dates) {
      setState(() => (next) ? _getNextMonth() : _getPrevMonth());
    } else if (_currentView == CalendarViews.year) {
      if (next) {
        midYear = (midYear == null) ? _currentDateTime.year + 9 : midYear! + 9;
      } else {
        midYear = (midYear == null) ? _currentDateTime.year - 9 : midYear! - 9;
      }
      setState(() {});
    }
  }

  // calendar
  Widget _buildCalendarBody() {
    if (_sequentialDates == null) return const SizedBox();
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: _sequentialDates!.length + 7,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 5,
        crossAxisCount: 7,
        crossAxisSpacing: 15,
      ),
      itemBuilder: (context, index) {
        if (index < 7) return _buildWeekDayTitle(index);
        if (_sequentialDates![index - 7].date == _selectedDateTime) {
          return _buildSelector(_sequentialDates![index - 7]);
        }
        return _buildCalendarDates(_sequentialDates![index - 7]);
      },
    );
  }

  // calendar header
  Widget _buildWeekDayTitle(int index) {
    return Center(
      child: Text(
        _weekDays[index],
        style: Theme.of(context).normalStyle.copyWith(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  // calendar element
  Widget _buildCalendarDates(Calendar calendarDate) {
    return InkWell(
      onTap: () {
        setState(() {
          if (_distanceIn30Day(calendarDate.date) == false) {
            _selectedDateTime = calendarDate.date;
            widget.onSelectedDate(_selectedDateTime);
            App.pop();
          }
        });
      },
      child: Center(
          child: Text(
        '${calendarDate.date.day}',
        style: Theme.of(context).normalStyle.copyWith(
            color: _distanceIn30Day(calendarDate.date)
                ? AppColors.grey
                : AppColors.black),
      )),
    );
  }

  ///distance from selected DateTime to 30 days
  bool _distanceIn30Day(DateTime date) {
    return (_selectedDateTime.difference(date).inDays).abs() >= 30;
  }

  // date selector
  Widget _buildSelector(Calendar calendarDate) {
    return CircleAvatar(
      radius: 60,
      backgroundColor: AppColors.lightGrey,
      child: ClipOval(
        child: Text(
          '${calendarDate.date.day}',
          style: const TextStyle(
              color: AppColors.primaryColor, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // get next month calendar
  void _getNextMonth() {
    if (_currentDateTime.month == 12) {
      _currentDateTime = DateTime(_currentDateTime.year + 1, 1);
    } else {
      _currentDateTime =
          DateTime(_currentDateTime.year, _currentDateTime.month + 1);
    }
    _getCalendar();
  }

  // get previous month calendar
  void _getPrevMonth() {
    if (_currentDateTime.month == 1) {
      _currentDateTime = DateTime(_currentDateTime.year - 1, 12);
    } else {
      _currentDateTime =
          DateTime(_currentDateTime.year, _currentDateTime.month - 1);
    }
    _getCalendar();
  }

  // get calendar for current month
  void _getCalendar() {
    _sequentialDates = CalendarHelper().getMonthCalendar(
        _currentDateTime.month, _currentDateTime.year,
        startWeekDay: StartWeekDay.monday);
  }

  // show months list
  Widget _buildMonthsList() {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () => setState(() => _currentView = CalendarViews.year),
          child: Text(
            '${_currentDateTime.year}',
            style: Theme.of(context)
                .normalStyle
                .copyWith(color: AppColors.primaryColor, fontSize: 24),
          ),
        ),
        const Divider(
          color: Colors.white,
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: _monthNames.length,
            itemBuilder: (context, index) => ListTile(
              onTap: () {
                _currentDateTime = DateTime(_currentDateTime.year, index + 1);
                _getCalendar();
                setState(() => _currentView = CalendarViews.dates);
              },
              title: Center(
                child: Text(
                  _monthNames[index],
                  style: Theme.of(context)
                      .normalStyle
                      .copyWith(color: Colors.black),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // years list views
  Widget _buildYearsView(int midYear) {
    return GridView.builder(
        shrinkWrap: true,
        itemCount: 9,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemBuilder: (context, index) {
          int thisYear;
          if (index < 4) {
            thisYear = midYear - (4 - index);
          } else if (index > 4) {
            thisYear = midYear + (index - 4);
          } else {
            thisYear = midYear;
          }
          return ListTile(
            onTap: () {
              _currentDateTime = DateTime(thisYear, _currentDateTime.month);
              _getCalendar();
              setState(() => _currentView = CalendarViews.months);
            },
            title: Text(
              '$thisYear',
              style: Theme.of(context).normalStyle.copyWith(
                  fontSize: 24,
                  color: (thisYear == _currentDateTime.year)
                      ? AppColors.primaryColor
                      : AppColors.black),
            ),
          );
        });
  }
}
