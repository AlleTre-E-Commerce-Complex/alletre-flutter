import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/screens/contact%20screen/contact_screen.dart';
import 'package:alletre_app/view/widgets/common%20widgets/footer_elements_appbar.dart';
import 'package:alletre_app/view/widgets/profile%20widgets/profile_list_tile.dart';
import 'package:alletre_app/view/widgets/settings%20widgets/settings_section_title.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../faqs screen/faqs_screen.dart';
import '../login screen/login_page.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return 'Version ${packageInfo.version}';
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('LOGOUT'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    if (!context.mounted) return;

    final scaffold = ScaffoldMessenger.of(context);

    try {
      // Perform logout
      await context.read<UserProvider>().logout();

      // Navigate to login page and reset navigation stack
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
        
        // Show success message
        scaffold.showSnackBar(
          SnackBar(
            content: Center(child: Text('Successfully logged out')),
            backgroundColor: activeColor,
          ),
        );
      }

      // Reset tab index to 0 (Home) before logging out
      if (context.mounted) {
        final tabIndexProvider = context.read<TabIndexProvider>();
        tabIndexProvider.updateIndex(0);
      }
    } catch (e) {
      if (context.mounted) {
        scaffold.showSnackBar(
          SnackBar(
            content: Center(child: Text('Logout failed: ${e.toString()}')),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavbarElementsAppbar(appBarTitle: 'Settings', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsSectionTitle(title: 'General'),
            ProfileListTile(
              icon: Icons.question_mark_rounded,
              title: 'FAQs',
              subtitle: 'Know more about the services',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FaqScreen(),
                  ),
                );
              },
            ),
            ProfileListTile(
              icon: Icons.call,
              title: 'Contact us',
              subtitle: 'Reach out for help',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContactUsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 5),
            SettingsSectionTitle(title: 'Account'),
            ProfileListTile(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Logout from your account',
              onTap: () => _showLogoutConfirmation(context),
            ),
            ProfileListTile(
              icon: Icons.delete,
              title: 'Delete Account',
              subtitle: 'Delete your account',
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
                            color: greyColor,
                            fontSize: 13,
                          ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
