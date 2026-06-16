# Developer Guide

## Understanding the Permission States

The package normalizes platform-specific states into 6 unified states:

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

`PermissionDetector` identifies whether the raw status is from iOS or Android based on the status string.

### Step 2: Platform-Specific Mapping

**iOS Mapping**:
```
authorized    → granted
provisional   → granted (delivers silently)
ephemeral     → granted (current session only)
notDetermined → notRequested
denied        → permanentlyDenied (if previously requested) | denied
restricted    → restricted
```

**Android Mapping**:
```
granted      → granted
notrequested → notRequested
denied       → permanentlyDenied (if previously requested) | denied
restricted   → restricted
```

### Step 3: History-Aware Decision

Normalization combines platform state with local request history:

```dart
case 'denied':
  return wasRequested
      ? PermissionState.permanentlyDenied  // User explicitly denied after prompt
      : PermissionState.denied;            // Declined without a prior request
```

This distinction helps avoid re-requesting permission when already permanently denied.

### Step 4: Caching

Result is cached for 5 seconds. Next call within that window returns the cached state. Use `refresh()` to bypass the cache.

## Adding Support for New Platforms

Example: Add Web support.

### 1. Create Web Implementation

```dart
// web/notification_permission_pro_web_plugin.dart
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class NotificationPermissionProWeb {
  Future<Map<String, dynamic>> getPermissionStatus() async {
    // Call JS Notification API
  }
}
```

### 2. Register in pubspec.yaml

```yaml
flutter:
  plugin:
    platforms:
      web:
        pluginClass: NotificationPermissionProWeb
        fileName: notification_permission_pro_web_plugin.dart
```

### 3. Add Platform Detection

```dart
// method_channel_permission.dart
if (kIsWeb) {
  return WebNotificationService.getStatus();
}
```

### 4. Add Web Normalization

```dart
bool _isWebStatus(String status) {
  const webStatuses = ['granted', 'denied', 'default'];
  return webStatuses.contains(status.toLowerCase());
}
```

## Extending the Permission State Model

Example: Separate `provisional` into its own state.

```dart
// 1. Add to enum
enum PermissionState { ..., provisional, ... }

// 2. Add extension
bool get isProvisional => this == PermissionState.provisional;

// 3. Update normalization
case 'provisional':
  return PermissionState.provisional;
```

## Debugging

### Bypass Cache

```dart
final status = await permissionPro.refresh();
```

### Clear Cache (Testing Only)

```dart
await permissionPro.clearStorage();
```

## Testing

```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/permission_detector_test.dart
```

For manual testing, run the example app:

```bash
cd example
flutter run
```

> **Real device note**: iOS simulator permission behaviour differs from a physical device. For production validation, test on real hardware.

## Common Mistakes & Fixes

### Not Initializing

```dart
// ❌ StateError thrown
final status = await permissionPro.status;

// ✅
await NotificationPermissionPro.initialize();
final status = await permissionPro.status;
```

### Ignoring Unknown State

```dart
// ❌ Treats unknown as denied
if (state != PermissionState.granted) return false;

// ✅
if (state.isUnknown) return null; // Indeterminate — retry or handle explicitly
```

### Not Refreshing After Settings

```dart
// ❌ Shows stale cached state
await permissionPro.openAppSettings();

// ✅
await permissionPro.openAppSettings();
// ... when user returns:
final newStatus = await permissionPro.refresh();
```

## Release Checklist

- [ ] Version bumped in `pubspec.yaml`
- [ ] `CHANGELOG.md` updated
- [ ] All tests passing (`flutter test`)
- [ ] No lint errors (`dart analyze`)
- [ ] Example app tested on iOS and Android
- [ ] No breaking changes (or documented)
