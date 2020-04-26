part of 'search_bloc.dart';

@immutable
abstract class SearchState {
  final List<Video> searchResults;

  SearchState([this.searchResults]);
}

class InitialSearchState extends SearchState {}

class SearchLoadingState extends SearchState {
  SearchLoadingState([List<Video> oldSearchResults]) : super(oldSearchResults);
}

class SearchResultsState extends SearchState {
  SearchResultsState(List<Video> searchResults) : super(searchResults);
}
