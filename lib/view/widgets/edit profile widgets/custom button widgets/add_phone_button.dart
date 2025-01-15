import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';

class AddPhoneButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddPhoneButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, right: 29.0),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: primaryColor,
        ),
        child: IconButton(
          icon: const Icon(Icons.add_ic_call_sharp, color: secondaryColor, size: 20),
          onPressed: () async {
            // Open dialog to input phone number
            final phoneNumber = await _showPhoneNumberDialog(context);
            if (phoneNumber != null && phoneNumber.isNotEmpty) {
              // Update the phone number in the UserProvider
              // ignore: use_build_context_synchronously
              context.read<UserProvider>().setPhoneNumber(phoneNumber as PhoneNumber);
              onPressed(); // Call the onPressed callback if needed
            }
          },
        ),
      ),
    );
  }

  // Function to show the phone number dialog
  // Function to show the phone number dialog
Future<String?> _showPhoneNumberDialog(BuildContext context) async {
  String? phoneNumber = '';
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Enter Phone Number',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 10.0),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.2, // Set smaller width
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  phoneNumber = number.phoneNumber;
                },
                selectorConfig: const SelectorConfig(
                  selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                  showFlags: true, // Show country flags
                ),
                initialValue: PhoneNumber(isoCode: 'US'),
                textFieldController: TextEditingController(),
                formatInput: true,
                keyboardType: TextInputType.number,
                inputBorder: const OutlineInputBorder(),
                inputDecoration: const InputDecoration(
                  hintText: 'Enter your number',
                  hintStyle: TextStyle(fontSize: 10),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 9), // Reduced padding
                  isDense: true, // Makes the input field more compact
                ),
                onSaved: (PhoneNumber number) {
                  phoneNumber = number.phoneNumber;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(fontSize: 12)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, phoneNumber); // Returns phone number
            },
            child: const Text('Save', style: TextStyle(fontSize: 12)),
          ),
        ],
      );
    },
  );
}

}
