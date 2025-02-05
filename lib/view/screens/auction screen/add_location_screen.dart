import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:alletre_app/controller/providers/location_provider.dart';
import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/utils/validators/form_validators.dart';
import 'package:alletre_app/view/screens/edit%20profile%20screen/add_address_screen.dart';
import 'package:csc_picker_plus/csc_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';

class AddLocationScreen extends StatelessWidget {
  const AddLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Add Location',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.read<TabIndexProvider>().updateIndex(1);
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
                      cityLanguage: CityLanguage.native,
                      onCountryChanged: (country) {
                        locationProvider.updateCountry(country);
                      },
                      onStateChanged: (state) {
                        locationProvider.updateState(state);
                      },
                      onCityChanged: (city) {
                        locationProvider.updateCity(city);
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
                          // ignore: use_build_context_synchronously
                          context
                              .read<UserProvider>()
                              .addAddress(selectedLocation);
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
                  const SizedBox(height: 26),
                  // Display Address List
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
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          context.read<TabIndexProvider>().updateIndex(1);
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
                          final userProvider = context.read<UserProvider>();

                          if (locationProvider.selectedCountry == null ||
                              locationProvider.selectedState == null ||
                              locationProvider.selectedCity == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please select the country, state, and city'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          if (userProvider.addresses.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Please add at least one address'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          if (formKey.currentState?.validate() ?? false) {
                            context.read<TabIndexProvider>().updateIndex(10);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill all the fields'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
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
