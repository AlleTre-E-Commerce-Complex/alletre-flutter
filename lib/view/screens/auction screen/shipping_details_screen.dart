// ignore_for_file: avoid_print, use_build_context_synchronously
import 'dart:convert';
import 'dart:io';
import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/location_provider.dart';
import 'package:alletre_app/controller/providers/login_state.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/screens/login%20screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../listed product widgets/listed_success_dialog.dart';
import '../../widgets/common widgets/address_card.dart';
import '../../widgets/common widgets/footer_elements_appbar.dart';
import 'add_location_screen.dart';
import 'payment_details_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:alletre_app/utils/constants/api_endpoints.dart';
import '../../../controller/helpers/address_service.dart';

// Add this helper function at the top-level of the file (outside the widget class)
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

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['success'] == true && data['data'] is List) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
  }
  return [];
}

// Caches the future for stateless use
final Future<List<Map<String, dynamic>>> _cachedAddressesFuture = fetchUserAddresses();

class ShippingDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> auctionData;
  final List<String> imagePaths;
  final String title;

  const ShippingDetailsScreen({
    super.key,
    required this.auctionData,
    required this.imagePaths,
    this.title = 'Create Auction',
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final auctionProvider = Provider.of<AuctionProvider>(context);
    final loginProvider = Provider.of<LoggedInProvider>(context);
    final defaultAddress = userProvider.defaultAddress;
    // final addressLabelController = TextEditingController();
    // final phoneController = TextEditingController();

    // print('ShippingDetailsScreen build() called');

    return Scaffold(
      appBar: NavbarElementsAppbar(
          appBarTitle: title, showBackButton: true),
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
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _cachedAddressesFuture,
                builder: (context, snapshot) {
                  // print('ShippingDetailsScreen FutureBuilder called. State: ${snapshot.connectionState}');
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Text('Failed to load addresses');
                  }
                  final apiAddresses = snapshot.data ?? [];
                  return Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      // --- Merge backend and frontend addresses logic (copied from EditProfileScreen) ---
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
                          .where((a) => a['address'] != '').toList();
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
                      final mergedDisplayAddresses = [
                        ...backendDisplayAddresses,
                        ...localDisplayAddresses.where((a) =>
                            backendDisplayAddresses.every((b) => b['id'] != a['id'])),
                      ];
                      final defaultAddressObj = backendDisplayAddresses.firstWhere(
                          (e) => e['isDefault'] == true,
                          orElse: () => <String, dynamic>{});
                      final defaultAddress = defaultAddressObj['address'] ?? userProvider.defaultAddress;
                      final sortedDisplayAddresses = [
                        ...mergedDisplayAddresses
                      ]..sort((a, b) {
                          if (a['address'] == defaultAddress) return -1;
                          if (b['address'] == defaultAddress) return 1;
                          return 0;
                        });
                      return ListView.builder(
                        itemCount: sortedDisplayAddresses.length,
                        itemBuilder: (context, index) {
                          final address = sortedDisplayAddresses[index];
                          final addressId = address['id'] is int ? address['id'] : int.tryParse(address['id'].toString());
                          final isSelected = addressId != null && addressId == locationProvider.selectedLocationId;
                          return AddressCard(
                            key: ValueKey(address['id']),
                            address: address['address'] ?? '',
                            addressLabel: address['addressLabel'] ?? '',
                            phone: address['phone'] ?? '',
                            isDefault: address['address'] == defaultAddress,
                            selected: isSelected,
                            onTap: () {
                              if (addressId != null) {
                                locationProvider.selectedLocationId = addressId;
                              }
                            },
                            onMakeDefault: address['address'] != defaultAddress
                                ? () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Make Default Address'),
                                        content: const Text('Are you sure you want to set this as your default address?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Yes'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirmed == true) {
                                      await AddressService.makeDefaultAddress(address['id'].toString());
                                      // Refresh the screen
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ShippingDetailsScreen(
                                            auctionData: auctionData,
                                            imagePaths: imagePaths,
                                            title: title,
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                : null,
                            onEdit: () async {
                              // Navigate to AddLocationScreen in edit mode (you may want a dedicated edit screen)
                              final updatedLocation = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddLocationScreen(
                                    existingAddress: address,
                                  ),
                                ),
                              );
                              if (updatedLocation != null) {
                                await AddressService.updateAddress(address['id'].toString(), updatedLocation);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShippingDetailsScreen(
                                      auctionData: auctionData,
                                      imagePaths: imagePaths,
                                      title: title,
                                    ),
                                  ),
                                );
                              }
                            },
                            onDelete: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Address'),
                                  content: const Text('Are you sure you want to delete this address?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                await AddressService.deleteAddress(address['id'].toString());
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShippingDetailsScreen(
                                      auctionData: auctionData,
                                      imagePaths: imagePaths,
                                      title: title,
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

            // Add Address Button
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: InkWell(
                onTap: () async {
                  final selectedLocation = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddLocationScreen(),
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
            ),
          ],
        ),
      ),
      // Previous and Create Auction Buttons
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(right: 12, bottom: 10),
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
                style: TextStyle(color: onSecondaryColor),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () async {
                // First check if user is logged in
                if (!loginProvider.isLoggedIn) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please login to continue...'),
                    ),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          LoginPage(fromAuctionCreation: true),
                    ),
                  );
                  return;
                }

                // Check if we have at least one address
                final addressesSnapshot = await _cachedAddressesFuture;
                if (addressesSnapshot.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please add at least one address'),
                    ),
                  );
                  return;
                }

                try {
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  // Debug log auction data
                  debugPrint('Incoming auction data:');
                  debugPrint('Product data: ${auctionData['product']}');

                  // Ensure product data is properly structured
                  if (auctionData['product'] == null || 
                      auctionData['product'] is! Map<String, dynamic>) {
                    throw Exception('Product data is not properly structured');
                  }

                  // Parse duration and unit
                  String durationStr = auctionData['duration'] ?? '1 DAYS';
                  List<String> durationParts = durationStr.split(' ');
                  int duration = int.parse(durationParts[0]);
                  String durationUnit = durationParts[1].toUpperCase().contains('HR') ? 'HOURS' : 'DAYS';
                  
                  // Parse prices
                  int startBidAmount = (double.parse(auctionData['startingPrice']?.toString() ?? '0')).toInt();
                  double buyNowPrice = double.parse(auctionData['buyNowPrice']?.toString() ?? '0');
                  
                  // Calculate end time based on duration and start time
                  DateTime startTime;
                  if (auctionData['scheduleBid'] == true) {
                      // Parse the ISO string and convert to local time
                      startTime = DateTime.parse(auctionData['startTime'] ?? auctionData['startDate']).toLocal();
                  } else {
                      startTime = DateTime.now();
                  }
                  
                  DateTime endTime;
                  if (durationUnit == 'HOURS') {
                    endTime = startTime.add(Duration(hours: duration));
                  } else {
                    endTime = startTime.add(Duration(days: duration));
                  }

                  // Debug end time calculation
                  debugPrint('Start time: $startTime');
                  debugPrint('Duration: $duration ${durationUnit.toLowerCase()}');
                  debugPrint('Calculated end time: $endTime');

                  // Create the full auction data structure
                  final Map<String, dynamic> fullAuctionData = {
                    'type': auctionData['scheduleBid'] == true ? 'SCHEDULED' : 'ON_TIME',
                    'durationUnit': durationUnit,
                    'duration': duration,
                    'startBidAmount': startBidAmount,
                    'startDate': startTime.toIso8601String(),
                    'endDate': endTime.toIso8601String(), 
                    'scheduleBid': auctionData['scheduleBid'] ?? false,
                    'buyNowEnabled': auctionData['buyNowEnabled'] ?? false,
                    'buyNowPrice': buyNowPrice,
                                             'product': {
                      ...Map<String, dynamic>.from(
                          auctionData['product']),
                      // Always set ProductListingPrice for backend compatibility
                      'ProductListingPrice': auctionData['product']
                          ['price'],
                      // Add location IDs to product data for backend
                      // Ensure countryId is always 1 for UAE
                      'countryId': 1,
                      // Use cityId from locationProvider, defaulting to 1 (Dubai) if not set
                      'cityId': locationProvider.cityId ?? 1,
                      // Add address and addressLabel for backend DTO
                      // 'address': defaultAddress ?? '',
                      // 'addressLabel': 'Main Address',
                    },
                    // 'locationId': locationProvider.selectedLocationId ?? 0,
                    'shippingDetails': {
                      'country':
                          locationProvider.selectedCountry ?? 'UAE',
                      'state': locationProvider.selectedState ??
                          'Ras Al Khaima',
                      'city': locationProvider.selectedCity ?? 'Nakheel',
                      'address': defaultAddress,
                      'phone': userProvider.phoneNumber,
                    },
                  };

                  // Debug auction data
                  debugPrint('Creating auction with data: ${json.encode(fullAuctionData)}');

                  // Clean and convert product data
                  var productData = fullAuctionData['product'] as Map<String, dynamic>;
                  productData.removeWhere((key, value) => value == null || value == '');
                  // Convert numeric fields
                  if (productData['categoryId'] != null) {
                    productData['categoryId'] = int.parse(productData['categoryId'].toString());
                  }
                  if (productData['subCategoryId'] != null) {
                    productData['subCategoryId'] = int.parse(productData['subCategoryId'].toString());
                  }
                  if (productData['quantity'] != null) {
                    productData['quantity'] = int.parse(productData['quantity'].toString());
                  }
                  fullAuctionData['product'] = productData;

                  // --- LOGIC UPDATE: Use selectedLocationId ---
                  final int? locationId = locationProvider.selectedLocationId;
                  if (locationId == null) {
                    throw Exception('Please select a shipping address before proceeding.');
                  }
                  // Remove address/addressLabel from productData to avoid backend confusion
                  productData.remove('address');
                  productData.remove('addressLabel');
                  // Remove cityId/countryId from productData if your backend expects them only via locationId
                  // productData.remove('cityId');
                  // productData.remove('countryId');
                  // --- END LOGIC UPDATE ---

                  // Validate product data structure
                  final product = fullAuctionData['product'] as Map<String, dynamic>;
                  if (!product.containsKey('title') || !product.containsKey('description') ||
                      !product.containsKey('categoryId') || !product.containsKey('subCategoryId')) {
                    throw Exception('Product data missing required fields');
                  }

                  // Add optional policies if present
                  if (auctionData['returnPolicy'] != null) {
                    fullAuctionData['returnPolicy'] = auctionData['returnPolicy'];
                  }
                  if (auctionData['warrantyPolicy'] != null) {
                    fullAuctionData['warrantyPolicy'] = auctionData['warrantyPolicy'];
                  }

                  // Debug log the final structure
                  debugPrint('Final auction data structure:');
                  debugPrint(fullAuctionData.toString());

                  // Debug log media files
                  debugPrint('ShippingDetailsScreen - Media files before API call:');
                  debugPrint('Total files: ${imagePaths.length}');
                  for (var i = 0; i < imagePaths.length; i++) {
                    final path = imagePaths[i];
                    final isVideo = path.toLowerCase().endsWith('.mp4') || path.toLowerCase().endsWith('.mov');
                    debugPrint('  File $i: $path');
                    debugPrint('    Type: ${isVideo ? 'Video' : 'Image'}');
                    final file = File(path);
                    if (await file.exists()) {
                      debugPrint('    Size: ${(await file.length() / 1024).toStringAsFixed(2)} KB');
                      debugPrint('    Exists: Yes');
                    } else {
                      debugPrint('    Exists: No');
                    }
                  }

                  // Ensure locationId is included in fullAuctionData before API call
                  fullAuctionData['locationId'] = locationId;
                  debugPrint('End time before API call: ${endTime.toIso8601String()}');
                  
                  // Debug the auction data before API call
                  debugPrint('Full auction data before API call:');
                  debugPrint(json.encode(fullAuctionData));

                  final response = title == 'Create Auction'
                      ? await auctionProvider.createAuction(
                          auctionData: fullAuctionData,
                          imagePaths: imagePaths,
                        )
                      : await auctionProvider.listProduct(
                          auctionData: fullAuctionData,
                          imagePaths: imagePaths,
                        );

                  debugPrint('API Response: $response');

                  // Hide loading indicator
                  if (context.mounted) {
                    Navigator.pop(context);
                  }

                  if (response['success'] == true) {
                    // Show success message
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Center(child: Text('Item created successfully')),
                        ),
                      );
                    }

                    // Debug the data before navigation
                    debugPrint('Shipping Screen - Full auction data: $fullAuctionData');
                    debugPrint('Shipping Screen - API Response: $response');
                    debugPrint('Shipping Screen - End time: ${endTime.toIso8601String()}');
                    final navigationData = {
                      'success': response['success'],
                      'data': {
                        ...response['data'],
                        'endTime': endTime.toIso8601String(),
                        ...fullAuctionData,
                        'ProductListingPrice': fullAuctionData['product']
                            ['price'],
                        'product': {
                          ...fullAuctionData['product'],
                          'images': imagePaths,
                        },
                      }
                    };
                    debugPrint('Shipping Screen - Navigation data: $navigationData');
                    
                    // Print item details
                    print('🔦🔦New Item Created:');
                    print('🔦🔦Item Name: ${auctionData['product']['title']}');
                    print('🔦🔦Status: ${response['status']}');
                    // Use ProductListingPrice for listed products, fallback to product price
                    final listingPrice = navigationData['data']
                            ['ProductListingPrice'] ??
                        navigationData['data']['product']['price'];
                    print('🔦🔦Listing Price: $listingPrice');

                    if (context.mounted) {
                      if (title == 'Create Auction') {
                        // Navigate to payment details for auctions
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentDetailsScreen(
                              auctionData: navigationData,
                            ),
                          ),
                        );
                      } else {
                        ListedSuccessDialog.show(context);
                      }
                    }
                  } else {
                    throw Exception(response['message'] ?? 'Failed to create auction');
                  }
                } catch (e) {
                  Navigator.pop(context);

                  // Show error message
                  if (context.mounted) {
                    String errorMsg = e.toString();
                    // Remove all 'Exception:' prefixes (even nested)
                    while (errorMsg.trim().toLowerCase().startsWith('exception:')) {
                      errorMsg = errorMsg.substring(10).trim();
                    }
                    // Replace auction message with product message if listing product
                    if (errorMsg.startsWith('Failed to create auction:')) {
                      errorMsg = errorMsg.replaceFirst('Failed to create auction:', 'Failed to list product:').trim();
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMsg),
                      ),
                    );
                  }
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
              child: Text(
                title,
                style: const TextStyle(color: secondaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
