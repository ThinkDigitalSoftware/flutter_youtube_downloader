import 'dart:io';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

class DatabaseService {
  final Directory directory;
  final Box _box;

  DatabaseService({@required this.directory})
      : _box = Hive.box('${directory.path}/database') {
    List<Map> downloadJson = _box.get('downloads');
    List<MediaDownload> downloads =
        downloadJson.map((e) => MediaDownload.fromJson(e)).toList();
    _scan(downloads);
  }

  List<MediaDownload> _scan(List<MediaDownload> downloads) {
    final List<MediaDownload> verifiedDownloads = [];
    for (final download in downloads) {
      bool fileExists = download.file.existsSync();
      if (fileExists) {
        verifiedDownloads.add(download);
      }
    }
    return verifiedDownloads;
  }
}

class MediaDownload {
  final String videoId;
  final String path;

  File get file => File(path);

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const MediaDownload({
    @required this.videoId,
    @required this.path,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaDownload &&
          runtimeType == other.runtimeType &&
          videoId == other.videoId &&
          path == other.path);

  @override
  int get hashCode => videoId.hashCode ^ path.hashCode;

  @override
  String toString() {
    return 'MediaDownload{' + ' videoId: $videoId,' + ' path: $path,' + '}';
  }

  MediaDownload copyWith({
    String videoId,
    String path,
  }) {
    return new MediaDownload(
      videoId: videoId ?? this.videoId,
      path: path ?? this.path,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videoId': this.videoId,
      'path': this.path,
    };
  }

  factory MediaDownload.fromJson(Map<String, dynamic> map) {
    return MediaDownload(
      videoId: map['videoId'] as String,
      path: map['path'] as String,
    );
  }

//</editor-fold>
}
