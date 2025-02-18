// OnboardingPage2.dart
import 'package:alletre_app/utils/images/images.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class OnboardingPage2 extends StatelessWidget {
  final PageController pageController;

  const OnboardingPage2({super.key, required this.pageController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SvgPicture.asset(
            AppImages.onboarding2,
            fit: BoxFit.cover,
          ),
          // Swipe Icon
          const Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Icon(
                Icons.swipe_left_rounded,
                color: primaryColor,
                size: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
