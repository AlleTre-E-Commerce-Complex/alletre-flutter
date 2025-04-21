// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:alletre_app/controller/providers/location_provider.dart';
import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/utils/location_maps.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/utils/validators/form_validators.dart';
import 'package:alletre_app/view/screens/edit%20profile%20screen/add_address_screen.dart';
import 'package:csc_picker_plus/csc_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';

class AddLocationScreen extends StatelessWidget {
  final Map<String, dynamic>? initialAddressMap;
  final String? initialAddressLabel;
  final String? initialPhone;
  final String? initialCountry;
  final String? initialCity;
  final String? initialState;

  const AddLocationScreen({
    super.key,
    this.initialAddressMap,
    this.initialAddressLabel,
    this.initialPhone,
    this.initialCountry,
    this.initialCity,
    this.initialState,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final locationProvider = context.read<LocationProvider>();

    // 🏁 DEBUG: Print initial country and state values on screen open
    print('number: $initialPhone');
    print('address: ${initialAddressMap?['address'] ?? ''}');
    print('addressLabel: $initialAddressLabel');
    print('initialCountry: $initialCountry');
    print('initialCity: $initialCity');
    print('initialState: $initialState');

    final phoneController = TextEditingController(text: initialPhone ?? '');
    final addressLabelController =
        TextEditingController(text: initialAddressLabel ?? '');
    final formKey = GlobalKey<FormState>();

    // Schedule address initialization after build to avoid setState error
    if (initialAddressMap != null && userProvider.addresses.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        userProvider.addAddress(initialAddressMap!);
      });
    }

