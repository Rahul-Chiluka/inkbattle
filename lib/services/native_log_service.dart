import 'dart:developer' as developer;
import 'package:flutter/services.dart';

/// Sends app logs to the platform logger (Android logcat, iOS OSLog)
/// so they appear in device logs and can be captured with bug reports.
class NativeLogService {
  static const MethodChannel _channel = MethodChannel('com.inkbattle.app/native_log');

  /// Logs a message to the device's native logger (logcat on Android, OSLog on iOS).
  /// Also calls [developer.log] in debug so IDE/DevTools still show it.
  /// [tag] is used as the log tag/category (e.g. widget or feature name).
  /// [level] can be 'debug', 'info', 'warning', 'error'.
  static void log(
    String message, {
    String? tag,
    String level = 'info',
  }) {
    developer.log(message, name: tag ?? 'App');
    try {
      _channel.invokeMethod<void>('log', <String, dynamic>{
        'message': message,
        'tag': tag ?? 'InkBattle',
        'level': level,
      });
    } on PlatformException catch (_) {
      // Ignore if native side isn't available (e.g. during tests or web)
    }
  }
}
