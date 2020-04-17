part of 'app_bloc.dart';

@immutable
class AppState {
  final List<HistoryEntry> history;
  final int navigationDrawerIndex;
  final Video video;
  final MediaStreamInfoSet mediaStreamInfoSet;
  final bool isLoading;
  final bool isDownloading;
  final DragMediaType mediaTypeBeingDragged;

  bool get hasVideo => video != null;

  bool get hasMediaStreamInfo => mediaStreamInfoSet != null;

  Map<String, dynamic> toJson() {
    return {
      if (history != null)
        'history': [for (final entry in history) entry.toJson()],
      'navigationDrawerIndex': this.navigationDrawerIndex,
      'video': video?.toJson(),
      'isLoading': isLoading,
      'isDownloading': isDownloading,
      'mediaStreamInfoSet':
          this.mediaStreamInfoSet.toString(), // TODO: Change this
    };
  }

  factory AppState.fromJson(Map<String, dynamic> map) {
    return AppState(
        history: HistoryEntry.fromJsonList(map['history']),
        navigationDrawerIndex: map['navigationDrawerIndex'] as int,
        video: VideoX.fromJson(map['video']),
        isLoading: map['isLoading'] as bool,
        isDownloading: map['isDownloading'] as bool,
        mediaStreamInfoSet: null,
        //TODO: Fix this
        mediaTypeBeingDragged: null);
  }

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const AppState({
    @required this.history,
    @required this.navigationDrawerIndex,
    this.video,
    this.mediaStreamInfoSet,
    @required this.isLoading,
    @required this.isDownloading,
    @required this.mediaTypeBeingDragged,
  }) : assert(isLoading != null && isDownloading != null);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppState &&
          runtimeType == other.runtimeType &&
          history == other.history &&
          navigationDrawerIndex == other.navigationDrawerIndex &&
          video == other.video &&
          mediaStreamInfoSet == other.mediaStreamInfoSet &&
          isLoading == other.isLoading &&
          isDownloading == other.isDownloading &&
          mediaTypeBeingDragged == other.mediaTypeBeingDragged);

  @override
  int get hashCode =>
      history.hashCode ^
      navigationDrawerIndex.hashCode ^
      video.hashCode ^
      mediaStreamInfoSet.hashCode ^
      isLoading.hashCode ^
      isDownloading.hashCode ^
      mediaTypeBeingDragged.hashCode;

  @override
  String toString() {
    return 'AppState{' +
        ' history: $history,' +
        ' navigationDrawerIndex: $navigationDrawerIndex,' +
        ' video: $video,' +
        ' mediaStreamInfoSet: $mediaStreamInfoSet,' +
        ' isLoading: $isLoading,' +
        ' isDownloading: $isDownloading,' +
        '}';
  }

  AppState copyWith({
    List<HistoryEntry> history,
    int navigationDrawerIndex,
    Video video,
    MediaStreamInfoSet mediaStreamInfoSet,
    bool isLoading,
    bool isDownloading,
    DragMediaType mediaTypeBeingDragged,
  }) {
    return new AppState(
      history: history ?? this.history,
      navigationDrawerIndex:
          navigationDrawerIndex ?? this.navigationDrawerIndex,
      video: video ?? this.video,
      mediaStreamInfoSet: mediaStreamInfoSet ?? this.mediaStreamInfoSet,
      isLoading: isLoading ?? this.isLoading,
      isDownloading: isDownloading ?? this.isDownloading,
      mediaTypeBeingDragged:
          mediaTypeBeingDragged ?? this.mediaTypeBeingDragged,
    );
  }

  AppState nullableCopyWith({
    DragMediaType mediaTypeBeingDragged,
  }) {
    return AppState(
      history: history,
      navigationDrawerIndex: navigationDrawerIndex,
      video: video,
      mediaStreamInfoSet: mediaStreamInfoSet,
      isLoading: isLoading,
      isDownloading: isDownloading,
      mediaTypeBeingDragged: mediaTypeBeingDragged,
    );
  }

//</editor-fold>
}

class AppInitial extends AppState {
  const AppInitial()
      : super(
          history: const [],
          navigationDrawerIndex: 0,
          isLoading: false,
          isDownloading: false,
          mediaTypeBeingDragged: null,
        );
}
