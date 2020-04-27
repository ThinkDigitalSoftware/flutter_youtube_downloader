import 'package:flutter/material.dart';
import 'package:flutter_youtube_downloader/bloc/app/app_bloc.dart';
import 'package:flutter_youtube_downloader/services/database.dart';
import 'package:flutter_youtube_downloader/widgets/format_list_view.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' hide Container;

class DownloadSection extends StatefulWidget {
  final VoidCallback onClear;
  final String url;

  final AudioStreamInfo audioStreamInfoToMerge;

  final VideoStreamInfo videoStreamInfoToMerge;

  const DownloadSection(
      {Key key,
      @required this.onClear,
      @required this.url,
      @required this.audioStreamInfoToMerge,
      @required this.videoStreamInfoToMerge})
      : super(key: key);

  @override
  _DownloadSectionState createState() => _DownloadSectionState();
}

class _DownloadSectionState extends State<DownloadSection>
    with SingleTickerProviderStateMixin {
  AnimationController showInFinderAnimationController;
  @override
  void initState() {
    showInFinderAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 20),
      lowerBound: 0,
      upperBound: 1,
    );
    super.initState();
  }

  @override
  void dispose() {
    showInFinderAnimationController.dispose();
    super.dispose();
  }

  AppBloc get appBloc => AppBloc.of(context);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Card(
              child: Container(
                height: 90,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
                child: StreamBuilder(
                  stream: AppBloc.of(context).downloadController?.stream ??
                      Stream<String>.empty(),
                  initialData: '',
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    String data = snapshot.data;
                    double progressIndicatorPercentage =
                        _getProgressIndicatorPercentage(data);

                    if (progressIndicatorPercentage == 1.0) {
                      data = 'Complete!';
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                            child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 15.0),
                                child: Text(
                                  data,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ),
                            if (data == 'Complete!')
                              AnimatedBuilder(
                                builder: (BuildContext context, Widget child) {
                                  return FlatButton(
                                    onPressed: openDownload,
                                    child: Text('Show in Finder'),
                                  );
                                },
                                animation: showInFinderAnimationController,
                              ),
                          ],
                        )),
                        LinearProgressIndicator(
                          value: progressIndicatorPercentage,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlineButton(
                  child: Text('Clear'),
                  onPressed: widget.onClear,
                ),
                RaisedButton.icon(
                    onPressed: downloadAndMerge(),
                    icon: Icon(Icons.merge_type),
                    label: Text('Download and Merge')),
                RaisedButton.icon(
                    onPressed: downloadAndMergeBest(),
                    icon: Icon(Icons.merge_type),
                    label: Text('Auto-select Best'))
              ],
            ),
          )
        ],
      ),
    );
  }

  Function downloadAndMerge() {
    if (widget.videoStreamInfoToMerge != null &&
        widget.audioStreamInfoToMerge != null) {
      return () => appBloc.downloadAndMerge(
            videoFormat: widget.videoStreamInfoToMerge,
            audioFormat: widget.audioStreamInfoToMerge,
          );
    } else {
      return null;
    }
  }

  Function downloadAndMergeBest() {
    if (!appBloc.state.hasVideo) {
      return null;
    } else {
      return () => appBloc.downloadAndMergeBest();
    }
  }

  double _getProgressIndicatorPercentage(String data) {
    DownloadProgress progress = DownloadProgress.fromString(data);
    if (data.isEmpty) {
      return 0.0;
    }
    if (data.contains('downloaded') || data.startsWith('Deleting')) {
      return 1;
    }

    return progress?.percentage;
  }

  void openDownload() {
    // ignore: close_sinks
    final MediaDownload download = appBloc.databaseService.downloads.last;
    if (download.file.existsSync()) {
      appBloc.showInFinder(
        download,
      );
    } else {
      showInFinderAnimationController.repeat(
          reverse: true, period: Duration(milliseconds: 500));
    }
  }
}
