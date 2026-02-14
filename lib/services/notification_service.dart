import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:inkbattle_frontend/utils/routes/routes.dart';
import 'package:inkbattle_frontend/services/native_log_service.dart';

/// Top-level background handler for FCM messages.
/// Must be a global function and annotated as an entry-point so it works
/// after tree-shaking in release builds.
const String _logTag = 'NotificationService';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  NativeLogService.log(
    'Background message: ${message.messageId}, data: ${message.data}',
    tag: _logTag,
    level: 'debug',
  );
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  GlobalKey<NavigatorState>? _navigatorKey;
  GoRouter? _router;

  /// Set the navigator key for navigation handling
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  /// Set the router for navigation handling
  void setRouter(GoRouter router) {
    _router = router;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      // Initialize Timezone
      tz.initializeTimeZones();

      // Register the background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Request notification permissions
      await _requestPermissions();

      // Initialize local notifications with tap handler
      await _initLocalNotifications();

      // Handle notification taps when app is opened from terminated state
      _messaging.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          NativeLogService.log(
            'App opened from notification: ${message.messageId}',
            tag: _logTag,
            level: 'debug',
          );
          _navigateToHome();
        }
      });

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        NativeLogService.log(
          'Notification tapped (background): ${message.messageId}',
          tag: _logTag,
          level: 'debug',
        );
        _navigateToHome();
      });

      // Log and expose the FCM token
      // The white screen often happens here if entitlements are missing
      final token = await _messaging.getToken();
      NativeLogService.log(
        'FCM Device Token: $token',
        tag: _logTag,
        level: 'debug',
      );

      // Listen for foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    } catch (e) {
      // This catch block prevents the "White Screen" by allowing main() to finish
      NativeLogService.log(
        'Notification initialization failed: $e',
        tag: _logTag,
        level: 'error',
      );
    }
  }

  // NEW METHOD: Schedule the 24-hour reminder
  Future<void> schedule24HourReminder() async {
    // Cancel old ones so we don't spam the user
    await _flutterLocalNotificationsPlugin.cancel(101); 

    // Set time for 24 hours from now
    final scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(hours: 24));

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      channelDescription: 'Reminds you to play InkBattle',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      101, // Unique ID
      'The arena is calling! 🎨',
      'Come back and claim your daily spot in InkBattle.',
      scheduledDate,
      const NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails()),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'local_reminder', // Payload to identify local notifications
    );
    NativeLogService.log(
      'Reminder scheduled for: $scheduledDate',
      tag: _logTag,
      level: 'debug',
    );
  }

  // NEW METHOD: Clear notifications when user opens app
  Future<void> cancelAllReminders() async {
    await _flutterLocalNotificationsPlugin.cancel(101);
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

    // Handle notification taps (both local and push notifications)
    void onDidReceiveNotificationResponse(NotificationResponse response) {
      NativeLogService.log(
        'Notification tapped: ${response.id} - ${response.payload}',
        tag: _logTag,
        level: 'debug',
      );
      _navigateToHome();
    }

    final initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  /// Navigate to home screen when notification is tapped
  void _navigateToHome() {
    // Try using GoRouter first (preferred method)
    if (_router != null) {
      _router!.go(Routes.homeScreen);
      NativeLogService.log(
        'Navigated to home via GoRouter successfully',
        tag: _logTag,
        level: 'debug',
      );
      return;
    }
    
    // Fallback to Navigator key if GoRouter not available
    if (_navigatorKey?.currentContext != null) {
      final context = _navigatorKey!.currentContext!;
      if (context.mounted) {
        context.go(Routes.homeScreen);
        NativeLogService.log(
          'Navigated to home via Navigator context successfully',
          tag: _logTag,
          level: 'debug',
        );
        return;
      }
    }
    
    NativeLogService.log(
      'Router/Navigator not set, cannot navigate to home successfully',
      tag: _logTag,
      level: 'warning',
    );
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
      payload: 'push_notification', // Payload to identify push notifications
    );

    if (kDebugMode) {
      NativeLogService.log(
        'Foreground message: ${notification.title} - ${notification.body}',
        tag: _logTag,
        level: 'debug',
      );
    }
  }
}
