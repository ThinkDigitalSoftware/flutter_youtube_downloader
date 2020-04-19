import 'package:flutter_youtube_downloader/constants.dart';
import 'package:flutter_youtube_downloader/services/database.dart';
import 'package:flutter_youtube_downloader/widgets/downloads_view.dart';
import 'package:flutter_youtube_downloader/widgets/format_list_view.dart';

import 'package:flutter_youtube_downloader/bloc/history_entry.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_youtube_downloader/bloc/app_bloc.dart';
import 'package:flutter_youtube_downloader/widgets/format_list_view_section.dart';
import 'package:flutter_youtube_downloader/widgets/format_tile.dart';
import 'package:flutter_youtube_downloader/widgets/search_drawer_section.dart';
import 'package:flutter_youtube_downloader/widgets/video_details_section.dart';
import 'package:flutter_youtube_downloader/widgets/video_history_list.dart';
import 'package:hive/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final TextEditingController urlController = TextEditingController();
  AnimationController searchAnimationController;
  AnimationController showInFinderAnimationController;
  AudioStreamInfo _audioStreamInfoToMerge;
  VideoStreamInfo _videoStreamInfoToMerge;

  double _videoStreamDropTargetElevation = 0;

  double _audioStreamDropTargetElevation = 0;

  @override
  void initState() {
    searchAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
      lowerBound: 0,
      upperBound: 1,
    );

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
    urlController.dispose();
    searchAnimationController.dispose();
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
        if (state.isLoading && !searchAnimationController.isAnimating) {
          searchAnimationController.repeat(reverse: true);
          await appBloc.firstWhere((appState) => appState.isLoading == false);
          searchAnimationController.reverse();
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
                      turns: searchAnimationController,
                      child: AnimatedIcon(
                        icon: AnimatedIcons.search_ellipsis,
                        progress: searchAnimationController,
                      ),
                    ),
                    label: Text('Search'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.history),
                    label: Text('History'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.view_list,
                        color: !(state?.hasMediaStreamInfo ?? false)
                            ? Colors.grey
                            : null),
                    label: Text('Formats'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.format_list_numbered,
                        color: !(state.hasMediaStreamInfo ?? false)
                            ? Colors.grey
                            : null),
                    label: Text('Downloads'),
                  ),
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
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.hasVideo)
                        Expanded(child: VideoDetailsSection()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Divider(),
                      ),
                      Expanded(
//                        flex: 2,
                        child: Padding(
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
                                      //TODO @ThinkDigitalSoftware: Break these two DropTargets into separate widgets.
                                      Expanded(
                                        // Video DropTarget
                                        child: DragTarget<MediaStreamInfo>(
                                          builder: (BuildContext context,
                                              List<MediaStreamInfo>
                                                  candidateData,
                                              List<dynamic> rejectedData) {
                                            Widget child;
                                            bool hasVideoInfo =
                                                _videoStreamInfoToMerge != null;
                                            if (!hasVideoInfo) {
                                              child = Text('Drop Video Here',
                                                  style:
                                                      _videoStreamDropTargetElevation !=
                                                              0
                                                          ? TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .accentColor,
                                                            )
                                                          : null);
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
                                          onAccept: (MediaStreamInfo
                                              videoStreamInfo) {
                                            setState(() {
                                              _videoStreamInfoToMerge =
                                                  videoStreamInfo;
                                            });
                                          },
                                          onLeave: (_) {
                                            if (_videoStreamInfoToMerge ==
                                                null) {
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
                                          // Audio DropTarget
                                          builder: (BuildContext context,
                                              List<MediaStreamInfo>
                                                  candidateData,
                                              List<dynamic> rejectedData) {
                                            Widget child;
                                            var hasAudioInfo =
                                                _audioStreamInfoToMerge != null;
                                            if (hasAudioInfo) {
                                              child = FormatTile(
                                                format: _audioStreamInfoToMerge,
                                              );
                                            } else {
                                              child = Text(
                                                'Drop Audio Here',
                                                style:
                                                    _audioStreamDropTargetElevation !=
                                                            0
                                                        ? TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .accentColor,
                                                          )
                                                        : null,
                                              );
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
                                            if (_audioStreamInfoToMerge ==
                                                null) {
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
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Divider(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, bottom: 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Card(
                                          child: Container(
                                            height: 90,
                                            padding: EdgeInsets.all(10),
                                            margin: EdgeInsets.all(10),
                                            child: StreamBuilder(
                                              stream: appBloc.downloadController
                                                      ?.stream ??
                                                  Stream<String>.empty(),
                                              initialData: '',
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<String>
                                                      snapshot) {
                                                String data = snapshot.data;
                                                double
                                                    progressIndicatorPercentage =
                                                    _getProgressIndicatorPercentage(
                                                        data);

                                                if (progressIndicatorPercentage ==
                                                    1.0) {
                                                  data = 'Complete!';
                                                }
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Expanded(
                                                        child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: <Widget>[
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 15.0),
                                                            child: Text(
                                                              data,
                                                              overflow:
                                                                  TextOverflow
                                                                      .fade,
                                                            ),
                                                          ),
                                                        ),
                                                        if (data == 'Complete!')
                                                          AnimatedBuilder(
                                                            builder:
                                                                (BuildContext
                                                                        context,
                                                                    Widget
                                                                        child) {
                                                              return FlatButton(
                                                                onPressed:
                                                                    openDownload,
                                                                child: Text(
                                                                    'Show in Finder'),
                                                              );
                                                            },
                                                            animation:
                                                                showInFinderAnimationController,
                                                          ),
                                                      ],
                                                    )),
                                                    LinearProgressIndicator(
                                                      value:
                                                          progressIndicatorPercentage,
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            OutlineButton(
                                              child: Text('Clear'),
                                              onPressed: () {
                                                setState(() {
                                                  _audioStreamInfoToMerge =
                                                      null;
                                                  _audioStreamDropTargetElevation =
                                                      0;
                                                  _videoStreamInfoToMerge =
                                                      null;
                                                  _videoStreamDropTargetElevation =
                                                      0;
                                                });
                                              },
                                            ),
                                            RaisedButton.icon(
                                                onPressed: downloadAndMerge(),
                                                icon: Icon(Icons.merge_type),
                                                label:
                                                    Text('Download and Merge')),
                                            RaisedButton.icon(
                                                onPressed:
                                                    downloadAndMergeBest(),
                                                icon: Icon(Icons.merge_type),
                                                label: Text('Auto-select Best'))
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
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

  void openDownload() {
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

  Function downloadAndMerge() {
    if (_videoStreamInfoToMerge != null && _audioStreamInfoToMerge != null) {
      return () => appBloc.downloadAndMerge(
            videoFormat: _videoStreamInfoToMerge,
            audioFormat: _audioStreamInfoToMerge,
          );
    } else {
      return null;
    }
  }

  Function downloadAndMergeBest() {
    String url = urlController.text;

    if (url.isEmpty || YoutubeExplode.parseVideoId(url) == null) {
      return null;
    } else {
      return () => appBloc.downloadAndMergeBest(url);
    }
  }

  Widget getDrawerWidget(AppState state) {
    switch (state.navigationDrawerIndex) {
      case 0:
        return SearchDrawerSection(controller: urlController);
      case 1:
        return VideoHistoryList(
          history: state.history,
          onPressed: (HistoryEntry entry) {
            urlController.text = entry.url;
            appBloc.changeNavigationIndex(0);
            appBloc.getVideoDetails(entry.url);
          },
        );
      case 2:
        return FormatListViewSection(
          padding: 10.0,
        );
      case 3:
        return DownloadsView();
      default:
        return Container();
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
