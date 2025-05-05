// ignore_for_file: avoid_print, use_build_context_synchronously
import 'dart:convert';
import 'dart:io';
import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/location_provider.dart';
import 'package:alletre_app/controller/providers/login_state.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/utils/ui_helpers.dart';
import 'package:alletre_app/view/screens/login%20screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../listed product widgets/listed_success_dialog.dart';
import '../../widgets/common widgets/address_card.dart';
import '../../widgets/common widgets/footer_elements_appbar.dart';
import '../edit profile screen/edit_profile_screen.dart';
import 'add_location_screen.dart';
import 'payment_details_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:alletre_app/utils/constants/api_endpoints.dart';
import '../../../controller/helpers/address_service.dart';

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

class ShippingDetailsScreen extends StatefulWidget {
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
  State<ShippingDetailsScreen> createState() => _ShippingDetailsScreenState();
}

class _ShippingDetailsScreenState extends State<ShippingDetailsScreen> {
  late Future<List<Map<String, dynamic>>> _addressFuture;

  @override
  void initState() {
    super.initState();
    _addressFuture = fetchUserAddresses();
  }

  void _refreshAddresses() {
    setState(() {
      _addressFuture = fetchUserAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final auctionProvider = Provider.of<AuctionProvider>(context);
    final loginProvider = Provider.of<LoggedInProvider>(context);
    final defaultAddress = userProvider.defaultAddress;

    return Scaffold(
      appBar:
          NavbarElementsAppbar(appBarTitle: widget.title, showBackButton: true),
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
                future: _addressFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    print(
                        '\u001b[31mError fetching addresses: ${snapshot.error}');
                    return const Text('Failed to load addresses');
                  }
                  final apiAddresses = snapshot.data ?? [];
                  if (apiAddresses.isEmpty) {
                    return const Center(
                        child:
                            Text('No addresses found. Please add a location.'));
                  }
                  return Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
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
                      final mergedDisplayAddresses = [
                        ...backendDisplayAddresses,
                        ...localDisplayAddresses.where((a) =>
                            backendDisplayAddresses
                                .every((b) => b['id'] != a['id'])),
                      ];
                      final defaultAddressObj = backendDisplayAddresses
                          .firstWhere((e) => e['isDefault'] == true,
                              orElse: () => <String, dynamic>{});
                      final defaultAddress = defaultAddressObj['address'] ??
                          userProvider.defaultAddress;
                      final sortedDisplayAddresses = [...mergedDisplayAddresses]
                        ..sort((a, b) {
                          if (a['address'] == defaultAddress) return -1;
                          if (b['address'] == defaultAddress) return 1;
                          return 0;
                        });
                      return ListView.builder(
                        itemCount: sortedDisplayAddresses.length,
                        itemBuilder: (context, index) {
                          final address = sortedDisplayAddresses[index];
                          final addressId = address['id'] is int
                              ? address['id']
                              : int.tryParse(address['id'].toString());
                          final isSelected = addressId != null &&
                              addressId == locationProvider.selectedLocationId;
                          return AddressCard(
                            key: ValueKey(address['id']),
                            address: address['address'] ?? '',
                            addressLabel: address['addressLabel'] ?? '',
                            phone: address['phone'] ?? '',
                            isDefault: address['address'] == defaultAddress,
                            subtitle: ((address['city'] is Map &&
                                        address['city']['nameEn'] != null)
                                    ? address['city']['nameEn']
                                    : address['city']?.toString() ?? '') +
                                ((address['country'] is Map &&
                                        address['country']['nameEn'] != null)
                                    ? ', ${address['country']['nameEn']}'
                                    : address['country'] != null
                                        ? ', ${address['country']}'
                                        : ''),
                            selected: isSelected,
                            onTap: () {
                              if (addressId != null) {
                                locationProvider.selectedLocationId = addressId;
                              }
                            },
                            onMakeDefault: address['address'] != defaultAddress
                                ? () async {
                                    await AddressService.makeDefaultAddress(
                                        address['id'].toString());
                                    _refreshAddresses();
                                  }
                                : null,
                            onEdit: () async {
                              final updatedLocation = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddLocationScreen(
                                    initialAddressMap: address,
                                    initialAddressLabel:
                                        address['addressLabel'],
                                    initialPhone: address['phone'],
                                    initialCountry: address['country'] is Map
                                        ? address['country']['nameEn']
                                        : address['country']?.toString(),
                                    initialCity: address['city'] is Map
                                        ? address['city']['nameEn']
                                        : address['city']?.toString(),
                                    initialState: address['state'] is Map
                                        ? address['state']['nameEn']
                                        : address['state']?.toString(),
                                  ),
                                ),
                              );
                              if (updatedLocation != null) {
                                final mergedAddress = <String, dynamic>{
                                  ...address,
                                  ...updatedLocation
                                };
                                final locationId =
                                    mergedAddress['id'].toString();
                                final success =
                                    await AddressService.updateAddress(
                                        locationId, mergedAddress);
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Center(
                                      child:
                                          Text('Address updated successfully!'),
                                    )),
                                  );
                                  final updatedAddresses =
                                      await fetchUserAddresses();
                                  userProvider.setAddresses(updatedAddresses);
                                  addressRefreshKey.value++;
                                } else {
                                  showError(
                                      context, 'Failed to update address.');
                                }
                              }
                              _refreshAddresses();
                            },
                            onDelete: () async {
                              final success =
                                  await AddressService.deleteAddress(
                                      address['id'].toString());
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Center(
                                    child:
                                        Text('Address deleted successfully!'),
                                  )),
                                );
                                final updatedAddresses =
                                    await fetchUserAddresses();
                                userProvider.setAddresses(updatedAddresses);
                                addressRefreshKey.value++;
                              } else {
                                showError(context, 'Failed to delete address.');
                              }
                              _refreshAddresses();
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
                    // Validate fields before sending to backend
                    final errors = <String>[];
                    final address =
                        selectedLocation['address']?.toString().trim() ?? '';
                    final addressLabel =
                        selectedLocation['addressLabel']?.toString().trim() ??
                            '';
                    final countryId = selectedLocation['countryId'];
                    final cityId = selectedLocation['cityId'];
                    final phone =
                        selectedLocation['phone']?.toString().trim() ?? '';

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

                    final success =
                        await AddressService.addAddress(selectedLocation);
                    _refreshAddresses();
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Center(
                            child: Text('Address added successfully!'),
                          ),
                        ),
                      );
                      userProvider.clearAddresses();
                      _refreshAddresses();
                    } else {
                      showError(context, 'Failed to save address.');
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
                final addressesSnapshot = await _addressFuture;
                if (addressesSnapshot.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Center(
                          child: Text('Please add at least one address')),
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
                  debugPrint('Product data: ${widget.auctionData['product']}');

                  // Ensure product data is properly structured
                  if (widget.auctionData['product'] == null ||
                      widget.auctionData['product'] is! Map<String, dynamic>) {
                    throw Exception('Product data is not properly structured');
                  }

                  // Parse duration and unit
                  String durationStr =
                      widget.auctionData['duration'] ?? '1 DAYS';
                  List<String> durationParts = durationStr.split(' ');
                  int duration = int.parse(durationParts[0]);
                  String durationUnit =
                      durationParts[1].toUpperCase().contains('HR')
                          ? 'HOURS'
                          : 'DAYS';

                  // Parse prices
                  int startBidAmount = (double.parse(
                          widget.auctionData['startingPrice']?.toString() ??
                              '0'))
                      .toInt();
                  double buyNowPrice = double.parse(
                      widget.auctionData['buyNowPrice']?.toString() ?? '0');

                  // Calculate end time based on duration and start time
                  DateTime startTime;
                  if (widget.auctionData['scheduleBid'] == true) {
                    // Parse the ISO string and convert to local time
                    startTime = DateTime.parse(
                            widget.auctionData['startTime'] ??
                                widget.auctionData['startDate'])
                        .toLocal();
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
                  debugPrint(
                      'Duration: $duration ${durationUnit.toLowerCase()}');
                  debugPrint('Calculated end time: $endTime');

                  // Create the full auction data structure
                  final Map<String, dynamic> fullAuctionData = {
                    'type': widget.auctionData['scheduleBid'] == true
                        ? 'SCHEDULED'
                        : 'ON_TIME',
                    'durationUnit': durationUnit,
                    'duration': duration,
                    'startBidAmount': startBidAmount,
                    'startDate': startTime.toIso8601String(),
                    'endDate': endTime.toIso8601String(),
                    'scheduleBid': widget.auctionData['scheduleBid'] ?? false,
                    'buyNowEnabled':
                        widget.auctionData['buyNowEnabled'] ?? false,
                    'buyNowPrice': buyNowPrice,
                    'product': {
                      ...Map<String, dynamic>.from(
                          widget.auctionData['product']),
                      // Always set ProductListingPrice for backend compatibility
                      'ProductListingPrice': widget.auctionData['product']
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
                      'country': locationProvider.selectedCountry ?? 'UAE',
                      'state':
                          locationProvider.selectedState ?? 'Ras Al Khaima',
                      'city': locationProvider.selectedCity ?? 'Nakheel',
                      'address': defaultAddress,
                      'phone': userProvider.phoneNumber,
                    },
                  };

                  // Debug auction data
                  debugPrint(
                      'Creating auction with data: ${json.encode(fullAuctionData)}');

                  // Clean and convert product data
                  var productData =
                      fullAuctionData['product'] as Map<String, dynamic>;
                  productData.removeWhere(
                      (key, value) => value == null || value == '');
                  // Convert numeric fields
                  if (productData['categoryId'] != null) {
                    productData['categoryId'] =
                        int.parse(productData['categoryId'].toString());
                  }
                  if (productData['subCategoryId'] != null) {
                    productData['subCategoryId'] =
                        int.parse(productData['subCategoryId'].toString());
                  }
                  if (productData['quantity'] != null) {
                    productData['quantity'] =
                        int.parse(productData['quantity'].toString());
                  }
                  fullAuctionData['product'] = productData;

                  // --- LOGIC UPDATE: Use selectedLocationId ---
                  final int? locationId = locationProvider.selectedLocationId;
                  if (locationId == null) {
                    throw Exception(
                        'Please select a shipping address before proceeding.');
                  }
                  // Remove address/addressLabel from productData to avoid backend confusion
                  productData.remove('address');
                  productData.remove('addressLabel');
                  // Remove cityId/countryId from productData if your backend expects them only via locationId
                  // productData.remove('cityId');
                  // productData.remove('countryId');
                  // --- END LOGIC UPDATE ---

                  // Validate product data structure
                  final product =
                      fullAuctionData['product'] as Map<String, dynamic>;
                  if (!product.containsKey('title') ||
                      !product.containsKey('description') ||
                      !product.containsKey('categoryId') ||
                      !product.containsKey('subCategoryId')) {
                    throw Exception('Product data missing required fields');
                  }

                  // --- Ensure locationId is included in product payload ---
                  product['locationId'] = locationId;
                  fullAuctionData['product'] = product;

                  // Add optional policies if present
                  if (widget.auctionData['returnPolicy'] != null) {
                    fullAuctionData['returnPolicy'] =
                        widget.auctionData['returnPolicy'];
                  }
                  if (widget.auctionData['warrantyPolicy'] != null) {
                    fullAuctionData['warrantyPolicy'] =
                        widget.auctionData['warrantyPolicy'];
                  }

                  // Debug log the final structure
                  debugPrint('Final auction data structure:');
                  debugPrint(fullAuctionData.toString());

                  // Debug log media files
                  debugPrint(
                      'ShippingDetailsScreen - Media files before API call:');
                  debugPrint('Total files: ${widget.imagePaths.length}');
                  for (var i = 0; i < widget.imagePaths.length; i++) {
                    final path = widget.imagePaths[i];
                    final isVideo = path.toLowerCase().endsWith('.mp4') ||
                        path.toLowerCase().endsWith('.mov');
                    debugPrint('  File $i: $path');
                    debugPrint('    Type: ${isVideo ? 'Video' : 'Image'}');
                    final file = File(path);
                    if (await file.exists()) {
                      debugPrint(
                          '    Size: ${(await file.length() / 1024).toStringAsFixed(2)} KB');
                      debugPrint('    Exists: Yes');
                    } else {
                      debugPrint('    Exists: No');
                    }
                  }

                  // Ensure locationId is included in fullAuctionData before API call
                  fullAuctionData['locationId'] = locationId;
                  debugPrint(
                      'End time before API call: ${endTime.toIso8601String()}');

                  // Debug the auction data before API call
                  debugPrint('Full auction data before API call:');
                  debugPrint(json.encode(fullAuctionData));

                  final response = widget.title == 'Create Auction'
                      ? await auctionProvider.createAuction(
                          auctionData: fullAuctionData,
                          imagePaths: widget.imagePaths,
                        )
                      : await auctionProvider.listProduct(
                          auctionData: fullAuctionData,
                          imagePaths: widget.imagePaths,
                        );

                  debugPrint('API Response: $response');

                  // Hide loading indicator
                  if (context.mounted) {
                    Navigator.pop(context);
                  }

                  if (response['success'] == true) {
                    // Fetch auction details from backend to ensure isMyAuction is set
                    try {
                      final auctionId = response['data']['id'];
                      final detailsUrl = Uri.parse(
                          '${ApiEndpoints.baseUrl}/auctions/user/$auctionId/details');
                      final token = await const FlutterSecureStorage()
                          .read(key: 'access_token');
                      final detailsResponse = await http.get(
                        detailsUrl,
                        headers: {
                          'Authorization': 'Bearer $token',
                          'Content-Type': 'application/json',
                        },
                      );
                      final detailsJson = jsonDecode(detailsResponse.body);
                      if (detailsJson['success'] == true) {
                        // Optionally, merge in endTime and any extra data you want to pass
                        detailsJson['data']['endTime'] =
                            endTime.toIso8601String();
                        detailsJson['data']['ProductListingPrice'] =
                            fullAuctionData['product']['price'];
                        detailsJson['data']['product']['images'] =
                            widget.imagePaths;
                        if (context.mounted) {
                          if (widget.title == 'Create Auction') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentDetailsScreen(
                                  auctionData: {'data': detailsJson['data']},
                                ),
                              ),
                            );
                          } else {
                            ListedSuccessDialog.show(context);
                          }
                        }
                      } else {
                        throw Exception('Failed to fetch details');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to fetch details: '
                                  '${e.toString()}')),
                        );
                      }
                    }
                  } else {
                    throw Exception(
                        response['message'] ?? 'Failed to create auction');
                  }
                } catch (e) {
                  Navigator.pop(context);

                  // Show error message
                  if (context.mounted) {
                    String errorMsg = e.toString();
                    // Remove all 'Exception:' prefixes (even nested)
                    while (errorMsg
                        .trim()
                        .toLowerCase()
                        .startsWith('exception:')) {
                      errorMsg = errorMsg.substring(10).trim();
                    }
                    // Replace auction message with product message if listing product
                    if (errorMsg.startsWith('Failed to create auction:')) {
                      errorMsg = errorMsg
                          .replaceFirst('Failed to create auction:',
                              'Failed to list product:')
                          .trim();
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
                widget.title,
                style: const TextStyle(color: secondaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
