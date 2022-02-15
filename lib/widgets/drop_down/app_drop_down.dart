import 'package:flutter/material.dart';
import 'package:skaiscan/core/styles/app_colors.dart';
import 'package:skaiscan/core/styles/app_text_style.dart';
import 'package:skaiscan/utils/extend/view_extend.dart';

class AppDropDown extends StatefulWidget {
  const AppDropDown(
      {Key? key,
      required this.groupNameList,
      required this.onSelectedItem,
      required this.index,
      this.color,
      this.margin,
      this.textColor,
      this.icon,
      this.decoration,
      this.popUpLeft,
      this.textPopUpColor})
      : super(key: key);
  final List<String> groupNameList;
  final Function(int) onSelectedItem;
  final int index;
  final Color? color;
  final EdgeInsetsGeometry? margin;
  final Color? textColor;
  final Icon? icon;
  final Decoration? decoration;
  final double? popUpLeft;
  final Color? textPopUpColor;

  @override
  _AppDropDownState createState() => _AppDropDownState();
}

class _AppDropDownState extends State<AppDropDown> {
  late List<String> _menuList;
  String _selectedMenu = '';

  @override
  void didUpdateWidget(covariant AppDropDown oldWidget) {
    _loadData();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  void _loadData() {
    _menuList = widget.groupNameList;
    if (_menuList.isNotEmpty) {
      _selectedMenu = _menuList[widget.index];
    } else {
      _selectedMenu = 'No group name';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        elevation: 0,
        // itemPadding: widget.margin ?? EdgeInsets.zero,
        dropdownColor: Colors.transparent,
        value: _selectedMenu,
        onChanged: (String? val) {
          setState(() {
            if (val != null) {
              _selectedMenu = val;
              widget.onSelectedItem(_menuList.indexOf(_selectedMenu));
            }
          });
        },
        icon: const SizedBox(),
        // dropdownDecoration: BoxDecoration(
        //     color: Colors.transparent, borderRadius: BorderRadius.circular(8)),
        // dropdownElevation: 0,
        // itemHeight: 50,
        // dropdownPadding: const EdgeInsets.only(top: 5),
        items: _menuList.map<DropdownMenuItem<String>>((String value) {
          final currentIndex = _menuList.indexOf(value);

          return DropdownMenuItem<String>(
            value: value,
            child: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              decoration: BoxDecoration(
                color: _selectedMenu == value ? AppColors.grey3 : Colors.white,
                border: currentIndex == _menuList.length - 1
                    ? null
                    : const Border(
                        bottom: BorderSide(color: AppColors.grey3, width: 1),
                      ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
                  ).pl(value: 16),
                ],
              ),
            ),
          );
        }).toList(),
        selectedItemBuilder: (context) {
          return _menuList.map<Widget>((e) {
            return Center(
              child: Container(
                width: double.maxFinite,
                // margin:
                //     widget.margin ?? const EdgeInsets.only(left: 16, right: 16),
                height: 50,
                decoration: widget.decoration ??
                    BoxDecoration(
                      color: widget.color ?? AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _selectedMenu,
                        style: Theme.of(context).normalStyle.copyWith(
                            color: widget.textColor ?? Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    widget.icon ??
                        const RotatedBox(
                          quarterTurns: 3,
                          child: Icon(Icons.arrow_back_ios),
                        ).pb(value: 6),
                  ],
                ).pr(value: 20).pl(value: 16),
              ),
            );
          }).toList();
        },
      ),
    );
  }
}
