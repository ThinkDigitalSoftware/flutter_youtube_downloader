import 'package:flutter_youtube_downloader/services/system_process.dart';
import 'package:test/test.dart';

main() {
  test('Test systemProcess runAsync returns a Stream<String>', () async {
    final systemProcess = SystemProcess('ls');
    final Stream<String> process =
        await systemProcess.runAsync(arguments: ['-a']);
    print('about to start the process');
    process.listen(print);
  });
}
