import 'package:flutter/material.dart';

class EditProfileCardSection extends StatelessWidget {
  final Widget child;

  const EditProfileCardSection({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}
