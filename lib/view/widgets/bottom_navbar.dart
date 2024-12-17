import 'package:alletre_app/utils/button/textbutton.dart';
import 'package:alletre_app/utils/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BottomNavBarWidget extends StatelessWidget {
  const BottomNavBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Theme.of(context).bottomAppBarTheme.color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildFixedSizeButton(
            text: 'Login',
            onPressed: () {},
            backgroundColor: secondaryColor,
            borderColor: const Color.fromARGB(255, 253, 215, 222),
            textStyle: Theme.of(context).textTheme.bodySmall!,
          ),
          buildFixedSizeButton(
            text: 'Sign Up',
            onPressed: () {},
            backgroundColor: primaryColor,
            borderColor: secondaryColor,
            textStyle: Theme.of(context).textTheme.bodyMedium!,
          ),
        ],
      ),
    );
  }
}
