import 'package:alletre_app/view/widgets/common%20widgets/footer_elements_appbar.dart';
import 'package:alletre_app/view/widgets/contact%20widgets/contact_section.dart';
import 'package:alletre_app/view/widgets/contact%20widgets/social_media_section.dart';
import 'package:flutter/material.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavbarElementsAppbar(appBarTitle: 'Contact', showBackButton: true),
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
                contactInfo: 'auctions.alletre@gmail.com',
                onTap: () {},
              ),
              const SizedBox(height: 22),
              ContactSection(
                icon: Icons.headphones,
                title: 'Call us',
                description:
                    'Our customer support is available around the clock to assist with any concerns.',
                contactInfo: '+971 50 562 1180',
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
