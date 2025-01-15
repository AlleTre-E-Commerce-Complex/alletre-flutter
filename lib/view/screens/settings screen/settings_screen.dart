import 'package:alletre_app/controller/providers/bottom_navbar_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/settings%20widgets/settings_list_tile.dart';
import 'package:alletre_app/view/widgets/settings%20widgets/settings_section_title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return 'Version ${packageInfo.version}';
  }

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
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsSectionTitle(title: 'General'),
            SettingsListTile(
              title: 'Theme',
              subtitle: 'Use the theme set in your device settings',
              onTap: () {},
            ),
            SettingsListTile(
              title: 'Country',
              subtitle: 'India',
              onTap: () {},
            ),
            SettingsListTile(
              title: 'Clear search history',
              onTap: () {},
            ),
            Divider(color: dividerColor, thickness: 0.5),
            const SettingsSectionTitle(title: 'Support'),
            SettingsListTile(
              title: 'Contact us',
              onTap: () {},
            ),
            SettingsListTile(
              title: 'Terms and Conditions',
              onTap: () {
                context.read<TabIndexProvider>().updateIndex(15);
              },
            ),
            Divider(color: dividerColor, thickness: 0.5),
            const SettingsSectionTitle(title: 'About'),
            SettingsListTile(
              title: 'Delete account',
              onTap: () {},
            ),
            SettingsListTile(
              title: 'Logout',
              onTap: () {},
            ),
            const SizedBox(height: 20),
            FutureBuilder<String>(
              future: _getAppVersion(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading version',
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                    ),
                  );
                } else {
                  return Center(
                    child: Text(
                      snapshot.data!,
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
