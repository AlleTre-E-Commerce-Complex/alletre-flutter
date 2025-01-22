// // // auction_screen_helper.dart
// // import 'package:flutter/material.dart';
// // import 'package:alletre_app/controller/providers/auction_provider.dart';
// // import 'package:alletre_app/model/auction_item.dart';
// // import 'package:provider/provider.dart';

// // class AuctionHelper {
// //   static Future<void> pickScheduledTime(BuildContext context) async {
// //     final pickedTime = await showDatePicker(
// //       context: context,
// //       initialDate: DateTime.now(),
// //       firstDate: DateTime.now(),
// //       lastDate: DateTime(2100),
// //     );
// //     if (pickedTime != null) {
// //       // Update the scheduled time through the provider
// //       // ignore: use_build_context_synchronously
// //       context.read<AuctionProvider>().scheduledTime = pickedTime;
// //     }
// //   }

// //   static void saveAuction({
// //     required BuildContext context,
// //     required GlobalKey<FormState> formKey,
// //     required TextEditingController titleController,
// //     required TextEditingController imageUrlController,
// //     required TextEditingController priceController,
// //   }) {
// //     if (!formKey.currentState!.validate()) return;

// //     final scheduledTime = context.read<AuctionProvider>().scheduledTime;
// //     if (scheduledTime == null) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('Please select a scheduled time!')),
// //       );
// //       return;
// //     }

// //     final newAuction = AuctionItem(
// //       title: titleController.text,
// //       imageUrl: imageUrlController.text,
// //       price: priceController.text,
// //       scheduledTime: scheduledTime,
// //     );

// //     context.read<AuctionProvider>().addUpcomingAuction(newAuction);
// //     Navigator.of(context).pop();
// //   }
// // }


// import 'package:flutter/material.dart';
// import 'package:alletre_app/controller/providers/auction_provider.dart';
// import 'package:alletre_app/model/auction_item.dart';
// import 'package:provider/provider.dart';

// class AuctionHelper {
//   static Future<void> pickScheduledTime(BuildContext context) async {
//     final pickedTime = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2100),
//     );
//     if (pickedTime != null) {
//       // Update the scheduled time through the provider
//       // ignore: use_build_context_synchronously
//       context.read<AuctionProvider>().scheduledTime = pickedTime;
//     }
//   }

//   static void saveAuction({
//     required BuildContext context,
//     required GlobalKey<FormState> formKey,
//     required TextEditingController titleController,
//     required TextEditingController descriptionController,
//     required TextEditingController categoryController,
//     required TextEditingController priceController,
//   }) {
//     if (!formKey.currentState!.validate()) return;

//     final auctionProvider = context.read<AuctionProvider>();
//     final scheduledTime = auctionProvider.scheduledTime;
//     final media = auctionProvider.media;
//     final condition = auctionProvider.condition;

//     if (scheduledTime == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a scheduled time!')),
//       );
//       return;
//     }

//     if (media.length < 3) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please add at least 3 media items!')),
//       );
//       return;
//     }

//     final newAuction = AuctionItem(
//       title: titleController.text,
//       imageUrl: media.isNotEmpty ? media.first : '',
//       price: priceController.text,
//       description: descriptionController.text,
//       category: categoryController.text,
//       media: media,
//       condition: condition,
//       scheduledTime: scheduledTime,
//     );

//     auctionProvider.addUpcomingAuction(newAuction);
//     auctionProvider.clearMedia(); // Clear media after saving
//     Navigator.of(context).pop();
//   }
// }
