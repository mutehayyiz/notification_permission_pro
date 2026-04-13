# Developer Guide

## Overview for Contributors

This guide explains how the package works internally and how to extend or modify it.

## Understanding the Permission States

### The Problem This Package Solves

Initially, developers had to handle:
- **iOS**: 5+ different authorization statuses
- **Android**: 3+ separate checks (runtime permission, system toggle, OEM restrictions)

This created inconsistent, fragmented code across platforms.

### The Solution: Unified State Model

The package normalizes all of this into 6 clear states:

```
PermissionState enum:
├── granted              (Ready to send notifications)
├── denied               (User said no, might ask again)
├── notRequested         (Never asked, safe to request)
├── permanentlyDenied    (Denied + locked, needs settings to recover)
├── restricted           (System blocked, user can't fix)
└── unknown              (Couldn't determine)
```

## How Normalization Works

### Step 1: Platform Detection

The `PermissionDetector` class identifies whether the raw status is from iOS or Android:

```dart
bool _isIosStatus(String status) {
  const iosStatuses = ['authorized', 'provisional', 'denied', ...];
  return iosStatuses.contains(status.toLowerCase());
}
```

### Step 2: Platform-Specific Mapping

Each platform has unique states that map differently:

**iOS Mapping**:
```
authorized  → granted
provisional → granted (partial)
notDetermined → notRequested
denied → permanently_denied (if requested) OR denied (if not)
restricted → restricted
```

**Android Mapping**:
```
granted → granted
notrequested → notRequested
denied → permanently_denied (if requested) OR denied (if not)
restricted → restricted
```

### Step 3: History-Aware Decision

The normalization combines platform state with request history:

```dart
PermissionState _normalizeIosStatus(String status, bool wasRequested) {
  switch (status.toLowerCase()) {
    case 'denied':
      // Was permission requested before?
      return wasRequested
          ? PermissionState.permanentlyDenied  // User explicitly denied
          : PermissionState.denied;            // Just declined
    // ...
  }
}
```