    // When passing address maps, always ensure an 'id' is present for editing
    Map<String, dynamic>? editingAddressMap = initialAddressMap;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          editingAddressMap != null ? 'Edit Location' : 'Add Location',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            addressLabelController.clear();
            phoneController.clear();
            userProvider.clearAddresses();
            locationProvider.reset();
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Location is required *\n',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: errorColor,
                    ),
                  ),
                  TextSpan(
                    text:
                        '\nIn order to complete the procedure, we need to get access to your location.\nYou can manage it later.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: onSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: formKey,
              child: Column(
                children: [
                  Consumer<LocationProvider>(
                    builder: (context, locationProvider, child) =>
                        CSCPickerPlus(
                      layout: Layout.vertical,
                      flagState: CountryFlag.ENABLE,
                      currentCountry: initialCountry,
                      showCities: false,
                      currentState: initialCity,
                      onCountryChanged: (country) {
                        print('Picker country: $country');
                        // UAE is always countryId 1
                        locationProvider.updateCountry(country, id: 1);
                      },
                      onStateChanged: (state) {
                        print('Picker state: $state');
                        int? stateId;
                        String normalizedState = (state ?? '')
                            .trim()
                            .toLowerCase()
                            .replaceAll('emirate', '')
                            .replaceAll('-', ' ')
                            .replaceAll(RegExp(r'\s+'), ' ')
                            .replaceAll('umm al quwain', 'umm al quwain')
                            .replaceAll('ras al khaimah', 'ras al khaimah')
                            .replaceAll('abu dhabi', 'abu dhabi')
                            .replaceAll('ajman', 'ajman')
                            .replaceAll('dubai', 'dubai')
                            .replaceAll('fujairah', 'fujairah')
                            .replaceAll('sharjah', 'sharjah')
                            .trim();

                        cityIdToName.forEach((id, name) {
                          String backendName = name
                              .trim()
                              .toLowerCase()
                              .replaceAll('-', ' ')
                              .replaceAll(RegExp(r'\s+'), ' ')
                              .replaceAll('umm al quwain', 'umm al quwain')
                              .replaceAll('ras al khaimah', 'ras al khaimah')
                              .replaceAll('abu dhabi', 'abu dhabi')
                              .replaceAll('ajman', 'ajman')
                              .replaceAll('dubai', 'dubai')
                              .replaceAll('fujairah', 'fujairah')
                              .replaceAll('sharjah', 'sharjah')
                              .trim();
                          if (backendName == normalizedState) {
                            stateId = id;
                          }
                        });
                        print('Normalized state: "$normalizedState"');
                        print(
                            'Matched stateId (cityId): $stateId for state "$state"');
                        if (stateId == null) {
                          print(
                              'WARNING: Could not match "$state" to any cityId. Check cityIdToName map!');
                        }
                        locationProvider.updateState(state, id: stateId);
                      },
                      onCityChanged: (city) {
                        print('Picker city (ignored for backend): $city');
                      },
                      countryFilter: const [CscCountry.United_Arab_Emirates],
                      countryDropdownLabel: "Select Country",
                      stateDropdownLabel: "Select State",
                      cityDropdownLabel: "Select City",
                      dropdownDecoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      disabledDropdownDecoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        color: Colors.grey.shade300,
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      selectedItemStyle: const TextStyle(
                          color: onSecondaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                      dropdownHeadingStyle: const TextStyle(
                          color: onSecondaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                      dropdownItemStyle: const TextStyle(
                          color: onSecondaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<UserProvider>(
                    builder: (context, provider, child) =>
                        InternationalPhoneNumberInput(
                      onInputChanged: (PhoneNumber number) {
                        provider.setPhoneNumber(number);
                      },
                      selectorConfig: const SelectorConfig(
                        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                        showFlags: true,
                      ),
                      initialValue: PhoneNumber(isoCode: provider.isoCode),
                      textFieldController: phoneController,
                      formatInput: true,
                      keyboardType: TextInputType.phone,
                      inputDecoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: const TextStyle(
                          color: onSecondaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade600),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 10,
                        ),
                      ),
                      validator: (_) => FormValidators.validatePhoneNumber(
                          phoneController.text),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: addressLabelController,
                    decoration: InputDecoration(
                      labelText: 'Address Label',
                      labelStyle: const TextStyle(
                        color: onSecondaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade600),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<UserProvider>(
                    builder: (context, provider, child) {
                      final address = provider.addresses.isNotEmpty
                          ? provider.addresses.last['address'] ?? ''
                          : (editingAddressMap?['address'] ?? '');
                      return TextFormField(
                        readOnly: true,
                        maxLines: 3,
                        controller: TextEditingController(text: address),
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Address',
                          labelStyle: const TextStyle(
                            color: onSecondaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade600),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 25),
                  // Add/Edit Address Button
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      final selectedLocation = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GoogleMapScreen(),
                        ),
                      );
                      if (selectedLocation != null) {
                        // Ensure selectedLocation is a Map<String, dynamic>
                        Map<String, dynamic> selectedMap;
                        if (selectedLocation is String) {
                          selectedMap = {'address': selectedLocation};
                        } else if (selectedLocation is Map<String, dynamic>) {
                          selectedMap = selectedLocation;
                        } else {
                          // Unexpected type, fallback
                          selectedMap = {
                            'address': selectedLocation.toString()
                          };
                        }
                        // If editing, preserve the id
                        if (editingAddressMap != null &&
                            editingAddressMap['id'] != null) {
                          selectedMap['id'] = editingAddressMap['id'];
                        }
                        final userProvider = context.read<UserProvider>();
                        if (editingAddressMap != null) {
                          userProvider.editAddress(
                              editingAddressMap, selectedMap);
                        } else {
                          userProvider.addAddress(selectedMap);
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: avatarColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              editingAddressMap != null
                                  ? Icons.edit
                                  : Icons.add,
                              color: onSecondaryColor,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              editingAddressMap != null
                                  ? 'Edit Address'
                                  : 'Add Address',
                              style: const TextStyle(
                                color: onSecondaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          addressLabelController.clear();
                          phoneController.clear();
                          userProvider.clearAddresses();
                          locationProvider.reset();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(80, 33),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          backgroundColor: Colors.grey[300],
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          final locationProvider =
                              context.read<LocationProvider>();

                          // 🐞 DEBUG: Print values on Done button press
                          print(
                              '🟢 [DONE] locationProvider.countryId: ${locationProvider.countryId}');
                          print(
                              '🔵 [DONE] locationProvider.stateId: ${locationProvider.stateId}');
                          print(
                              '🟡 [DONE] locationProvider.selectedCountry: ${locationProvider.selectedCountry}');
                          print(
                              '🟠 [DONE] locationProvider.selectedState: ${locationProvider.selectedState}');

                          String? address;
                          String? addressLabel;
                          String? phone;
                          // Use address map structure
                          Map<String, dynamic>? currentAddressMap =
                              userProvider.addresses.isNotEmpty
                                  ? userProvider.addresses.last
                                  : (editingAddressMap);
                          address = currentAddressMap?['address'] ?? '';
                          addressLabel = addressLabelController.text.trim();
                          // Use the provider's phoneNumber, which is set by onInputChanged
                          phone = phoneController.text;
                          print(
                              'phoneController.text: ${phoneController.text}');
                          print(
                              'userProvider.phoneNumber: ${userProvider.phoneNumber}');

                          final countryId = locationProvider.countryId;
                          final cityId = locationProvider
                              .stateId; // Use stateId as cityId for backend

                          print('address: \'$address\'');
                          print('addressLabel: \'$addressLabel\'');
                          print('countryId: $countryId');
                          print('phone: \'$phone\'');
                          print(
                              'selectedState: \'${locationProvider.selectedState}\'');

                          if (address!.isEmpty ||
                              countryId == null ||
                              cityId == null ||
                              addressLabel.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Center(
                                    child: Text('Please fill all the fields')),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          final locationMap = {
                            'address': address,
                            'addressLabel': addressLabel,
                            'countryId': countryId,
                            'cityId': cityId, // This is the stateId
                            'phone': phone,
                          };
                          // If editing, preserve the id
                          if (editingAddressMap != null &&
                              editingAddressMap['id'] != null) {
                            locationMap['id'] = editingAddressMap['id'];
                          }

                          print('locationMap: $locationMap');

                          Navigator.pop(context, locationMap);
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(80, 33),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: const Text(
                          "Done",
                          style: TextStyle(color: secondaryColor),
                        ),
                      ),
                    ],
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
