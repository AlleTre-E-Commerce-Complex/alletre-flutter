import 'package:alletre_app/controller/providers/bottom_navbar_provider.dart';
import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/screens/edit%20profile%20screen/add_address_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShippingDetailsScreen extends StatelessWidget {
  const ShippingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final isSubmitted = ValueNotifier<bool>(false);
    final userProvider = Provider.of<UserProvider>(context);
    final selectedAddresses = userProvider.addresses;
    final defaultAddress = userProvider.defaultAddress;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false,
        title: const Text(
          'Create Auction',
          style: TextStyle(color: secondaryColor, fontSize: 18),
        ),
      ),
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
                  // Default Address Card
                  if (defaultAddress != null)
                    _buildAddressCard(
                      context,
                      address: defaultAddress,
                      isDefault: true,
                      onMakeDefault: null, // No action for default address
                    ),

                  // Other Address Cards
                  for (final address in selectedAddresses)
                    if (address != defaultAddress)
                      _buildAddressCard(
                        context,
                        address: address,
                        isDefault: false,
                        onMakeDefault: () {
                          userProvider.setDefaultAddress(address);
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
                              color: primaryColor,
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Add Address',
                              style: TextStyle(
                                color: primaryColor,
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
                      context.read<TabIndexProvider>().updateIndex(10);
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
                        context.read<TabIndexProvider>().updateIndex(17);
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

  // Helper method to build an address card
  Widget _buildAddressCard(
    BuildContext context, {
    required String address,
    required bool isDefault,
    VoidCallback? onMakeDefault,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
    side: BorderSide(color: Colors.grey.shade300), // Added border color
    borderRadius: BorderRadius.circular(8), // Rounded corners
  ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8), // Reduced bottom padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDefault)
              Container(
                width: 50,
                height: 15,
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: primaryColor),
                  borderRadius: BorderRadius.circular(4),
                  color: primaryColor,
                ),
                child: const Text(
                  'Default',
                  style: TextStyle(
                    fontSize: 9,
                    color: secondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            Text(
              address,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: onSecondaryColor,
              ),
            ),
            if (!isDefault)
              Container(
                margin: const EdgeInsets.only(top: 4), // Reduced top margin
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onMakeDefault,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, // Remove default padding
                    minimumSize: Size.zero, // Remove minimum size
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrink tap target
                  ),
                  child: const Text(
                    'Make Default',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}