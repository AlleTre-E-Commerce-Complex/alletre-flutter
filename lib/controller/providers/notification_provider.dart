import 'package:alletre_app/controller/helpers/notification_service.dart';
import 'package:alletre_app/model/notification_item.dart';
import 'package:flutter/material.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationItem> notifications = [];
  final NotificationService _notificationService = NotificationService();
  fetchNotifications() async {
    try {
      notifications = await _notificationService.fetchNotifications();
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      notifyListeners();
    }
  }

  markAsRead() {
    _notificationService.markAsRead();
  }
}
