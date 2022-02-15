import 'package:skaiscan/utils/extend/data_extend.dart';

extension ListExtend<T> on List<T>? {
  T? getOrNull(int index) {
    if (this == null) return null;
    if (index < this!.length) return this![index];
    return null;
  }
}

extension MapBasics<K, V> on Map<K, V>? {
  bool isNullOrEmpty() {
    if (this == null || this!.isEmpty) return true;
    return false;
  }
}

extension IterableBasics<E> on Iterable<E>? {
  List<T> mapAsList<T>(T Function(E e) f) => this?.map(f).toList() ?? [];

  bool isNullOrEmpty() {
    if (this == null || this!.isEmpty) return true;
    return false;
  }

  Iterable<E> filter(bool Function(E element) conditionMethod) {
    return this?.where(conditionMethod) ?? [];
  }

  E? find(bool Function(E element) conditionMethod) {
    return filterAsList(conditionMethod).getOrNull(0);
  }

  List<E> filterAsList(bool Function(E element) conditionMethod) {
    return filter(conditionMethod).toList();
  }

  List<E> searchList(String? searchText, String? Function(E element) mapping) {
    return filterAsList((element) {
      return (mapping(element)
              ?.unsignedLower()
              ?.contains(searchText?.unsignedLower() ?? '') ??
          false);
    });
  }

  // use "Nill" to avoid conflict name
  E? firstOrNull() {
    if (this == null || this!.isEmpty) return null;
    return firstOrElse(() => null as E);
  }

  E? firstOrElse(E Function() orElse) {
    if (this == null || this!.isEmpty) return null;
    return this?.firstWhere((_) => true, orElse: orElse);
  }

  Iterable<T>? mapIndexed<T>(T Function(E e, int i) f) {
    var i = 0;
    if (isNullOrEmpty()) {
      return null;
    }
    return this!.map((e) => f(e, i++));
  }

  List<U> mapAsListIndexed<U>(
    U Function(E currentValue, int index) transformer,
  ) {
    return mapIndexed(transformer)?.toList() ?? [];
  }
}
