part of 'search_bloc.dart';

@immutable
abstract class SearchState {}

class InitialSearchState extends SearchState {}

class SearchResultsState extends SearchState {
  final List<Video> searchResults;

  SearchResultsState(this.searchResults);
}
