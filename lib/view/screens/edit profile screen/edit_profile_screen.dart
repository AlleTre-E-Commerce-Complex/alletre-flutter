import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileEditPage extends StatelessWidget {
  const ProfileEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: customTheme(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Profile', style: TextStyle(color: secondaryColor)),
          centerTitle: true,
          backgroundColor: primaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final user = userProvider.user;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: avatarColor,
                        child: const Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        user.name,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.link),
                      label: const Text("Link with UAE PASS"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                      ),
                    ),
                    Divider(height: 32, color: dividerColor),
                    _buildSectionTitle('Personal Information', context),
                    _buildEditableField(
                      context,
                      label: 'Primary Number',
                      value: user.phoneNumber,
                      icon: Icons.phone,
                      onEdit: (newValue) => userProvider.setPhoneNumber(newValue),
                    ),
                    _buildEditableField(
                      context,
                      label: 'Primary Email',
                      value: user.email,
                      icon: Icons.email,
                      onEdit: (newValue) => userProvider.setEmail(newValue),
                      actionButton: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                        child: const Text('Verify'),
                      ),
                    ),
                    Divider(height: 32, color: dividerColor),
                    _buildSectionTitle('Address Book', context),
                    _buildEmptySection(
                      icon: Icons.add_location_alt,
                      text: 'No addresses yet!',
                      actionLabel: 'Add Address',
                      onTap: () {},
                    ),
                    Divider(height: 32, color: dividerColor),
                    _buildSectionTitle('Traffic Profiles', context),
                    _buildEmptySection(
                      icon: Icons.person,
                      text: 'No traffic profiles yet!',
                      actionLabel: 'Add Traffic Profile',
                      onTap: () {},
                    ),
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
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildEditableField(BuildContext context,
      {required String label,
      required String value,
      required IconData icon,
      required Function(String) onEdit,
      Widget? actionButton}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: avatarColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                TextField(
                  controller: TextEditingController(text: value),
                  onChanged: onEdit,
                  decoration: const InputDecoration(border: InputBorder.none),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          if (actionButton != null) actionButton,
        ],
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
