import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:alletre_app/controller/services/auth_services.dart';
import 'package:alletre_app/utils/images/images.dart';
import 'package:alletre_app/utils/routes/main_stack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';

class OnboardingPage3 extends StatelessWidget {
  final PageController pageController; // Added PageController

  const OnboardingPage3(
      {super.key, required this.pageController}); // Receiving PageController

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
          Positioned(
            bottom: 30,
            left: 30,
            right: 30,
            child: SlideAction(
              text: "Get Started",
              textStyle:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              height: 60,
              sliderButtonIconSize: 17,
              sliderRotate: true,
              onSubmit: () async {
                // Mark onboarding as completed
                final userAuthService = UserAuthService();
                await userAuthService.setOnboardingCompleted();

                // Navigate to home screen with auth options
                if (!context.mounted) return null;
                
                // Set index to home (0) before navigating
                Provider.of<TabIndexProvider>(context, listen: false).updateIndex(0);
                
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainStack()),
                  (route) => false,
                );
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
