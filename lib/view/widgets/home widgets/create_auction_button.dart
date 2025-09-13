// ignore_for_file: use_build_context_synchronously

import 'package:alletre_app/controller/helpers/address_service.dart';
import 'package:alletre_app/view/screens/auction%20screen/add_location_screen.dart';
import 'package:flutter/material.dart';
import 'package:alletre_app/controller/providers/login_state.dart';
import 'package:provider/provider.dart';
import '../../../utils/auth_helper.dart';
import '../../screens/auction screen/product_details_screen.dart';

class CreateAuctionButton extends StatelessWidget {
  const CreateAuctionButton({super.key});

  // Generate a unique hero tag for each instance
  static int _tagCounter = 0;
  static String _getUniqueHeroTag() => 'create_auction_fab_${_tagCounter++}';

  void _handleOptionSelected(BuildContext context, String option) {
    if (option == 'Create Auction') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductDetailsScreen(title: 'Create Auction')));
    } else if (option == 'List Product') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductDetailsScreen(title: 'List Product')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<LoggedInProvider>().isLoggedIn;

    return FloatingActionButton(
      heroTag: _getUniqueHeroTag(),
      onPressed: () async {
        if (!isLoggedIn) {
          AuthHelper.showAuthenticationRequiredMessage(context);
          return;
        }

        final addresses = await AddressService.fetchAddresses();
        if (addresses.isEmpty) {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddLocationScreen()),
          );
          return;
        }

        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            MediaQuery.of(context).size.width / 2 - 100, // center horizontally
            MediaQuery.of(context).size.height - 200,    // position above nav
            MediaQuery.of(context).size.width / 2 + 100,
            0,
          ),
          items: [
            PopupMenuItem<String>(
              value: 'Create Auction',
              child: const Text('Create Auction', textAlign: TextAlign.center),
              onTap: () => _handleOptionSelected(context, 'Create Auction'),
            ),
            PopupMenuItem<String>(
              value: 'List Product',
              child: const Text('List Product', textAlign: TextAlign.center),
              onTap: () => _handleOptionSelected(context, 'List Product'),
            ),
          ],
        );
      },
      backgroundColor: Theme.of(context).primaryColorLight, // OLX-style bright color
      shape: const CircleBorder(),
      elevation: 6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add, size: 28, color: Colors.white),
          Text(
            'Sell',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
