import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/contact%20widgets/contact_section.dart';
import 'package:alletre_app/view/widgets/contact%20widgets/social_media_section.dart';
import 'package:flutter/material.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Contact Us', style: Theme.of(context).textTheme.titleMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: secondaryColor),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: secondaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ContactSection(
                icon: Icons.email,
                title: 'Email us',
                description:
                    'Reach out to us via email and a customer service representative will respond as soon as possible.',
                contactInfo: 'cs@emiratesauction.ae',
                onTap: () {},
              ),
              const SizedBox(height: 16),
              ContactSection(
                icon: Icons.headphones,
                title: 'Call us',
                description:
                    'Our customer support is available around the clock to assist with any concerns.',
                contactInfo: '+971 600 54 54 54',
                contactPrefix: '24/7',
                onTap: () {},
              ),
              const SizedBox(height: 16),
              SocialMediaSection(),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  icon: const Icon(Icons.chat, color: secondaryColor),
                  label: const Text('Live Chat',
                      style: TextStyle(color: secondaryColor, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}