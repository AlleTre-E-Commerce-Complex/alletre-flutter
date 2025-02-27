import 'package:alletre_app/app.dart';
import 'package:flutter/material.dart';
import 'utils/extras/custom_timeago_messages.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:alletre_app/services/api/category_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize categories
  await CategoryApiService.initializeCategories();
  
  timeago.setLocaleMessages('en_custom', CustomTimeagoMessages());
  runApp(const MyApp());
}
