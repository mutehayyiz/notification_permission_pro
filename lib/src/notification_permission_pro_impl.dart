import 'package:flutter/foundation.dart';

import 'models/permission_state.dart';
import 'platform/method_channel_permission.dart';
import 'storage/permission_storage.dart';
import 'core/permission_detector.dart';

/// Main public API for notification permission handling.
///
/// This class provides a unified and reliable abstraction layer for
/// notification permission status across iOS and Android platforms.
///
/// Usage:
/// ```dart
/// final permissionPro = NotificationPermissionPro();
/// 
/// // Check current permission status
/// final status = await permissionPro.status;
/// if (status.isGranted) {
///   // Can show notifications
/// }
/// 
/// // Request permission
/// final granted = await permissionPro.requestPermission();
/// 
/// // Refresh status
/// final refreshed = await permissionPro.refresh();
/// 
/// // Open app settings
/// await permissionPro.openAppSettings();
/// ```
class NotificationPermissionPro {
  static NotificationPermissionPro? _instance;
  
  late PermissionStorage _storage;
  late PermissionDetector _detector;
  
  bool _initialized = false;
  PermissionState _cachedState = PermissionState.unknown;

  /// Private constructor for singleton pattern.
  NotificationPermissionPro._();

  /// Get singleton instance. Must call [initialize] before use.
  factory NotificationPermissionPro() {
    _instance ??= NotificationPermissionPro._();
    return _instance!;
  }

  /// Initialize the package.
  ///
  /// This must be called once before using any other methods.
  /// Typically done in main() or during app initialization.
  static Future<void> initialize() async {
    final instance = NotificationPermissionPro();
    if (instance._initialized) return;

    instance._storage = await PermissionStorage.initialize();
    instance._detector = PermissionDetector(instance._storage);
    instance._initialized = true;

    // Load cached state if available
    final cachedState = instance._storage.getState();
    if (cachedState != null) {
      instance._cachedState = instance._detector.normalize(cachedState);
    }
  }

  /// Get current permission status.
  ///
  /// This method:
  /// 1. Checks if cached state is still valid (< 5 seconds old)
  /// 2. If cache is fresh, returns cached state
  /// 3. Otherwise, queries the native platform for current status
  /// 4. Normalizes platform status to unified model
  /// 5. Caches the result
  ///
  /// Returns a PermissionState representing current notification permissions.
  Future<PermissionState> get status async {
    _ensureInitialized();

    // Use cache if valid (less than 5 seconds old)
    if (_storage.isCacheValid(const Duration(seconds: 5))) {
      return _cachedState;
    }

    // Query platform for fresh status
    return _refreshInternal();
  }

  /// Refresh permission status by querying the platform.
  ///
  /// This method always queries the native platform, bypassing cache.
  /// Use this when you need the latest permission status or after
  /// the user returns from app settings.
  ///
  /// Returns the current PermissionState.
  Future<PermissionState> refresh() async {
    _ensureInitialized();
    return _refreshInternal();
  }

  /// Internal method to refresh state from platform.
  Future<PermissionState> _refreshInternal() async {
    try {
      final result = await MethodChannelPermission.getPermissionStatus();
      final platformStatus = result['status'] as String? ?? 'unknown';
      
      // Normalize platform status
      final normalizedState = _detector.normalize(platformStatus);
      
      // Cache the result
      await _storage.setState(platformStatus);
      _cachedState = normalizedState;
      
      return normalizedState;
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing permission status: $e');
      }
      return PermissionState.unknown;
    }
  }

  /// Request notification permission from the user.
  ///
  /// This method:
  /// 1. Only proceeds if current state is notRequested
  /// 2. Calls native platform to show permission requestdialog
  /// 3. Marks permission as requested in local storage
  /// 4. Returns true if permission was granted
  ///
  /// If the user has already denied permission or system restricted
  /// notifications, this will return false without showing a dialog.
  Future<bool> requestPermission() async {
    _ensureInitialized();

    try {
      // Get current state
      final currentState = await status;

      // Only request if not yet requested
      if (!_detector.shouldRequestPermission(currentState)) {
        if (kDebugMode) {
          print('Permission already handled. Current state: ${currentState.description}');
        }
        return currentState.isGranted;
      }

      // Request from platform
      final granted = await MethodChannelPermission.requestPermission();

      // Mark as requested
      await _storage.markPermissionRequested();

      // Refresh to get updated state
      await refresh();

      return granted;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting permission: $e');
      }
      return false;
    }
  }

  /// Open app settings where user can manually enable notifications.
  ///
  /// This should be called when:
  /// - User permanently denied permission (needs app settings to re-enable)
  /// - System restricted notifications (needs system settings)
  /// 
  /// Opens the following:
  /// - iOS: Notification settings for this app
  /// - Android: App Info > Notifications settings
  Future<void> openAppSettings() async {
    _ensureInitialized();

    try {
      await MethodChannelPermission.openAppSettings();
    } catch (e) {
      if (kDebugMode) {
        print('Error opening app settings: $e');
      }
    }
  }

  /// Get the number of times permission was requested.
  ///
  /// Useful for analytics or deciding when to show custom prompts.
  int getRequestCount() {
    _ensureInitialized();
    return _storage.getRequestCount();
  }

  /// Check if permission was previously requested.
  bool wasPermissionRequested() {
    _ensureInitialized();
    return _storage.wasPermissionRequested();
  }

  /// Clear all stored permission data.
  ///
  /// This resets local memory (cached state, request history).
  /// For testing only - do not use in production.
  Future<void> clearStorage() async {
    _ensureInitialized();
    await _storage.clear();
    _cachedState = PermissionState.unknown;
  }

  /// Ensure package is initialized before use.
  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'NotificationPermissionPro not initialized. '
        'Call NotificationPermissionPro.initialize() in main().',
      );
    }
  }
}
