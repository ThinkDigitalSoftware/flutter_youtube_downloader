import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class VideoListTile extends StatelessWidget {
  final String tooltipMessage;

  final String thumbnailUrl;

  final String title;

  final Widget trailing;
  final VoidCallback onTap;

  const VideoListTile({
    Key key,
    @required this.tooltipMessage,
    @required this.thumbnailUrl,
    @required this.title,
    this.trailing,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltipMessage,
      child: ListTile(
        contentPadding: EdgeInsets.only(right: 16.0),
        leading: CachedNetworkImage(
          height: 50,
          fit: BoxFit.contain,
          imageUrl: thumbnailUrl,
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 12),
        ),
        hoverColor: Colors.white70,
        trailing: trailing,
        onTap: onTap,
      ),
      waitDuration: Duration(seconds: 3),
    );
  }
}
