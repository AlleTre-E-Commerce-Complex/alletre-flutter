import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/common%20widgets/footer_elements_appbar.dart';
import 'package:alletre_app/view/widgets/profile%20widgets/user_profile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
                    // Add upload photo functionality here
                  },
                ),
                const SizedBox(height: 4),
                _buildSectionTitle('Personal Information', context),
                _buildProfileCard(
                  context,
                  label: 'Username',
                  value: user.name,
                  icon: Icons.person,
                  actionButton: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // Open dialog or text field to edit the username
                    },
                  ),
                  trailingIcon: Icons.add,
                  trailingAction: () {},
                ),
                const SizedBox(height: 16),
                _buildProfileCard(
                  context,
                  label: 'Primary Number',
                  value: user.phoneNumber,
                  icon: Icons.phone,
                  actionButton: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      // Add functionality to add another phone number
                    },
                  ),
                  trailingIcon: Icons.add,
                  trailingAction: () {},
                ),
                const SizedBox(height: 16),
                _buildProfileCard(
                  context,
                  label: 'Primary Email',
                  value: user.email,
                  icon: Icons.email,
                  actionButton: ElevatedButton(
                    onPressed: () {
                      // Add functionality to verify email
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: primaryColor),
                    child: const Text('Verify',
                        style: TextStyle(color: secondaryColor)),
                  ),
                  trailingIcon: Icons.add,
                  trailingAction: () {},
                ),
                Divider(height: 32, color: dividerColor),
                _buildCardSection(
                  context,
                  title: 'Address Book',
                  child: _buildEmptySection(
                    icon: Icons.add_location_alt,
                    text: 'No addresses yet!',
                    actionLabel: 'Add Address',
                    onTap: () {},
                  ),
                ),
                Divider(height: 32, color: dividerColor),
                _buildSectionTitle('Login Service', context),
                _buildLoginOption('assets/icons/apple_icon.svg',
                    'Connect with Apple', false, () {}),
                _buildLoginOption('assets/icons/google_icon.svg',
                    'Connect with Google', true, () {}),
                _buildLoginOption('assets/icons/facebook_icon.svg',
                    'Connect with Facebook', false, () {}),
                Divider(height: 32, color: dividerColor),
                _buildSectionTitle('Settings', context),
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

  Widget _buildProfileCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Widget actionButton,
    required IconData trailingIcon,
    required VoidCallback trailingAction,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width *
            0.9, // Sets width to 90% of screen width
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Icon(icon, color: avatarColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.bodySmall),
                    SizedBox(
                      height: 36,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(text: value),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 1.0, horizontal: 6.0),
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontSize: 14),
                            ),
                          ),
                          // Conditional rendering for each section

                          // If it's the Username section, show the Edit button
                          if (label == 'Username')
                            Padding(
                              padding: const EdgeInsets.only(left: 38.0),
                              child: Container(
                                width:
                                    36, // Set a specific width for the background container
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: primaryColor,
                                  shape: BoxShape.rectangle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.white, size: 21),
                                  onPressed: () {
                                    // Handle your action when the "edit" button is pressed
                                  },
                                ),
                              ),
                            ),

                          // If it's the Primary Number section, show the + button
                          if (label == 'Primary Number')
                            Padding(
                              padding: const EdgeInsets.only(left: 38.0),
                              child: Container(
                                width: 36,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color:
                                      primaryColor, // Background color for the button
                                  shape: BoxShape.rectangle, // Makes it round
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.add_ic_call_sharp,
                                      color: Colors.white, size: 20),
                                  onPressed: () {
                                    // Handle your action when the "+" button is pressed
                                  },
                                ),
                              ),
                            ),

                          // If it's the Primary Email section, show the Verify button
                          if (label == 'Primary Email')
                            Padding(
                              padding: const EdgeInsets.only(left: 13.0),
                              child: SizedBox(
                                width: 61, // Adjust the width of the button
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Add functionality to verify email
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          4), // Slight rounding for corners
                                    ),
                                    padding: EdgeInsets
                                        .zero, // Remove additional padding
                                  ),
                                  child: const Text(
                                    'Verify',
                                    style: TextStyle(
                                      color: secondaryColor,
                                      fontSize: 12, // Adjust the font size
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardSection(BuildContext context,
      {required String title, required Widget child}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildLoginOption(
      String svgPath, String label, bool isConnected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBgColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SvgPicture.asset(
              svgPath,
              width: 15,
              height: 15,
            ),
            Text(label, style: const TextStyle(fontSize: 14)),
            if (isConnected)
              const Icon(Icons.check_circle, color: Colors.green)
            else
              const Icon(Icons.link_outlined, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildEmptySection({
    required IconData icon,
    required String text,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Icon(icon, size: 48, color: avatarColor),
        const SizedBox(height: 8),
        Text(text, style: TextStyle(color: avatarColor)),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.add),
          label: Text(actionLabel),
          style: ElevatedButton.styleFrom(backgroundColor: buttonBgColor),
        ),
      ],
    );
  }
}
