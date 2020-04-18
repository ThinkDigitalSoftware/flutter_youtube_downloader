import 'dart:io';

import 'package:flutter_youtube_downloader/services/system_process.dart';
import 'package:meta/meta.dart';

class FFMpeg {
  final SystemProcess process = SystemProcess('ffmpeg');

  FFMpeg();

  String get help => run(['-h']);

  String run([List<String> arguments]) => process.runSync(arguments: arguments);

  void merge(String audioPath, String videoPath,
      {@required String destinationPath}) {
    final File audioFile = File(audioPath);
    final File videoFile = File(videoPath);

    if (!audioFile.existsSync()) {
      throw FileSystemException('Audio File not found', audioPath);
    }

    if (!videoFile.existsSync()) {
      throw FileSystemException('Video File not found', videoPath);
    }
    final result = process.runSync(arguments: [
      '-i',
      videoPath,
      '-i',
      audioPath,
      '-c:v',
      'copy',
      '-c:a',
      'aac',
      destinationPath
    ]);
    return;
  }
}
