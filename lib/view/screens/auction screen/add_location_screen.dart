import 'package:alletre_app/controller/providers/bottom_navbar_provider.dart';
import 'package:alletre_app/controller/providers/location_provider.dart';
import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:csc_picker_plus/csc_picker_plus.dart';
import 'package:alletre_app/utils/validators/form_validators.dart';

class AddLocationScreen extends StatelessWidget {
  const AddLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final labelController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      title: const Text.rich(
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
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Consumer<LocationProvider>(
                builder: (context, locationProvider, child) => CSCPickerPlus(
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
                  defaultCountry: CscCountry.United_Arab_Emirates,
                  countryFilter: [CscCountry.United_Arab_Emirates],
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
              const SizedBox(height: 10),
              // Street Address Field Styled Similarly
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Street Address',
                  labelStyle: const TextStyle(
                    color: onSecondaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your street address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // Phone Number Field Styled Similarly
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
                  validator: (_) =>
                      FormValidators.validatePhoneNumber(phoneController.text),
                ),
              ),
              const SizedBox(height: 10),
              // Address Label Field Styled Similarly
              TextFormField(
                controller: labelController,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a label for your address';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
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
        const SizedBox(width: 2),
        ElevatedButton(
          onPressed: () {
            final locationProvider = context.read<LocationProvider>();
            if (locationProvider.selectedCountry == null ||
                locationProvider.selectedState == null ||
                locationProvider.selectedCity == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Please select the country, state and city')),
              );
              return;
            }
            if (formKey.currentState?.validate() ?? false) {
              context.read<TabIndexProvider>().updateIndex(10);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill all the fields')),
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
          child: const Text("Add",
                          style: TextStyle(color: secondaryColor)),
        ),
      ],
    );
  }
}
