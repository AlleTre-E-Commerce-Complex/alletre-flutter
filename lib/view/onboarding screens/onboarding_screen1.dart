// OnboardingPage1.dart
import 'package:alletre_app/utils/images/images.dart';
import 'package:alletre_app/utils/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class OnboardingPage1 extends StatelessWidget {
  final PageController pageController;

  const OnboardingPage1({super.key, required this.pageController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          SvgPicture.asset(
            AppImages.onboarding1,
            fit: BoxFit.cover,
          ),
          // Skip Button
          Positioned(
            top: 32,
            right: 12,
            child: TextButton(
              onPressed: () {
                // Navigate to the next page (Onboarding 2)
                pageController.jumpToPage(2);
              },
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: primaryVariantColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Swipe Icon
          const Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Icon(
                Icons.swipe_right_rounded,
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
