part of 'app_bloc.dart';

@immutable
abstract class AppEvent {}

class YieldState extends AppEvent {
  final AppState state;

  YieldState(this.state);
}
