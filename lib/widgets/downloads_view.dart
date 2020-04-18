import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_youtube_downloader/bloc/app_bloc.dart';
import 'package:flutter_youtube_downloader/services/database.dart';

class DownloadsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Downloads downloads = AppBloc.of(context).downloads;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Downloads',
          style: Theme.of(context).textTheme.headline6,
        ),
        Expanded(
          child: ListView.separated(
            itemCount: downloads.length,
            itemBuilder: (BuildContext context, int index) {
              final download = downloads.allDownloads[index];
              return ListTile(
                leading: CachedNetworkImage(
                  imageUrl: download.thumbnailUrl,
                ),
                //TODO: Add onClick to open file. Add blurred out view if download not available.
                title: Text(
                  download.video.title,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return Divider();
            },
          ),
        ),
      ],
    );
  }
}
