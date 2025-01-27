import 'package:alletre_app/controller/providers/bottom_navbar_provider.dart';
import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/utils/validators/form_validators.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';

class AddLocationScreen extends StatelessWidget {
  const AddLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final countryController = TextEditingController();
    final cityController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final labelController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      title: const Text('Location is required *'),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "In order to finish the procedure, we have to get access to your location. You can manage them later.",
                style: TextStyle(fontSize: 12, color: greyColor),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: countryController,
                decoration: const InputDecoration(labelText: 'Country'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your country';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
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
                  initialValue: provider.currentPhoneNumber,
                  textFieldController: phoneController,
                  formatInput: true,
                  keyboardType: TextInputType.phone,
                  inputDecoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter your phone number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 10,
                    ),
                  ),
                  validator: (_) =>
                      FormValidators.validatePhoneNumber(phoneController.text),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: labelController,
                decoration: const InputDecoration(labelText: 'Address Label'),
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
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              context.read<TabIndexProvider>().updateIndex(10);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill all fields')),
              );
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
