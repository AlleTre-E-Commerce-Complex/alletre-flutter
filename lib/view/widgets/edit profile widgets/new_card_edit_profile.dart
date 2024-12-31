// import 'package:flutter/material.dart';

// class NewCardWidget extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final VoidCallback onTap;

//   const NewCardWidget({
//     Key? key,
//     required this.title,
//     required this.subtitle,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       margin: const EdgeInsets.symmetric(vertical: 8.0),
//       child: InkWell(
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 subtitle,
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
