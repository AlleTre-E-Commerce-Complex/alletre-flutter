import 'dart:convert';
import 'dart:ui';

import 'package:alletre_app/utils/constants/api_endpoints.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../utils/app_logger.dart';

final FlutterSecureStorage _storage = const FlutterSecureStorage();
final _localNotifications = FlutterLocalNotificationsPlugin();

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  try {
    final notification = message.notification;
    if (notification == null) return;
  } catch (err) {
    AppLogger.log.d('Error occurred while showing notification : handleBackgroundMessage');
    // print(err);
  }
}

Future<void> onMessageOpenedAppBackground(RemoteMessage? message) async {
  try {
    if (message != null) {}
  } catch (err) {
    AppLogger.log.d('Error occurred while showing notification : onMessageOpenedAppBackground');
    // print(err);
  }
}

Future<NotificationDetails> _notificationDetails() async {
  // ANDROID DETAILS
  AndroidNotificationDetails androidPlatformChannelSpecifics = const AndroidNotificationDetails(
    'alletre_notification', // Unique Channel ID
    'Alletre Notifications', // Channel Name
    channelDescription: 'This channel will show notifications from the Alletre service',
    importance: Importance.max,
    priority: Priority.max,
    playSound: true,
    ticker: 'ticker',
    // Ensure 'ic_launcher' is in the drawable folders
    icon: 'ic_launcher', 
    largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
    // Note: color is an Android specific setting
    color: Color.fromARGB(255, 243, 145, 33), 
  );

  // IOS DETAILS
  const DarwinNotificationDetails iosPlatformChannelSpecifics = DarwinNotificationDetails(
    // You can customize sound, presentAlert, presentBadge, presentSound here
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  NotificationDetails platformSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iosPlatformChannelSpecifics, // Add iOS details
  );
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

Future<void> initializedFirebaseNotification() async {
  final _firebaseMessaging = FirebaseMessaging.instance;
  try {
    AppLogger.log.d('--- Firebase permission request start ---');
    // 1. REQUEST PERMISSIONS (Crucial for iOS)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    AppLogger.log.d('User granted permission: ${settings.authorizationStatus}');

    // 2. SUBSCRIBER AND TOKEN RETRIEVAL
    _firebaseMessaging.subscribeToTopic('ALLETRENOTIFY');
    final tokenFcm = await _firebaseMessaging.getToken();

    // Call backend FCM Update endpoint
    // (Your existing backend logic is kept here)
    AppLogger.log.d('📤 Preparing FCM Token update request...');
    AppLogger.log.d('🌐 Parsed Request URL: ${ApiEndpoints.baseUrl}/notifications/save-token');

    var accessToken = await _storage.read(key: 'access_token');
    if (tokenFcm != null && accessToken != null) {
        final response = await http.post(
          Uri.parse('${ApiEndpoints.baseUrl}/notifications/save-token'),
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'},
          body: jsonEncode({'fcmToken': tokenFcm}),
        );
        AppLogger.log.d('\n=== FCM Update Response ===');
        AppLogger.log.d('Status Code: ${response.statusCode}');
        // AppLogger.log.d('Body: ${response.body}'); // Commented out for security/verbosity
        AppLogger.log.d('=====================\n');
    }

    // 3. LOCAL NOTIFICATIONS INITIALIZATION
    // Set presentation options for foreground notifications (needed for iOS)
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    
    // ANDROID INITIALIZATION
    const android = AndroidInitializationSettings('ic_launcher');
    
    // iOS INITIALIZATION
    const DarwinInitializationSettings ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // You can add a handler for when a notification is presented in the foreground here if needed.
    );
    
    final initSettings = InitializationSettings(android: android, iOS: ios);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveBackgroundNotificationResponse: onSelectNotification,
      onDidReceiveNotificationResponse: onSelectNotification,
    );

    // 4. FOREGROUND MESSAGE HANDLER
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      // You MUST use local notifications to display a notification when the app is in the foreground on iOS
      if (notification == null) return;
      try {
        AppLogger.log.d('FCM Foreground message received. Title: ${notification.title}');
        showLocalNotification(
          id: 0, 
          title: notification.title!, 
          body: notification.body!, 
          payload: jsonEncode(message.toMap()),
        );
      } catch (err) {
        AppLogger.log.d('Error occurred while showing local notification onMessage: $err');
      }
    });

    // 5. MESSAGE OPENED HANDLERS
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedAppBackground);
    FirebaseMessaging.instance.getInitialMessage().then(onMessageOpenedAppBackground);

    // 6. BACKGROUND MESSAGE HANDLER
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    
  } catch (err) {
    print('An error occurred during Firebase/Notification initialization: $err');
  }
}