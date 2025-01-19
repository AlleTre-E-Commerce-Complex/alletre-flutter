import 'package:alletre_app/controller/providers/bottom_navbar_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/contact%20widgets/contact_section.dart';
import 'package:alletre_app/view/widgets/contact%20widgets/social_media_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: secondaryColor),
          onPressed: () {
            context.read<TabIndexProvider>().updateIndex(14);
          },
        ),
        title: const Text('Contact us', style: TextStyle(color: secondaryColor)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ContactSection(
                icon: Icons.email,
                title: 'Email us',
                description:
                    'Reach out to us via email and a customer service representative will respond as soon as possible.',
                contactInfo: 'info@alletre.com',
                onTap: () {},
              ),
              const SizedBox(height: 22),
              ContactSection(
                icon: Icons.headphones,
                title: 'Call us',
                description:
                    'Our customer support is available around the clock to assist with any concerns.',
                contactInfo: '+971 72663004',
                contactPrefix: '24/7',
                onTap: () {},
              ),
              const SizedBox(height: 22),
              SocialMediaSection(),        
            ],
          ),
        ),
      ),
    );
  }
}