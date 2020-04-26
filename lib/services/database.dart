import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter_youtube_downloader/extensions.dart';

class DatabaseService {
  final Directory directory;
  final Box _box;
  Downloads downloads;

  DatabaseService({@required this.directory}) : _box = Hive.box('database') {
    downloads = Downloads.fromJson(_box.get('downloads'));
    _box.watch(key: 'downloads').listen((event) {
      downloads = Downloads.fromJson(event.value);
    });
    _scan(downloads);
  }

  void _scan(Downloads downloads) {
    final List<MediaDownload> verifiedDownloads = [];
    final List<MediaDownload> removed = [];
    for (final download in downloads.existing) {
      bool fileExists = download.file.existsSync();
      if (fileExists) {
        verifiedDownloads.add(download);
      } else {
        removed.add(download);
      }
    }

    this.downloads = Downloads(existing: verifiedDownloads, removed: removed);
    _box.put('downloads', downloads.toJson());
  }

  void write(MediaDownload mediaDownload) {
    if (!downloads.contains(mediaDownload)) {
      debugPrint('New download written to ${mediaDownload.path}');
      downloads.existing.add(mediaDownload);
      _box.put('downloads', downloads.toJson());
    }
  }

  void clearDownloads() {
    _box.clear();
  }
}

class MediaDownload {
  final String path;
  final String thumbnailUrl;
  final Video video;
  final bool fileExists;

  File get file => File(path);

  Directory get containingDirectory => file.parent;

  String get containingDirectoryPath => containingDirectory.path;

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  MediaDownload({
    @required this.path,
    @required this.thumbnailUrl,
    @required this.video,
  }) : fileExists = File(path).existsSync();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaDownload &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          thumbnailUrl == other.thumbnailUrl &&
          video == other.video);

  @override
  int get hashCode => path.hashCode ^ thumbnailUrl.hashCode ^ video.hashCode;

  @override
  String toString() {
    return 'MediaDownload{' +
        ' path: $path,' +
        ' thumbnailUrl: $thumbnailUrl,' +
        ' video: $video,' +
        '}';
  }

  MediaDownload copyWith({
    String path,
    String thumbnailUrl,
    Video video,
  }) {
    return MediaDownload(
      path: path ?? this.path,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      video: video ?? this.video,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': this.path,
      'thumbnailUrl': this.thumbnailUrl,
      'video': this.video.toJson(),
    };
  }

  factory MediaDownload.fromJson(Map<dynamic, dynamic> map) {
    return new MediaDownload(
      path: map['path'] as String,
      thumbnailUrl: map['thumbnailUrl'] as String,
      video: VideoX.fromJson(map['video']),
    );
  }

//</editor-fold>
}

class Downloads {
  final List<MediaDownload> existing;
  final List<MediaDownload> removed;

  MediaDownload get last => existing.last;

  List<MediaDownload> get allDownloads => [...existing, ...removed];

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const Downloads({
    @required this.existing,
    @required this.removed,
  });

  int get length => existing.length + removed.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Downloads &&
          runtimeType == other.runtimeType &&
          existing == other.existing &&
          removed == other.removed);

  @override
  int get hashCode => existing.hashCode ^ removed.hashCode;

  @override
  String toString() {
    return 'Downloads{' + ' existing: $existing,' + ' removed: $removed,' + '}';
  }

  Downloads copyWith({
    List<MediaDownload> existing,
    List<MediaDownload> removed,
  }) {
    return new Downloads(
      existing: existing ?? this.existing,
      removed: removed ?? this.removed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'existing': this.existing.map((e) => e.toJson()).toList(),
      'removed': this.removed.map((e) => e.toJson()).toList(),
    };
  }

  factory Downloads.fromJson(Map<dynamic, dynamic> map) {
    if (map == null) {
      return Downloads(existing: [], removed: []);
    }
    return Downloads(
      existing: (map['existing'] as List)
          .map((e) => MediaDownload.fromJson(e))
          .toList(),
      removed: (map['removed'] as List)
          .map((e) => MediaDownload.fromJson(e))
          .toList(),
    );
  }

  bool contains(MediaDownload mediaDownload) =>
      allDownloads.contains(mediaDownload);

//</editor-fold>
}
