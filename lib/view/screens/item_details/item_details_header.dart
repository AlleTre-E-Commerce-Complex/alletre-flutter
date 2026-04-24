// import 'package:flutter/material.dart';
// import 'package:alletre_app/model/auction_item.dart';

// class ItemDetailsHeader extends StatelessWidget {
//   final AuctionItem item;

//   const ItemDetailsHeader({
//     super.key,
//     required this.item,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             item.title,
//             style: Theme.of(context).textTheme.headlineSmall,
//           ),
//           const SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Current Bid',
//                     style: Theme.of(context).textTheme.bodyMedium,
//                   ),
//                   Text(
//                     '\$${item.currentBid}',
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                   ),
//                 ],
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     'Time Remaining',
//                     style: Theme.of(context).textTheme.bodyMedium,
//                   ),
//                   Text(
//                     item.timeRemaining(),
//                     style: Theme.of(context).textTheme.titleMedium,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
