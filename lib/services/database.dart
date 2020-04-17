import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

class DatabaseService {
  final Directory directory;
  final Box _box;
  Downloads downloads;

  DatabaseService({@required this.directory}) : _box = Hive.box('database') {
    Map downloadJson = _box.get('downloads');
    downloads = Downloads.fromJson(downloadJson);
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
    debugPrint('New download written to ${mediaDownload.path}');
    downloads.existing.add(mediaDownload);
    _box.put('downloads', downloads.toJson());
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

  factory MediaDownload.fromJson(Map<dynamic, dynamic> map) {
    return MediaDownload(
      videoId: map['videoId'] as String,
      path: map['path'] as String,
    );
  }

//</editor-fold>
}

class Downloads {
  final List<MediaDownload> existing;
  final List<MediaDownload> removed;

//<editor-fold desc="Data Methods" defaultstate="collapsed">

  const Downloads({
    @required this.existing,
    @required this.removed,
  });

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

//</editor-fold>
}
