import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/utils/validators/form_validators.dart';
import 'package:alletre_app/view/widgets/common%20widgets/common_obscure_password_field.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';

class SignupFormFields extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const SignupFormFields({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final TextEditingController phoneController = TextEditingController(
      text: userProvider.phoneNumber,
    );

    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            onChanged: (value) => userProvider.setName(value),
            validator: FormValidators.validateName,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person),
              labelText: 'Name',
              hintText: 'Enter your name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            onChanged: (value) => userProvider.setEmail(value),
            validator: FormValidators.validateEmail,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.email),
              labelText: 'Email',
              hintText: 'Enter your email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Consumer<UserProvider>(
            builder: (context, provider, child) => InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) {
                provider.setPhoneNumber(number);
              },
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                showFlags: true,
              ),
              initialValue: provider.currentPhoneNumber,
              // textFieldController: phoneController,
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
              validator: (_) => FormValidators.validatePhoneNumber(phoneController.text),
            ),
          ),
          const SizedBox(height: 16),

          ObscurePasswordField(
            labelText: 'Password',
            hintText: 'Enter your password',
            validator: FormValidators.validatePassword,
            onChanged: (value) => userProvider.setPassword(value),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Transform.scale(
                scale: 0.8,
                child: Checkbox(
                  value: userProvider.agreeToTerms,
                  onChanged: (_) => userProvider.toggleAgreeToTerms(),
                ),
              ),
              const Text(
                'I agree to the ',
                style: TextStyle(
                  fontSize: 15,
                  color: onSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: () {
                },
                child: const Text(
                  'Terms & Conditions',
                  style: TextStyle(
                    fontSize: 15,
                    color: surfaceColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}