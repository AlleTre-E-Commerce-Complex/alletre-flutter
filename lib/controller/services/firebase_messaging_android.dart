import 'dart:convert';
import 'dart:ui';

import 'package:alletre_app/utils/constants/api_endpoints.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

final FlutterSecureStorage _storage = const FlutterSecureStorage();
final _localNotifications = FlutterLocalNotificationsPlugin();

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  try {
    final notification = message.notification;
    if (notification == null) return;
  } catch (err) {
    debugPrint('Error occurred while showing notification : handleBackgroundMessage');
    // print(err);
  }
}

Future<void> onMessageOpenedAppBackground(RemoteMessage? message) async {
  try {
    if (message != null) {}
  } catch (err) {
    debugPrint('Error occurred while showing notification : onMessageOpenedAppBackground');
    // print(err);
  }
}

Future<NotificationDetails> _notificationDetails() async {
  AndroidNotificationDetails androidPlatformChannelSpecifics = const AndroidNotificationDetails('parco_notification', 'Parco Notifications',
      groupKey: 'com.example.parco_admin_mobile',
      channelDescription: 'This channel will show notifications from Parco Admin service',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      ticker: 'ticker',
      icon: 'app_icon_launcher',
      largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
      color: Color.fromARGB(255, 243, 145, 33));
  NotificationDetails platformSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
  return platformSpecifics;
}

Future<void> showLocalNotification({required int id, required String title, required String body, required String payload}) async {
  final platformSpecifics = await _notificationDetails();
  await _localNotifications.show(id, title, body, platformSpecifics, payload: payload);
}

onSelectNotification(NotificationResponse notificationResponse) async {
  try {} on Exception catch (err) {
    print(err);
  }
}

initializedFirebaseNotification() async {
  final _firebaseMessaging = FirebaseMessaging.instance;
  try {
    _firebaseMessaging.subscribeToTopic('ALLETRENOTIFY');
    await _firebaseMessaging.requestPermission();
    final tokenFcm = await _firebaseMessaging.getToken();

    // Call backend FCM Update endpoint
    debugPrint('📤 Preparing FCM Token update request...');
    debugPrint('Base URL: ${ApiEndpoints.baseUrl}');
    debugPrint('🌐 Parsed Request URL: ${ApiEndpoints.baseUrl}/notifications/save-token');

    var accessToken = await _storage.read(key: 'access_token');
    final response = await http.post(
      Uri.parse('${ApiEndpoints.baseUrl}/notifications/save-token'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'},
      body: jsonEncode({'fcmToken': tokenFcm}),
    );

    debugPrint('\n=== FCM Update Response ===');
    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Headers: ${response.headers}');
    debugPrint('Body: ${response.body}');
    debugPrint('=====================\n');

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    const android = AndroidInitializationSettings('ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveBackgroundNotificationResponse: onSelectNotification,
      onDidReceiveNotificationResponse: onSelectNotification,
    );

    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      try {
        showLocalNotification(id: 0, title: notification.title!, body: notification.body!, payload: jsonEncode(message.toMap()));
      } catch (err) {
        print('Error occurred while showing notitfication onMessage');
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedAppBackground);
    FirebaseMessaging.instance.getInitialMessage().then(onMessageOpenedAppBackground);

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  } catch (err) {
    print(err);
  }
}
