import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter_youtube_downloader/extensions.dart';

class FormatTile extends StatelessWidget {
  const FormatTile({
    Key key,
    @required this.format,
    this.trailing,
  }) : super(key: key);

  final MediaStreamInfo format;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
