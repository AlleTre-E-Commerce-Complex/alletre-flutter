import 'package:alletre_app/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'utils/extras/custom_timeago_messages.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  timeago.setLocaleMessages('en_custom', CustomTimeagoMessages());
  runApp(const MyApp());
}
