import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_youtube_downloader/bloc/app_bloc.dart';
import 'package:flutter_youtube_downloader/extensions.dart';
import 'package:flutter_youtube_downloader/widgets/link_aware_text.dart';

class VideoDetailsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (BuildContext context, state) {
        return Container(
          constraints: BoxConstraints(maxHeight: 300),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Card(
                    child: CachedNetworkImage(
                      imageUrl: state.video.thumbnailSet.mediumResUrl,
                      fit: BoxFit.fitHeight,
                    ),
                    elevation: 8,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              state.video.title,
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            subtitle: Text(
                                '${state.video.statistics.viewCount} views • ${state.video.uploadDate.toMdY()}'),
                          ),
                          Divider(),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: SingleChildScrollView(
                                child: LinkAwareClickableText(
                                  state.video.description,
                                  onClick: (_) {},
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
