import 'dart:async';
import 'dart:io';
import 'package:flutter_youtube_downloader/services/system_process.dart';
import 'package:meta/meta.dart';

/// tl;dr for youtube-dl:
/// Download videos from YouTube and other websites.
///More information: <http://rg3.github.io/youtube-dl/>./
///
///- Download a video or playlist:/
///    youtube-dl https://www.youtube.com/watch?v=oHg5SJYRHA0/
///
///- List all formats that a video or playlist is available in:/
///    youtube-dl --list-formats https://www.youtube.com/watch?v=Mwa0_nE9H7A/
///
///- Download a video or playlist at a specific quality:/
///    youtube-dl --format "best[height<=480]" https://www.youtube.com/watch?v=oHg5SJYRHA0/
///
///- Download the audio from a video and convert it to an MP3:/
///    youtube-dl -x --audio-format mp3 url/
///
///- Download video(s) as MP4 files with custom filenames:/
///    youtube-dl --format mp4 -o "%(title)s by %(uploader)s on %(upload_date)s in %(playlist)s.%(ext)s" url/
///
///- Download a video and save its description, metadata, annotations, subtitles, and thumbnail:/
///    youtube-dl --write-description --write-info-json --write-annotations --write-sub --write-thumbnail url/
///
///- From a playlist, download all "Let's Play" videos that aren't marked "NSFW" or age-restricted for 7 year-olds:/
///    youtube-dl --match-title "let's play" --age-limit 7 --reject-title "nsfw" playlist_url/
class YoutubeDL {
  final SystemProcess process = SystemProcess('youtube-dl');

  static const String listFormatsParam = '--list-formats';

  Future<File> downloadBestAudioVideo(
    String url, {
    @required String outputPath,
    bool merge = true,
    StreamController outputStreamController,
  }) async {
    String outputFile;
    String filename;
    final downloadProcess = await process.runAsync(
        workingDirectory: outputPath,
        arguments: ['-f', 'bestvideo+bestaudio', url]);

    if (outputStreamController != null) {
      await for (final line in downloadProcess) {
        outputStreamController.add(line);
        if (line.contains('Merging formats into')) {
          filename = RegExp(r'\[ffmpeg\] Merging formats into (?<filename>.*)')
              .firstMatch(line)
              ?.namedGroup('filename')
              ?.replaceAll('"', '');
        } else if (line.contains('has already been downloaded')) {
          filename = RegExp(r'\[download\]\s(?<filename>.*\..*?)\s')
              .firstMatch(line)
              ?.namedGroup('filename')
              ?.replaceAll('"', '');
          outputFile = '$outputPath/$filename';
        }
      }
    }

    outputFile = '$outputPath/$filename';
    final file = File(outputFile);
    assert(file.existsSync());
    return file;
  }
}
