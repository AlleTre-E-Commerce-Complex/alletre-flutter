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
                            _buildAddressCard(
                              context,
                              address: address,
                              isDefault: address == defaultAddress,
                              onMakeDefault: () {
                                userProvider.setDefaultAddress(address);
                              },
                              onEdit: () async {
                                final editedAddress = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const GoogleMapScreen(),
                                  ),
                                );

                                if (editedAddress != null) {
                                  userProvider.editAddress(
                                      address, editedAddress);
                                }
                              },
                              onDelete: () {
                                userProvider.removeAddress(address);
                              },
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
                        context.read<TabIndexProvider>().updateIndex(22);
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
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding:
            EdgeInsets.fromLTRB(14, isDefault ? 2 : 14, 14, isDefault ? 14 : 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: isDefault ? 0 : 8, // Add spacing control based on isDefault
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isDefault)
                  Container(
                    width: 50,
                    height: 15,
                    margin: const EdgeInsets.only(
                        bottom: 0), // Removed bottom margin
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
                if (isDefault)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18, color: primaryColor),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero, // Removed padding
                  ),
              ],
            ),
            if (isDefault) const SizedBox(height: 0),
            Text(
              address,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: onSecondaryColor,
              ),
            ),
            if (!isDefault)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 0),
                    alignment: Alignment.bottomLeft,
                    child: TextButton(
                      onPressed: onMakeDefault,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Make Default',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 128),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit,
                            size: 18, color: primaryColor),
                        onPressed: onEdit,
                      ),
                    ],
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.delete, size: 18, color: primaryColor),
                    onPressed: onDelete,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
