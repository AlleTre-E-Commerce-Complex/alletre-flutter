import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/screens/auction%20screen/payment_details_screen.dart';
import 'package:alletre_app/view/screens/edit%20profile%20screen/add_address_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/common widgets/address_card.dart';
import '../../widgets/common widgets/footer_elements_appbar.dart';

class ShippingDetailsScreen extends StatelessWidget {
  const ShippingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final isSubmitted = ValueNotifier<bool>(false);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: const NavbarElementsAppbar(
          appBarTitle: 'Create Auction', showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.only(left: 14, right: 14, top: 8, bottom: 8),
        child: Column(
          children: [
            const Divider(thickness: 1, color: primaryColor),
            const Center(
              child: Text(
                "Shipping Details",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: onSecondaryColor,
                ),
              ),
            ),
            const Divider(thickness: 1, color: primaryColor),
            const SizedBox(height: 10),

            // List of Address Cards
            Expanded(
              child: ListView(
                children: [

                  // Address Cards
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      final addresses = userProvider.addresses;
                      final defaultAddress = userProvider.defaultAddress;

                      // Sort addresses to put default address first
                      final sortedAddresses = [...addresses]..sort((a, b) {
                          if (a == defaultAddress) return -1;
                          if (b == defaultAddress) return 1;
                          return 0;
                        });

                      return Column(
                        children: [
                          for (final address in sortedAddresses)
                            AddressCard(
            address: address,
            isDefault: address == defaultAddress,
            onMakeDefault: () => userProvider.setDefaultAddress(address),
            onEdit: () async {
              final editedAddress = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GoogleMapScreen(),
                ),
              );

              if (editedAddress != null) {
                userProvider.editAddress(address, editedAddress);
              }
            },
            onDelete: () => userProvider.removeAddress(address),
          ),
                        ],
                      );
                    },
                  ),

                  // Add Address Button
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: InkWell(
                      onTap: () async {
                        final selectedLocation = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GoogleMapScreen(),
                          ),
                        );

                        if (selectedLocation != null) {
                          userProvider.addAddress(selectedLocation);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add,
                              color: onSecondaryColor,
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Add Address',
                              style: TextStyle(
                                color: onSecondaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Previous and Create Auction Buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(80, 33),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      backgroundColor: Colors.grey[300],
                    ),
                    child: const Text(
                      "Previous",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      isSubmitted.value = true;
                      final isValid = formKey.currentState!.validate();
                      if (isValid) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PaymentDetailsScreen()));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(50, 33),
                      maximumSize: const Size(130, 33),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text(
                      "Create Auction",
                      style: TextStyle(color: secondaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
