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
      // await Future.delayed(const Duration(seconds: 1));
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
    return StreamBuilder<String?>(
      stream: getRemainingTimeStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) return const SizedBox(); // Hide if expired
        return Text('Start Date:\n${
          snapshot.data ?? getRemainingTime()}',
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: primaryVariantColor,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
        );
      },
    );
  }
}
