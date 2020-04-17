import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_youtube_downloader/bloc/app_bloc.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

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
      builder: (BuildContext context, AppState state) {
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
                      labelText: 'Video Url',
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
                      if (state.video.id != YoutubeExplode.parseVideoId(url)) {
                        submit(url);
                      }
                    },
                    validator: (String url) {
                      bool isValid = YoutubeExplode.parseVideoId(url) != null;
                      if (!isValid) {
                        return 'Please enter a valid Youtube video Url';
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
                    onTap: state.isLoading
                        ? null
                        : () {
                            if (_formKey.currentState.validate()) {
                              if (state?.video?.id !=
                                  YoutubeExplode.parseVideoId(videoUrl)) {
                                submit(videoUrl);
                              }
                            }
                          },
                  ),
                )
              ]),
            ),
            if (state.hasVideo) ...[
//              Text.rich(TextSpan(text: 'Author: ', children: [
//                TextSpan(
//                  text: state.video.author,
//                  style: TextStyle(fontWeight: FontWeight.w200),
//                )
//              ])),
              ListTile(
                title: Text('Author'),
                subtitle: Text(state.video.author),
              ),
              ListTile(
                title: Text('Duration'),
                subtitle: Text(state.video.duration.toString()),
              ),

              Row(
                children: <Widget>[Expanded(child: Divider()), Spacer()],
              ),
              ExpansionTile(
                title: Text('Description'),
                subtitle: AnimatedOpacity(
                  opacity: shouldShowPreviewDescriptionText ? 1 : 0.2,
                  duration: kThemeAnimationDuration,
                  child: Text(
                    state.video.description,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                onExpansionChanged: (isExpanded) {
                  setState(() {
                    shouldShowPreviewDescriptionText = !isExpanded;
                  });
                },
                children: [Text(state.video.description)],
              ),
            ]
          ],
        );
      },
    );
  }

  Future<void> loadDetails(String url) async =>
      AppBloc.of(context).getVideoDetails(url);

  void submit(String url) {
    final formIsValid = _formKey.currentState.validate();
    if (formIsValid) {
      AppBloc.of(context).getVideoDetails(url);
    }
  }
}
