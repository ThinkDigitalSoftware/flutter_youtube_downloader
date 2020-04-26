import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_youtube_downloader/bloc/app/app_bloc.dart';
import 'package:flutter_youtube_downloader/bloc/search/search_bloc.dart';
import 'package:flutter_youtube_downloader/widgets/video_tile.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' hide Container;

class SearchDrawerSection extends StatefulWidget {
  final TextEditingController controller;

  const SearchDrawerSection({Key key, @required this.controller})
      : super(key: key);

  @override
  _SearchDrawerSectionState createState() => _SearchDrawerSectionState();
}

class _SearchDrawerSectionState extends State<SearchDrawerSection> {
  GlobalKey<FormState> _formKey = GlobalKey();
  bool shouldShowPreviewDescriptionText = true;

  @override
  void dispose() {
    super.dispose();
  }

  String get videoUrl => widget.controller.text;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (BuildContext context, AppState appState) {
        return BlocBuilder<SearchBloc, SearchState>(
          builder: (BuildContext context, SearchState searchState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Form(
                  key: _formKey,
                  child: Row(children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        toolbarOptions: ToolbarOptions(
                          paste: true,
                          copy: true,
                          cut: true,
                          selectAll: true,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: 'Search',
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              if (videoUrl.isNotEmpty) {
                                widget.controller.clear();
                              }
                            },
                          ),
                        ),
                        controller: widget.controller,
                        onChanged: (_) {},
                        onFieldSubmitted: (String url) {
                          if (appState.video.id !=
                              YoutubeExplode.parseVideoId(url)) {
                            submit(url);
                          }
                        },
                        validator: (String url) {
                          bool isValid = url.isNotEmpty;
                          if (!isValid) {
                            return 'Please enter a search term or video ';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.search),
                        ),
                        onTap: searchOnTap(appState),
                      ),
                    )
                  ]),
                ),
                if (searchState is SearchResultsState)
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: searchState.searchResults.length,
                      itemBuilder: (BuildContext context, int index) {
                        final video = searchState.searchResults[index];
                        return VideoSearchListTile(
                          video: video,
                          onTap: () {
                            appBloc.loadFromVideo(video);
                          },
                        );
                      },
                    ),
                  )
              ],
            );
          },
        );
      },
    );
  }

  Function searchOnTap(AppState state) {
    if (state.isLoading) {
      return null;
    } else {
      return () {
        if (_formKey.currentState.validate()) {
          if (state?.video?.id != YoutubeExplode.parseVideoId(videoUrl)) {
            submit(videoUrl);
          }
        }
      };
    }
  }

  Future<void> loadDetails(String url) async => appBloc.getVideoDetails(url);

  AppBloc get appBloc => AppBloc.of(context);

  SearchBloc get searchBloc => SearchBloc.of(context);

  void submit(String value) {
    final formIsValid = _formKey.currentState.validate();
    if (formIsValid) {
      if (YoutubeExplode.parseVideoId(value) != null) {
        appBloc.getVideoDetails(value);
      } else {
        searchBloc.search(value);
      }
    }
  }
}

class VideoSearchListTile extends StatelessWidget {
  final Video video;
  final VoidCallback onTap;

  const VideoSearchListTile({Key key, @required this.video, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VideoListTile(
      thumbnailUrl: video.thumbnailSet.lowResUrl,
      title: video.title,
      tooltipMessage: video.description,
      onTap: onTap,
    );
  }
}
