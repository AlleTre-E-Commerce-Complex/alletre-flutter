import 'package:alletre_app/controller/providers/auction_details_provider.dart';
import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/bottom_navbar_provider.dart';
import 'package:alletre_app/controller/providers/category_state.dart';
import 'package:alletre_app/controller/providers/focus_state_provider.dart';
import 'package:alletre_app/controller/providers/language_provider.dart';
import 'package:alletre_app/controller/providers/location_provider.dart';
import 'package:alletre_app/controller/providers/search_provider.dart';
import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/utils/routes/named_routes.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/screens/splash%20screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'controller/providers/login_state.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
          ChangeNotifierProvider(create: (context) => AuctionProvider()),
          ChangeNotifierProvider(create: (context) => AuctionDetailsProvider()),
          ChangeNotifierProvider(create: (context) => LanguageProvider()),
          ChangeNotifierProvider(create: (context) => CategoryState()),
          ChangeNotifierProvider(create: (_) => FocusStateNotifier()),
          ChangeNotifierProvider(create: (context) => SearchProvider()),
          ChangeNotifierProvider(create: (_) => TabIndexProvider()),
          ChangeNotifierProvider(create: (_) => LoggedInProvider()),
          ChangeNotifierProvider(create: (_) => LocationProvider()),
        ],
        child: Consumer<LoggedInProvider>(
          builder: (context, loggedInProvider, _) {
            return MaterialApp(
              title: 'Alletre',
              theme: customTheme(),
              debugShowCheckedModeBanner: false,
              routes: AppRoutes.routes,
              home: const SplashScreen(),
            );
          },
        ),
      ),
    );
  }
}