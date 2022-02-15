import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:skaiscan/all_file/import_styles.dart';
import 'package:skaiscan/utils/extend/list_extend.dart';
import 'package:velocity_x/velocity_x.dart';

bool canPop(BuildContext context) => ModalRoute.of(context)?.canPop ?? false;

class SliverListExtend {
  static SliverList separator(
      {required Widget Function(int index) delegateBuilder,
      required int childCount,
      required Widget separator,
      Widget? tail}) {
    final tailCount = tail != null ? 1 : 0;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final int itemIndex = index ~/ 2;
          if (index.isEven) {
            if (tailCount == 1 && itemIndex == childCount) {
              return tail;
            }

            return delegateBuilder(itemIndex);
          }
          return separator;
        },
        semanticIndexCallback: (Widget widget, int localIndex) {
          if (localIndex.isEven) return localIndex ~/ 2;
          return null;
        },
        childCount: math.max(0, (childCount + tailCount) * 2 - 1),
      ),
    );
  }
}

extension NullExtend on dynamic {
  dynamic checkEmpty() {
    if (this == null) return Gaps.empty;
    return this;
  }
}

extension ListWidgetExtend<T extends Widget> on List<T> {
  List<Widget> withDivider(Widget divider) {
    if (isNullOrEmpty()) return [];

    List<Widget> rs = [];
    forEach((element) {
      rs.add(element);
      rs.add(divider);
    });
    rs.removeLast();
    return rs;
  }
}

extension ViewIntExtend on int {
  SizedBox toHSizeBox() {
    return SizedBox(
      width: toDouble(),
    );
  }

  SizedBox toVSizeBox() {
    return SizedBox(
      height: toDouble(),
    );
  }
}

extension ViewDoubleExtend on double {
  SizedBox toHSizeBox() {
    return SizedBox(
      width: this,
    );
  }

  SizedBox toVSizeBox() {
    return SizedBox(
      height: this,
    );
  }
}

extension WidgetExtend on Widget {
  Padding pDefault({Key? key}) => Padding(
        key: key,
        padding: const EdgeInsets.all(Vx.dp20),
        child: this,
      );

  Padding pDefaultL({Key? key}) => Padding(
        key: key,
        padding: const EdgeInsets.all(Vx.dp24),
        child: this,
      );

  // 430 screen width on mobile
  ConstrainedBox maxWidth({Key? key, double maxWidth = 430}) {
    return ConstrainedBox(
      key: key,
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: this,
    );
  }

  ConstrainedBox maxHeight(double maxHeight, {Key? key}) {
    return ConstrainedBox(
      key: key,
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: this,
    );
  }

  ConstrainedBox minWidth({Key? key, double minWidth = 430}) {
    return ConstrainedBox(
      key: key,
      constraints: BoxConstraints(minWidth: minWidth),
      child: this,
    );
  }

  ConstrainedBox minHeight(double minHeight, {Key? key}) {
    return ConstrainedBox(
      key: key,
      constraints: BoxConstraints(minHeight: minHeight),
      child: this,
    );
  }

  Padding pb24({Key? key}) => Padding(
        key: key,
        padding: const EdgeInsets.only(bottom: Vx.dp24),
        child: this,
      );

  Padding pb20({Key? key}) => Padding(
        key: key,
        padding: const EdgeInsets.only(bottom: Vx.dp20),
        child: this,
      );

  Padding pb16({Key? key}) => Padding(
        key: key,
        padding: const EdgeInsets.only(bottom: Vx.dp16),
        child: this,
      );

  Padding pb12({Key? key}) => Padding(
        key: key,
        padding: const EdgeInsets.only(bottom: Vx.dp12),
        child: this,
      );

  Padding pb4({Key? key}) => Padding(
        key: key,
        padding: const EdgeInsets.only(bottom: Vx.dp4),
        child: this,
      );

  Padding pb8({Key? key}) => Padding(
        key: key,
        padding: const EdgeInsets.only(bottom: Vx.dp8),
        child: this,
      );

  Padding pt24({Key? key}) => Padding(
        key: key,
        padding: const EdgeInsets.only(top: Vx.dp24),
        child: this,
      );

  Padding pt20({Key? key}) => Padding(
        key: key,
        padding: const EdgeInsets.only(top: Vx.dp20),
        child: this,
      );

  Padding pt16({Key? key}) => Padding(
        key: key,
        padding: const EdgeInsets.only(top: Vx.dp16),
        child: this,
      );

  Padding pt18({Key? key}) => Padding(
        key: key,
        padding: const EdgeInsets.only(top: 18.0),
        child: this,
      );

  Padding pt12({Key? key}) => Padding(
        key: key,
        padding: const EdgeInsets.only(top: Vx.dp12),
        child: this,
      );

  Padding pt8({Key? key}) => Padding(
        key: key,
        padding: const EdgeInsets.only(top: Vx.dp8),
        child: this,
      );

  Padding pt({Key? key, required double value}) => Padding(
        key: key,
        padding: EdgeInsets.only(top: value),
        child: this,
      );

  Padding pl({Key? key, required double value}) => Padding(
        key: key,
        padding: EdgeInsets.only(left: value),
        child: this,
      );

  Padding plf({Key? key, required double value}) => Padding(
        key: key,
        padding: EdgeInsets.symmetric(horizontal: value),
        child: this,
      );

  Padding pr({Key? key, required double value}) => Padding(
        key: key,
        padding: EdgeInsets.only(right: value),
        child: this,
      );

  Padding pb({Key? key, required double value}) => Padding(
        key: key,
        padding: EdgeInsets.only(bottom: value),
        child: this,
      );
}
extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
      <K, List<E>>{},
          (Map<K, List<E>> map, E element) =>
      map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
}