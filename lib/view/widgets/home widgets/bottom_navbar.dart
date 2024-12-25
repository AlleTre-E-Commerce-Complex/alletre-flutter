import 'package:alletre_app/utils/extras/text_button.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/screens/login%20screen/login_page.dart';
import 'package:alletre_app/view/screens/signup%20screen/signup_page.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildFixedSizeButton(
          text: 'Login',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          ),
          backgroundColor: secondaryColor,
          borderColor: const Color.fromARGB(255, 253, 215, 222),
          textStyle: Theme.of(context).textTheme.bodySmall!,
        ),
        buildFixedSizeButton(
          text: 'Sign Up',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignUpPage()),
          ),
          backgroundColor: primaryColor,
          borderColor: secondaryColor,
          textStyle: Theme.of(context).textTheme.bodyMedium!,
        ),
      ],
    );
  }
}
