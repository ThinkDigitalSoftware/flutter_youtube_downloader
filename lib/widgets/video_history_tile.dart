import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_youtube_downloader/bloc/history_entry.dart';

class VideoHistoryTile extends StatelessWidget {
  final HistoryEntry entry;
  final VoidCallback onPressed;

  const VideoHistoryTile({
    Key key,
    @required this.entry,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: entry.video.description,
      child: ListTile(
        contentPadding: EdgeInsets.only(right: 16.0),
        leading: CachedNetworkImage(
          height: 50,
          fit: BoxFit.contain,
          imageUrl: entry.video.thumbnailSet.lowResUrl,
        ),
        title: Text(
          entry.title,
          style: TextStyle(fontSize: 12),
        ),
        hoverColor: Colors.white70,
        trailing: OutlineButton(
          child: Text('Select'),
          onPressed: onPressed,
        ),
      ),
      waitDuration: Duration(seconds: 3),
    );
  }
}
