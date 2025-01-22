// import 'package:alletre_app/controller/providers/auction_provider.dart';
// import 'package:alletre_app/utils/themes/app_theme.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class AuctionDetailsScreen extends StatefulWidget {
//   const AuctionDetailsScreen({Key? key}) : super(key: key);

//   @override
//   State<AuctionDetailsPage> createState() => _AuctionDetailsPageState();
// }

// class _AuctionDetailsPageState extends State<AuctionDetailsPage> {
//   bool isQuickAuction = true;
//   bool isScheduleBidEnabled = false;
//   bool isBuyNowEnabled = false;
//   bool isReturnPolicyEnabled = false;
//   bool isWarrantyPolicyEnabled = false;

//   final TextEditingController hoursController = TextEditingController();
//   final TextEditingController startPriceController = TextEditingController();
//   final TextEditingController buyNowPriceController = TextEditingController();
//   final TextEditingController returnPolicyController = TextEditingController();
//   final TextEditingController warrantyPolicyController = TextEditingController();

//   DateTime? selectedStartDate;

//   Future<void> _selectDateTime(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null) {
//       setState(() {
//         selectedStartDate = picked;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final auctionProvider = Provider.of<AuctionProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Auction Details'),
//         backgroundColor: primaryColor,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             // Auction Type Selection
//             Text('Auction Type', style: Theme.of(context).textTheme.bodyLarge),
//             Row(
//               children: [
//                 Expanded(
//                   child: ListTile(
//                     title: const Text('Quick Auction'),
//                     leading: Radio<bool>(
//                       value: true,
//                       groupValue: isQuickAuction,
//                       onChanged: (value) {
//                         setState(() {
//                           isQuickAuction = value!;
//                         });
//                       },
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: ListTile(
//                     title: const Text('Long Auction'),
//                     leading: Radio<bool>(
//                       value: false,
//                       groupValue: isQuickAuction,
//                       onChanged: (value) {
//                         setState(() {
//                           isQuickAuction = value!;
//                         });
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             // Duration
//             TextField(
//               controller: hoursController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: 'Duration (hrs)',
//                 hintText: 'Enter duration in hours',
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Schedule Bid
//             SwitchListTile(
//               title: const Text('Schedule Bid (Optional)'),
//               value: isScheduleBidEnabled,
//               onChanged: (value) {
//                 setState(() {
//                   isScheduleBidEnabled = value;
//                 });
//               },
//             ),
//             if (isScheduleBidEnabled)
//               InkWell(
//                 onTap: () => _selectDateTime(context),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: greyColor),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     selectedStartDate != null
//                         ? selectedStartDate!.toLocal().toString()
//                         : 'Select Start Date',
//                     style: Theme.of(context).textTheme.bodyMedium,
//                   ),
//                 ),
//               ),
//             const SizedBox(height: 16),

//             // Pricing
//             TextField(
//               controller: startPriceController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: 'Start Price',
//                 hintText: 'Enter starting price',
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Buy Now
//             SwitchListTile(
//               title: const Text('Buy Now (Optional)'),
//               value: isBuyNowEnabled,
//               onChanged: (value) {
//                 setState(() {
//                   isBuyNowEnabled = value;
//                 });
//               },
//             ),
//             if (isBuyNowEnabled)
//               TextField(
//                 controller: buyNowPriceController,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   labelText: 'Purchasing Price',
//                   hintText: 'Enter purchasing price',
//                 ),
//               ),
//             const SizedBox(height: 16),

//             // Return Policy
//             SwitchListTile(
//               title: const Text('Return Policy (Optional)'),
//               value: isReturnPolicyEnabled,
//               onChanged: (value) {
//                 setState(() {
//                   isReturnPolicyEnabled = value;
//                 });
//               },
//             ),
//             if (isReturnPolicyEnabled)
//               TextField(
//                 controller: returnPolicyController,
//                 decoration: const InputDecoration(
//                   labelText: 'Policy Description',
//                   hintText: 'Enter return policy description',
//                 ),
//               ),
//             const SizedBox(height: 16),

//             // Warranty Policy
//             SwitchListTile(
//               title: const Text('Warranty Policy (Optional)'),
//               value: isWarrantyPolicyEnabled,
//               onChanged: (value) {
//                 setState(() {
//                   isWarrantyPolicyEnabled = value;
//                 });
//               },
//             ),
//             if (isWarrantyPolicyEnabled)
//               TextField(
//                 controller: warrantyPolicyController,
//                 decoration: const InputDecoration(
//                   labelText: 'Policy Description',
//                   hintText: 'Enter warranty policy description',
//                 ),
//               ),
//             const SizedBox(height: 32),

//             // Next Button
//             ElevatedButton(
//               onPressed: () {
//                 // Save or submit logic
//                 auctionProvider.scheduledTime = selectedStartDate;
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primaryColor,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//               ),
//               child: const Text('Next'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
