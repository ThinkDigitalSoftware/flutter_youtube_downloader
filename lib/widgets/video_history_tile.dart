import 'package:flutter/material.dart';
import 'package:flutter_youtube_downloader/bloc/history_entry.dart';
import 'package:flutter_youtube_downloader/widgets/video_tile.dart';

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
    return VideoListTile(
      title: entry.title,
      thumbnailUrl: entry.video.thumbnailSet.lowResUrl,
      tooltipMessage: entry.video.description,
      trailing: OutlineButton(
        child: Text('Select'),
        onPressed: onPressed,
      ),
    );
  }
}
