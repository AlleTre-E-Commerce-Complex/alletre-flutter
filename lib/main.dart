// ignore_for_file: avoid_print

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'app.dart';
import 'utils/extras/custom_timeago_messages.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:alletre_app/services/api/category_api_service.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('⭐ main(): WidgetsFlutterBinding initialized');

  // Initialize Firebase
  print('⭐ main(): Initializing Firebase...');
  await Firebase.initializeApp();
  print('⭐ main(): Firebase initialized');

  // Initialize Stripe with test key
  print('⭐ main(): Setting Stripe publishable key...');
  Stripe.publishableKey = 'pk_test_51PjvreLb7rADQxlhNguFowjeUKGOe8vrgmoKbPboIuSfDF2KiqdevkpElFb6QIO7RVeBST80waLymed3v62w91Eh00YXNr6FRC';
  print('⭐ main(): Applying Stripe settings...');
  await Stripe.instance.applySettings();
  print('⭐ main(): Stripe initialized');

  // Setup Dio interceptors for global token refresh/logout logic
  print('⭐ main(): Setting up ApiService interceptors...');
  ApiService.setupInterceptors();
  print('⭐ main(): ApiService interceptors set up');

  // Initialize categories
  print('⭐ main(): Initializing categories...');
  try {
    await CategoryApiService.initCategories()
        .timeout(const Duration(seconds: 10));
    print('⭐ main(): Categories initialized');
  } catch (e, stack) {
    print('❌ main(): Failed to initialize categories: $e');
    print(stack);
  }

  print('⭐ main(): Setting timeago locale messages...');
  timeago.setLocaleMessages('en_custom', CustomTimeagoMessages());
  print('⭐ main(): Running app...');
  runApp(const MyApp());
}
