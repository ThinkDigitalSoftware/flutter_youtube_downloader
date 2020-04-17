import 'dart:io';
import 'package:flutter_youtube_downloader/constants.dart';
import 'package:flutter_youtube_downloader/format_list_view.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_youtube_downloader/bloc/history_entry.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_youtube_downloader/bloc/app_bloc.dart';
import 'package:flutter_youtube_downloader/format_tile.dart';
import 'package:flutter_youtube_downloader/widgets/search_drawer_section.dart';
import 'package:flutter_youtube_downloader/widgets/video_history_list.dart';
import 'package:hive/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:flutter_youtube_downloader/extensions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' hide Container;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  print(directory.path);
  await Hive.openBox('database');

  BlocSupervisor.delegate = await HydratedBlocDelegate.build();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Youtube Video Downloader',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(title: 'Youtube Video Downloader'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController urlController = TextEditingController();
  AnimationController animationController;
  AudioStreamInfo _audioStreamInfoToMerge;
  VideoStreamInfo _videoStreamInfoToMerge;

  double _videoStreamDropTargetElevation = 0;

  double _audioStreamDropTargetElevation = 0;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
      lowerBound: 0,
      upperBound: 1,
    );
    super.initState();
  }

  @override
  void dispose() {
    urlController.dispose();
    animationController.dispose();
    super.dispose();
  }

  AppBloc get appBloc => BlocProvider.of<AppBloc>(context);

  @override
  Widget build(BuildContext context) {
    const double dropTargetHeight = 100;
    return BlocConsumer<AppBloc, AppState>(
      listenWhen: (oldState, newState) {
        return oldState.isLoading != newState.isLoading ||
            oldState.mediaTypeBeingDragged != newState.mediaTypeBeingDragged;
      },
      listener: (context, state) async {
        if (state.isLoading && !animationController.isAnimating) {
          animationController.repeat(reverse: true);
          await appBloc.firstWhere((appState) => appState.isLoading == false);
          animationController.reverse();
        }

        setState(() {
          if (state.mediaTypeBeingDragged == DragMediaType.audio) {
            _audioStreamDropTargetElevation = 1;
          } else if (state.mediaTypeBeingDragged == DragMediaType.video) {
            _videoStreamDropTargetElevation = 1;
          } else {
            _audioStreamDropTargetElevation = 0;
            _videoStreamDropTargetElevation = 0;
          }
        });
      },
      builder: (BuildContext context, AppState state) {
        const padding = 10.0;
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Row(
            children: <Widget>[
              NavigationRail(
                destinations: [
                  NavigationRailDestination(
                      icon: RotationTransition(
                        turns: animationController,
                        child: AnimatedIcon(
                          icon: AnimatedIcons.search_ellipsis,
                          progress: animationController,
                        ),
                      ),
                      label: Text('Search')),
                  NavigationRailDestination(
                      icon: Icon(Icons.history), label: Text('History')),
                ],
                selectedIndex: state.navigationDrawerIndex,
                labelType: NavigationRailLabelType.selected,
                onDestinationSelected: (int index) {
                  appBloc.changeNavigationIndex(index);
                },
              ),
              Drawer(
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: AnimatedSwitcher(
                      duration: kThemeAnimationDuration,
                      child: getDrawerWidget(state),
                    )),
              ),
              Expanded(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.hasVideo)
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Card(
                                child: CachedNetworkImage(
                                  imageUrl:
                                      state.video.thumbnailSet.mediumResUrl,
                                  fit: BoxFit.fitHeight,
                                ),
                                elevation: 8,
                              ),
                              Card(
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      ListTile(
                                        title: Text(state.video.title),
                                        subtitle: Text(
                                            '${state.video.statistics.viewCount} views • ${state.video.uploadDate.toMdY()}'),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      if (state.hasMediaStreamInfo)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(padding),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: FormatListView(
                                    title: 'Video with Audio',
                                    mediaStreams:
                                        state.mediaStreamInfoSet.muxed,
                                    onPressed: (
                                      MediaStreamInfo format,
                                    ) async {
                                      await appBloc.downloadVideo(
                                          video: state.video,
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
                                      mediaStreams:
                                          state.mediaStreamInfoSet.video,
                                      onPressed:
                                          (MediaStreamInfo format) async {
                                        await appBloc.downloadVideo(
                                            video: state.video,
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
                                      mediaStreams:
                                          state.mediaStreamInfoSet.audio,
                                      onPressed:
                                          (MediaStreamInfo format) async {
                                        await appBloc.downloadVideo(
                                            video: state.video,
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
                        ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Card(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Material(
                                color: Theme.of(context).cardColor,
                                elevation: elevation,
                                child: Container(
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(padding),
                                  child: Text('Merge'),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(padding),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: DragTarget<MediaStreamInfo>(
                                        builder: (BuildContext context,
                                            List<MediaStreamInfo> candidateData,
                                            List<dynamic> rejectedData) {
                                          Widget child;
                                          bool hasVideoInfo =
                                              _videoStreamInfoToMerge != null;
                                          if (!hasVideoInfo) {
                                            child = Text('Drop Video Here');
                                          } else {
                                            child = FormatTile(
                                              format: _videoStreamInfoToMerge,
                                            );
                                          }
                                          return Card(
                                            elevation:
                                                _videoStreamDropTargetElevation,
                                            child: Container(
                                              height: dropTargetHeight,
                                              alignment: Alignment.center,
                                              child: child,
                                            ),
                                          );
                                        },
                                        onWillAccept: (MediaStreamInfo data) {
                                          if (data is VideoStreamInfo) {
                                            setState(() {
                                              _videoStreamDropTargetElevation =
                                                  5;
                                            });
                                            return true;
                                          } else {
                                            return false;
                                          }
                                        },
                                        onAccept:
                                            (MediaStreamInfo videoStreamInfo) {
                                          setState(() {
                                            _videoStreamInfoToMerge =
                                                videoStreamInfo;
                                          });
                                        },
                                        onLeave: (_) {
                                          if (_videoStreamInfoToMerge == null) {
                                            setState(() {
                                              _videoStreamDropTargetElevation =
                                                  0;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    Icon(
                                      Icons.merge_type,
                                      color: _getMergeIconColor(),
                                    ),
                                    Expanded(
                                      child: DragTarget<MediaStreamInfo>(
                                        builder: (BuildContext context,
                                            List<MediaStreamInfo> candidateData,
                                            List<dynamic> rejectedData) {
                                          Widget child;
                                          var hasAudioInfo =
                                              _audioStreamInfoToMerge != null;
                                          if (hasAudioInfo) {
                                            child = FormatTile(
                                              format: _audioStreamInfoToMerge,
                                            );
                                          } else {
                                            child = Text('Drop Audio Here');
                                          }
                                          return Card(
                                            elevation:
                                                _audioStreamDropTargetElevation,
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: dropTargetHeight,
                                              child: child,
                                            ),
                                          );
                                        },
                                        onWillAccept: (data) {
                                          if (data is AudioStreamInfo) {
                                            setState(() {
                                              _audioStreamDropTargetElevation =
                                                  5;
                                            });
                                            return true;
                                          } else {
                                            return false;
                                          }
                                        },
                                        onAccept: (audioStreamInfo) =>
                                            setState(() {
                                          _audioStreamInfoToMerge =
                                              audioStreamInfo;
                                        }),
                                        onLeave: (_) {
                                          if (_audioStreamInfoToMerge == null) {
                                            setState(() {
                                              _audioStreamDropTargetElevation =
                                                  0;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ButtonBar(
                                children: [
                                  OutlineButton(
                                    child: Text('Clear'),
                                    onPressed: () {
                                      setState(() {
                                        _audioStreamInfoToMerge = null;
                                        _audioStreamDropTargetElevation = 0;
                                        _videoStreamInfoToMerge = null;
                                        _videoStreamDropTargetElevation = 0;
                                      });
                                    },
                                  ),
                                  RaisedButton.icon(
                                      onPressed: () {
                                        appBloc.downloadAndMerge(
                                            videoFormat:
                                                _videoStreamInfoToMerge,
                                            audioFormat:
                                                _audioStreamInfoToMerge);
                                      },
                                      icon: Icon(Icons.merge_type),
                                      label: Text('Download and Merge'))
                                ],
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget getDrawerWidget(AppState state) {
    switch (state.navigationDrawerIndex) {
      case 0:
        return SearchDrawerSection(controller: urlController);
      case 1:
      default:
        return VideoHistoryList(
          history: state.history,
          onPressed: (HistoryEntry entry) {
            urlController.text = entry.url;
            appBloc.changeNavigationIndex(0);
            appBloc.getVideoDetails(entry.url);
          },
        );
    }
  }

  Color _getMergeIconColor() {
    if (_videoStreamInfoToMerge != null && _audioStreamInfoToMerge != null) {
      return Theme.of(context).accentColor;
    } else {
      return Theme.of(context).iconTheme.color;
    }
  }
}
