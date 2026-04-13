import '../models/permission_state.dart';
import '../storage/permission_storage.dart';

/// Core permission detector that normalizes platform-specific states.
///
/// This class contains the normalization logic that maps platform-specific
/// permission states into the unified PermissionState model.
class PermissionDetector {
  final PermissionStorage _storage;

  PermissionDetector(this._storage);

  /// Normalize platform permission state to unified model.
  ///
  /// Takes raw platform status and combines with local app memory
  /// (previous request history, etc.) to determine the best-fit state.
  ///
  /// Platform status format (from native):
  /// - iOS: 'authorized' | 'denied' | 'notDetermined' | 'provisional' | 'ephemeral'
  /// - Android: 'granted' | 'denied' | 'notRequested' | 'unknown'
  PermissionState normalize(String platformStatus) {
    final wasRequested = _storage.wasPermissionRequested();

    // Handle iOS states
    if (_isIosStatus(platformStatus)) {
      return _normalizeIosStatus(platformStatus, wasRequested);
    }

    // Handle Android states
    if (_isAndroidStatus(platformStatus)) {
      return _normalizeAndroidStatus(platformStatus, wasRequested);
    }

    // Unknown platform or status
    return PermissionState.unknown;
  }

  /// Normalize iOS-specific notification status.
  /// 
  /// iOS UNNotificationSettings status:
  /// - authorized: User has explicitly granted permission
  /// - provisional: Provisional permission (iOS 12+) - can send notifications quietly
  /// - ephemeral: Temporary permission (iOS 14+) - granted for current app session only
  /// - denied: User explicitly denied
  /// - notDetermined: User hasn't been asked yet
  /// - restricted: System has restricted notifications (e.g., MDM)
  PermissionState _normalizeIosStatus(String status, bool wasRequested) {
    switch (status.toLowerCase()) {
      case 'authorized':
        return PermissionState.granted;
      case 'provisional':
      case 'ephemeral':
        // Provisional and ephemeral are treated as granted since
        // notifications can be delivered, just silently
        return PermissionState.granted;
      case 'denied':
        return wasRequested
            ? PermissionState.permanentlyDenied
            : PermissionState.denied;
      case 'notdetermined':
        return PermissionState.notRequested;
      case 'restricted':
        return PermissionState.restricted;
      default:
        return PermissionState.unknown;
    }
  }

  /// Normalize Android-specific notification status.
  ///
  /// Android has multiple indicators:
  /// - POST_NOTIFICATIONS permission (runtime, Android 13+)
  /// - areNotificationsEnabled() system check
  /// - Device/OEM restrictions
  ///
  /// The platform integration combines these into a single status.
  PermissionState _normalizeAndroidStatus(String status, bool wasRequested) {
    switch (status.toLowerCase()) {
      case 'granted':
        return PermissionState.granted;
      case 'denied':
        return wasRequested
            ? PermissionState.permanentlyDenied
            : PermissionState.denied;
      case 'notrequested':
        return PermissionState.notRequested;
      case 'restricted':
        return PermissionState.restricted;
      default:
        return PermissionState.unknown;
    }
  }

  /// Check if status is iOS-style (quick heuristic).
  bool _isIosStatus(String status) {
    const iosStatuses = [
      'authorized',
      'provisional',
      'ephemeral',
      'denied',
      'notdetermined',
      'restricted'
    ];
    return iosStatuses.contains(status.toLowerCase());
  }

  /// Check if status is Android-style (quick heuristic).
  bool _isAndroidStatus(String status) {
    const androidStatuses = ['granted', 'denied', 'notrequested', 'restricted'];
    return androidStatuses.contains(status.toLowerCase());
  }

  /// Decide whether requesting permission makes sense.
  /// 
  /// Requesting should only happen when:
  /// - current state is notRequested
  /// - doesn't waste requests on permanentlyDenied, restricted, or granted
  bool shouldRequestPermission(PermissionState state) {
    return state == PermissionState.notRequested;
  }

  /// Decide whether user should be sent to app settings.
  ///
  /// This typically happens when:
  /// - User permanently denied
  /// - System restricted
  /// - Special states that need manual user action
  bool shouldOpenSettings(PermissionState state) {
    return state == PermissionState.permanentlyDenied ||
        state == PermissionState.restricted;
  }
}
