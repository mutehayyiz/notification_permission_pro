# notification_permission_pro

A lightweight, production-ready Flutter package providing a unified and reliable abstraction layer for notification permission status across iOS and Android.

## Overview

Flutter and native platforms expose fragmented notification permission states that vary significantly between iOS and Android. This package solves that fragmentation by creating a unified permission state engine that normalizes platform-specific states into a single consistent model.

### What This Package Does

✅ Detects notification permission status across platforms
✅ Normalizes fragmented platform states into unified `PermissionState` enum  
✅ Maintains local memory of permission request history  
✅ Provides easy-to-use methods to request and check permissions  
✅ Lightweight with zero external dependencies (except `shared_preferences`)  

### What This Package Does NOT Do

❌ Schedule or show notifications  
❌ Depend on Firebase  
❌ Handle UI directly  
❌ Handle notification channels (platform responsibility)  
❌ Guarantee absolute OS truth (uses best-effort normalization)  

## Features

### Core API

```dart
class NotificationPermissionPro {
  // Get current permission status (cached for 5 seconds)
  Future<PermissionState> get status;
  
  // Refresh status by querying platform
  Future<PermissionState> refresh();
  
  // Request permission from user
  Future<bool> requestPermission();
  
  // Open app settings for manual permission change
  Future<void> openAppSettings();
}
```

### Unified Permission States

The package normalizes all platform states into a single `PermissionState` enum:

```dart
enum PermissionState {
  granted,              // User granted permission
  denied,               // User denied (after request)
  notRequested,         // Never asked
  permanentlyDenied,    // Denied and likely blocked (needs settings)
  restricted,           // System restricted (MDM, parental controls)
  unknown,              // Could not determine
}
```

## Installation

1. Add to `pubspec.yaml`:

```yaml
dependencies:
  notification_permission_pro: ^1.0.0
```

2. Run:

```bash
flutter pub get
```

3. **iOS**: Add to `Info.plist`:

```xml
<key>NSUserNotificationUsageDescription</key>
<string>We'd like to send you notifications</string>
```

4. **Android**: The package handles permissions automatically. Can also add to `AndroidManifest.xml` for clarity:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

## Usage

### Initialize

Call `initialize()` once during app startup (before using any other methods):

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize
  await NotificationPermissionPro.initialize();
  
  runApp(MyApp());
}
```

### Check Permission Status

```dart
final permissionPro = NotificationPermissionPro();

// Get status (uses cache if fresh)
final status = await permissionPro.status;

if (status.isGranted) {
  // Notifications can be sent
}

if (status.isDenied) {
  // Explicitly denied
}

if (status.isPermanentlyDenied) {
  // Likely need app settings to re-enable
}
```

### Request Permission

```dart
final granted = await permissionPro.requestPermission();

if (granted) {
  print('Permission granted!');
} else {
  print('Permission denied or current state prevents request');
}
```

### Manually Refresh

Get fresh status by bypassing cache:

```dart
final refreshed = await permissionPro.refresh();
```

### Open App Settings

Allow user to manually enable notifications:

```dart
await permissionPro.openAppSettings();
```

### Debug Information

```dart
// How many times was permission requested?
final requestCount = permissionPro.getRequestCount();

// Was permission ever requested?
final wasRequested = permissionPro.wasPermissionRequested();

// Clear local storage (testing only)
await permissionPro.clearStorage();
```

## Platform Implementation Details

### iOS

Uses `UNUserNotificationCenter.getNotificationSettings()`:

| iOS Status | Mapped To |
|------------|-----------|
| `authorized` | `granted` |
| `provisional` | `granted` (partial) |
| `ephemeral` | `granted` (partial) |
| `denied` | `denied` / `permanentlyDenied` (depending on request history) |
| `notDetermined` | `notRequested` |
| `restricted` | `restricted` |

### Android

Combines multiple indicators:

1. **Runtime Permission** (`POST_NOTIFICATIONS` on Android 13+)
2. **System Toggle** (`areNotificationsEnabled()`)
3. **OEM Restrictions** (detected via system checks)

| Android Conditions | Mapped To |
|--------------------|-----------|
| POST_NOTIFICATIONS granted + system enabled | `granted` |
| POST_NOTIFICATIONS denied | `denied` |
| POST_NOTIFICATIONS not requested | `notRequested` |
| System restrictions detected | `restricted` |
| Indeterminate state | `unknown` |

## Normalization Algorithm

The package combines:
- Platform API responses
- Local app memory (request history)
- System state checks

To determine the most appropriate unified state:

```
1. Query platform for raw status
2. Check local storage for request history
3. Apply normalization rules specific to platform
4. Map to PermissionState
5. Cache result for 5 seconds
6. Return normalized state
```

## Architecture

```
lib/
 ├── src/
 │    ├── core/
 │    │    └── permission_detector.dart      # Normalization logic
 │    ├── platform/
 │    │    └── method_channel_permission.dart # Platform bridge
 │    ├── models/
 │    │    └── permission_state.dart         # PermissionState enum
 │    ├── storage/
 │    │    └── permission_storage.dart       # Local memory
 │    └── notification_permission_pro_impl.dart # Main implementation
 └── notification_permission_pro.dart         # Public API
```

## Caching Strategy

Status is cached for **5 seconds**:
- Speeds up repeated checks
- Reduces platform calls
- `refresh()` bypasses cache
- Cache auto-invalidates after 5 seconds

## Error Handling

The package gracefully handles errors:

```dart
// If platform check fails, returns PermissionState.unknown
// If initialization not called, throws StateError
// All exceptions are caught and logged in debug mode
```

## Production Readiness

✅ Lightweight (~2KB minified)  
✅ No Firebase dependency  
✅ No UI components  
✅ Full iOS & Android support  
✅ Handles edge cases (restricted, permanent denial, etc.)  
✅ Caching for performance  
✅ Request history tracking  

## Example

See `example/` directory for a complete working app demonstrating:
- Checking permission status
- Displaying status UI
- Requesting permission
- Opening app settings
- Debug information

Run:

```bash
cd example
flutter run
```

## FAQ

**Q: Why does the package return `unknown`?**  
A: Usually means the platform call failed or returned unexpected values. Check platform integration.

**Q: Can I use this with Firebase Cloud Messaging?**  
A: Yes! This package only handles permission state. Use FCM for actual notifications.

**Q: Do I need to handle notification channels?**  
A: No, that's the OS responsibility. This package only checks permissions.

**Q: How do I handle the permanently denied state?**  
A: Use `openAppSettings()` to send user to notification settings.

**Q: Is the status always accurate?**  
A: It's best-effort. System can change permissions outside your app. Call `refresh()` when returning from app settings.

## Limitations

- Relies on platform APIs (changes between OS versions)
- Cannot guarantee absolute OS truth (system can change permissions independently)
- Caching may return stale state briefly (5 second max staleness)
- Doesn't handle permission groups (only notifications)

## Contributing

Contributions welcome! Please ensure:
- Code follows Dart style guide
- All tests pass
- iOS/Android implementations are symmetric
- Documentation is updated

## License

MIT License - see LICENSE file

## Support

For issues or questions:
1. Check the example app
2. Review platform implementation details above
3. Open an issue with detailed reproduction steps

---

Built with ❤️ for production Flutter apps.
