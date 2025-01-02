import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/common%20widgets/footer_elements_appbar.dart';
import 'package:alletre_app/view/widgets/edit%20profile%20widgets/custom%20button%20widgets/add_phone_button.dart';
import 'package:alletre_app/view/widgets/edit%20profile%20widgets/custom%20button%20widgets/edit_name_button.dart';
import 'package:alletre_app/view/widgets/edit%20profile%20widgets/custom%20button%20widgets/verify_email_button.dart';
import 'package:alletre_app/view/widgets/edit%20profile%20widgets/edit_profile_card.dart';
import 'package:alletre_app/view/widgets/edit%20profile%20widgets/edit_profile_card_section.dart';
import 'package:alletre_app/view/widgets/edit%20profile%20widgets/edit_profile_empty_section.dart';
import 'package:alletre_app/view/widgets/edit%20profile%20widgets/edit_profile_login_option.dart';
import 'package:alletre_app/view/widgets/edit%20profile%20widgets/edit_profile_title.dart';
import 'package:alletre_app/view/widgets/profile%20widgets/user_profile_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavbarElementsAppbar(
          title: 'Edit Profile', showBackButton: true),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                UserProfileCard(
                  user: user,
                  buttonText: "Upload Photo",
                  onButtonPressed: () {
                    // upload photo functionality
                  },
                ),
                const SizedBox(height: 4),
                const EditProfileTitle(title: 'Personal Information'),
                EditProfileCard(
                  label: 'Username',
                  value: 'username',
                  icon: Icons.person,
                  actionButton: EditNameButton(
                    onPressed: () {
                      // Handle edit action
                    },
                  ),
                ),
                const SizedBox(height: 16),
                EditProfileCard(
                  label: 'Primary Number',
                  value: '123456789',
                  icon: Icons.phone,
                  actionButton: AddPhoneButton(
                    onPressed: () {
                      // Handle add phone action
                    },
                  ),
                ),
                const SizedBox(height: 16),
                EditProfileCard(
                  label: 'Primary Email',
                  value: 'user@gmail.com',
                  icon: Icons.email,
                  actionButton: VerifyEmailButton(
                    onPressed: () {
                      // Handle edit action
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Divider(height: 32, color: dividerColor, thickness: 0.5),
                const EditProfileTitle(title: 'Address Book'),
                EditProfileCardSection(
                  child: EditProfileEmptySection(
                    icon: Icons.add_location_alt,
                    text: 'No addresses yet!',
                    actionLabel: 'Add Address',
                    onTap: () {
                      // Add address functionality
                    },
                  ),
                ),
                const SizedBox(height: 14),
                Divider(height: 20, color: dividerColor, thickness: 0.5),
                const EditProfileTitle(title: 'Login Service'),
                EditProfileLoginOption(
                  svgPath: 'assets/icons/apple_icon.svg',
                  label: 'Connect with Apple',
                  isConnected: false,
                  onTap: () {},
                ),
                EditProfileLoginOption(
                  svgPath: 'assets/icons/google_icon.svg',
                  label: 'Connect with Google',
                  isConnected: true,
                  onTap: () {},
                ),
                EditProfileLoginOption(
                  svgPath: 'assets/icons/facebook_icon.svg',
                  label: 'Connect with Facebook',
                  isConnected: false,
                  onTap: () {},
                ),
                Divider(height: 32, color: dividerColor, thickness: 0.5),
                const EditProfileTitle(title: 'Settings'),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Change Password'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Delete my Account'),
                  onTap: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
