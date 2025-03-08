import 'package:alletre_app/controller/providers/auction_image_provider.dart';
import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/contact_provider.dart';
import 'package:alletre_app/controller/providers/share_provider.dart';
import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:alletre_app/controller/providers/category_state.dart';
import 'package:alletre_app/controller/providers/focus_state_provider.dart';
import 'package:alletre_app/controller/providers/language_provider.dart';
import 'package:alletre_app/controller/providers/location_provider.dart';
import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/controller/providers/wishlist_provider.dart';
import 'package:alletre_app/controller/services/auth_services.dart';
import 'package:alletre_app/utils/routes/main_stack.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'controller/providers/login_state.dart';
import 'view/screens/home screen/home_contents.dart';
import 'view/screens/login screen/login_page.dart';
import 'view/screens/splash screen/splash_screen.dart';

class MyApp extends StatelessWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();

  const MyApp({super.key});

  Future<Widget> getInitialScreen() async {
    try {
      final appLinks = AppLinks();
      final initialUri = await appLinks.getInitialLink();

      if (initialUri != null &&
          initialUri.scheme == 'alletre' &&
          initialUri.path == 'login') {
        return LoginPage();
      }

      // Then check authentication status
    final userAuthService = UserAuthService();
    final isAuthenticated = await userAuthService.isAuthenticated();
    final hasCompletedOnboarding = await userAuthService.hasCompletedOnboarding();
    
    if (isAuthenticated) {
      // User is authenticated, go straight to home
      // Also set LoggedInProvider to logged in
      Provider.of<LoggedInProvider>(navigatorKey.currentContext!, listen: false).logIn();
      Provider.of<TabIndexProvider>(navigatorKey.currentContext!, listen: false).updateIndex(1);
      return const HomeScreenContent();
    } else if (hasCompletedOnboarding) {
      // User has seen onboarding but is not logged in, go to login
      return LoginPage();
    } else {
      // New user, show onboarding
      return const SplashScreen();
    }

    } catch (e) {
      debugPrint('Error handling deep link: $e');
    }
    return const SplashScreen();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: secondaryColor,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: secondaryColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => UserProvider()),
          ChangeNotifierProvider(create: (context) => AuctionProvider()..initializeSocket()),
          // ChangeNotifierProvider(create: (context) => AuctionDetailsProvider()),
          ChangeNotifierProvider(create: (context) => LanguageProvider()),
          ChangeNotifierProvider(create: (context) => CategoryState()),
          ChangeNotifierProvider(create: (_) => FocusStateNotifier()),
          // ChangeNotifierProvider(create: (context) => SearchProvider()),
          ChangeNotifierProvider(create: (_) => TabIndexProvider()),
          ChangeNotifierProvider(create: (_) => LoggedInProvider()),
          ChangeNotifierProvider(create: (_) => LocationProvider()),
          ChangeNotifierProvider(create: (_) => ShareProvider()),
          ChangeNotifierProvider(create: (_) => AuctionImageProvider()),
          ChangeNotifierProvider(create: (_) => WishlistProvider()),
          ChangeNotifierProvider(create: (_) => ContactButtonProvider()),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Alletre',
          theme: customTheme(),
          debugShowCheckedModeBanner: false,
          home: FutureBuilder<Widget>(
            future: getInitialScreen(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }
              return snapshot.data ?? const MainStack();
            },
          ),
        ),
      ),
    );
  }
}