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
Color buttonBgColor = Colors.grey.shade200;

ThemeData customTheme() {
  return ThemeData(
    primaryColor: primaryColor,
    primaryColorDark: primaryVariantColor,
    primaryColorLight: surfaceColor,
    splashColor: secondaryColor,
    hintColor: surfaceColor,
    fontFamily: 'Montserrat',

    // Define text styles using specific Montserrat font weights
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.bold, 
        fontSize: 32, 
        color: onSecondaryColor
      ),
      displayMedium: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w500, // Medium
        fontSize: 14,
        color: onSecondaryColor
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w400, // Regular
        fontSize: 16, 
        color: onSecondaryColor
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w600, // Light
        fontSize: 14,
        color: secondaryColor
      ),
      bodySmall: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w600, // Medium
        fontSize: 14,
        color: primaryColor
      ),
      labelLarge: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w600, // Medium
        fontSize: 10,
        color: primaryColor
      ),
      titleLarge: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w700, // Bold
        fontSize: 24, 
        color: onSecondaryColor
      ),
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

    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Bottom App Bar Theme
    bottomAppBarTheme: const BottomAppBarTheme(color: primaryColor),

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
