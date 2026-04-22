// ignore_for_file: use_build_context_synchronously

import 'package:alletre_app/controller/helpers/address_service.dart';
import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/utils/ui_helpers.dart';
import 'package:alletre_app/view/screens/auction%20screen/add_location_screen.dart';
import 'package:alletre_app/view/screens/auction%20screen/shipping_details_screen.dart';
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
          final selectedLocation = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddLocationScreen()),
          );
          if (selectedLocation != null) {
            // Validate fields before sending to backend
            final errors = <String>[];
            final address = selectedLocation['address']?.toString().trim() ?? '';
            final addressLabel = selectedLocation['addressLabel']?.toString().trim() ?? '';
            final countryId = selectedLocation['countryId'];
            final cityId = selectedLocation['cityId'];
            final phone = selectedLocation['phone']?.toString().trim() ?? '';

            // Address validation
            if (address.isEmpty) {
              errors.add('Address is required.');
            }
            if (addressLabel.isEmpty) {
              errors.add('Address label is required.');
            }
            if (countryId == null || countryId.toString().isEmpty) {
              errors.add('Country is required.');
            }
            if (cityId == null || cityId.toString().isEmpty) {
              errors.add('State is required.');
            }
            if (phone.isEmpty) {
              errors.add('Phone number is required.');
            }

            if (errors.isNotEmpty) {
              showError(context, errors.join('\n'));
              return;
            }

            // Optimistic UI update: add address to provider and trigger UI refresh
            // userProvider.addAddress(selectedLocation);
            // addressRefreshKey.value++;

            final apiResp = await AddressService.addAddress(selectedLocation);
            final success = apiResp['success'];
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Center(
                  child: Text('Address added successfully!'),
                )),
              );
              // Always fetch the latest addresses from backend after adding
              final updatedAddresses = await fetchUserAddresses();
              Provider.of<UserProvider>(context, listen: false).setAddresses(updatedAddresses);
            } else {
              showError(context, 'Failed to save address : ${apiResp['message']['en']}');
            }
          }
          return;
        }

        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            MediaQuery.of(context).size.width / 2 - 100, // center horizontally
            MediaQuery.of(context).size.height - 200, // position above nav
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
      backgroundColor: Theme.of(context).textSelectionTheme.selectionColor, // OLX-style bright color
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
