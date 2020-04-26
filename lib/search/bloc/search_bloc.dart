import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

part 'search_event.dart';

part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final YoutubeExplode _youtubeExplode = YoutubeExplode();

  static SearchBloc of(BuildContext context) =>
      BlocProvider.of<SearchBloc>(context);

  @override
  SearchState get initialState => InitialSearchState();

  @override
  Stream<SearchState> mapEventToState(SearchEvent event) async* {
    if (event is YieldState) {
      yield event.state;
      return;
    }
  }

  Future<void> search(String query) async {
    add(YieldState(SearchLoadingState(state.searchResults)));

    final results = await _youtubeExplode.searchVideos(query);

    add(YieldState(SearchResultsState(results)));
  }
}
