import 'package:flutter/material.dart';

class Format {
  final String formatCode, extension, resolution, note;

  Format({this.formatCode, this.extension, this.resolution, this.note});

  factory Format.fromString(String format) {
    var splitList = format.split(RegExp(r'\s{2,}'));
    if (splitList.length > 4) {
      var joinedRemainder = splitList.sublist(3).join(' ');
      splitList[3] = joinedRemainder;
      splitList.removeRange(4, splitList.length);
    }
    assert(splitList.length == 4);
    return Format(
      formatCode: splitList[0],
      extension: splitList[1],
      resolution: splitList[2],
      note: splitList[3],
    );
  }

  Widget toWidget() {
    var labelStyle = TextStyle(fontWeight: FontWeight.bold);
    var normalStyle = TextStyle(fontWeight: FontWeight.normal);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: ListTile(
            title: Text('Resolution'),
            subtitle: Text.rich(
              TextSpan(
                  text: '$extension: ',
                  style: labelStyle,
                  children: [TextSpan(text: resolution, style: normalStyle)]),
              textAlign: TextAlign.start,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: ListTile(
            title: Text('Description'),
            subtitle: Text(note),
          ),
        )
      ],
    );
  }
}
