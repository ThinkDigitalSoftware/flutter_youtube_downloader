part of 'app_bloc.dart';

@immutable
class AppState {
  final List<HistoryEntry> history;
  final int navigationDrawerIndex;
  final Video video;
  final MediaStreamInfoSet mediaStreamInfoSet;
  final bool isLoading;

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const AppState({
    @required this.history,
    @required this.navigationDrawerIndex,
    this.video,
    this.mediaStreamInfoSet,
    @required this.isLoading,
  });

  bool get hasVideo => video != null;

  bool get hasMediaStreamInfo => mediaStreamInfoSet != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppState &&
          runtimeType == other.runtimeType &&
          history == other.history &&
          navigationDrawerIndex == other.navigationDrawerIndex &&
          video == other.video &&
          mediaStreamInfoSet == other.mediaStreamInfoSet &&
          isLoading == other.isLoading);

  @override
  int get hashCode =>
      history.hashCode ^
      navigationDrawerIndex.hashCode ^
      video.hashCode ^
      mediaStreamInfoSet.hashCode ^
      isLoading.hashCode;

  @override
  String toString() {
    return 'AppState{' +
        ' history: $history,' +
        ' navigationDrawerIndex: $navigationDrawerIndex,' +
        ' video: $video,' +
        ' mediaStreamInfoSet: $mediaStreamInfoSet,' +
        ' isLoading: $isLoading'
            '}';
  }

  AppState copyWith({
    List<HistoryEntry> history,
    int navigationDrawerIndex,
    Video video,
    MediaStreamInfoSet mediaStreamInfoSet,
    bool isLoading,
  }) {
    return AppState(
      history: history ?? this.history,
      navigationDrawerIndex:
          navigationDrawerIndex ?? this.navigationDrawerIndex,
      video: video ?? this.video,
      mediaStreamInfoSet: mediaStreamInfoSet ?? this.mediaStreamInfoSet,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'history': [for (final entry in history) entry.toJson()],
      'navigationDrawerIndex': this.navigationDrawerIndex,
      'video': video?.toJson(),
      'isLoading': isLoading,
      'mediaStreamInfoSet':
          this.mediaStreamInfoSet.toString(), // TODO: Change this
    };
  }

  factory AppState.fromJson(Map<String, dynamic> map) {
    return new AppState(
      history: HistoryEntry.fromJsonList(map['history']),
      navigationDrawerIndex: map['navigationDrawerIndex'] as int,
      video: VideoX.fromJson(map['video']),
      isLoading: map['isLoading'] as bool,
      mediaStreamInfoSet: null, //TODO: Fix this
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
        );
}
