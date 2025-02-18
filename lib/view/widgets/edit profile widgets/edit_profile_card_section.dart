import 'package:flutter/material.dart';

class EditProfileCardSection extends StatelessWidget {
  final Widget child;

  const EditProfileCardSection({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 7.0, 16.0, 7.0),
      child: child,
    );
  }
}
