import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_youtube_downloader/bloc/history_entry.dart';
import 'package:flutter_youtube_downloader/format_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_youtube_downloader/bloc/app_bloc.dart';
import 'package:flutter_youtube_downloader/widgets/search_drawer_section.dart';
import 'package:flutter_youtube_downloader/widgets/video_history_list.dart';
import 'package:hive/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:flutter_youtube_downloader/extensions.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Hive.init(Directory.current.path);
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
    return BlocConsumer<AppBloc, AppState>(
      listenWhen: (oldState, newState) =>
          oldState.isLoading != newState.isLoading,
      listener: (context, state) async {
        if (state.isLoading && !animationController.isAnimating) {
          animationController.repeat(reverse: true);
          await appBloc.firstWhere((appState) => appState.isLoading == false);
          animationController.reverse();
        }
//          if (!state.isLoading && (animationController?.isAnimating ?? false)) {
//            Function(AnimationStatus status) listener;
//            listener = (AnimationStatus status) {
//              if (status == AnimationStatus.forward) {
//                animationController.reset();
//                animationController.removeStatusListener(listener);
//              }
//            };
//            animationController.addStatusListener(listener);
//          }
      },
      builder: (BuildContext context, AppState state) {
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
                        Row(
                          children: [
                            Expanded(
                                child: Card(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text('Muxed'),
                                  ListView.separated(
                                    itemCount:
                                        state.mediaStreamInfoSet.muxed.length,
                                    shrinkWrap: true,
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return Divider();
                                    },
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final format =
                                          state.mediaStreamInfoSet.muxed[index];

                                      return FormatTile(
                                        format: format,
                                        trailing: IconButton(
                                          icon: Icon(Icons.cloud_download),
                                          onPressed: () async {
                                            await appBloc.downloadVideo(
                                              video: state.video,
                                              format: format,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ))
                          ],
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
}
