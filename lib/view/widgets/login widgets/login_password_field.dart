// // view/widgets/login_password_field.dart
// import 'package:flutter/material.dart';

// class LoginPasswordField extends StatelessWidget {
//   final TextEditingController controller;
//   final String? Function(String?)? validator;

//   const LoginPasswordField({
//     super.key,
//     required this.controller,
//     this.validator,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       validator: validator,
//       obscureText: true,
//       decoration: const InputDecoration(
//         labelText: 'Password',
//         hintText: 'Enter your password',
//         prefixIcon: Icon(Icons.lock),
//         border: OutlineInputBorder(),
//       ),
//     );
//   }
// }
