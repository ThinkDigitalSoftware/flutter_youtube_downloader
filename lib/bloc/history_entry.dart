import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter_youtube_downloader/extensions.dart';

import 'package:meta/meta.dart';

class HistoryEntry {
  final String url;
  final Video video;

  HistoryEntry.fromVideo(this.video, {@required this.url})
      : assert(video?.id != null);

  String get title => video.title;

  String get description => video.description;

  String get id => video.id;

  Map<String, dynamic> toJson() {
    return {
      'url': this.url,
      if (video?.id != null) 'video': video.toJson(),
    };
  }

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      url: json['url'] as String,
      video: VideoX.fromJson(json['video']),
    );
  }

  static List<HistoryEntry> fromJsonList(List json) {
    if (json == null) {
      return [];
    }
    return [for (final entry in json) HistoryEntry.fromJson(entry)];
  }

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const HistoryEntry({
    @required this.url,
    @required this.video,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryEntry &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          video == other.video);

  @override
  int get hashCode => url.hashCode ^ video.hashCode;

  @override
  String toString() {
    return 'HistoryEntry{' + ' url: $url,' + ' video: $video,' + '}';
  }

  HistoryEntry copyWith({
    String url,
    Video video,
  }) {
    return new HistoryEntry(
      url: url ?? this.url,
      video: video ?? this.video,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': this.url,
      'video': this.video,
    };
  }

  factory HistoryEntry.fromMap(Map<String, dynamic> map) {
    return new HistoryEntry(
      url: map['url'] as String,
      video: map['video'] as Video,
    );
  }

//</editor-fold>
}
