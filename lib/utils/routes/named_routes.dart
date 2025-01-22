import 'package:alletre_app/view/screens/auction%20screen/auction_details_screen.dart';
import 'package:alletre_app/view/screens/auction%20screen/product_details_screen.dart';
import 'package:alletre_app/view/screens/bids%20screen/bids_screen.dart';
import 'package:alletre_app/view/screens/categories%20screen/categories_page.dart';
import 'package:alletre_app/view/screens/edit%20profile%20screen/edit_profile_screen.dart';
import 'package:alletre_app/view/screens/home%20screen/home_screen.dart';
import 'package:alletre_app/view/screens/login%20screen/login_page.dart';
import 'package:alletre_app/view/screens/onboarding%20screens/onboarding_pages.dart';
import 'package:alletre_app/view/screens/onboarding%20screens/onboarding_screen3.dart';
import 'package:alletre_app/view/screens/profile%20screen/profile_screen.dart';
import 'package:alletre_app/view/screens/purchases%20screen/purchases_screen.dart';
import 'package:alletre_app/view/screens/search%20screen/search_screen.dart';
import 'package:alletre_app/view/screens/signup%20screen/signup_page.dart';
import 'package:alletre_app/view/screens/splash%20screen/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  // Defining named routes
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String onboarding3 = '/onboarding3';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String home = '/home';
  static const String productDetails = '/productDetails';
  static const String auctionDetails = '/auctionDetails';
  static const String search = '/search';
  static const String purchases = '/purchases';
  static const String bids = '/bids';
  static const String profile = '/profile';
  static const String editProfile = '/editProfile';
  static const String categories = '/categories';

  // Static method to define all the routes in one place
  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      onboarding: (context) => const OnboardingPages(),
      onboarding3: (context) {
        final PageController pageController = PageController();
        return OnboardingPage3(pageController: pageController);
      },
      signup: (context) => SignUpPage(),
      login: (context) => LoginPage(),
      home: (context) => const HomeScreen(),
      productDetails: (context) => const ProductDetailsScreen(),
      // auctionDetails: (context) => const AuctionDetailsScreen(),
      search: (context) => const SearchScreen(),
      purchases: (context) => const PurchaseScreen(),
      bids: (context) => const BidsScreen(),
      profile: (context) => const ProfileScreen(),
      editProfile : (context) => const EditProfileScreen(),
      categories : (context) => CategoriesPage()
    };
  }
}
