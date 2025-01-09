import 'package:alletre_app/controller/providers/bottom_navbar_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/profile%20widgets/profile_section_title.dart';
import 'package:alletre_app/view/widgets/settings%20widgets/settings_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: secondaryColor),
          onPressed: () {
            context.read<TabIndexProvider>().updateIndex(4);
          },
        ),
        title: const Text('Settings', style: TextStyle(color: secondaryColor)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileSectionTitle(title: 'Shopping'),
            SettingsListTile(
              title: 'Watchlist',
              subtitle: 'Keep tabs on watched items',
              onTap: () {},
            ),
            SettingsListTile(
              title: 'Selling',
              subtitle: 'View the selling items',
              onTap: () {},
            ),
            SettingsListTile(
              title: 'Bids & offers',
              subtitle: 'Active auctions and seller offers',
              onTap: () {},
            ),
            SettingsListTile(
              title: 'Recently viewed',
              subtitle: 'Listings you recently viewed',
              onTap: () {},
            ),
            Divider(color: dividerColor, thickness: 0.5),
            const ProfileSectionTitle(title: 'Account'),
            SettingsListTile(
              title: 'FAQS',
              subtitle: 'Know more about the services',
              onTap: () {
              },
            ),
            SettingsListTile(
              title: 'Settings',
              subtitle: 'View more settings',
              onTap: () {
              },
            ),
          ],
        ),
      ),
    );
  }
}
