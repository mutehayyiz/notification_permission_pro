import 'package:flutter/services.dart';

/// Platform channel for native permission checks.
///
/// This class handles communication with native iOS and Android code
/// to retrieve platform-specific permission states.
class MethodChannelPermission {
  static const String _channelName = 'notification_permission_pro/channel';
  static const String _methodGetStatus = 'getPermissionStatus';
  static const String _methodRequestPermission = 'requestPermission';
  static const String _methodOpenSettings = 'openAppSettings';

  static const MethodChannel _channel = MethodChannel(_channelName);

  /// Get the current permission status from native platform.
  ///
  /// Returns a map containing:
  /// - 'status': String representing the permission state
  /// - 'timestamp': Int64 timestamp of when the check was performed
  static Future<Map<String, dynamic>> getPermissionStatus() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        _methodGetStatus,
      );
      if (result == null) {
        return {'status': 'unknown', 'timestamp': DateTime.now().millisecondsSinceEpoch};
      }
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      print('Error getting permission status: ${e.message}');
      return {'status': 'unknown', 'timestamp': DateTime.now().millisecondsSinceEpoch};
    }
  }

  /// Request notification permission from the user.
  ///
  /// Returns true if permission is granted, false otherwise.
  static Future<bool> requestPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        _methodRequestPermission,
      );
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error requesting permission: ${e.message}');
      return false;
    }
  }

  /// Open the app settings page where user can manually enable notifications.
  static Future<void> openAppSettings() async {
    try {
      await _channel.invokeMethod<void>(_methodOpenSettings);
    } on PlatformException catch (e) {
      print('Error opening app settings: ${e.message}');
    }
  }
}
