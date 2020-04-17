import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_youtube_downloader/bloc/history_entry.dart';
import 'package:flutter_youtube_downloader/constants.dart';
import 'package:flutter_youtube_downloader/extensions.dart';
import 'package:flutter_youtube_downloader/format_list_view.dart';
import 'package:flutter_youtube_downloader/services/database.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

part 'app_event.dart';

part 'app_state.dart';

class AppBloc extends HydratedBloc<AppEvent, AppState> {
  final YoutubeExplode extractor = YoutubeExplode();
  final DatabaseService databaseService =
      DatabaseService(directory: Directory.current);

  final Dio _dio = Dio();

  static AppBloc of(BuildContext context) => BlocProvider.of<AppBloc>(context);

  final Map<MediaStreamInfo, Stream<Progress>> downloadProgress = {};

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

  Future<bool> downloadVideo({
    @required Video video,
    @required MediaStreamInfo format,
    ProgressCallback onReceiveProgress,
  }) async {
    var extension = format.container.extension;
    String suggestedFileName;
    if (format is MuxedStreamInfo) {
      suggestedFileName =
          '${state.video.title} - ${format.videoResolution}$extension';
    } else if (format is VideoStreamInfo) {
      suggestedFileName =
          '${state.video.title} - ${format.videoResolution}$extension';
    } else if (format is AudioStreamInfo) {
      suggestedFileName = '${state.video.title} - $extension';
    }

    final FileChooserResult fileChooserResult =
        await showSavePanel(suggestedFileName: suggestedFileName);
    final url = format.url.toString();

    if (!fileChooserResult.canceled) {
      final String path = fileChooserResult.paths.first;
      final file = File(path);
      final downloadController = StreamController<Progress>();
      downloadProgress[format] = downloadController.stream;
      add(YieldState(state.copyWith(isDownloading: true)));
      final Response result =
          await _dio.get(url, onReceiveProgress: (count, total) {
        downloadController.add(Progress(count, total));
      }, options: Options(responseType: ResponseType.bytes));
      downloadController.close();

      add(YieldState(state.copyWith(isDownloading: false)));

      await file.writeAsBytes(result.data, flush: true);
      databaseService.write(MediaDownload(path: path, videoId: video.id));
      return true;
    }

    return false;
  }

  void raiseDropTarget(DragMediaType mediaType) {
    add(YieldState(state.nullableCopyWith(mediaTypeBeingDragged: mediaType)));
  }

  @override
  void onError(Object error, StackTrace stacktrace) {
    super.onError(error, stacktrace);
  }

  Future<void> downloadAndMerge({
    VideoStreamInfo videoFormat,
    AudioStreamInfo audioFormat,
  }) async {
    var extension = videoFormat.container.extension;
    String suggestedFileName =
        '${state.video.title} - ${videoFormat.videoResolution}$extension';

    final FileChooserResult fileChooserResult =
        await showSavePanel(suggestedFileName: suggestedFileName);

    if (fileChooserResult.canceled) {
      return;
    }

    final videoDownloadController = StreamController<Progress>();
    final audioDownloadController = StreamController<Progress>();

    downloadProgress[videoFormat] = videoDownloadController.stream;
    downloadProgress[audioFormat] = audioDownloadController.stream;

    add(YieldState(state.copyWith(isDownloading: true)));

    final List<Response> downloads = await Future.wait([
      _dio.get(audioFormat.url.toString(), onReceiveProgress: (count, total) {
        audioDownloadController.add(Progress(count, total));
      }, options: Options(responseType: ResponseType.bytes)),
      _dio.get(videoFormat.url.toString(), onReceiveProgress: (count, total) {
        videoDownloadController.add(Progress(count, total));
      }, options: Options(responseType: ResponseType.bytes))
    ]);

    add(YieldState(state.copyWith(isDownloading: false)));

    final audioDownloadResult = downloads.first;
    final videoDownloadResult = downloads.last;

    audioDownloadController.close();
    videoDownloadController.close();

    final audioTemp = File('.temp.audio');
    final videoTemp = File('.temp.video');

    audioTemp.writeAsBytesSync(audioDownloadResult.data);
    videoTemp.writeAsBytesSync(videoDownloadResult.data);

    // merge using ffmpeg
  }
}
