import 'package:alletre_app/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'utils/extras/custom_timeago_messages.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:alletre_app/services/api/category_api_service.dart';
import 'services/api_service.dart';

void main() async {  
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Stripe with test key
  Stripe.publishableKey = 'pk_test_51PjvreLb7rADQxlhNguFowjeUKGOe8vrgmoKbPboIuSfDF2KiqdevkpElFb6QIO7RVeBST80waLymed3v62w91Eh00YXNr6FRC';
  await Stripe.instance.applySettings();

  // Setup Dio interceptors for global token refresh/logout logic
  ApiService.setupInterceptors();

  // Initialize categories
  await CategoryApiService.initCategories();

  timeago.setLocaleMessages('en_custom', CustomTimeagoMessages());
  runApp(const MyApp());
}
