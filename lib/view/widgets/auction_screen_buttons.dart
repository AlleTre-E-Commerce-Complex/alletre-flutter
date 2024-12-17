import 'package:flutter/material.dart';

class AuctionScreenButtons extends StatelessWidget {
  final VoidCallback onPickTime;
  final VoidCallback onSave;
  final DateTime? scheduledTime;

  const AuctionScreenButtons({
    super.key,
    required this.onPickTime,
    required this.onSave,
    required this.scheduledTime,
  });

  @override

  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          'Scheduled Time',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: onPickTime,
          child: const Text('Pick Scheduled Time'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (scheduledTime == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Please select a scheduled time')),
              );
              return;
            }
            onSave();
          },
          child: const Text('Save Auction'),
        ),
      ],
    );
  }
}
