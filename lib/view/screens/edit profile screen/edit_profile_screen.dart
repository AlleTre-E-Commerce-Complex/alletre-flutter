// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:alletre_app/controller/helpers/address_service.dart';
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
import 'package:alletre_app/utils/ui_helpers.dart';
import '../../widgets/common widgets/address_card.dart';
import '../../widgets/common widgets/footer_elements_appbar.dart';
import '../../widgets/edit profile widgets/custom button widgets/add_phone_button.dart';
import '../../widgets/edit profile widgets/custom button widgets/edit_name_button.dart';
import '../../widgets/edit profile widgets/edit_profile_card.dart';
import '../../widgets/edit profile widgets/edit_profile_card_section.dart';
import '../../widgets/edit profile widgets/edit_profile_title.dart';
import '../../widgets/profile widgets/user_profile_card.dart';
import '../auction screen/add_location_screen.dart';

final addressRefreshKey = ValueNotifier<int>(0);

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldContext = context; // Top-level context for all SnackBars and errors
    // Get the current user info from the provider
    final userProvider = Provider.of<UserProvider>(context);
    final displayName = userProvider.displayName.isNotEmpty ? userProvider.displayName : 'Username';
    final displayNumber = userProvider.displayNumber.isNotEmpty ? userProvider.displayNumber : 'Number';
    final displayEmail = userProvider.displayEmail.isNotEmpty ? userProvider.displayEmail : 'Email';
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

    // --- Add helper function for making default address ---
    Future<bool> makeDefaultAddressOnBackend(String locationId) async {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'access_token');
      final url = Uri.parse('${ApiEndpoints.baseUrl}/users/locations/$locationId/make-default');
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      debugPrint('Make Default API status: \u001b[33m${response.statusCode}\u001b[0m');
      debugPrint('Make Default API raw body: \u001b[36m${response.body}\u001b[0m');
      return response.statusCode == 200 || response.statusCode == 201;
    }

    return Scaffold(
      appBar: const NavbarElementsAppbar(appBarTitle: 'Edit Profile', showBackButton: true),
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
                if (authMethod == 'google' || authMethod == 'apple' && photoUrl != null)
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
                          showError(scaffoldContext, snapshot.error);
                          return const Text('Failed to load addresses');
                        }
                        final apiAddresses = snapshot.data ?? [];
                        debugPrint('Final address list for UI: \u001b[34m${json.encode(apiAddresses)}\u001b[0m');
                        return EditProfileCardSection(
                          child: Consumer<UserProvider>(
                            builder: (context, userProvider, child) {
                              // --- Merge backend and frontend addresses ---
                              // Build a list of display objects for addresses
                              final backendDisplayAddresses = apiAddresses
                                  .map((e) => {
                                        'address': e['address'] ?? '',
                                        'addressLabel': e['addressLabel'] ?? '',
                                        'phone': e['phone'] ?? '',
                                        'isDefault': e['isMain'] == true,
                                        'country': e['country']?['nameEn'] ?? '',
                                        'city': e['city']?['nameEn'] ?? '',
                                        'isBackend': true,
                                        'id': e['id'],
                                      })
                                  .where((a) => a['address'] != '')
                                  .toList();
                              final localDisplayAddresses = userProvider.addresses
                                  .toSet()
                                  .toList()
                                  .map((a) => {
                                        'address': a['address'] ?? '',
                                        'addressLabel': a['addressLabel'] ?? '',
                                        'phone': a['phone'] ?? '',
                                        'isDefault': false,
                                        'country': a['country'] ?? '',
                                        'city': a['city'] ?? '',
                                        'isBackend': false,
                                        'id': a['id'],
                                      })
                                  .toList();
                              // Avoid duplicates (by id, not address string)
                              final mergedDisplayAddresses = [
                                ...backendDisplayAddresses,
                                ...localDisplayAddresses.where((a) => backendDisplayAddresses.every((b) => b['id'] != a['id'])),
                              ];
                              // Default address logic
                              final defaultAddressObj = backendDisplayAddresses.firstWhereOrNull((e) => e['isDefault'] == true);
                              final defaultAddress = defaultAddressObj?['address'] ?? userProvider.defaultAddress;
                              final sortedDisplayAddresses = [...mergedDisplayAddresses]..sort((a, b) {
                                  if (a['address'] == defaultAddress) return -1;
                                  if (b['address'] == defaultAddress) return 1;
                                  return 0;
                                });
                              return Builder(
                                builder: (context) {
                                  return Column(
                                    children: [
                                      // List of Addresses
                                      for (final addr in sortedDisplayAddresses)
                                        Builder(
                                          builder: (context) {
                                            // Find the real address map by id in userProvider.addresses
                                            final realAddress = userProvider.addresses.firstWhere(
                                              (a) => a['id'] == addr['id'],
                                              orElse: () => addr,
                                            );
                                            return AddressCard(
                                              key: ValueKey(realAddress['id']),
                                              address: realAddress['address'],
                                              addressLabel: realAddress['addressLabel'],
                                              phone: realAddress['phone'],
                                              isDefault: realAddress['address'] == defaultAddress,
                                              subtitle: ((realAddress['city'] is Map && realAddress['city']['nameEn'] != null) ? realAddress['city']['nameEn'] : realAddress['city']?.toString() ?? '') +
                                                  ((realAddress['country'] is Map && realAddress['country']['nameEn'] != null)
                                                      ? ', ${realAddress['country']['nameEn']}'
                                                      : realAddress['country'] != null
                                                          ? ', ${realAddress['country']}'
                                                          : ''),
                                              onMakeDefault: () async {
                                                final locationId = realAddress['id'];
                                                if (locationId == null) {
                                                  showError(scaffoldContext, 'Unable to set as default: missing address ID.');
                                                  return;
                                                }
                                                final success = await makeDefaultAddressOnBackend(locationId.toString());
                                                if (success) {
                                                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                                                    const SnackBar(content: Text('Default address updated successfully!')),
                                                  );
                                                  userProvider.markAddressAsDefault(locationId); // <-- local instant update
                                                  // Optionally, also fetch from backend for full sync:
                                                  final updatedAddresses = await fetchUserAddresses();
                                                  userProvider.setAddresses(updatedAddresses);
                                                  addressRefreshKey.value++;
                                                } else {
                                                  showError(scaffoldContext, 'Failed to update default address.');
                                                }
                                              },
                                              onEdit: () async {
                                                final editedAddress = await Navigator.push(
                                                  scaffoldContext,
                                                  MaterialPageRoute(
                                                    builder: (context) => AddLocationScreen(
                                                      initialAddressMap: realAddress,
                                                      initialAddressLabel: realAddress['addressLabel'],
                                                      initialPhone: realAddress['phone'],
                                                      initialCountry: realAddress['country'] is Map ? realAddress['country']['nameEn'] : realAddress['country']?.toString(),
                                                      initialCity: realAddress['city'] is Map ? realAddress['city']['nameEn'] : realAddress['city']?.toString(),
                                                      initialState: realAddress['state'] is Map ? realAddress['state']['nameEn'] : realAddress['state']?.toString(),
                                                    ),
                                                  ),
                                                );
                                                if (editedAddress != null) {
                                                  final mergedAddress = <String, dynamic>{...realAddress, ...editedAddress};
                                                  final locationId = mergedAddress['id'].toString();
                                                  final success = await AddressService.updateAddress(locationId, mergedAddress);
                                                  if (success) {
                                                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                                                      const SnackBar(
                                                          content: Center(
                                                        child: Text('Address updated successfully!'),
                                                      )),
                                                    );
                                                    final updatedAddresses = await fetchUserAddresses();
                                                    userProvider.setAddresses(updatedAddresses);
                                                    addressRefreshKey.value++;
                                                  } else {
                                                    showError(scaffoldContext, 'Failed to update address.');
                                                  }
                                                }
                                              },
                                              onDelete: () async {
                                                final locationId = realAddress['id'];
                                                if (locationId == null) {
                                                  showError(scaffoldContext, 'Unable to delete: missing address ID.');
                                                  return;
                                                }
                                                // Call backend DELETE API
                                                const storage = FlutterSecureStorage();
                                                final token = await storage.read(key: 'access_token');
                                                final url = Uri.parse('${ApiEndpoints.baseUrl}/users/locations/$locationId');
                                                final response = await http.delete(
                                                  url,
                                                  headers: {
                                                    'Authorization': 'Bearer $token',
                                                    'Content-Type': 'application/json',
                                                  },
                                                );
                                                if (response.statusCode == 200 || response.statusCode == 204) {
                                                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                                                    const SnackBar(
                                                        content: Center(
                                                      child: Text('Address deleted successfully!'),
                                                    )),
                                                  );
                                                  // Always fetch the latest addresses from backend after deleting
                                                  final updatedAddresses = await fetchUserAddresses();
                                                  userProvider.setAddresses(updatedAddresses);
                                                  addressRefreshKey.value++;
                                                } else {
                                                  showError(scaffoldContext, 'Failed to delete address.');
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      const SizedBox(height: 8),
                                      InkWell(
                                        onTap: () async {
                                          final selectedLocation = await Navigator.push(
                                            scaffoldContext,
                                            MaterialPageRoute(
                                              builder: (context) => const AddLocationScreen(),
                                            ),
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
                                              showError(scaffoldContext, errors.join('\n'));
                                              return;
                                            }

                                            // Optimistic UI update: add address to provider and trigger UI refresh
                                            // userProvider.addAddress(selectedLocation);
                                            // addressRefreshKey.value++;

                                            final apiResp = await AddressService.addAddress(selectedLocation);
                                            final success = apiResp['success'];
                                            if (success) {
                                              ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                                                const SnackBar(
                                                    content: Center(
                                                  child: Text('Address added successfully!'),
                                                )),
                                              );
                                              // Always fetch the latest addresses from backend after adding
                                              final updatedAddresses = await fetchUserAddresses();
                                              userProvider.setAddresses(updatedAddresses);
                                              addressRefreshKey.value++;
                                            } else {
                                              showError(scaffoldContext, 'Failed to save address : ${apiResp['message']['en']}');
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
                // Divider(height: 32, color: dividerColor, thickness: 0.5),
                // const EditProfileTitle(title: 'Settings'),
                // ListTile(
                //   leading: const Icon(Icons.delete),
                //   title: const Text('Delete my account'),
                //   onTap: () {},
                // ),
                // ListTile(
                //   leading: const Icon(Icons.logout),
                //   title: const Text('Logout'),
                //   onTap: () {},
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}
