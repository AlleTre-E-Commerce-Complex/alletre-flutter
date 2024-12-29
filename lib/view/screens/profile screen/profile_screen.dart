import 'package:alletre_app/model/user_model.dart';
import 'package:alletre_app/utils/extras/common_navbar.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/common%20widgets/footer_elements_appbar.dart';
import 'package:alletre_app/view/widgets/profile%20widgets/profile_list_tile.dart';
import 'package:alletre_app/view/widgets/profile%20widgets/profile_section_title.dart';
import 'package:alletre_app/view/widgets/profile%20widgets/user_profile_card.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserModel(
      name: "Fahad TT",
      email: "fahad@example.com",
      phoneNumber: "+1234567890",
      profileImagePath: null, // Initially empty
    );

    return Scaffold(
      appBar: const NavbarElementsAppbar(title: 'Profile'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _buildSectionTitle('Your updates', context),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     _buildQuickActionTile(
            //       title: 'Watchlist',
            //       subtitle: 'Your favorites and lists',
            //       onTap: () {},
            //     ),
            //     _buildQuickActionTile(
            //       title: 'Bids & offers',
            //       subtitle: 'Active auctions and seller offers',
            //       onTap: () {},
            //     ),
            //   ],
            // ),
            const SizedBox(height: 4),
            UserProfileCard(user: user),
            const SizedBox(height: 4),
            const ProfileSectionTitle(title: 'Shopping'),
            ProfileListTile(
              icon: Icons.favorite_border,
              title: 'Watchlist',
              subtitle: 'Keep tabs on watched items',
              onTap: () {},
            ),
            ProfileListTile(
              icon: Icons.sell_outlined,
              title: 'Selling',
              subtitle: 'View the selling items',
              onTap: () {},
            ),
            ProfileListTile(
              icon: Icons.gavel,
              title: 'Bids & offers',
              subtitle: 'Active auctions and seller offers',
              onTap: () {},
            ),
            ProfileListTile(
              icon: Icons.visibility_outlined,
              title: 'Recently viewed',
              subtitle: 'Listings you recently viewed',
              onTap: () {},
            ),
            Divider(color: dividerColor, thickness: 0.5),
            const ProfileSectionTitle(title: 'Account'),
            ProfileListTile(
              icon: Icons.help_outline,
              title: 'Help',
              subtitle: 'Let us know your queries',
              onTap: () {},
            ),
            ProfileListTile(
              icon: Icons.settings,
              title: 'Settings',
              subtitle: 'View more settings',
              onTap: () {},
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).bottomAppBarTheme.color,
        height: Theme.of(context).bottomAppBarTheme.height,
        child: NavBarUtils.buildAuthenticatedNavBar(context),
      ),
    );
  }

  // Widget _buildQuickActionTile({
  //   required String title,
  //   required String subtitle,
  //   required VoidCallback onTap,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       width: 160,
  //       padding: const EdgeInsets.all(12.0),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(8),
  //         color: buttonBgColor,
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             title,
  //             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //           ),
  //           const SizedBox(height: 4),
  //           Text(
  //             subtitle,
  //             style: const TextStyle(fontSize: 12, color: Colors.grey),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
