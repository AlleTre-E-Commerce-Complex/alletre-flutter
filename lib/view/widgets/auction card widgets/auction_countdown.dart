import 'dart:async';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';

class AuctionCountdown extends StatelessWidget {
  final DateTime startDate;

  const AuctionCountdown({super.key, required this.startDate});

  Stream<String?> getRemainingTimeStream() async* {
    while (true) {
      final remainingTime = getRemainingTime();
      yield remainingTime;
      if (remainingTime == null) break; // Stop updating if expired
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  String? getRemainingTime() {
    final DateTime now = DateTime.now();
    if (startDate.isBefore(now)) return null; // Hide if expired

    final Duration difference = startDate.difference(now);
    final int days = difference.inDays;
    final int hours = difference.inHours % 24;
    final int minutes = difference.inMinutes % 60;
    final int seconds = difference.inSeconds % 60;

    return '$days days: $hours hrs: $minutes min: $seconds sec';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    
    if (startDate.isAfter(now)) {
      return StreamBuilder<String?>(
        stream: getRemainingTimeStream(),
        builder: (context, snapshot) {
          final remainingTime = snapshot.data ?? getRemainingTime();
          if (!snapshot.hasData || remainingTime == null) return const SizedBox();
          
          return RichText(
            text: TextSpan(
              text: 'Ending Time:\n',
              style: const TextStyle(
                color: primaryVariantColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: remainingTime,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    
    return StreamBuilder<String?>(
      stream: getRemainingTimeStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) return const SizedBox(); // Hide if expired
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'Start Date:\n',
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: primaryVariantColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
            children: [
              TextSpan(
                text: snapshot.data ?? getRemainingTime(),
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
