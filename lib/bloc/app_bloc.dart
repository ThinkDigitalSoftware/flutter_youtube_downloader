import 'dart:async';
import 'dart:io';

import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_youtube_downloader/bloc/history_entry.dart';
import 'package:flutter_youtube_downloader/extensions.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart';

part 'app_event.dart';

part 'app_state.dart';

class AppBloc extends HydratedBloc<AppEvent, AppState> {
  final extractor = YoutubeExplode();

  static AppBloc of(BuildContext context) => BlocProvider.of<AppBloc>(context);

  @override
  AppState get initialState => super.initialState ?? AppInitial();

  @override
  Stream<AppState> mapEventToState(
    AppEvent event,
  ) async* {
    if (event is YieldState) {
      yield event.state;
      return;
    }
  }

  Future<void> getVideoDetails(String url) async {
    final id = YoutubeExplode.parseVideoId(url);

    add(YieldState(state.copyWith(isLoading: true)));

    final video = await extractor.getVideo(id);
    final MediaStreamInfoSet mediaStreamInfoSet = await getMediaStreamUrls(id);
    final historyEntry = HistoryEntry.fromVideo(video, url: url);

    add(
      YieldState(
        state.copyWith(
          video: video,
          mediaStreamInfoSet: mediaStreamInfoSet,
          history: [
            ...state.history,
            if (!state.history.any((entry) => entry.id == historyEntry.id))
              historyEntry
          ],
          navigationDrawerIndex: state.navigationDrawerIndex,
          isLoading: false,
        ),
      ),
    );
  }

  Future<MediaStreamInfoSet> getMediaStreamUrls(String id) async {
    final MediaStreamInfoSet mediaStreams =
        await extractor.getVideoMediaStream(id);

    return mediaStreams;
  }

  @override
  AppState fromJson(Map<String, dynamic> json) => AppState.fromJson(json);

  @override
  Map<String, dynamic> toJson(AppState appState) => appState.toJson();

  void changeNavigationIndex(int index) {
    add(YieldState(state.copyWith(navigationDrawerIndex: index)));
  }

  Future<bool> downloadVideo(
      {@required Video video, @required MediaStreamInfo format}) async {
    var extension = format.container.extension;
    String suggestedFileName;
    if (format is MuxedStreamInfo) {
      suggestedFileName =
          '${state.video.title} - ${format.videoResolution}$extension';
    } else if (format is VideoStreamInfo) {
      suggestedFileName =
          '${state.video.title} - ${format.videoResolution}$extension';
    } else if (format is AudioEncoding) {
      suggestedFileName =
          '${state.video.title} - ${format.container.toString()}$extension';
    }
    final FileChooserResult fileChooserResult =
        await showSavePanel(suggestedFileName: suggestedFileName);
    final url = format.url.toString();

    if (!fileChooserResult.canceled) {
      final file = File(fileChooserResult.paths.first);
      final result = await get(url);
      await file.writeAsBytes(result.bodyBytes, flush: true);
      return true;
    }

    return false;
  }
}
