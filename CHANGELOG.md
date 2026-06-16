# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2026-06-17

### Fixed
- Added missing `android/build.gradle` with correct namespace (`com.example.notification_permission_pro`), `compileSdk 34`, `minSdk 21`, Java/Kotlin 17
- Fixed `.gitignore` to no longer suppress `android/build.gradle` (added `!**/android/**/build.gradle` exception)
- Fixed iOS `pluginClass` mismatch in `ios/pubspec.yaml` (was `NotificationPermissionProPlugin`, now matches actual Swift class `NotificationPermissionPro`)
- Fixed podspec placeholder values: updated `homepage`, `author`, and `email` to real project values
- Fixed wrong Android file path in `ARCHITECTURE.md` (was `NotificationPermissionProPlugin.kt`, now `NotificationPermissionPro.kt`)

## [1.0.1] - 2026-04-13


### Fixed
- Corrected GitHub repository URL from placeholder to actual repository URL
- Fixed Dart analyzer issues (deprecated lints and type safety warnings)
- Removed deprecated `invariant_booleans` lint from analysis_options.yaml
- Added `kDebugMode` guards to debug print statements

## [1.0.0] - 2026-04-13

### Added
- Initial release of `notification_permission_pro`
- Unified permission state model (`PermissionState` enum)
- iOS support using `UNUserNotificationCenter.getNotificationSettings()`
- Android support for runtime permissions and system checks
- Local storage for permission request history
- 5-second caching strategy for performance
- Full normalization logic for platform states
- Example app demonstrating all features
- Comprehensive documentation and API reference
- Production-ready implementation
- 34 comprehensive unit tests covering all core functionality
- Git repository with Flutter best practices .gitignore
