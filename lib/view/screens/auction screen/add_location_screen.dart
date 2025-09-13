// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:alletre_app/controller/providers/location_provider.dart';
import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/screens/edit%20profile%20screen/add_address_screen.dart';
import 'package:collection/collection.dart';
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
  final Map<String, dynamic>? existingAddress;

  const AddLocationScreen({
    super.key,
    this.initialAddressMap,
    this.initialAddressLabel,
    this.initialPhone,
    this.initialCountry,
    this.initialCity,
    this.initialState,
    this.existingAddress,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final locationProvider = context.read<LocationProvider>();
    final phoneController = TextEditingController(text: initialPhone ?? '');
    final addressLabelController = TextEditingController(text: initialAddressLabel ?? '');
    final formKey = GlobalKey<FormState>();
    final errorNotifier = ValueNotifier<String?>(null);
    Map<String, dynamic>? editingAddressMap = existingAddress ?? initialAddressMap;
    // Track phone validity
    final phoneValidNotifier = ValueNotifier<bool>(false);
    PhoneNumber? parsedPhoneNumber;

    // Address value notifier for reactive updates
    final addressValueNotifier = ValueNotifier<String>(existingAddress?['address'] ?? initialAddressMap?['address'] ?? '');

    // --- Ensure initial phone number is validated if pre-filled ---
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (phoneController.text.isNotEmpty) {
        try {
          final phoneNumber = await PhoneNumber.getRegionInfoFromPhoneNumber(phoneController.text);
          // Optionally, validate further if needed
          phoneValidNotifier.value = true;
          parsedPhoneNumber = phoneNumber;
        } catch (e) {
          phoneValidNotifier.value = false;
        }
      }
    });

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
            ValueListenableBuilder<String?>(
              valueListenable: errorNotifier,
              builder: (context, error, child) {
                if (error == null) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: errorColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: errorColor.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: errorColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          error,
                          style: const TextStyle(color: errorColor, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
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
                    text: '\nIn order to complete the procedure, we need to get access to your location.\nYou can manage it later.',
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
                    builder: (context, locationProvider, child) {
                      if (locationProvider.lsCscCountries.isEmpty) {
                        locationProvider.fetchCountries();
                      }
                      return CSCPickerPlus(
                        layout: Layout.vertical,
                        flagState: CountryFlag.ENABLE,
                        currentCountry: initialCountry,
                        showCities: false,
                        currentState: initialCity,
                        onCountryChanged: (country) {
                          // UAE is always countryId 1
                          final regex = RegExp(r'[\u{1F1E6}-\u{1F1FF}]+', unicode: true);
                          country = country.replaceAll(regex, '').trim();
                          int countryId = locationProvider.lsCountries.singleWhere((elem) => ((elem.nameEn == country) || (elem.nameAr == country))).id;
                          locationProvider.fetchStates(countryId);
                          locationProvider.updateCountry(country, id: countryId);
                        },
                        onStateChanged: (state) {
                          if (state != null && state != "Select State") {
                            var stateInfo = locationProvider.lsStates.singleWhereOrNull((elem) => ((elem.nameEn == state) || (elem.nameAr == state)));
                            if (stateInfo != null) {
                              locationProvider.updateState(state, id: stateInfo.id);
                            }
                          }
                        },
                        onCityChanged: (city) {
                          print('Picker city (ignored for backend): $city');
                        },
                        countryFilter: locationProvider.lsCscCountries,
                        countryDropdownLabel: "Select Country",
                        stateDropdownLabel: "Select State",
                        cityDropdownLabel: "Select City",
                        dropdownDecoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        disabledDropdownDecoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                          color: Colors.grey.shade300,
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        selectedItemStyle: const TextStyle(color: onSecondaryColor, fontSize: 15, fontWeight: FontWeight.w500),
                        dropdownHeadingStyle: const TextStyle(color: onSecondaryColor, fontSize: 15, fontWeight: FontWeight.bold),
                        dropdownItemStyle: const TextStyle(color: onSecondaryColor, fontSize: 15, fontWeight: FontWeight.w500),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Consumer<UserProvider>(
                    builder: (context, provider, child) => InternationalPhoneNumberInput(
                      onInputChanged: (PhoneNumber number) {
                        provider.setPhoneNumber(number);
                        parsedPhoneNumber = number;
                      },
                      onInputValidated: (bool value) {
                        phoneValidNotifier.value = value;
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
                  ValueListenableBuilder<String>(
                    valueListenable: addressValueNotifier,
                    builder: (context, address, _) {
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
                          selectedMap = {'address': selectedLocation.toString()};
                        }
                        // If editing, preserve the id
                        if (editingAddressMap != null && editingAddressMap?['id'] != null) {
                          selectedMap['id'] = editingAddressMap?['id'];
                        }
                        // --- Ensure we merge the map result into editingAddressMap ---
                        editingAddressMap = {
                          ...?editingAddressMap,
                          ...selectedMap, // This ensures lat/lng are present for submission
                        };
                        // Update address notifier
                        addressValueNotifier.value = selectedMap['address'] ?? '';
                        // --- Update phone in editingAddressMap if edited ---
                        editingAddressMap?['phone'] = phoneController.text.trim();
                        final userProvider = context.read<UserProvider>();
                        if (editingAddressMap != null) {
                          userProvider.editAddress(editingAddressMap!, selectedMap);
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
                              Icons.search,
                              color: onSecondaryColor,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Search Map',
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
                        onPressed: () async {
                          final address = userProvider.addresses.isNotEmpty ? userProvider.addresses.last['address'] ?? '' : (editingAddressMap?['address'] ?? '');
                          final addressLabel = addressLabelController.text.trim();
                          final countryId = locationProvider.countryId;
                          final cityId = locationProvider.stateId;
                          // Defensive: treat 0, null, or empty as not selected
                          bool countryMissing = countryId == null || countryId == 0 || countryId.toString().isEmpty;
                          bool cityMissing = cityId == null || cityId == 0 || cityId.toString().isEmpty;
                          print('[DEBUG] countryId: \x1B[33m$countryId\x1B[0m, cityId: \x1B[33m$cityId\x1B[0m');
                          print('[DEBUG] countryMissing: $countryMissing, cityMissing: $cityMissing');
                          final rawPhone = phoneController.text.trim();
                          final errors = <String>[];
                          if (address.isEmpty) {
                            errors.add('Address is required.');
                          }
                          if (addressLabel.isEmpty) {
                            errors.add('Address label is required.');
                          }
                          if (countryMissing) {
                            errors.add('Country is required.');
                          }
                          if (cityMissing) {
                            errors.add('Sorry!. We are not running our services on this state.');
                          }
                          // Use intl_phone_number_input validation
                          final phoneIsValid = phoneValidNotifier.value;
                          if (!phoneIsValid) {
                            errors.add('Phone number must be valid.');
                          }
                          // Use parsed phone number in E.164 format if possible
                          String? normalizedPhone;
                          if (parsedPhoneNumber != null && phoneIsValid) {
                            normalizedPhone = parsedPhoneNumber!.phoneNumber;
                          } else {
                            normalizedPhone = rawPhone;
                          }
                          print('[DEBUG] Phone entered: "$rawPhone"');
                          print('[DEBUG] Phone normalized: "$normalizedPhone"');
                          if (errors.isNotEmpty) {
                            errorNotifier.value = errors.join('\n');
                            return;
                          }
                          errorNotifier.value = null;
                          print('[DEBUG] Location map sent to backend:');
                          final lat = editingAddressMap?['lat'];
                          final lng = editingAddressMap?['lng'];
                          print({
                            ...?editingAddressMap,
                            'address': address,
                            'addressLabel': addressLabel,
                            'countryId': countryId,
                            'cityId': cityId,
                            'phone': normalizedPhone,
                            if (lat != null) 'lat': lat,
                            if (lng != null) 'lng': lng,
                          });
                          Navigator.pop(context, {
                            ...?editingAddressMap,
                            'address': address,
                            'addressLabel': addressLabel,
                            'countryId': countryId,
                            'cityId': cityId,
                            'phone': normalizedPhone,
                            if (lat != null) 'lat': lat,
                            if (lng != null) 'lng': lng,
                          });
                          userProvider.clearAddresses();
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
