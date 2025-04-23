import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareProvider with ChangeNotifier {
  Future<void> shareApp(BuildContext context) async {
    try {
      const String shareMessage = 
          "Check out this amazing bidding app! Download now: https://www.alletre.com";
      
      await Share.share(
        shareMessage,
        subject: 'Check out this app!',
      );
    } catch (e) {
      // Show error message to user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to share: ${e.toString()}'),
            backgroundColor: errorColor,
          ),
        );
      }
      debugPrint('Share error: $e');
    }
  }
}