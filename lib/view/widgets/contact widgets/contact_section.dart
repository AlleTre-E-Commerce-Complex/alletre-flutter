import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';

class ContactSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String contactInfo;
  final String? contactPrefix;
  final VoidCallback onTap;

  const ContactSection({super.key, 
    required this.icon,
    required this.title,
    required this.description,
    required this.contactInfo,
    this.contactPrefix,
    required this.onTap,
  });

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
          Row(
            children: [
              Icon(icon, size: 32, color: primaryColor),
              const SizedBox(width: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          if (contactPrefix != null)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    contactPrefix!,
                    style: const TextStyle(color: secondaryColor, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  contactInfo,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            )
          else
            GestureDetector(
              onTap: onTap,
              child: Text(
                contactInfo,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}