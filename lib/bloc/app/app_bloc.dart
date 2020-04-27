import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_youtube_downloader/bloc/history_entry.dart';
import 'package:flutter_youtube_downloader/constants.dart';
import 'package:flutter_youtube_downloader/extensions.dart';
import 'package:flutter_youtube_downloader/services/file_manager.dart';
import 'package:flutter_youtube_downloader/widgets/format_list_view.dart';
import 'package:flutter_youtube_downloader/services/database.dart';
import 'package:flutter_youtube_downloader/services/youtube_dl_manager.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

part 'app_event.dart';

part 'app_state.dart';

class AppBloc extends HydratedBloc<AppEvent, AppState> {
  final YoutubeExplode extractor = YoutubeExplode();
  final DatabaseService databaseService =
      DatabaseService(directory: Directory.current);

  Downloads get downloads => databaseService.downloads;
  final Dio _dio = Dio();
  final YoutubeDL youtubeDL = YoutubeDL();

  StreamController<String> downloadController = StreamController.broadcast();

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

    final video = await extractor.getVideo(id);

    await loadFromVideo(video);

    await _loadMediaStreamInfo(id);
    await _addHistoryEntry(video);
    add(YieldState(state.copyWith(isLoading: false)));
  }

  Future<void> _loadMediaStreamInfo(String id) async {
    add(YieldState(state.copyWith(isLoading: true)));
    final MediaStreamInfoSet mediaStreamInfoSet = await _getMediaStreamUrls(id);

    add(
      YieldState(
        state.copyWith(
          mediaStreamInfoSet: mediaStreamInfoSet,
          navigationDrawerIndex: 2,
          isLoading: false,
        ),
      ),
    );
    await first;
  }

  Future<MediaStreamInfoSet> _getMediaStreamUrls(String id) async {
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
        downloadController.add(Progress(count.toDouble(), total.toDouble()));
      }, options: Options(responseType: ResponseType.bytes));
      downloadController.close();

      add(YieldState(state.copyWith(isDownloading: false)));

      await file.writeAsBytes(result.data, flush: true);
      databaseService.write(
        MediaDownload(
          path: path,
          video: state.video,
          thumbnailUrl: state.video.thumbnailSet.lowResUrl,
        ),
      );
      return true;
    }

    return false;
  }

  Future<void> loadFromVideo(Video video) async {
    _loadVideo(video);
    await firstWhere((newState) => newState.video == video);
    await _loadMediaStreamInfo(video.id);
    await _addHistoryEntry(video);
    add(YieldState(state.copyWith(isLoading: false)));
  }

  void _loadVideo(Video video) {
    add(YieldState(state.copyWith(video: video)));
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
        audioDownloadController
            .add(Progress(count.toDouble(), total.toDouble()));
      }, options: Options(responseType: ResponseType.bytes)),
      _dio.get(videoFormat.url.toString(), onReceiveProgress: (count, total) {
        videoDownloadController
            .add(Progress(count.toDouble(), total.toDouble()));
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

    //TODO: merge using ffmpeg
  }

  Future<void> downloadAndMergeBest() async {
    final videoFormat = state.mediaStreamInfoSet.video.first;

    var extension = videoFormat.container.extension;
    String suggestedFileName =
        '${state.video.title} - ${videoFormat.videoResolution}$extension';

    final FileChooserResult fileChooserResult =
        await showOpenPanel(canSelectDirectories: true);

    if (!fileChooserResult.canceled) {
      final String path = fileChooserResult.paths.first;
      final outputFile = await youtubeDL.downloadBestAudioVideo(
          getUrlFromVideoId(state.video.id),
          outputPath: path,
          outputStreamController: downloadController);

      // write to db
      databaseService.write(
        MediaDownload(
            path: outputFile.path,
            video: state.video,
            thumbnailUrl: state.video.thumbnailSet.lowResUrl),
      );
    }
  }

  @override
  Future<void> close() {
    downloadController.close();
    return super.close();
  }

  void showInFinder(MediaDownload download) {
    FileSystemManager.openFile(
      download.path,
      openContainingDirectory: true,
    );
  }

  String getUrlFromVideoId(String id) => 'https://www.youtube.com/watch?v=$id';

  Future<void> _addHistoryEntry(Video video) async {
    final historyEntry =
        HistoryEntry.fromVideo(video, url: getUrlFromVideoId(video.id));
    add(
      YieldState(
        state.copyWith(
          history: [
            ...state.history,
            if (!state.history.any((entry) => entry.id == historyEntry.id))
              historyEntry
          ],
        ),
      ),
    );
    await first;
    return;
  }

  @override
  void onTransition(Transition<AppEvent, AppState> transition) {
    super.onTransition(transition);
  }
}
