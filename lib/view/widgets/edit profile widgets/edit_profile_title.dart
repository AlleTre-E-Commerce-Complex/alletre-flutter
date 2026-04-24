import 'package:flutter/material.dart';

class EditProfileTitle extends StatelessWidget {
  final String title;

  const EditProfileTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 19)
      ),
    );
  }
}
