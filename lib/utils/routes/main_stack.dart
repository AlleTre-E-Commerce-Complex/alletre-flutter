import 'package:alletre_app/view/screens/auction%20screen/add_location_screen.dart';
import 'package:alletre_app/view/screens/auction%20screen/auction_details_screen.dart';
import 'package:alletre_app/view/screens/auction%20screen/payment_details_screen.dart';
import 'package:alletre_app/view/screens/auction%20screen/product_details_screen.dart';
import 'package:alletre_app/view/screens/auction%20screen/shipping_details_screen.dart';
import 'package:alletre_app/view/screens/categories%20screen/categories_page.dart';
import 'package:alletre_app/view/screens/contact%20screen/contact_screen.dart';
import 'package:alletre_app/view/screens/edit%20profile%20screen/add_address_screen.dart';
import 'package:alletre_app/view/screens/edit%20profile%20screen/edit_profile_screen.dart';
import 'package:alletre_app/view/screens/faqs%20screen/faqs_screen.dart';
import 'package:alletre_app/view/screens/list%20products%20screen/list_products_screen.dart';
import 'package:alletre_app/view/screens/login%20screen/login_page.dart';
import 'package:alletre_app/view/screens/onboarding%20screens/onboarding_pages.dart';
import 'package:alletre_app/view/screens/onboarding%20screens/onboarding_screen3.dart';
import 'package:alletre_app/view/screens/search%20screen/search_screen.dart';
import 'package:alletre_app/view/screens/settings%20screen/settings_screen.dart';
import 'package:alletre_app/view/screens/signup%20screen/signup_page.dart';
import 'package:alletre_app/view/screens/sub%20categories%20screen/sub_categories_screen.dart';
import 'package:alletre_app/view/screens/user%20terms%20screen/user_terms.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:alletre_app/view/screens/home%20screen/home_contents.dart';
import 'package:alletre_app/view/screens/purchases%20screen/purchases_screen.dart';
import 'package:alletre_app/view/screens/bids%20screen/bids_screen.dart';
import 'package:alletre_app/view/screens/profile%20screen/profile_screen.dart';

// class MainStack extends StatelessWidget {
//   const MainStack({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final PageController pageController = PageController();

//     return Consumer<TabIndexProvider>(
//       builder: (context, tabIndexProvider, _) {
//          // Add print statement for debugging
//         // ignore: avoid_print
//         print('Current index: ${tabIndexProvider.selectedIndex}');
        
//         return IndexedStack(
//           index: tabIndexProvider.selectedIndex,
//           children: [
//             const OnboardingPages(), //index 0
//             const HomeScreenContent(), // index 1
//             LoginPage(), // index 2
//             SignUpPage(), // index 3
//             const ProfileScreen(), // index 4
//             const FaqScreen(), // index 5
//             const EditProfileScreen(), // index 6
//             const PurchaseScreen(), // index 7
//             const BidsScreen(), // index 8
//             OnboardingPage3(pageController: pageController), // index 9
//             const ProductDetailsScreen(), // index 10
//             CategoriesPage(), // index 11
//             const SubCategoryPage(categoryName: "Default"), // index 12 
//             const SearchScreen(), // index 13
//             const SettingsScreen(), // index 14
//             const TermsAndConditions(), // index 15
//             const ContactUsScreen(), // index 16
//             const AuctionDetailsScreen(), //index 17
//             const ShippingDetailsScreen(), //index 18
//             const AddLocationScreen(), //index 19
//             const ListProductsScreen(), //index 20
//             const GoogleMapScreen(), //index 21
//             const PaymentDetailsScreen() //index 22
//           ],
//         );
//       },
//     );
//   }
// }

class MainStack extends StatelessWidget {
  const MainStack({super.key});

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const OnboardingPages();
      case 1:
        return const HomeScreenContent();
      case 2:
        return LoginPage();
      case 3:
        return SignUpPage();
      case 4:
        return const ProfileScreen();
      case 5:
        return const FaqScreen();
      case 6:
        return const EditProfileScreen();
      case 7:
        return const PurchaseScreen();
      case 8:
        return const BidsScreen();
      case 9:
        return OnboardingPage3(pageController: PageController());
      case 10:
        return const ProductDetailsScreen();
      case 11:
        return CategoriesPage();
      case 12:
        return const SubCategoryPage(categoryName: "Default");
      case 13:
        return const SearchScreen();
      case 14:
        return const SettingsScreen();
      case 15:
        return const TermsAndConditions();
      case 16:
        return const ContactUsScreen();
      case 17:
        return const AuctionDetailsScreen();
      case 18:
        return const ShippingDetailsScreen();
      case 19:
        return const AddLocationScreen();
      case 20:
        return const ListProductsScreen();
      case 21:
        return const GoogleMapScreen();
      case 22:
        return const PaymentDetailsScreen();
      default:
        return const HomeScreenContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TabIndexProvider>(
      builder: (context, tabIndexProvider, _) {
        // ignore: avoid_print
        print('Building MainStack with index: ${tabIndexProvider.selectedIndex}');
        return Scaffold(
          key: ValueKey(tabIndexProvider.selectedIndex),
          body: Navigator(
            key: GlobalKey<NavigatorState>(),
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (_) => _buildScreen(tabIndexProvider.selectedIndex),
              );
            },
          ),
          // bottomNavigationBar: BottomAppBar(
          //   color: Theme.of(context).bottomAppBarTheme.color,
          //   height: Theme.of(context).bottomAppBarTheme.height,
          //   child: Consumer<LoggedInProvider>(
          //     builder: (context, loginProvider, _) {
          //       return loginProvider.isLoggedIn
          //           ? NavBarUtils.buildAuthenticatedNavBar(
          //               context,
          //               onTabChange: (index) {
          //                 Navigator.of(context).popUntil((route) => route.isFirst);
          //                 tabIndexProvider.updateIndex(index);
          //               },
          //             )
          //           : const BottomNavBar();
          //     },
          //   ),
          // ),
        );
      },
    );
  }
}