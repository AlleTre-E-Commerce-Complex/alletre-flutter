import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<void> navigateToScreen(BuildContext context, int screenIndex) async {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Provider.of<TabIndexProvider>(context, listen: false).updateIndex(screenIndex);
  }
  
  static Future<void> pushScreen(BuildContext context, Widget screen) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static Future<void> pushReplacementScreen(BuildContext context, Widget screen) async {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static void pop(BuildContext context) {
    Navigator.of(context).pop();
  }
}