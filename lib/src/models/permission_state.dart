/// Unified notification permission state across platforms.
///
/// This enum represents the normalized permission state for notifications.
/// The state is derived from platform-specific APIs and normalized into
/// this single consistent model.
enum PermissionState {
  /// User has granted notification permissions.
  /// On iOS: authorized status
  /// On Android: POST_NOTIFICATIONS permission + notifications enabled
  granted,

  /// User explicitly denied notification permissions.
  /// On iOS: denied status
  /// On Android: POST_NOTIFICATIONS permission denied after request
  denied,

  /// Permission has not been requested yet from the user.
  /// On iOS: notDetermined status
  /// On Android: permission not yet requested
  notRequested,

  /// User previously denied, and the permission request was shown.
  /// This typically means requesting again would be blocked (iOS) or
  /// the user would need to use app settings to re-enable.
  permanentlyDenied,

  /// System has restricted notifications (e.g., parental controls, MDM).
  /// On iOS: restricted status
  /// On Android: system-level restriction detected
  restricted,

  /// The permission state could not be determined.
  /// This occurs when platform check fails or is unavailable.
  unknown,
}

/// Extension methods for PermissionState
extension PermissionStateExtension on PermissionState {
  /// Returns true if user can receive notifications.
  bool get isGranted => this == PermissionState.granted;

  /// Returns true if user explicitly denied permissions.
  bool get isDenied => this == PermissionState.denied;

  /// Returns true if permission was never requested.
  bool get isNotRequested => this == PermissionState.notRequested;

  /// Returns true if user permanently denied (likely needs app settings).
  bool get isPermanentlyDenied => this == PermissionState.permanentlyDenied;

  /// Returns true if system restricted notifications.
  bool get isRestricted => this == PermissionState.restricted;

  /// Returns true if state is unknown.
  bool get isUnknown => this == PermissionState.unknown;

  /// Returns a human-readable description.
  String get description {
    switch (this) {
      case PermissionState.granted:
        return 'Granted';
      case PermissionState.denied:
        return 'Denied';
      case PermissionState.notRequested:
        return 'Not Requested';
      case PermissionState.permanentlyDenied:
        return 'Permanently Denied';
      case PermissionState.restricted:
        return 'Restricted';
      case PermissionState.unknown:
        return 'Unknown';
    }
  }
}
