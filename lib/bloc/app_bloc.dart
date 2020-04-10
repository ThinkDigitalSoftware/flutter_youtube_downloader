import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final extractor = YoutubeExplode();
  @override
  AppState get initialState => AppInitial();

  @override
  Stream<AppState> mapEventToState(
    AppEvent event,
  ) async* {
   
  }

  Future<void> getVideoDetails(String url) async {
    final id = YoutubeExplode.parseVideoId(url);
    final video = await extractor.getVideo(id);
    return;
  }
}