**Why**:
- Distinguishes between "never asked" and "asked but refused"
- Helps decide if we should ask again (don't ask permanent denials)
- Tracks request history in local storage

### Step 4: Caching for Performance

Result is cached with timestamp:

```dart
await _storage.setState(platformStatus);
_cachedState = normalizedState;
```

Next request within 5 seconds uses cache instead of querying platform.

## Adding Support for New Platforms

Example: Add Web support

### 1. Create Web Implementation

Create `web/notification_permission_pro_web_plugin.dart`:

```dart
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class NotificationPermissionProWeb {
  // Use JavaScript Notification API
  Future<Map<String, dynamic>> getPermissionStatus() async {
    // Call JS to check Notification.permission
  }
}
```

### 2. Register Plugin

Update `pubspec.yaml`:

```yaml
flutter:
  plugin:
    platforms:
      web:
        pluginClass: NotificationPermissionProWeb
        fileName: notification_permission_pro_web_plugin.dart
```

### 3. Add Platform Detection

Update `method_channel_permission.dart` to handle web:

```dart
if (kIsWeb) {
  return WebNotificationService.getStatus();
}
```

### 4. Add Web Normalization

Update `permission_detector.dart`:

```dart
bool _isWebStatus(String status) {
  const webStatuses = ['granted', 'denied', 'default'];
  return webStatuses.contains(status.toLowerCase());
}

PermissionState _normalizeWebStatus(String status, bool wasRequested) {
  // Web normalization logic
}
```

## Extending the Permission State Model

Example: Add "warning" state for provisonal iOS permissions

### 1. Update Enum

```dart
enum PermissionState {
  granted,
  denied,
  notRequested,
  permanentlyDenied,
  restricted,
  warning,        // NEW: Provisional/ephemeral on iOS
  unknown,
}
```

### 2. Add Extension Methods

```dart
extension PermissionStateExtension on PermissionState {
  bool get isWarning => this == PermissionState.warning;
}
```

### 3. Update Normalization

```dart
PermissionState _normalizeIosStatus(String status, bool wasRequested) {
  switch (status.toLowerCase()) {
    case 'provisional':
    case 'ephemeral':
      return PermissionState.warning;  // NEW
    // ...
  }
}
```

## Debugging

### Enable Debug Logging

The package logs in debug mode:

```dart
if (kDebugMode) {
  print('Error refreshing permission status: $e');
}
```

### Check Cached State

```dart
final detector = permissionPro._detector;
final storage = permissionPro._storage;

print(storage.getState());              // Raw platform status
print(storage.getStateTimestamp());     // When it was last checked
print(storage.wasPermissionRequested()); // Request history
```

### Bypass Cache

Always get fresh status:

```dart
final status = await permissionPro.refresh();
```

### Clear Cache (Testing)

```dart
await permissionPro.clearStorage();
```

## Testing Locally

### Unit Tests

Run all tests:

```bash
flutter test
```

Run specific test file:

```bash
flutter test test/permission_detector_test.dart
```

### Manual Testing

1. Run example app:
```bash
cd example
flutter run
```

2. Use the UI to:
   - Check current status
   - Request permission
   - Open app settings
   - View request count and history

3. Test state transitions:
   - Grant → Check state
   - Open settings → Change permission → Return to app → Refresh
   - Request multiple times → Check request count

### Real Device Testing Requirements

- **iOS**: Physical iPhone (simulator permissions differ)
- **Android**: Physical Android device or emulator with Play Services

## Performance Optimization Tips

### 1. Use Cache Wisely

✅ **Good**: Check status frequently (uses cache)
```dart
// Called multiple times per second = uses cache
for (int i = 0; i < 100; i++) {
  await permissionPro.status;  // Only queries platform on first call
}
```

❌ **Bad**: Bypass cache unnecessarily
```dart
// Wastes platform calls
for (int i = 0; i < 100; i++) {
  await permissionPro.refresh();  // Queries platform every time
}
```

### 2. Lazy Initialize

Only initialize when needed:

```dart
class PermissionService {
  static NotificationPermissionPro? _instance;
  
  static Future<NotificationPermissionPro> getInstance() async {
    if (_instance == null) {
      await NotificationPermissionPro.initialize();
      _instance = NotificationPermissionPro();
    }
    return _instance!;
  }
}
```

### 3. Batch Operations

Group permission checks:

```dart
// Efficient: Single initialization
await NotificationPermissionPro.initialize();
final permissionPro = NotificationPermissionPro();

final status1 = await permissionPro.status;
final status2 = await permissionPro.status;  // Uses cache
```

## Common Mistakes & Fixes

### Mistake 1: Not Initializing

```dart
// ❌ WRONG - StateError thrown
final status = await permissionPro.status;

// ✅ CORRECT
await NotificationPermissionPro.initialize();
final status = await permissionPro.status;
```

### Mistake 2: Ignoring Unknown State

```dart
// ❌ WRONG - Assumes unknown means denied
if (state != PermissionState.granted) {
  return false;
}

// ✅ CORRECT - Handle unknown explicitly
if (state.isUnknown) {
  // Retry or handle error
  return null;  // Indeterminate
}
```

### Mistake 3: Requesting Persistently

```dart
// ❌ WRONG - Spams user with permission dialogs
Stream.periodic(Duration(seconds: 1))
    .listen((_) => permissionPro.requestPermission());

// ✅ CORRECT - Request only once
if (status.isNotRequested) {
  await permissionPro.requestPermission();
}
```

### Mistake 4: Not Refreshing After Settings

```dart
// ❌ WRONG - User changes settings, but app shows cached denied
await permissionPro.openAppSettings();

// ✅ CORRECT - Refresh when returning
onReturn() {
  final newStatus = await permissionPro.refresh();
}
```

## Code Review Checklist

Before submitting changes:

- [ ] All unit tests pass (`flutter test`)
- [ ] No lint errors (`flutter analyze`)
- [ ] iOS implementation handles all `UNNotificationSettings` cases
- [ ] Android implementation handles API levels (8+, 13+)
- [ ] Error handling with try-catch
- [ ] Debug logging in debug mode only
- [ ] Documentation updated
- [ ] Example app still works
- [ ] No external dependencies added

## Release Checklist

Before publishing:

- [ ] Update version in `pubspec.yaml`
- [ ] Update `CHANGELOG.md` with changes
- [ ] All tests passing on real devices
- [ ] Documentation complete
- [ ] Example app tested end-to-end
- [ ] Platform code reviewed
- [ ] No breaking changes (or documented)

## Architecture Decision Record

### Why Singleton?

**Decision**: Use singleton pattern for `NotificationPermissionPro`

**Rationale**:
- Single source of truth for permission state
- Consistent caching across app
- Prevents duplicate permissions checks
- Simplifies API

**Alternative Considered**: Static methods
- **Rejected**: Can't maintain state easily

### Why Caching?

**Decision**: Cache status for 5 seconds

**Rationale**:
- Permission rarely changes within milliseconds
- Reduces platform calls significantly
- Improves performance without sacrificing freshness
- `refresh()` available for manual updates

**Alternative Considered**: No caching
- **Rejected**: Excessive native calls, poor performance

### Why Separate Storage?

**Decision**: Use dedicated storage layer

**Rationale**:
- Request history tracking
- Cache validation
- Easy testing
- Potential for custom storage backends

**Alternative Considered**: Store in memory only
- **Rejected**: Loses request history on app restart

## Future Enhancements

Potential improvements (post-1.0):

1. **Stream API**: Real-time permission change updates
2. **Multiple Permissions**: Check multiple permissions at once
3. **Permission Groups**: Group related permissions
4. **Web Support**: Use Notification API
5. **Analytics Integration**: Built-in permission events
6. **Custom Storage**: Allow alternative storage backends
7. **Telemetry**: Anonymized usage patterns
