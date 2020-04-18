import 'dart:io';

import 'package:flutter_youtube_downloader/services/ffmpeg_manager.dart';
import 'package:flutter_youtube_downloader/services/file_manager.dart';
import 'package:test/test.dart';

main() {
  final ffmpeg = FFMpeg();
  test('test help', () {
    expect(ffmpeg.help, TypeMatcher<String>());
  });

  test('test merge', () {
    final dir = Directory.current;
    expect(ffmpeg.help, TypeMatcher<String>());
  });

  test('test RegExp', () {
    final string =
        '[ffmpeg] Merging formats into "MUSIC _ JESSIE REYEZ - COFFIN-My3tzsGwsx0.mkv';
    final filename = RegExp(
            r'\[ffmpeg\] Merging formats into (.*) | \[download\](.*\..*?)\s')
        .firstMatch(string)
        ?.group(1)
        ?.replaceAll('"', '');
    final filename2 = RegExp(r'\[download\]\s(.*\..*?)\s')
        .firstMatch(
            '[download] MUSIC _ JESSIE REYEZ - COFFIN-My3tzsGwsx0.mkv has already been downloaded and merged')
        ?.group(1)
        ?.replaceAll('"', '');
    print('');
  });

  test('opendir opens dir', () {
    FileSystemManager.openFile(
        '/Users/thinkdigital/Downloads/Jonathan White _ Onboarding Documents/• EIACA.pdf',
        openContainingDirectory: true);
  });
}
