import 'package:flutter/material.dart';

class IntroductoryText extends StatelessWidget {
  const IntroductoryText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        'We welcome you to the "ALLE TRE" platform, where we provide electronic auction services. By using the platform, you agree to be bound by the terms and conditions and wish them below. Please read these fine print, as your use of the platform constitutes full acceptance of these terms. If you do not agree, please refrain from using the platform.',
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }
}