import 'package:alletre_app/utils/extras/common_navbar.dart';
import 'package:alletre_app/view/widgets/common%20widgets/footer_elements_appbar.dart';
import 'package:flutter/material.dart';

class BidsScreen extends StatelessWidget {
  const BidsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavbarElementsAppbar(title: 'Bids'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.gavel,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              'No active bids!',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add functionality to browse auctions or listings
              },
              child: const Text('Browse Auctions'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context)
            .bottomAppBarTheme
            .color, 
        height: Theme.of(context)
            .bottomAppBarTheme
            .height, 
        child: NavBarUtils.buildAuthenticatedNavBar(context),
      ),
    );
  }
}
