// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'package:alletre_app/controller/providers/focus_state_provider.dart';
import 'package:alletre_app/utils/images/images.dart';
import 'package:alletre_app/utils/routes/main_stack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _navigateToOnBoarding(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainStack()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final focusState = Provider.of<FocusStateNotifier>(context);
    _navigateToOnBoarding(context);

    return GestureDetector(
      onTap: () {
        focusState.unfocus(); // Unfocus the field when tapping outside
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).splashColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo Image
              Container(
                height: 230,
                width: 230,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                ),
                child: ClipOval(
                  child: SvgPicture.asset(
                    AppImages.splash,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
