import 'package:alletre_app/model/user_model.dart';
import 'package:alletre_app/view/screens/auction%20screen/add_location_screen.dart';
import 'package:alletre_app/view/screens/item_details/item_details.dart';
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
import 'package:alletre_app/model/auction_item.dart';

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
      // case 13:
      //   return const SearchScreen();
      case 14:
        return const SettingsScreen();
      case 15:
        return const TermsAndConditions();
      case 16:
        return const ContactUsScreen();
      case 17:
        return ItemDetailsScreen(item: AuctionItem.empty(), title: '', user: UserModel.empty());
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
        );
      },
    );
  }
}