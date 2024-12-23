import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/utils/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'controller/providers/language_provider.dart';
import 'controller/providers/search_provider.dart';
import 'utils/navigation/named_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: secondaryColor,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: secondaryColor, // Navigation bar color
        systemNavigationBarIconBrightness:
            Brightness.dark, // Navigation bar icon color
      ),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => UserProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => AuctionProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => LanguageProvider(),
          ),
          ChangeNotifierProvider(create: (context) => SearchProvider())
        ],
        child: MaterialApp(
          title: 'Alletre',
          theme: customTheme(),
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.splash,
          routes: AppRoutes.routes,
        ),
      ),
    );
  }
}
