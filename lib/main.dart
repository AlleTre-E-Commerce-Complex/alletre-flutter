import 'package:alletre_app/app.dart';
import 'package:flutter/material.dart';
import 'utils/custom_timeago_messages.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  timeago.setLocaleMessages('en_custom', CustomTimeagoMessages());
  runApp(const MyApp());
}
