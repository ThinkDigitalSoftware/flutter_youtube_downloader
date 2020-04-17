import 'dart:io';

import 'package:meta/meta.dart';

class FFMpeg {
  static String get help => _run('-h');

  static merge(String audioPath, String videoPath,
      {@required String destinationPath}) {
    final File audioFile = File(audioPath);
    final File videoFile = File(videoPath);

    if (!audioFile.existsSync()) {
      throw FileSystemException('Audio File not found', audioPath);
    }

    if (!videoFile.existsSync()) {
      throw FileSystemException('Video File not found', videoPath);
    }
    final result = _run('-i', [
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

  static String _run(String command, [List<String> parameters]) {
    return Process.runSync('ffmpeg', [command, ...parameters ?? []])
        .stdout
        .toString();
  }
}
