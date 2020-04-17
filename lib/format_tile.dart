import 'package:flutter/material.dart';
import 'package:flutter_youtube_downloader/format_list_view.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter_youtube_downloader/extensions.dart';

class FormatTile extends StatelessWidget {
  const FormatTile({
    Key key,
    @required this.format,
    this.trailing,
    this.footer,
    this.progressStream,
  }) : super(key: key);

  final MediaStreamInfo format;
  final Widget trailing;
  final Widget footer;
  final Stream<Progress> progressStream;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text.rich(
            TextSpan(
              text: 'Format: ',
              children: [
                TextSpan(
                  text: _getFormatText(),
                  style: TextStyle(fontWeight: FontWeight.w200),
                )
              ],
            ),
          ),
          subtitle: Text.rich(
            TextSpan(
              text: '${format is AudioStreamInfo ? 'Bitrate' : 'Resolution'}: ',
              children: [
                TextSpan(
                  text: _getQualityText(),
                  style: TextStyle(fontWeight: FontWeight.w200),
                )
              ],
            ),
          ),
          trailing: trailing,
        ),
        if (progressStream != null)
          StreamBuilder<Progress>(
            stream: progressStream,
            initialData: Progress(0, 1),
            builder: (context, snapshot) {
              return LinearProgressIndicator(
                value: snapshot.data.ratio,
              );
            },
          )
      ],
    );
  }

  _getFormatText() {
    if (format is MuxedStreamInfo) {
      return (format as MuxedStreamInfo).container.extension.substring(1);
    } else if (format is VideoStreamInfo) {
      return (format as VideoStreamInfo).container.extension.substring(1);
    } else if (format is AudioStreamInfo) {
      return (format as AudioStreamInfo).audioEncoding.extension.substring(1);
    }
  }

  _getQualityText() {
    if (format is MuxedStreamInfo) {
      return (format as MuxedStreamInfo).videoResolution.toString();
    } else if (format is VideoStreamInfo) {
      return (format as VideoStreamInfo).videoResolution.toString();
    } else if (format is AudioStreamInfo) {
      var kbps = (format as AudioStreamInfo).bitrate / 100;
      return '$kbps kbps';
    }
  }
}
