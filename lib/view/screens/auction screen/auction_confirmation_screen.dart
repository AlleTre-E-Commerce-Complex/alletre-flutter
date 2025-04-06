// import 'package:flutter/material.dart';
// import 'package:alletre_app/utils/themes/app_theme.dart';
// import 'package:alletre_app/utils/routes/main_stack.dart';

// class AuctionConfirmationScreen extends StatelessWidget {
//   const AuctionConfirmationScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(
//                   Icons.check_circle_outline,
//                   color: activeColor,
//                   size: 80,
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Payment Successful!',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: onSecondaryColor,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   'Your auction deposit has been paid successfully.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: greyColor,
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.pushReplacementNamed(context, MainStack.home);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryColor,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 40,
//                       vertical: 15,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text(
//                     'Back to Home',
//                     style: TextStyle(
//                       color: secondaryColor,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
