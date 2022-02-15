import 'dart:html';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeLoadSuccess(HomeData(false))) {
    on<HomeEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
