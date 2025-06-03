import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/common%20widgets/footer_elements_appbar.dart';
import 'package:flutter/material.dart';

class BidsScreen extends StatelessWidget {
  const BidsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavbarElementsAppbar(appBarTitle: 'Bids'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.gavel,
              size: 100,
              color: greyColor,
            ),
            const SizedBox(height: 20),
            const Text(
              'No active bids!',
              style: TextStyle(fontSize: 18, color: greyColor),
            ),
          ],
        ),
      ),
    );
  }
}
