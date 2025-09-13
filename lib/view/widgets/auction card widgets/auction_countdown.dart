import 'dart:async';
import 'package:flutter/material.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:provider/provider.dart';

class AuctionCountdown extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final TextStyle? textStyle;
  final String? customPrefix;
  final String auctionId;

  const AuctionCountdown({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.auctionId,
    this.textStyle,
    this.customPrefix,
  });

  Stream<Map<String, String>> getTimeStream() async* {
    while (true) {
      yield getFormattedTime();
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Map<String, String> getFormattedTime() {
    final DateTime now = DateTime.now();

    // If auction hasn't started yet and it's not LIVE, show time until start
    if (now.isBefore(startDate) && customPrefix != 'Ending in:') {
      final Duration difference = startDate.difference(now);
      return formatDuration(difference, 'Starting in:');
    }

    // // If auction has ended, return empty to let provider handle removal
    if (now.isAfter(endDate)) {
      return {'prefix': '', 'time': ''};
    }

    // If auction is live, show time until end
    final Duration difference = endDate.difference(now);
    return formatDuration(difference, customPrefix ?? 'Ending in:');
  }

  Map<String, String> formatDuration(Duration duration, String prefix) {
    final int days = duration.inDays;
    final int hours = duration.inHours % 24;
    final int minutes = duration.inMinutes % 60;
    final int seconds = duration.inSeconds % 60;

    String timeValue;
    if (days > 0) {
      timeValue = '$days days: $hours hrs: $minutes mins';
    } else if (hours > 0) {
      timeValue = '$hours hrs: $minutes mins: $seconds sec';
    } else if (minutes > 0) {
      timeValue = '$minutes mins: $seconds sec';
    } else {
      timeValue = '$seconds sec';
    }

    return {'prefix': prefix, 'time': timeValue};
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, String>>(
      stream: getTimeStream(),
      initialData: getFormattedTime(),
      builder: (context, snapshot) {
        // Handle auction ended
        if (snapshot.hasData && snapshot.data!['time']!.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<AuctionProvider>().handleAuctionEnded(auctionId);
          });
          return const SizedBox();
        }
        if (!snapshot.hasData) return const SizedBox();
        final data = snapshot.data!;
        final prefix = data['prefix']!;
        final timeValue = data['time']!;
        // If auction has ended, show nothing
        if (timeValue.isEmpty) {
          return const SizedBox();
        }
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$prefix\n',
                style: (textStyle ?? Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: primaryVariantColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        )).copyWith(
                          color: primaryVariantColor,
                        ),
              ),
              TextSpan(
                text: timeValue,
                style: textStyle ??
                    Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: primaryVariantColor,
                          fontSize: 10,
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
