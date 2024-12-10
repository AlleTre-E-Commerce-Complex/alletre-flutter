import 'package:flutter/material.dart';

// Define color palette
const Color onSecondaryColor = Color(0xFF000000);
const Color primaryVariantColor = Color(0xFF5b0c1f);
const Color primaryColor = Color(0xFFa91d3a);
const Color surfaceColor = Color(0xFFc73659);
const Color secondaryColor = Color(0xFFFFFFFF);
const Color errorColor = Color(0xFFe40909);
const Color activeColor = Color(0xFF089F28);
const Color scheduledColor = Color(0xFFD57A0A);

ThemeData customTheme() {
  return ThemeData(
    primaryColor: primaryColor,
    primaryColorDark: primaryVariantColor,
    primaryColorLight: surfaceColor,
    splashColor: secondaryColor,
    hintColor: surfaceColor,
    fontFamily: 'Montserrat',

    // Define text styles
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 32, color: onSecondaryColor),
      displayMedium: TextStyle(
          fontWeight: FontWeight.w600, fontSize: 28, color: onSecondaryColor),
      bodyLarge: TextStyle(
          fontWeight: FontWeight.w400, fontSize: 16, color: onSecondaryColor),
      bodyMedium: TextStyle(
          fontWeight: FontWeight.w300, fontSize: 14, color: onSecondaryColor),
      bodySmall: TextStyle(
          fontWeight: FontWeight.w300, fontSize: 12, color: onSecondaryColor),
      labelLarge: TextStyle(
          fontWeight: FontWeight.w600, fontSize: 18, color: secondaryColor),
      titleLarge: TextStyle(
          fontWeight: FontWeight.w700, fontSize: 24, color: onSecondaryColor),
    ),

    // Color scheme with errorColor
    colorScheme: ColorScheme.fromSwatch(
        primarySwatch: MaterialColor(primaryColor.value, const {
      50: primaryColor,
      100: primaryColor,
      200: primaryColor,
      300: primaryColor,
      400: primaryColor,
      500: primaryColor,
      600: primaryColor,
      700: primaryColor,
      800: primaryColor,
      900: primaryColor,
    })).copyWith(
      error: errorColor,
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      titleTextStyle: TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: secondaryColor),
      iconTheme: IconThemeData(color: secondaryColor),
    ),

    // Button Theme
    buttonTheme: ButtonThemeData(
      buttonColor: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textTheme: ButtonTextTheme.primary,
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Bottom App Bar Theme
    bottomAppBarTheme: const BottomAppBarTheme(color: surfaceColor),

    // Input Decoration Theme
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: secondaryColor,
      hintStyle: TextStyle(color: onSecondaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor),
      ),
    ),
  );
}
