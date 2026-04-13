# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- iOS plugin now correctly conforms to `FlutterPlugin` protocol using `FlutterPluginRegistrar`
- iOS `register(with:)` method now uses correct `registrar.messenger()` API
- Android plugin class renamed to `NotificationPermissionPro` for consistency with pubspec.yaml
- Example app now uses singleton instance pattern correctly
- Example app request permission method now properly handles bool return value
- Example app type safety improved with correct Dart types

### Added
- iOS CocoaPods podspec (`ios/notification_permission_pro.podspec`) for proper plugin distribution
- iOS platform configuration in example app Info.plist
- Android platform configuration in example app AndroidManifest.xml
- Example app now fully tested and running on iOS 17.4 simulator
- Deep linking support for opening app settings

### Improved
- iOS plugin code now includes detailed comments for protocol conformance
- Example app UI now shows request history tracking
- Example app includes permission states documentation
- Better error handling in example app with user-friendly messaging

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
