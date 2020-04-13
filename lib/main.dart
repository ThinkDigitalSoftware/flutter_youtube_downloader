import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_youtube_downloader/bloc/app_bloc.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' hide Container;

void main() {
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

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController controller = TextEditingController();

  var selectedFormat;
  AppBloc get appBloc => BlocProvider.of<AppBloc>(context);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (BuildContext context, AppState state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: [
              FlatButton(
                child: Text(
                  'Load',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  if (videoUrl.isNotEmpty) {
                    loadDetails(videoUrl);
                  }
                },
              ),
              FlatButton(
                child: Text(
                  'List formats',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: listFormats,
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state is VideoDetailsState)
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(border: Border.all()),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Card(
                          child: Image.network(
                            state.video.thumbnailSet.mediumResUrl,
                            fit: BoxFit.fitHeight,
                          ),
                          elevation: 8,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            state.video.description,
                            softWrap: true,
                          ),
                        )
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Video Url',
                            border: OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                if (videoUrl.isNotEmpty) {
                                  controller.clear();
                                }
                              },
                            ),
                          ),
                          controller: controller,
                          onChanged: (_) {},
                          validator: (String url) {
                            bool isValid =
                                YoutubeExplode.parseVideoId(url) != null;
                            if (!isValid) {
                              return 'Please enter a valid Youtube video Url';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (state is VideoDetailsState)
                  ExpansionTile(title: Text('Video Streams'))
                // Expanded(
                //   child: Container(
                //     height: 50,
                //     padding: EdgeInsets.all(10),
                //     child: DropdownButton<Format>(
                //       value: selectedFormat,
                //       hint: Text('Select a format'),
                //       items: [
                //         for (final format in state.mediaStreamInfoSet)
                //           DropdownMenuItem<Format>(
                //             child: Container(
                //                 width:
                //                     MediaQuery.of(context).size.width * .85,
                //                 child: format.toWidget()),
                //             value: format,
                //           )
                //       ],
                //       onChanged: (Format value) {
                //         setState(() {
                //           selectedFormat = value;
                //         });
                //       },
                //     ),
                //   ),
                // )
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: selectedFormat != null ? () async {} : null,
            tooltip: 'Download video',
            child: Icon(Icons.cloud_download),
          ),
        );
      },
    );
  }

  String get videoUrl => controller.text;

  void loadThumbnail(String url) async {}

  String get videoId {
    final regex = RegExp('v=(.+)');

    final allMatches = regex.allMatches(videoUrl);
    if (allMatches.isNotEmpty) {
      var id = allMatches.first.group(1);
      if (id.length == 11) {
        return id;
      }
    }
    return '';
  }

  void listFormats() async {
    // final result =
    //     await Process.run('youtube-dl', ['--list-formats', videoUrl]);

    // List rawFormats = result.stdout
    //     .toString()
    //     .split('\n')
    //     .skipWhile((value) => !value.startsWith(RegExp(r'\d')))
    //     .where((value) => value.isNotEmpty)
    //     .toList();

    // List<Format> formats = rawFormats.map((e) => Format.fromString(e)).toList();
    // setState(() {
    //   selectedFormat = null;
    //   availableFormats = formats;
    // });
  }

  Future<void> loadDetails(String url) async {
    appBloc.getVideoDetails(url);
//    final String description =
//        await command(url: url, command: '--get-description');
//    final String duration = await command(url: url, command: '--get-duration');
//    final String fileName = await command(url: url, command: '--get-filename');
//    VideoDetails details = VideoDetails(
//        duration: duration, fileName: fileName, description: description);
//    return details;
  }

  Future<String> command({
    @required String url,
    @required String command,
  }) async {
    final result = await Process.run('youtube-dl', [command, url]);
    return result.stdout.toString().trim();
  }
}
