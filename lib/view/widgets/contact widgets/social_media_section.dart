import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';

class SocialMediaSection extends StatelessWidget {
  final List<Map<String, dynamic>> socialIcons = [
    {'icon': Icons.facebook, 'color': Colors.blue},
    {'icon': Icons.tiktok, 'color': Colors.black},
    {'icon': Icons.youtube_searched_for, 'color': Colors.red},
    {'icon': Icons.linked_camera, 'color': Colors.blue.shade700},
    // Add more social icons if needed
  ];

  SocialMediaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Get in Touch',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Stay updated with our latest activities by visiting our social media pages.',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: socialIcons
                .map((iconData) => Icon(iconData['icon'], color: iconData['color']))
                .toList(),
          ),
        ],
      ),
    );
  }
}
