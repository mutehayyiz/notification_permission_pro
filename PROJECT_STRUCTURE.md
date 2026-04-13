# Project Structure

```
notification_permission_pro/
├── lib/
│   ├── notification_permission_pro.dart       # Main entry point (exports public API)
│   └── src/
│       ├── notification_permission_pro_impl.dart   # Main public class
│       ├── core/
│       │   └── permission_detector.dart           # Normalization logic
│       ├── models/
│       │   └── permission_state.dart              # PermissionState enum & extensions
│       ├── platform/
│       │   └── method_channel_permission.dart     # Platform bridge (method channel)
│       └── storage/
│           └── permission_storage.dart             # Local storage with SharedPreferences
│
├── android/
│   ├── src/main/
│   │   ├── kotlin/com/example/notification_permission_pro/
│   │   │   └── NotificationPermissionPro.kt         # Android native implementation (Kotlin)
│   │   └── AndroidManifest.xml                      # Android permissions & app config
│   ├── build.gradle                                  # Android build config (Gradle)
│   └── pubspec.yaml
│
├── ios/
│   ├── Classes/
│   │   └── NotificationPermissionProPlugin.swift    # iOS native implementation (Swift)
│   ├── notification_permission_pro.podspec          # CocoaPods pod specification
│   └── pubspec.yaml
│
├── example/
│   ├── lib/
│   │   └── main.dart                                # Complete example app
│   └── pubspec.yaml
│
├── test/
│   ├── permission_state_test.dart                   # PermissionState unit tests
│   ├── permission_detector_test.dart                # Normalization logic tests
│   └── permission_storage_test.dart                 # Storage layer tests
│
├── pubspec.yaml                                      # Main package definition
├── analysis_options.yaml                            # Dart lint rules
├── README.md                                        # Full documentation
├── QUICK_START.md                                   # Quick start guide
├── ARCHITECTURE.md                                  # Architecture & design docs
├── CHANGELOG.md                                     # Version history
└── LICENSE                                          # MIT License
```

## Key Files Overview

### Dart (lib/)
- **notification_permission_pro_impl.dart** (400 lines)
  - Main `NotificationPermissionPro` class
  - Singleton pattern with initialize()
  - Caching logic
  - Public API methods
  
- **permission_detector.dart** (100 lines)
  - Normalization logic
  - Platform-specific mappings
  - Request history awareness
  
- **permission_storage.dart** (100 lines)
  - SharedPreferences wrapper
  - Request tracking
  - Cache validation
  
- **permission_state.dart** (80 lines)
  - Enum definition
  - Extension methods for convenience

- **method_channel_permission.dart** (80 lines)
  - Platform channel bridge
  - Error handling
  - Native communication

### Platform Code
- **NotificationPermissionProPlugin.swift** (150 lines, iOS)
  - Swift implementation using UNUserNotificationCenter
  - All iOS authorization status types: authorized, provisional, ephemeral, denied, notDetermined, restricted
  - Permission request dialog handling
  - App settings navigation
  - Proper FlutterPlugin protocol conformance
  - Async/await with completion handlers
  
- **notification_permission_pro.podspec** (iOS)
  - CocoaPods pod specification for iOS plugin distribution
  - Swift 5.0+ configuration
  - Platform minimum requirement: iOS 11.0
  - Simulator architecture exclusion configuration
  
- **NotificationPermissionPro.kt** (150 lines, Android)
  - Kotlin implementation with multi-API level support
  - Android 4.3+ compatibility
  - Android 13+ POST_NOTIFICATIONS runtime permission
  - System notification toggle detection
  - FlutterPlugin & ActivityAware protocol implementation

### Tests
- **permission_state_test.dart** (60 lines)
  - Enum property tests
  - Description tests
  
- **permission_detector_test.dart** (130 lines)
  - iOS normalization tests
  - Android normalization tests
  
- **permission_storage_test.dart** (100 lines)
  - Persistence tests
  - Cache validation

### Documentation
- **README.md** - Complete user-facing documentation
- **QUICK_START.md** - Quick reference and patterns
- **ARCHITECTURE.md** - Technical design and implementation details

## Total Package Statistics

- **Dart Code**: ~800 lines (main implementation)
- **Swift Code**: ~150 lines (iOS)
- **Kotlin Code**: ~150 lines (Android)
- **Tests**: ~290 lines
- **Documentation**: ~500 lines
- **Total**: ~2,000 lines production-ready code

## Dependencies

**Runtime**:
- `shared_preferences` (lightweight local storage, < 2KB)

**Dev**:
- `flutter_test` (Flutter testing framework)
- `flutter_lints` (Dart linting)

**Zero external dependencies** for core functionality:
- No Firebase
- No additional notification packages
- No platform-specific plugins

## Build Configuration

### iOS
- Target: iOS 11.0+
- Swift 5+
- Uses native UserNotifications framework

### Android
- Min SDK: 18
- Target SDK: 33
- Targets Android 13+ and older versions
- Uses androidx core library
- Kotlin 1.7.10+

## Package Information

- **Name**: notification_permission_pro
- **Version**: 1.0.0
- **License**: MIT
- **Platform Support**: iOS 11+, Android 4.3+
- **Flutter Support**: 3.0.0+
- **Dart Support**: 3.0.0+

## Directory Explanation

```
lib/                    # Dart source code
├── src/               # Private implementation
│   ├── core/          # Core logic (normalization)
│   ├── models/        # Data models
│   ├── platform/      # Platform bridge
│   ├── storage/       # Persistence layer
│   └── impl.dart      # Main class

android/               # Android native code
├── src/main/kotlin/   # Kotlin source
│   └── ...Plugin.kt
└── src/main/          # Android configuration
    └── AndroidManifest.xml

ios/                   # iOS native code
├── Classes/           # Swift source
│   └── ...Plugin.swift
└── pubspec.yaml       # iOS plugin config

example/               # Example/demo app
├── lib/               # Flutter app code
└── pubspec.yaml       # App dependencies

test/                  # Unit tests
├── *_test.dart        # Test files
└── ...

Configuration Files:
├── pubspec.yaml       # Main package config
├── analysis_options.yaml  # Lint rules
├── README.md          # Documentation
├── CHANGELOG.md       # Version history
└── LICENSE            # MIT license
```
