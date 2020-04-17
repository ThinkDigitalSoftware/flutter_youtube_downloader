import 'dart:async';

import 'package:conditional_wrapper/conditional_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_youtube_downloader/bloc/app_bloc.dart';
import 'package:flutter_youtube_downloader/constants.dart';
import 'package:flutter_youtube_downloader/format_tile.dart';
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
  final int count;
  final int total;

  Progress(this.count, this.total);

  double get ratio => count / total;
}
