import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';

class HighlightedText extends StatelessWidget {
  final String fullText;
  final String query;
  final TextStyle? normalStyle;
  final TextStyle? highlightStyle;
  final int? maxLines;
  final TextOverflow? overflow;

  const HighlightedText({
    super.key,
    required this.fullText,
    required this.query,
    this.normalStyle,
    this.highlightStyle,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(
        fullText,
        style: normalStyle,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final lowerCaseFullText = fullText.toLowerCase();
    final lowerCaseQuery = query.toLowerCase();
    final List<TextSpan> spans = [];
    int start = 0;

    while (true) {
      final index = lowerCaseFullText.indexOf(lowerCaseQuery, start);
      if (index < 0) {
        spans.add(TextSpan(
          text: fullText.substring(start),
          style: normalStyle,
        ));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(
          text: fullText.substring(start, index),
          style: normalStyle,
        ));
      }
      spans.add(TextSpan(
        text: fullText.substring(index, index + query.length),
        style: highlightStyle ??
            normalStyle?.copyWith(backgroundColor: highlightColor) ??
            const TextStyle(backgroundColor: highlightColor),
      ));
      start = index + query.length;
    }

    return Text.rich(
      TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
