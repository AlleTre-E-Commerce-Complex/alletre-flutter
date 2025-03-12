import 'package:alletre_app/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'utils/extras/custom_timeago_messages.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:alletre_app/services/api/category_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize categories and subcategories
  await CategoryApiService.initCategories();
  // Initialize subcategories for Electronics (ID: 1)
  await CategoryApiService.initSubCategories(1);

  timeago.setLocaleMessages('en_custom', CustomTimeagoMessages());
  runApp(const MyApp());
}
