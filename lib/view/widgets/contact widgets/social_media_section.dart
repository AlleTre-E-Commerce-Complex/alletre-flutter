import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';

class SocialMediaSection extends StatelessWidget {
  final List<Map<String, dynamic>> socialIcons = [
    {
      'icon': FontAwesomeIcons.facebookF,
      'color': facebookColor,
      'url': 'https://www.facebook.com/alletr.ae',
    },
    {
      'icon': FontAwesomeIcons.instagram,
      'color': instagramColor,
      'url': 'https://www.instagram.com/alletre.ae/',
    },
    {
      'icon': FontAwesomeIcons.youtube,
      'color': youtubeColor,
      'url': 'https://www.youtube.com/@Alletre_ae',
    },
    {
      'icon': FontAwesomeIcons.tiktok,
      'color': tiktokColor,
      'size': 18.0,
      'url': 'https://www.tiktok.com/@alletre.ae',
    },
    {
      'icon': FontAwesomeIcons.snapchat,
      'color': snapchatColor,
      'url': 'https://www.snapchat.com/add/alletre',
    },
    {
      'icon': FontAwesomeIcons.whatsapp,
      'color': whatsappColor,
      'url': 'https://api.whatsapp.com/send/?phone=97172663004&text&type=phone_number&app_absent=0',
    },
    {
      'icon': FontAwesomeIcons.squareWhatsapp,
      'color': whatsappColor,
      'size': 22.0,
      'url': 'https://www.whatsapp.com/channel/0029Valpc9dLI8YQT9VNDk1R',
    },
    {
      'icon': FontAwesomeIcons.telegram,
      'color': telegramColor,
      'size': 22.0,
      'url': 'https://t.me/Alletre',
    },
  ];

  SocialMediaSection({super.key});

  Future<void> _openSocialMedia(BuildContext context, String url) async {
    try {
      // Encode the URL to handle special characters
      final encodedUrl = Uri.encodeFull(url);
      final uri = Uri.parse(encodedUrl);
      
      // First try to launch with external application mode
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      // If external launch fails, try launching in platform default browser
      if (!launched) {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
      }

      // If both attempts fail, show error message
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $url'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

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
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 10),
          Text(
            'Stay updated with our latest activities by visiting our social media pages.',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: socialIcons.map((iconData) {
              return InkWell(
                onTap: () => _openSocialMedia(context, iconData['url']),
                child: FaIcon(
                  iconData['icon'],
                  color: iconData['color'],
                  size: iconData['size'] ?? 20.0
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
