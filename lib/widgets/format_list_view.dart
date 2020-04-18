import 'dart:async';

import 'package:conditional_wrapper/conditional_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_youtube_downloader/bloc/app_bloc.dart';
import 'package:flutter_youtube_downloader/constants.dart';
import 'package:flutter_youtube_downloader/widgets/format_tile.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' hide Container;

class FormatListView extends StatelessWidget {
  final List<MediaStreamInfo> mediaStreams;
  final String title;
  final Function(DragMediaType) onDragStarted;

  final ValueChanged<MediaStreamInfo> onPressed;

  const FormatListView({
    Key key,
    @required this.title,
    @required this.mediaStreams,
    @required this.onPressed,
    this.onDragStarted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Material(
              color: Theme.of(context).cardColor,
              elevation: elevation,
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8.0),
                child: Text(title),
              ),
            ),
            Expanded(
              child: CupertinoScrollbar(
                child: ListView.separated(
                  itemCount: mediaStreams.length,
                  shrinkWrap: true,
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider();
                  },
                  itemBuilder: (BuildContext context, int index) {
                    final MediaStreamInfo format = mediaStreams[index];
                    Stream<Progress> downloadProgress =
                        AppBloc.of(context).downloadProgress[format];
                    return ConditionalWrapper(
                      condition: format is! MuxedStreamInfo,
                      builder: (context, child) {
                        return Draggable<MediaStreamInfo>(
                          data: format,
                          feedback: Icon(Icons.insert_drive_file),
                          child: child,
                          onDragStarted: () {
                            if (format is VideoStreamInfo) {
                              onDragStarted(DragMediaType.video);
                            }
                            if (format is AudioStreamInfo) {
                              onDragStarted(DragMediaType.audio);
                            }
                          },
                          onDraggableCanceled: (_, __) {
                            onDragStarted(null);
                          },
                        );
                      },
                      child: FormatTile(
                        format: format,
                        trailing: IconButton(
                            icon: Icon(Icons.cloud_download),
                            onPressed: () => onPressed(format)),
                        progressStream: downloadProgress,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Progress {
  final double count;
  final double total;

  Progress(this.count, this.total);

  double get ratio => count / total;
}

class DownloadProgress extends Progress {
  final String downloadSpeed;
  final String totalSize;
  final String eta;
  final String _source;

  DownloadProgress({
    @required double count,
    @required double total,
    @required this.totalSize,
    @required this.downloadSpeed,
    @required this.eta,
    String source,
  })  : _source = source,
        super(count, total);

  double get percentage => count / 100;
  // String should follow this format.
  // [download]  99.6% of ~11.84MiB at  4.41MiB/s ETA 00:00
  factory DownloadProgress.fromString(String downloadProgress) {
    final RegExp regex =
        RegExp(r'^.*?(\d.*?)%\s+of\s~?(\d.*?)\s+at\s+(\d.*?)\s(.*)');
    final RegExpMatch matches = regex.firstMatch(downloadProgress.trim());

    if (matches == null) {
      return null;
    }

    final double percentage = double.tryParse(matches.group(1));
    final String totalSize = matches.group(2);
    final String downloadSpeed = matches.group(3);
    final eta = matches.group(4);

    return DownloadProgress(
      count: percentage,
      total: 100,
      downloadSpeed: downloadSpeed,
      totalSize: totalSize,
      eta: eta,
      source: downloadProgress,
    );
  }

  @override
  String toString() => _source;
}
