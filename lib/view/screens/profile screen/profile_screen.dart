import 'package:alletre_app/app.dart';
import 'package:alletre_app/controller/providers/share_provider.dart';
import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/controller/services/auth_services.dart';
import 'package:alletre_app/model/user_model.dart';
import 'package:alletre_app/view/screens/my%20auctions%20screen/my_auctions_screen.dart';
import 'package:alletre_app/view/screens/my%20products%20screen/my_products.dart';
import 'package:alletre_app/view/screens/privacy%20policy%20screen/privacy_policy_screen.dart';
import 'package:alletre_app/view/screens/settings%20screen/settings_screen.dart';
import 'package:alletre_app/view/screens/user%20terms%20screen/user_terms.dart';
import 'package:alletre_app/view/widgets/common%20widgets/footer_elements_appbar.dart';
import 'package:alletre_app/view/widgets/profile%20widgets/profile_list_tile.dart';
import 'package:alletre_app/view/widgets/profile%20widgets/profile_section_title.dart';
import 'package:alletre_app/view/widgets/profile%20widgets/user_profile_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../draft screen/draft_screen.dart';
import '../edit profile screen/edit_profile_screen.dart';
import '../wishlist screen/wishlist_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String? title;

  const ProfileScreen({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    final user = UserModel(
      name: "Username",
      email: "email",
      phoneNumber: "+1234567890",
      profileImagePath: null, // Initially empty
    );

    return Scaffold(
      appBar: const NavbarElementsAppbar(appBarTitle: 'Profile'),
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
            UserProfileCard(
              user: user,
              buttonText: "Edit Profile",
              onButtonPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
              },
            ),
            const SizedBox(height: 4),
            const ProfileSectionTitle(title: 'Shopping'),
            ProfileListTile(
              icon: Icons.bookmark_outline,
              title: 'Wishlist',
              subtitle: 'Save and track your favorite items',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => WishlistScreen(title: title ?? '', user: UserModel.empty())));
              },
            ),
            ProfileListTile(
              icon: Icons.sell_outlined,
              title: 'My Auctions',
              subtitle: 'Manage your auction listings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyAuctionsScreen(),
                  ),
                );
              },
            ),
            // ProfileListTile(
            //   icon: Icons.gavel,
            //   title: 'My Bids',
            //   subtitle: 'Check the status of your bids',
            //   onTap: () {},
            // ),
            ProfileListTile(
              icon: Icons.inventory_2_outlined,
              title: 'My Products',
              subtitle: 'Manage your selling items',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyProductsScreen(),
                  ),
                );
              },
            ),
            // ProfileListTile(
            //   icon: Icons.shopping_cart_outlined,
            //   title: 'My Purchases',
            //   subtitle: 'View order history and details',
            //   onTap: () {},
            // ),
            ProfileListTile(
              icon: Icons.drafts_outlined,
              title: 'My Drafts',
              subtitle: 'View your drafted items',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DraftsPage(user: user)));
              },
            ),
            const ProfileSectionTitle(title: 'About'),
            ProfileListTile(
              icon: Icons.policy,
              title: 'Privacy Policy',
              subtitle: 'Know how we protect your data',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
              },
            ),
            ProfileListTile(
              icon: Icons.document_scanner,
              title: 'Terms and Conditions',
              subtitle: 'Know the company terms',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsAndConditions()));
              },
            ),
            // ProfileListTile(
            //   icon: Icons.help_outline,
            //   title: 'FAQs',
            //   subtitle: 'Know more about the services',
            //   onTap: () {
            //     Navigator.push(context,
            //         MaterialPageRoute(builder: (context) => const FaqScreen()));
            //   },
            // ),
            ProfileListTile(
              icon: FontAwesomeIcons.shareFromSquare,
              title: 'Share App',
              subtitle: 'Let your network know about us',
              onTap: () {
                context.read<ShareProvider>().shareApp(context);
              },
            ),
            ProfileListTile(
              icon: Icons.settings,
              title: 'Settings',
              subtitle: 'View more settings',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
