// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'package:alletre_app/view/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _navigateToHome(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    _navigateToHome(context);

    return Scaffold(
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
                  'assets/images/alletre_splash.svg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
