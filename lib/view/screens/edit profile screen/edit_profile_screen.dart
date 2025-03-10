import 'dart:io';
import 'package:alletre_app/controller/helpers/image_picker_helper.dart';
import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/common widgets/footer_elements_appbar.dart';
import '../../widgets/edit profile widgets/custom button widgets/add_phone_button.dart';
import '../../widgets/edit profile widgets/custom button widgets/edit_name_button.dart';
import '../../widgets/edit profile widgets/edit_profile_card.dart';
import '../../widgets/edit profile widgets/edit_profile_card_section.dart';
import '../../widgets/edit profile widgets/edit_profile_title.dart';
import '../../widgets/profile widgets/user_profile_card.dart';
import 'add_address_screen.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user info from the provider
    final userProvider = Provider.of<UserProvider>(context);
    final displayName = userProvider.displayName.isNotEmpty
        ? userProvider.displayName
        : 'Username';
    final displayNumber = userProvider.displayNumber.isNotEmpty
        ? userProvider.displayNumber
        : 'Number';
    final displayEmail = userProvider.displayEmail.isNotEmpty
        ? userProvider.displayEmail
        : 'Email';
    final emailVerified = userProvider.emailVerified;
    final authMethod = userProvider.authMethod;
    final photoUrl = userProvider.photoUrl;

    return Scaffold(
      appBar: const NavbarElementsAppbar(
          appBarTitle: 'Edit Profile', showBackButton: true),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          // final selectedAddress = userProvider.selectedAddress ?? 'No address selected';
          // final hasAddress = selectedAddress != 'No address selected';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                UserProfileCard(
                  user: user,
                  buttonText: "Upload Photo",
                  onButtonPressed: () async {
                    final File? newImage = await pickImageFromGallery();
                    if (newImage != null) {
                      await userProvider.updateProfilePhoto(newImage);
                    }
                  },
                ),
                const SizedBox(height: 4),
                const EditProfileTitle(title: 'Personal Information'),
                if (authMethod == 'google' ||
                    authMethod == 'apple' && photoUrl != null)
                  EditProfileCard(
                    label: 'Username',
                    value: displayName,
                    icon: Icons.person,
                    actionButton: EditNameButton(
                      onPressed: () {
                        // Handle edit action
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                EditProfileCard(
                  label: 'Primary Number',
                  // value: context.watch<UserProvider>().phoneNumber,
                  value: displayNumber,
                  icon: Icons.phone,
                  actionButton: AddPhoneButton(
                    onPressed: () {
                      // Handle add phone action
                    },
                  ),
                ),
                const SizedBox(height: 16),
                EditProfileCard(
                  label: 'Primary Email',
                  value: displayEmail,
                  icon: Icons.email,
                  actionButton: emailVerified == true
                      ? const Padding(
                          padding: EdgeInsets.only(top: 16.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.verified,
                                color: activeColor,
                                size: 16,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  color: activeColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
                
                const SizedBox(height: 8),
                Divider(height: 32, color: dividerColor, thickness: 0.5),
                const EditProfileTitle(title: 'Address Book'),
                EditProfileCardSection(
                  child: Consumer<UserProvider>(
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
                          // List of Addresses
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
                          const SizedBox(height: 8),
                          InkWell(
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
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // Divider(height: 20, color: dividerColor, thickness: 0.5),
                // const EditProfileTitle(title: 'Login Service'),
                // EditProfileLoginOption(
                //   svgPath: 'assets/icons/apple_icon.svg',
                //   label: 'Connect with Apple',
                //   isConnected: false,
                //   onTap: () {},
                // ),
                // EditProfileLoginOption(
                //   svgPath: 'assets/icons/google_icon.svg',
                //   label: 'Connect with Google',
                //   isConnected: true,
                //   onTap: () {},
                // ),
                // ),
                Divider(height: 32, color: dividerColor, thickness: 0.5),
                const EditProfileTitle(title: 'Settings'),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Change Password'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Delete my account'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {},
                ),
              ],
            ),
          );
        },
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
