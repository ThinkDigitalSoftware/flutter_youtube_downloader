class VideoDetails {
  final String description, duration, fileName;

  VideoDetails({this.description, this.duration, this.fileName});

  @override
  String toString() {
    return 'VideoDetails{description: $description, duration: $duration, fileName: $fileName}';
  }
}
