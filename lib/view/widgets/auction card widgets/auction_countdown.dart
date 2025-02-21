// import 'dart:async';
// import 'package:alletre_app/utils/themes/app_theme.dart';
// import 'package:flutter/material.dart';

// class AuctionCountdown extends StatelessWidget {
//   final DateTime startDate;

//   const AuctionCountdown({super.key, required this.startDate});

//   Stream<String?> getRemainingTimeStream() async* {
//     while (true) {
//       final remainingTime = getRemainingTime();
//       yield remainingTime;
//       if (remainingTime == null) break; // Stop updating if expired
//       await Future.delayed(const Duration(seconds: 1));
//     }
//   }


//   String? getRemainingTime() {
//     final DateTime now = DateTime.now();
//     if (startDate.isBefore(now)) return null; // Hide if expired

//     final Duration difference = startDate.difference(now);
//     final int days = difference.inDays;
//     final int hours = difference.inHours % 24;
//     final int minutes = difference.inMinutes % 60;
//     final int seconds = difference.inSeconds % 60;

//     return '$days days: $hours hrs: $minutes min: $seconds sec';
//   }

//   @override

//   Widget build(BuildContext context) {
//     final now = DateTime.now();
    
//     if (startDate.isAfter(now)) {
//       return StreamBuilder<String?>(
//         stream: getRemainingTimeStream(),
//         builder: (context, snapshot) {
//           final remainingTime = snapshot.data ?? getRemainingTime();
//           if (!snapshot.hasData || remainingTime == null) return const SizedBox();
          
//           return RichText(
//             text: TextSpan(
//               text: 'Ending Time:\n',
//               style: const TextStyle(
//                 color: primaryVariantColor,
//                 fontSize: 11,
//                 fontWeight: FontWeight.bold,
//               ),
//               children: [
//                 TextSpan(
//                   text: remainingTime,
//                   style: const TextStyle(
//                     fontSize: 10,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     }

    
//     return StreamBuilder<String?>(
//       stream: getRemainingTimeStream(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData || snapshot.data == null) return const SizedBox(); // Hide if expired
//         return RichText(
//           textAlign: TextAlign.center,
//           text: TextSpan(
//             text: 'Start Date:\n',
//             style: Theme.of(context).textTheme.labelLarge!.copyWith(
//                   color: primaryVariantColor,
//                   fontSize: 10,
//                   fontWeight: FontWeight.bold,
//                 ),
//             children: [
//               TextSpan(
//                 text: snapshot.data ?? getRemainingTime(),
//                 style: const TextStyle(
//                   fontSize: 9,
//                   fontWeight: FontWeight.normal,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// import 'dart:async';
// import 'package:alletre_app/utils/themes/app_theme.dart';
// import 'package:flutter/material.dart';

// class AuctionCountdown extends StatelessWidget {
//   final DateTime startDate;
//   final DateTime endDate;

//   const AuctionCountdown({
//     super.key, 
//     required this.startDate,
//     required this.endDate,
//   });

//   Stream<String> getTimeStream() async* {
//     while (true) {
//       yield getFormattedTime();
//       await Future.delayed(const Duration(seconds: 1));
//     }
//   }

//   String getFormattedTime() {
//     final DateTime now = DateTime.now();
    
//     // If auction hasn't started yet, show time until start
//     if (now.isBefore(startDate)) {
//       final Duration difference = startDate.difference(now);
//       return formatDuration(difference, 'Starting in:\n');
//     }
    
//     // If auction has ended, show expired
//     if (now.isAfter(endDate)) {
//       return 'Auction Ended';
//     }
    
//     // If auction is live, show time until end
//     final Duration difference = endDate.difference(now);
//     return formatDuration(difference, 'Ending in:\n');
//   }

//   String formatDuration(Duration duration, String prefix) {
//     final int days = duration.inDays;
//     final int hours = duration.inHours % 24;
//     final int minutes = duration.inMinutes % 60;
//     final int seconds = duration.inSeconds % 60;

//     if (days > 0) {
//       return '$prefix$days days: $hours hrs: $minutes min';
//     } else if (hours > 0) {
//       return '$prefix$hours hrs: $minutes min: $seconds sec';
//     } else {
//       return '$prefix$minutes min: $seconds sec';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<String>(
//       stream: getTimeStream(),
//       initialData: getFormattedTime(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) return const SizedBox();
        
//         return Text(
//           snapshot.data!,
//           style: Theme.of(context).textTheme.labelSmall!.copyWith(
//             color: primaryVariantColor,
//             fontSize: 10,
//             fontWeight: FontWeight.w600,
//           ),
//         );
//       },
//     );
//   }
// }

import 'dart:async';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';

class AuctionCountdown extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;

  const AuctionCountdown({
    super.key, 
    required this.startDate,
    required this.endDate,
  });

  Stream<Map<String, String>> getTimeStream() async* {
    while (true) {
      yield getFormattedTime();
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Map<String, String> getFormattedTime() {
    final DateTime now = DateTime.now();
    
    // If auction hasn't started yet, show time until start
    if (now.isBefore(startDate)) {
      final Duration difference = startDate.difference(now);
      return formatDuration(difference, 'Starting in:');
    }
    
    // If auction has ended, show expired
    if (now.isAfter(endDate)) {
      return {'prefix': '', 'time': 'Auction Ended'};
    }
    
    // If auction is live, show time until end
    final Duration difference = endDate.difference(now);
    return formatDuration(difference, 'Ending in:');
  }

  Map<String, String> formatDuration(Duration duration, String prefix) {
    final int days = duration.inDays;
    final int hours = duration.inHours % 24;
    final int minutes = duration.inMinutes % 60;
    final int seconds = duration.inSeconds % 60;

    String timeValue;
    if (days > 0) {
      timeValue = '$days days: $hours hrs: $minutes min:\n$seconds sec';
    } else if (hours > 0) {
      timeValue = '$hours hrs: $minutes min: $seconds sec';
    } else {
      timeValue = '$minutes min: $seconds sec';
    }
    
    return {'prefix': prefix, 'time': timeValue};
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, String>>(
      stream: getTimeStream(),
      initialData: getFormattedTime(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final data = snapshot.data!;
        final prefix = data['prefix']!;
        final timeValue = data['time']!;
        // If Auction Ended, we display the full text in one go with smaller font size.
        if (timeValue == 'Auction Ended') {
          return Text(
            timeValue,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: primaryVariantColor,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          );
        }
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$prefix\n',
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: primaryVariantColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: timeValue,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: primaryVariantColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
