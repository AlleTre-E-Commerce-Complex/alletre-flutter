import 'package:flutter/material.dart';

Color getStatusColor(String status) {
  switch (status) {
    case "WAITING_FOR_PAYMENT":
      return errorColor;
    case "EXPIRED":
      return const Color(0xFF9E9E9E);
    case "ACTIVE":
      return activeColor;
    case "IN_SCHEDULED":
      return scheduledColor;
    case "CANCELLED_BEFORE_EXP_DATE":
      return primaryColor;
    default:
      return const Color(0xFF757575);
  }
}

double getCardHeight(String title) {
  switch (title) {
    case "Live Auctions":
      return 337; // Taller to accommodate the countdown and the buttons
    case "Listed Products":
      return 333; // Tall enough for location and view details button
    case "Upcoming Auctions":
      return 288; // Bit shorter since no buttons
    default:
      return 248; // For expired auctions
  }
}

// Define color palette
const Color onSecondaryColor = Color(0xFF000000);
const Color primaryVariantColor = Color(0xFF5b0c1f);
const Color primaryColor = Color(0xFFa91d3a);
const Color surfaceColor = Color(0xFFc73659);
const Color secondaryColor = Color(0xFFFFFFFF);
const Color errorColor = Color(0xFFB91C1C);
const Color activeColor = Color(0xFF089F28);
const Color scheduledColor = Color(0xFFD57A0A);
const Color selectedIndex = Color(0xFFCDAF89);
Color buttonBgColor = Colors.grey.shade200;
Color borderColor = Colors.grey.shade300;
Color placeholderColor = Colors.grey.shade100;
Color avatarColor = Colors.grey.shade600;
Color dividerColor = Colors.black54;
const Color greyColor = Colors.grey;
final overlayColor = Color.alphaBlend(
  Colors.black.withAlpha(128), // Semi-transparent black
  Colors.transparent, // Base color
);
Color tiktokColor = const Color(0xFFEE1D52);
Color facebookColor = const Color(0xFF1877F2);
Color youtubeColor = const Color(0xFFFF0000);
Color instagramColor = const Color(0xFFE1306C);
Color telegramColor = const Color(0xFF0088CC);
Color whatsappColor = const Color(0xFF25D366);
Color snapchatColor = const Color(0xFFFFCC00);

const TextStyle radioTextStyle = TextStyle(
    fontSize: 14, color: onSecondaryColor, fontWeight: FontWeight.w500);

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
        displaySmall: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400, // Light
            fontSize: 14,
            color: onSecondaryColor),
        displayLarge: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 32,
            color: onSecondaryColor),
        displayMedium: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500, // Medium
            fontSize: 15,
            color: onSecondaryColor),
        bodyLarge: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500, // Regular
            fontSize: 16,
            color: onSecondaryColor),
        bodyMedium: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600, // Medium
            fontSize: 14,
            color: secondaryColor),
        bodySmall: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600, // Medium
            fontSize: 14,
            color: primaryColor),
        labelSmall: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500, // Regular
            fontSize: 12,
            color: onSecondaryColor),
        labelLarge: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600, // Medium
            fontSize: 10,
            color: primaryColor),
        titleMedium: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600, // Bold
            fontSize: 20,
            color: secondaryColor),
        titleLarge: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600, // Bold
          fontSize: 20,
          color: onSecondaryColor,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600, // Bold
          fontSize: 16,
          color: primaryColor,
        )),

    // Color scheme with errorColor
    colorScheme: ColorScheme.fromSwatch(
        primarySwatch: const MaterialColor(0xFFa91d3a, {
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
    bottomAppBarTheme: const BottomAppBarTheme(
      height: 72,
      color: primaryColor,
    ),

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
        borderSide: BorderSide(color: onSecondaryColor), // Default border color
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
            color: primaryColor), // Border color when focused (tapped)
      ),
      errorStyle: TextStyle(
        color: errorColor, // Error text color
        fontSize: 12, // Adjust font size for error text
        fontWeight: FontWeight.w500, // Medium weight for better visibility
      ),
    ),
  );
}
