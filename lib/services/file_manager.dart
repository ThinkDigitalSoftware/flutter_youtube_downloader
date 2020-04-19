import 'dart:io';

import 'package:flutter_youtube_downloader/services/system_process.dart';

class FileSystemManager {
  static openDirectory(String path) {
    if (!Directory(path).existsSync()) {
      throw OSError('No directory found at "$path"');
    }
    final SystemProcess process = SystemProcess(openCommand);
    process.runSync(arguments: [path]);
  }

  static String get openCommand {
    if (Platform.isMacOS) {
      return 'open';
    }
    if (Platform.isWindows) {
      return 'start';
    }
    if (Platform.isLinux) {
      return 'xdg-open';
    }
    throw UnsupportedError('This platform is not currently supported');
  }

  static openFile(String path, {bool openContainingDirectory = false}) {
    if (!File(path).existsSync()) {
      throw OSError('No file found at "$path"');
    }

    final SystemProcess process = SystemProcess(openCommand);
    process.runSync(arguments: [
      if (openContainingDirectory && Platform.isMacOS) '-R',
      path
    ]);
  }
}
