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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.logout_sharp,
                color: greyColor,
                size: 64,
              ),
              const SizedBox(height: 24),
              const Text(
                'Confirm Logout?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  color: onSecondaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Yes',
                          style: TextStyle(color: secondaryColor, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              color: primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'No',
                          style: TextStyle(color: primaryColor, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldLogout != true) return;
    if (!context.mounted) return;

    final scaffold = ScaffoldMessenger.of(context);

    try {
      await context.read<UserProvider>().logout();

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );

        scaffold.showSnackBar(
          SnackBar(
            content: Center(child: Text('Successfully logged out')),
            backgroundColor: activeColor,
          ),
        );
      }

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

  Future<void> _showDeleteAccountConfirmation(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.logout_sharp,
                color: greyColor,
                size: 64,
              ),
              const SizedBox(height: 24),
              const Text(
                'Confirm Delete?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  color: onSecondaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Yes',
                          style: TextStyle(color: secondaryColor, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              color: primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'No',
                          style: TextStyle(color: primaryColor, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldDelete != true) return;
    if (!context.mounted) return;

    final scaffold = ScaffoldMessenger.of(context);

    try {
      await context.read<UserProvider>().logout();

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );

        scaffold.showSnackBar(
          SnackBar(
            content: Center(child: Text('Your account has been deleted')),
            backgroundColor: activeColor,
          ),
        );
      }

      if (context.mounted) {
        final tabIndexProvider = context.read<TabIndexProvider>();
        tabIndexProvider.updateIndex(0);
      }
    } catch (e) {
      if (context.mounted) {
        scaffold.showSnackBar(
          SnackBar(
            content: Center(child: Text('Failed to delete account: ${e.toString()}')),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavbarElementsAppbar(
          appBarTitle: 'Settings', showBackButton: true),
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
              onTap: () => _showDeleteAccountConfirmation(context),
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
