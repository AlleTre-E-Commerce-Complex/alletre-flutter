import 'package:alletre_app/utils/images/images.dart';
import 'package:alletre_app/utils/navigation/named_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:slide_to_act/slide_to_act.dart';

class OnboardingPage3 extends StatelessWidget {
  final PageController pageController;  // Added PageController

  const OnboardingPage3({super.key, required this.pageController});  // Receiving PageController

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SvgPicture.asset(
            AppImages.onboarding3,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity
          ),
          // Slide to act button
          Positioned(
            bottom: 30,
            left: 30,
            right: 30,
            child: SlideAction(
              text: "Get Started",
              textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              height: 60,
              sliderButtonIconSize: 17,
              sliderRotate: true,
              onSubmit: () {
                Navigator.pushReplacementNamed(context, AppRoutes.home);
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
