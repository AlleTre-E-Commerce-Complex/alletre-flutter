import 'package:flutter/material.dart';

class EditProfileCardSection extends StatelessWidget {
  final Widget child;

  const EditProfileCardSection({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 7.0),
          child: child,
        ),
      ),
    );
  }
}
