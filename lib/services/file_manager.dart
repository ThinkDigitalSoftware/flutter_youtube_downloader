import 'dart:io';

import 'package:flutter_youtube_downloader/services/system_process.dart';

class FileSystemManager {
  static openDirectory(String path) {
    if (!Directory(path).existsSync()) {
      throw OSError('No directory found at "$path"');
    }

    final SystemProcess process = SystemProcess('open');
    process.runSync(arguments: [path]);
  }

  static openFile(String path, {bool openContainingDirectory = false}) {
    if (!File(path).existsSync()) {
      throw OSError('No file found at "$path"');
    }

    final SystemProcess process = SystemProcess('open');
    process.runSync(arguments: [if (openContainingDirectory) '-R', path]);
  }
}
