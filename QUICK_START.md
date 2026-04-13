# Quick Start Guide

## Try the Example App

The fastest way to see the package in action is to run the included example app:

### iOS Simulator
```bash
cd example
flutter run -d "iPhone 17 Pro Max"  # or your available simulator
```

### Android Emulator  
```bash
cd example
flutter run -d "emulator-5554"  # or your emulator id
```

The example app demonstrates:
- ✅ Checking current permission status
- ✅ Requesting user permission
- ✅ Refreshing status (bypasses 5-second cache)
- ✅ Opening app settings for manual permission changes
- ✅ Displaying request history
- ✅ Color-coded permission state indicators

---

## Installation & Setup

### 1. Add to pubspec.yaml
```yaml
dependencies:
  notification_permission_pro: ^1.0.0
```

### 2. Initialize in main()
```dart
import 'package:notification_permission_pro/notification_permission_pro.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationPermissionPro.initialize();
  runApp(const MyApp());
}
```

### 3. Use in your app
```dart
final permissionPro = NotificationPermissionPro();

// Check status
final status = await permissionPro.status;
if (status.isGranted) {
  // Ready to show notifications
}

// Request permission
final granted = await permissionPro.requestPermission();

// Refresh
await permissionPro.refresh();

// Open settings
await permissionPro.openAppSettings();
```

## Common Patterns

### Pattern 1: Check and Request on App Startup

```dart
Future<void> _initializeNotifications() async {
  final status = await permissionPro.status;
  
  if (status.isNotRequested) {
    // First time asking
    await permissionPro.requestPermission();
  }
}
```

### Pattern 2: Handle Permanently Denied

```dart
Future<void> _checkNotificationPermission() async {
  final status = await permissionPro.status;
  
  if (status.isPermanentlyDenied || status.isRestricted) {
    // Show dialog suggesting app settings
    _showSettingsDialog();
  } else if (status.isDenied) {
    // Just denied, maybe try again later
  }
}
```

### Pattern 3: Show Permission Prompt

```dart
Future<void> _requestNotificationAccess() async {
  final status = await permissionPro.status;
  
  if (!_permissionPro.shouldRequestPermission(status)) {
    // Already requested or permanently denied
    if (status.isPermanentlyDenied) {
      await permissionPro.openAppSettings();
    }
    return;
  }
  
  // Safe to request
  final granted = await permissionPro.requestPermission();
  
  if (granted) {
    // Setup notifications
  } else {
    // User denied
  }
}
```

### Pattern 4: Permission Check Before Sending

```dart
Future<void> sendNotification(String message) async {
  final status = await permissionPro.status;
  
  if (!status.isGranted) {
    print('Notifications not permitted');
    return;
  }
  
  // Proceed with sending notification
  // (use your chosen notification service)
}
```

### Pattern 5: Analytics/Debugging

```dart
void _logPermissionMetrics() {
  final requestCount = permissionPro.getRequestCount();
  final wasRequested = permissionPro.wasPermissionRequested();
  
  analytics.logEvent('permission_metrics', {
    'request_count': requestCount,
    'was_requested': wasRequested,
  });
}
```

## State Interpretation Guide

| State | Meaning | Action |
|-------|---------|--------|
| `granted` | Notifications enabled and permitted | Send notifications |
| `denied` | User denied after request | Offer to request again later |
| `notRequested` | Never asked user yet | Request permission |
| `permanentlyDenied` | Denied and locked (needs settings) | Offer app settings link |
| `restricted` | System restricted (MDM, etc.) | Inform user (can't fix) |
| `unknown` | Could not determine | Assume denied, try later |

## iOS Setup

Add to `ios/Runner/Info.plist`:

```xml
<key>NSUserNotificationUsageDescription</key>
<string>We'd like to send you notifications about important updates</string>
```

## Android Setup

Package handles everything automatically. Optional - add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

## Troubleshooting

### Status always returns unknown

**Possible causes**:
1. Not initialized - call `NotificationPermissionPro.initialize()`
2. Platform error - check logs in debug mode
3. Incompatible API level

**Solution**: Check example app for correct setup

### Permission request doesn't show dialog

**Possible causes**:
1. Already requested (use `wasPermissionRequested()`)
2. Permanently denied (show settings option)
3. Android: needs activity context

**Solution**: Check current state before requesting

### Cannot open app settings

**Possible causes**:
1. Platform setting URL not available
2. Native code error (check logs)

**Solution**: Ensure app settings is available on device

### Cached state seems stale

**Expected behavior**: Status cached for 5 seconds. Call `refresh()` for fresh check.

**Reason**: Improves performance, prevents excessive native calls.

## API Reference Quick Overview

```dart
// Getters
Future<PermissionState> get status         // Check status (cached)
int getRequestCount()                       // # of times requested
bool wasPermissionRequested()               // Was permission ever requested

// Methods
Future<PermissionState> refresh()           // Force refresh from platform
Future<bool> requestPermission()            // Request from user
Future<void> openAppSettings()              // Open notification settings

// Initialization
static Future<void> initialize()            // Call once in main()

// Testing
Future<void> clearStorage()                 // Clear cached data (testing only)
```

## When to Use This Package

✅ You need to check if notifications are allowed  
✅ You need to request notification permission  
✅ You need to direct user to notification settings  
✅ You need permission state for analytics  

❌ You want to send/schedule notifications (use FCM, local_notifications)  
❌ You need UI components (build your own)  
❌ You need Firebase integration (combine with fcm package)  

## Best Practices

1. **Initialize Early** - Call `initialize()` in main()
2. **Check Before Requesting** - Don't spam permission requests
3. **Handle All States** - Every state has a purpose
4. **Use History** - `wasPermissionRequested()` helps decide UX
5. **Refresh When Needed** - After app returns from settings
6. **Handle unknown State** - Treat as denied
7. **Test on Real Devices** - Simulator permissions differ
8. **Read Architecture Docs** - Understand the normalization logic

## Integration with Notification Services

### With flutter_local_notifications

```dart
final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final permissionPro = NotificationPermissionPro();

Future<void> initializeNotifications() async {
  // Check permission first
  final status = await permissionPro.status;
  if (!status.isGranted) {
    await permissionPro.requestPermission();
  }
  
  // Now initialize local notifications
  const initSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );
  await flutterLocalNotificationsPlugin.initialize(initSettings);
}
```

### With Firebase Cloud Messaging

```dart
final permissionPro = NotificationPermissionPro();

Future<void> setupFCM() async {
  // Check permission
  final status = await permissionPro.status;
  if (!status.isGranted) {
    // FCM will queue notifications until permission granted
    // but you might want to notify user
  }
  
  // Get FCM token
  final token = await FirebaseMessaging.instance.getToken();
  print('FCM Token: $token');
}
```

## Examples

See `example/` directory for complete working app demonstrating:
- Permission status checking
- Permission requesting
- App settings navigation
- State-based UI
- Debug information display

Run with:
```bash
cd example
flutter run
```

---

For detailed information, see:
- [README.md](README.md) - Full documentation
- [ARCHITECTURE.md](ARCHITECTURE.md) - Implementation details
- [example/lib/main.dart](example/lib/main.dart) - Complete example app
