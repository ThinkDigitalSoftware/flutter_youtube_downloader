import 'dart:convert';
import 'dart:io';

class SystemProcess {
  final String baseProgram;

  SystemProcess(this.baseProgram);

  String runSync({String workingDirectory, List<String> arguments}) {
    ProcessResult processResult = Process.runSync(baseProgram, arguments,
        workingDirectory: workingDirectory);
    print('Running $baseProgram ${arguments.join(' ')},}');
    return processResult.stdout.toString();
  }

  Future<Stream<String>> runAsync({
    List<String> arguments = const [],
    String workingDirectory,
  }) async {
    final Process process = await Process.start(
      baseProgram,
      arguments,
      workingDirectory: workingDirectory,
    );
    return process.stdout.transform(utf8.decoder).asBroadcastStream()
      ..listen(print);
  }
}
