import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LinkAwareClickableText extends StatelessWidget {
  final String text;
  final Function(String link) onClick;

  const LinkAwareClickableText(this.text, {@required this.onClick})
      : assert(onClick != null);

  @override
  Widget build(BuildContext context) {
    //TODO clean up this split so it doesn't take non-word characters.
    List splitText = text.split(RegExp(r'\s'));
    print(splitText);
    List<List<String>> sections = [[]];
    int currentListIndex = 0;

    for (final word in splitText) {
      if (!word.startsWith(youtubeLinkRegExp)) {
        sections[currentListIndex].add(word);
      } else {
        currentListIndex++; // move up an index, add the link and then move up again to add more words.
        sections.addAll([
          [word],
          []
        ]);
        currentListIndex++;
      }
    }

    // WIP
    sections.map((list) {
      if (list.isEmpty) {
        return ['~~~~~~~~~~~~~~~~~~~~~~~~~~'];
      }
      return list;
    });
    List<String> joinedLists =
        sections.map((section) => section.join(' ')).toList();
    String firstTextSpan = joinedLists.removeAt(0);
    List<TextSpan> children = [
      for (final text in joinedLists) _getTextSpan(text)
    ];
    return Text.rich(
      TextSpan(
        text: firstTextSpan,
        children: children,
      ),
    );
  }

  RegExp get youtubeLinkRegExp => RegExp(r'https:\/\/www.yout.*');

  TextSpan _getTextSpan(String text) {
    if (text.startsWith(youtubeLinkRegExp)) {
      return TextSpan(
          text: " $text",
          style: TextStyle(color: Colors.blue),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              if (onClick != null) {
                return onClick(text);
              }
            });
    } else {
      return TextSpan(text: " $text");
    }
  }
}
