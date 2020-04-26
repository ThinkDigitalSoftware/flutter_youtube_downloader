import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_youtube_downloader/bloc/app/app_bloc.dart';
import 'package:flutter_youtube_downloader/constants.dart';
import 'package:flutter_youtube_downloader/widgets/format_list_view.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' hide Container;

class FormatListViewSection extends StatelessWidget {
  const FormatListViewSection({
    Key key,
    @required this.padding,
  }) : super(key: key);

  final double padding;

  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    AppBloc appBloc = AppBloc.of(context);
    return BlocBuilder<AppBloc, AppState>(
      builder: (BuildContext context, AppState state) {
        if (!state.hasMediaStreamInfo) {
          return Text(
            'Load a video first to see format information',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline6,
          );
        } else {
          return Padding(
            padding: EdgeInsets.all(padding),
            child: Container(
              constraints: BoxConstraints(minHeight: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: FormatListView(
                      title: 'Video with Audio',
                      mediaStreams: state.mediaStreamInfoSet.muxed,
                      onPressed: (
                        MediaStreamInfo format,
                      ) async {
                        await appBloc.downloadVideo(
                            format: format,
                            onReceiveProgress: (count, total) {
                              print('$count/$total');
                            });
                      },
                    ),
                  ),
                  Expanded(
                    child: FormatListView(
                        title: 'Video Only',
                        mediaStreams: state.mediaStreamInfoSet.video,
                        onPressed: (MediaStreamInfo format) async {
                          await appBloc.downloadVideo(
                              format: format,
                              onReceiveProgress: (count, total) {
                                print('$count/$total');
                              });
                        },
                        onDragStarted: (DragMediaType mediaType) {
                          appBloc.raiseDropTarget(mediaType);
                        }),
                  ),
                  Expanded(
                    child: FormatListView(
                        title: 'Audio only',
                        mediaStreams: state.mediaStreamInfoSet.audio,
                        onPressed: (MediaStreamInfo format) async {
                          await appBloc.downloadVideo(
                              format: format,
                              onReceiveProgress: (count, total) {
                                print('$count/$total');
                              });
                        },
                        onDragStarted: (DragMediaType mediaType) {
                          appBloc.raiseDropTarget(mediaType);
                        }),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
