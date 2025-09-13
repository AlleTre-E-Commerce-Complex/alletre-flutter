import 'package:alletre_app/controller/providers/login_state.dart';
import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/controller/services/auth_services.dart';
import 'package:alletre_app/controller/services/google_auth.dart';
import 'package:alletre_app/model/user_model.dart';
import 'package:alletre_app/utils/extras/navbar_utils.dart';
import 'package:alletre_app/view/screens/auction%20screen/add_location_screen.dart';
import 'package:alletre_app/view/screens/bids%20screen/bids_screen.dart';
import 'package:alletre_app/view/screens/item_details/item_details.dart';
import 'package:alletre_app/view/screens/auction%20screen/payment_details_screen.dart';
import 'package:alletre_app/view/screens/auction%20screen/product_details_screen.dart';
import 'package:alletre_app/view/screens/auction%20screen/shipping_details_screen.dart';
import 'package:alletre_app/view/screens/categories%20screen/categories_page.dart';
import 'package:alletre_app/view/screens/contact%20screen/contact_screen.dart';
import 'package:alletre_app/view/screens/edit%20profile%20screen/edit_profile_screen.dart';
import 'package:alletre_app/view/screens/faqs%20screen/faqs_screen.dart';
import 'package:alletre_app/view/screens/login%20screen/login_page.dart';
import 'package:alletre_app/view/screens/onboarding%20screens/onboarding_pages.dart';
import 'package:alletre_app/view/screens/onboarding%20screens/onboarding_screen3.dart';
import 'package:alletre_app/view/screens/purchases%20screen/purchases_screen.dart';
import 'package:alletre_app/view/screens/settings%20screen/settings_screen.dart';
import 'package:alletre_app/view/screens/signup%20screen/signup_page.dart';
import 'package:alletre_app/view/screens/sub%20categories%20screen/sub_categories_screen.dart';
import 'package:alletre_app/view/screens/user%20terms%20screen/user_terms.dart';
import 'package:alletre_app/view/widgets/home%20widgets/create_auction_button.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:alletre_app/view/screens/home%20screen/home_contents.dart';
import 'package:alletre_app/view/screens/profile%20screen/profile_screen.dart';
import 'package:alletre_app/model/auction_item.dart';
import '../../view/widgets/home widgets/bottom_navbar.dart';

class MainStack extends StatelessWidget {
  const MainStack({super.key});

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String createAuction = '/create-auction';
  static const String auctionDetails = '/auction-details';
  static const String paymentDetails = '/payment-details';
  static const String faqs = '/faqs';

  Widget _buildScreen(int index, bool isLoggedIn) {
    // // If not logged in, show splash screen first
    // if (!isLoggedIn && index == 0) {
    //   return const SplashScreen();
    // }

    switch (index) {
      case 0: // Home
        return const HomeScreenContent();
      case 1: // Purchases
        return const PurchaseScreen();
      case 2: // My Bids
        return const BidsScreen();
      case 3: // Profile
        return const ProfileScreen();
      // Other screens that can be navigated to from the main screens
      case 4:
        return const FaqScreen();
      case 5:
        return const EditProfileScreen();
      case 6:
        return const ProductDetailsScreen();
      case 7:
        return CategoriesPage();
      case 8:
        return const SubCategoryPage(categoryName: "Default");
      case 9:
        return const SettingsScreen();
      case 10:
        return const TermsAndConditions();
      case 11:
        return const ContactUsScreen();
      case 12:
        return ItemDetailsScreen(item: AuctionItem.empty(), title: '', user: UserModel.empty());
      case 13:
        return const ShippingDetailsScreen(auctionData: {}, imagePaths: []);
      case 14:
        return const AddLocationScreen();
      case 15:
      // return const ListProductsScreen();
      case 16:
        return const PaymentDetailsScreen(auctionData: {'message': 'Please create an auction first'});
      // Auth screens
      case 18:
        return LoginPage();
      case 19:
        return SignUpPage();
      case 20:
        return const OnboardingPages();
      case 21:
        return OnboardingPage3(pageController: PageController());
      default:
        return const HomeScreenContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TabIndexProvider>(
      builder: (context, tabIndexProvider, _) {
        final isLoggedIn = context.watch<LoggedInProvider>().isLoggedIn;
        final currentIndex = tabIndexProvider.selectedIndex;

        // Redirect to login if trying to access protected pages while not logged in
        if (!isLoggedIn && currentIndex > 0 && currentIndex < 4) {
          // Delay to avoid build phase issues
          Future.microtask(() {
            tabIndexProvider.updateIndex(18); // Login page index
          });
        } else if (isLoggedIn) {
          final userProvider = context.read<UserProvider>();
          final userAuthService = UserAuthService();
          if ((userProvider.displayEmail.isEmpty || userProvider.displayEmail.trim() == 'Add Email') && isLoggedIn) {
            userAuthService.getAuthMethod().then((authMethod) {
              if (authMethod == 'custom') {
                userAuthService.fetchUserInfoForAlreadyLoggedInUser().then((data) {
                  if (data.containsKey('id') == true) {
                    userProvider.setName(data['userName']);
                    userProvider.setEmail(data['email']);

                    PhoneNumber.getRegionInfoFromPhoneNumber(data['phone'].toString(), 'AE').then((val) {
                      userProvider.setPhoneNumber(val);
                    });
                  }
                });
              } else if (authMethod == 'google') {
                final GoogleAuthService _googleAuthService = GoogleAuthService();
                _googleAuthService.signInWithGoogle().then((userCredential) {
                  userProvider.setFirebaseUserInfo(userCredential!.user, 'google');
                });
              }
            });
          }
        }

        return Scaffold(
          body: IndexedStack(
            index: currentIndex,
            children: List.generate(
              22, // Total number of screens
              (index) => KeyedSubtree(
                key: ValueKey(index),
                child: _buildScreen(index, isLoggedIn),
              ),
            ),
          ),
          floatingActionButton: isLoggedIn ? const CreateAuctionButton() : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: isLoggedIn
              ? BottomNavBarUtils.buildAuthenticatedNavBar(
                  context,
                  onTabChange: (index) => tabIndexProvider.updateIndex(index),
                )
              : const BottomNavBar(),
        );
      },
    );
  }
}
