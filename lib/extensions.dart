import 'package:youtube_explode_dart/youtube_explode_dart.dart';

extension VideoX on Video {
  Map<String, dynamic> toJson() {
    assert(id != null);
    return {
      'id': this.id,
      'author': this.author,
      'uploadDate': this.uploadDate.millisecondsSinceEpoch,
      'title': this.title,
      'description': this.description,
      'duration': this.duration.inMilliseconds,
      'keyWords': this.keyWords,
      if (statistics != null)
        'statistics': {
          'viewCount': statistics.viewCount,
          'likeCount': statistics.likeCount,
          'dislikeCount': statistics.dislikeCount
        }
    };
  }

  static Video fromJson(Map<String, dynamic> json) {
    assert(json['id'] != null);

    return Video(
      json['id'] as String,
      json['author'] as String,
      json['uploadDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['uploadDate'])
          : null,
      json['title'] as String,
      json['description'] as String,
      json['id'] != null ? ThumbnailSet(json['id']) : null,
      json['duration'] != null
          ? Duration(milliseconds: json['duration'])
          : null,
      (json['keyWords'] as List)?.cast<String>(),
      json['statistics'] != null
          ? Statistics(
              json['statistics']['viewCount'],
              json['statistics']['likeCount'],
              json['statistics']['dislikeCount'],
            )
          : null,
    );
  }
}

extension DateTimeX on DateTime {
  toMdY() => '${_monthToString(month)} $day, $year';

  _monthToString(int month) {
    switch (month) {
      case DateTime.january:
        return 'January';

      case DateTime.february:
        return 'February';
      case DateTime.march:
        return 'March';
      case DateTime.april:
        return 'April';
      case DateTime.may:
        return 'May';
      case DateTime.june:
        return 'June';
      case DateTime.july:
        return 'July';
      case DateTime.august:
        return 'August';
      case DateTime.september:
        return 'September';
      case DateTime.october:
        return 'October';
      case DateTime.november:
        return 'November';
      case DateTime.december:
        return 'December';
    }
  }
}
