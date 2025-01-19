import 'package:flutter/material.dart';

class SectionWidget extends StatelessWidget {
  final String title;
  final String content;

  const SectionWidget({
    required this.title,
    required this.content,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            content,
            style: Theme.of(context).textTheme.displaySmall
          ),
        ),
      ],
    );
  }
}