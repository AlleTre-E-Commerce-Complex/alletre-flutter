import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationItem {
  final int id;
  final int userId;
  final String message;
  final String productTitle;
  final String imageLink;
  final int auctionId;
  final bool isRead;
  final DateTime createdAt;
  final IconData icon;
  final MaterialColor iconColor;

  NotificationItem({
    required this.id,
    required this.userId,
    required this.message,
    required this.productTitle,
    required this.imageLink,
    required this.auctionId,
    required this.isRead,
    required this.createdAt,
    required this.icon,
    required this.iconColor,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
        id: json['id'] as int,
        userId: json['userId'] as int,
        message: json['message'] as String,
        productTitle: json['productTitle'] as String,
        imageLink: json['imageLink'] as String,
        auctionId: json['auctionId'] as int,
        isRead: json['isRead'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
        icon: json['icon'] as IconData,
        iconColor: json['iconColor'] as MaterialColor);
  }
}
