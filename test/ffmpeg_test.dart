import 'dart:io';

import 'package:flutter_youtube_downloader/services/ffmpeg_manager.dart';
import 'package:test/test.dart';

main() {
  test('test help', () {
    expect(FFMpeg.help, TypeMatcher<String>());
  });

  test('test merge', () {
    final dir = Directory.current;
    expect(FFMpeg.help, TypeMatcher<String>());
  });
}
