import 'package:flutter/material.dart';
import 'package:flutter_youtube_downloader/bloc/history_entry.dart';
import 'package:flutter_youtube_downloader/widgets/video_history_tile.dart';

class VideoHistoryList extends StatelessWidget {
  final List<HistoryEntry> history;
  final ValueChanged<HistoryEntry> onPressed;

  const VideoHistoryList(
      {Key key, @required this.history, @required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'History',
          style: TextStyle(fontSize: 30),
        ),
        Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: history.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              final HistoryEntry entry = history[index];
              return VideoHistoryTile(
                entry: entry,
                onPressed: () => onPressed(entry),
              );
            },
          ),
        ),
      ],
    );
  }
}
