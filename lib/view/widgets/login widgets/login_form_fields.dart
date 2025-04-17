import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/utils/validators/form_validators.dart';
import 'package:alletre_app/view/widgets/common%20widgets/common_obscure_password_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../screens/forgot password screen/forgot_password_screen.dart';

class LoginFormFields extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const LoginFormFields({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: userProvider.emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) =>
                FormValidators.validateLoginEmail(value, userProvider),
            onChanged: (value) => userProvider.setLoginEmail(value),
          ),
          const SizedBox(height: 16),
          ObscurePasswordField(
            labelText: 'Password',
            hintText: 'Enter your password',
            validator: (value) => FormValidators.validateLoginPassword(
              value,
              Provider.of<UserProvider>(context, listen: false),
            ),
            onChanged: (value) =>
                Provider.of<UserProvider>(context, listen: false)
                    .setLoginPassword(value),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row(
              //   children: [
              //     Transform.scale(
              //       scale: 0.8,
              //       child: Checkbox(
              //         value: userProvider.rememberPassword,
              //         onChanged: (_) => userProvider.toggleRememberPassword(),
              //       ),
              //     ),
              //     const Text(
              //       'Remember Password',
              //       style: TextStyle(
              //         fontSize: 15,
              //         color: onSecondaryColor,
              //         fontWeight: FontWeight.w500,
              //       ),
              //     ),
              //   ],
              // ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 15,
                      color: surfaceColor,
                      fontWeight: FontWeight.w500,
                    ),
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