import 'package:alletre_app/view/onboarding%20screens/onboarding_screen3.dart';
import 'package:flutter/material.dart';
import 'onboarding_screen1.dart';
import 'onboarding_screen2.dart';

class OnboardingPages extends StatelessWidget {
  const OnboardingPages({super.key});

  @override
  Widget build(BuildContext context) {
    // PageController to control the page view
    final PageController pageController = PageController();

    return Scaffold(
      body: PageView(
        controller: pageController,  // Use the controller
        children: [
          OnboardingPage1(pageController: pageController),
          OnboardingPage2(pageController: pageController),
          OnboardingPage3(pageController: pageController),
        ],
      ),
    );
  }
}
