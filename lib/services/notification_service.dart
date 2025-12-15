import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level background handler for FCM messages.
/// Must be a global function and annotated as an entry-point so it works
/// after tree-shaking in release builds.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🔔 [BG] Message ID: ${message.messageId}, data: ${message.data}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Register the background handler once, early in app startup.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request notification permissions (iOS + Android 13+).
    await _requestPermissions();

    // Initialize flutter_local_notifications for foreground banners.
    await _initLocalNotifications();

    // Log and expose the FCM token so it can be copied.
    final token = await _messaging.getToken();
    debugPrint('📱 FCM Device Token: $token');

    // Listen for foreground messages and show local notification.
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  Future<void> _requestPermissions() async {
    // iOS / macOS specific permission request
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Android 13+: Permission is handled via firebase_messaging + manifest.
    // No explicit runtime call is usually required beyond this on Android,
    // but this call ensures consistency across platforms.
    if (Platform.isAndroid) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final android = notification?.android;

    // If there is no notification payload, skip showing a banner.
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'fcm_default_channel',
      'Push Notifications',
      channelDescription: 'Notifications for real-time game updates',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title ?? 'Notification',
      notification.body ?? '',
      notificationDetails,
      payload: message.data.toString(),
    );

    if (kDebugMode) {
      debugPrint('🔔 [FG] Message: ${notification.title} - ${notification.body}');
    }
  }
}
