import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_youtube_downloader/format.dart';
import 'package:flutter_youtube_downloader/video_details.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' hide Container;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  String match = '';
  String thumbnailUrl;
  List<Format> availableFormats;
  Format selectedFormat;
  VideoDetails videoDetails;

  @override
  Widget build(BuildContext context) {
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
              loadThumbnail(controller.text);
              final details = await loadDetails(controller.text);
              setState(() {
                videoDetails = details;
              });
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
            if (thumbnailUrl != null)
              Container(
                height: 300,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(border: Border.all()),
                child: Row(
                  children: <Widget>[
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Card(
                          child: Image.network(
                            thumbnailUrl,
                            fit: BoxFit.fitHeight,
                          ),
                          elevation: 8,
                        ),
                        Text(videoDetails.description)
                      ],
                    ),
                    if (videoDetails != null) //TODO Fix overflow on screen.
                      Expanded(
                        flex: 2,
                        child: Text(
                          videoDetails.toString(),
                          textAlign: TextAlign.center,
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
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Video Url',
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () => controller.clear(),
                        ),
                      ),
                      controller: controller,
                      onChanged: (_) {
                        if (videoId.isNotEmpty) {
                          setState(() {
                            match = videoId;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (availableFormats != null)
              Expanded(
                child: Container(
                  height: 50,
                  padding: EdgeInsets.all(10),
                  child: DropdownButton<Format>(
                    value: selectedFormat,
                    hint: Text('Select a format'),
                    items: [
                      for (final format in availableFormats)
                        DropdownMenuItem<Format>(
                          child: Container(
                              width: MediaQuery.of(context).size.width * .85,
                              child: format.toWidget()),
                          value: format,
                        )
                    ],
                    onChanged: (Format value) {
                      setState(() {
                        selectedFormat = value;
                      });
                    },
                  ),
                ),
              )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: selectedFormat != null ? () async {} : null,
        tooltip: 'Download video',
        child: Icon(Icons.cloud_download),
      ),
    );
  }

  void loadThumbnail(String url) async {
  
  }

  String get videoId {
    final regex = RegExp('v=(.+)');

    final allMatches = regex.allMatches(controller.text);
    if (allMatches.isNotEmpty) {
      var id = allMatches.first.group(1);
      if (id.length == 11) {
        return id;
      }
    }
    return '';
  }

  void listFormats() async {
    final result =
        await Process.run('youtube-dl', ['--list-formats', controller.text]);

    List rawFormats = result.stdout
        .toString()
        .split('\n')
        .skipWhile((value) => !value.startsWith(RegExp(r'\d')))
        .where((value) => value.isNotEmpty)
        .toList();

    List<Format> formats = rawFormats.map((e) => Format.fromString(e)).toList();
    setState(() {
      selectedFormat = null;
      availableFormats = formats;
    });
  }

  Future<VideoDetails> loadDetails(String url) async {
//
    final String description =
        await command(url: url, command: '--get-description');
    final String duration = await command(url: url, command: '--get-duration');
    final String fileName = await command(url: url, command: '--get-filename');
    VideoDetails details = VideoDetails(
        duration: duration, fileName: fileName, description: description);
    return details;
  }

  Future<String> command({
    @required String url,
    @required String command,
  }) async {
    final result = await Process.run('youtube-dl', [command, url]);
    return result.stdout.toString().trim();
  }
}
