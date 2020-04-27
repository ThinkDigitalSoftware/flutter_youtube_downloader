import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FallbackLoadingCachedNetworkImage extends StatelessWidget {
  final List<String> urls;
  final LoadingErrorWidgetBuilder errorWidget;

  const FallbackLoadingCachedNetworkImage({
    Key key,
    @required this.urls,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return getChild(urls, errorWidget);
  }

  Widget getChild(List<String> urlList, LoadingErrorWidgetBuilder errorWidget) {
    List<String> remainingList = urlList;
    return CachedNetworkImage(
      imageUrl: remainingList.removeAt(0),
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
      fit: BoxFit.cover,
      errorWidget: (context, url, error) {
        if (remainingList.isNotEmpty) {
          return getChild(remainingList, errorWidget);
        } else {
          if (errorWidget != null) {
            return errorWidget(context, url, error);
          } else {
            return null;
          }
        }
      },
    );
  }
}
