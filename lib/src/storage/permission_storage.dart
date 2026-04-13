import 'package:shared_preferences/shared_preferences.dart';

/// Local storage for permission state tracking.
///
/// Maintains a local memory of:
/// - whether permission was previously requested
/// - last known state
/// - last check timestamp
class PermissionStorage {
  static const String _prefixKey = 'notification_permission_pro_';
  static const String _stateKey = '${_prefixKey}state';
  static const String _timestampKey = '${_prefixKey}timestamp';
  static const String _wasRequestedKey = '${_prefixKey}was_requested';
  static const String _requestCountKey = '${_prefixKey}request_count';

  final SharedPreferences _prefs;

  PermissionStorage(this._prefs);

  /// Factory method to create instance with initialized SharedPreferences.
  static Future<PermissionStorage> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return PermissionStorage(prefs);
  }

  /// Save the last known permission state.
  Future<void> setState(String state) async {
    await _prefs.setString(_stateKey, state);
    await _prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get the last known permission state.
  String? getState() => _prefs.getString(_stateKey);

  /// Get the timestamp of when the state was last set.
  int getStateTimestamp() => _prefs.getInt(_timestampKey) ?? 0;

  /// Mark that permission was previously requested.
  Future<void> markPermissionRequested() async {
    final count = _prefs.getInt(_requestCountKey) ?? 0;
    await _prefs.setBool(_wasRequestedKey, true);
    await _prefs.setInt(_requestCountKey, count + 1);
    await _prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Check if permission was previously requested.
  bool wasPermissionRequested() => _prefs.getBool(_wasRequestedKey) ?? false;

  /// Get the number of times permission was requested.
  int getRequestCount() => _prefs.getInt(_requestCountKey) ?? 0;

  /// Clear all stored permission data.
  Future<void> clear() async {
    await _prefs.remove(_stateKey);
    await _prefs.remove(_timestampKey);
    await _prefs.remove(_wasRequestedKey);
    await _prefs.remove(_requestCountKey);
  }

  /// Check if cached state is still valid (not older than duration).
  bool isCacheValid(Duration cacheDuration) {
    final lastCheckTime = getStateTimestamp();
    if (lastCheckTime == 0) return false;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - lastCheckTime) < cacheDuration.inMilliseconds;
  }
}
