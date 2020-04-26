part of 'search_bloc.dart';

@immutable
abstract class SearchEvent {
  const SearchEvent();
}

class YieldState extends SearchEvent {
  final SearchState state;

  const YieldState(this.state);
}
