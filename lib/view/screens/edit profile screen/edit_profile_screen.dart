// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:alletre_app/controller/helpers/image_picker_helper.dart';
import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/utils/constants/api_endpoints.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../widgets/common widgets/address_card.dart';
import '../../widgets/common widgets/footer_elements_appbar.dart';
import '../../widgets/edit profile widgets/custom button widgets/add_phone_button.dart';
import '../../widgets/edit profile widgets/custom button widgets/edit_name_button.dart';
import '../../widgets/edit profile widgets/edit_profile_card.dart';
import '../../widgets/edit profile widgets/edit_profile_card_section.dart';
import '../../widgets/edit profile widgets/edit_profile_title.dart';
import '../../widgets/profile widgets/user_profile_card.dart';
import '../auction screen/add_location_screen.dart';
import 'add_address_screen.dart';

final addressRefreshKey = ValueNotifier<int>(0);

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

    Future<List<Map<String, dynamic>>> fetchUserAddresses() async {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'access_token');
      final url = Uri.parse('${ApiEndpoints.baseUrl}/users/my-locations');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      debugPrint('Address API status: \u001b[33m${response.statusCode}\u001b[0m');
      debugPrint('Address API raw body: \u001b[36m${response.body}\u001b[0m');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Parsed API response: \u001b[32m${json.encode(data)}\u001b[0m');
        if (data['success'] == true && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    }

    // Store address in backend
    Future<bool> postUserAddress(Map<String, dynamic> location) async {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'access_token');
      final url = Uri.parse('${ApiEndpoints.baseUrl}/users/locations');
      final body = json.encode({
        'address': location['address'],
        'addressLabel': location['addressLabel'] ?? location['address'],
        'countryId': location['countryId'],
        'cityId': location['cityId'],
        'phone': location['phone'] ?? '',
      });
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );
      debugPrint('POST address status: \u001b[33m${response.statusCode}\u001b[0m');
      debugPrint('POST address raw body: \u001b[36m${response.body}\u001b[0m');
      return response.statusCode == 201 || response.statusCode == 200;
    }

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
                    final File? newImage = await pickMediaFromGallery();
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
                ValueListenableBuilder<int>(
                  valueListenable: addressRefreshKey,
                  builder: (context, refreshKey, _) {
                    return FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchUserAddresses(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          debugPrint('Error fetching addresses: \u001b[31m${snapshot.error}\u001b[0m');
                          return const Text('Failed to load addresses');
                        }
                        final apiAddresses = snapshot.data ?? [];
                        debugPrint('Final address list for UI: \u001b[34m${json.encode(apiAddresses)}\u001b[0m');
                        return EditProfileCardSection(
                          child: Consumer<UserProvider>(
                            builder: (context, userProvider, child) {
                              // --- Merge backend and frontend addresses ---
                              // Build a list of display objects for addresses
                              final backendDisplayAddresses = apiAddresses.map((e) => {
                                'address': e['address'] ?? '',
                                'addressLabel': e['addressLabel'] ?? '',
                                'phone': e['phone'] ?? '',
                                'isDefault': e['isMain'] == true,
                                'country': e['country']?['nameEn'] ?? '',
                                'city': e['city']?['nameEn'] ?? '',
                                'isBackend': true,
                              }).where((a) => a['address'] != '').toList();
                              final localDisplayAddresses = userProvider.addresses.toSet().toList().map((a) => {
                                'address': a,
                                'addressLabel': '',
                                'phone': '',
                                'isDefault': false,
                                'country': '',
                                'city': '',
                                'isBackend': false,
                              }).toList();
                              // Avoid duplicates (by address string)
                              final mergedDisplayAddresses = [
                                ...backendDisplayAddresses,
                                ...localDisplayAddresses.where((a) => backendDisplayAddresses.every((b) => b['address'] != a['address'])),
                              ];
                              // Default address logic
                              final defaultAddressObj = backendDisplayAddresses.firstWhereOrNull((e) => e['isDefault'] == true);
                              final defaultAddress = defaultAddressObj?['address'] ?? userProvider.defaultAddress;
                              final sortedDisplayAddresses = [...mergedDisplayAddresses]..sort((a, b) {
                                if (a['address'] == defaultAddress) return -1;
                                if (b['address'] == defaultAddress) return 1;
                                return 0;
                              });
                              return Column(
                                children: [
                                  // List of Addresses
                                  for (final addr in sortedDisplayAddresses)
                                    AddressCard(
                                      address: addr['address'],
                                      addressLabel: addr['addressLabel'],
                                      phone: addr['phone'],
                                      isDefault: addr['address'] == defaultAddress,
                                      // Show country/city for backend addresses
                                      subtitle: addr['isBackend'] ? '${addr['city']}, ${addr['country']}' : null,
                                      onMakeDefault: () => userProvider.setDefaultAddress(addr['address']),
                                      onEdit: () async {
                                        final editedAddress = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const GoogleMapScreen(),
                                          ),
                                        );
                                        if (editedAddress != null) {
                                          userProvider.editAddress(addr['address'], editedAddress);
                                        }
                                      },
                                      onDelete: () => userProvider.removeAddress(addr['address']),
                                    ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () async {
                                      final selectedLocation = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const AddLocationScreen(),
                                          // builder: (context) => const GoogleMapScreen(),
                                        ),
                                      );
                                      if (selectedLocation != null) {
                                        final success = await postUserAddress(selectedLocation);
                                        if (success) {
                                          addressRefreshKey.value++;
                                          return;
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Failed to save address to backend.')),
                                          );
                                        }
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
                                            'Add Location',
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
                        );
                      },
                    );
                  },
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
}
