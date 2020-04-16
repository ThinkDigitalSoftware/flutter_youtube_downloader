import 'package:flutter/material.dart';
import 'package:flutter_youtube_downloader/format_tile.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class FormatListView extends StatelessWidget {
  final List<MediaStreamInfo> mediaStreams;
  final String title;

  final ValueChanged<MediaStreamInfo> onPressed;

  const FormatListView({
    Key key,
    @required this.title,
    @required this.mediaStreams,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(title),
            ),
            ListView.separated(
              itemCount: mediaStreams.length,
              shrinkWrap: true,
              separatorBuilder: (BuildContext context, int index) {
                return Divider();
              },
              itemBuilder: (BuildContext context, int index) {
                final format = mediaStreams[index];

                return FormatTile(
                  format: format,
                  trailing: IconButton(
                    icon: Icon(Icons.cloud_download),
                    onPressed: () => onPressed(format),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
