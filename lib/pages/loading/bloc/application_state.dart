part of 'application_bloc.dart';

@immutable
abstract class ApplicationState {}

class ApplicationLoading extends ApplicationState {}

class ApplicationLoadSuccess extends ApplicationState {}
