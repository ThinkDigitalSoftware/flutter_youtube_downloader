part of 'app_bloc.dart';

@immutable
abstract class AppEvent {
  final StackTrace _stackTrace = StackTrace.current;
}

class YieldState extends AppEvent {
  final AppState state;

  YieldState(this.state);
}
