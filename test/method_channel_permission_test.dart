import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notification_permission_pro/src/platform/method_channel_permission.dart';

/// Tests for [MethodChannelPermission].
///
/// These tests mock the native platform channel to verify that:
/// - Correct method names are called on the channel
/// - Responses are correctly parsed and returned
/// - Null / error responses are handled gracefully
/// - Both iOS and Android response shapes are handled
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('notification_permission_pro/channel');

  setUp(() {
    // Reset any previously registered mock handlers
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  // ---------------------------------------------------------------------------
  // getPermissionStatus
  // ---------------------------------------------------------------------------

  group('getPermissionStatus', () {
    test('returns status map from iOS authorized response', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'getPermissionStatus');
        return {
          'status': 'authorized',
          'timestamp': 1700000000000,
        };
      });

      final result = await MethodChannelPermission.getPermissionStatus();

      expect(result['status'], 'authorized');
      expect(result['timestamp'], 1700000000000);
    });

    test('returns status map from Android granted response', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        return {
          'status': 'granted',
          'timestamp': 1700000000000,
        };
      });

      final result = await MethodChannelPermission.getPermissionStatus();

      expect(result['status'], 'granted');
    });

    test('returns status map from Android notRequested response', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        return {
          'status': 'notrequested',
          'timestamp': 1700000000000,
        };
      });

      final result = await MethodChannelPermission.getPermissionStatus();

      expect(result['status'], 'notrequested');
    });

    test('returns unknown status when platform returns null', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => null);

      final result = await MethodChannelPermission.getPermissionStatus();

      expect(result['status'], 'unknown');
      expect(result.containsKey('timestamp'), true);
    });

    test('returns unknown status on PlatformException', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(code: 'UNAVAILABLE', message: 'Not available');
      });

      final result = await MethodChannelPermission.getPermissionStatus();

      expect(result['status'], 'unknown');
      expect(result.containsKey('timestamp'), true);
    });

    test('iOS denied status is returned as-is', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        return {'status': 'denied', 'timestamp': 1700000000000};
      });

      final result = await MethodChannelPermission.getPermissionStatus();
      expect(result['status'], 'denied');
    });

    test('iOS notDetermined status is returned as-is', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        return {'status': 'notDetermined', 'timestamp': 1700000000000};
      });

      final result = await MethodChannelPermission.getPermissionStatus();
      expect(result['status'], 'notDetermined');
    });
  });

  // ---------------------------------------------------------------------------
  // requestPermission
  // ---------------------------------------------------------------------------

  group('requestPermission', () {
    test('returns true when platform grants permission', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'requestPermission');
        return true;
      });

      final result = await MethodChannelPermission.requestPermission();

      expect(result, true);
    });

    test('returns false when platform denies permission', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => false);

      final result = await MethodChannelPermission.requestPermission();

      expect(result, false);
    });

    test('returns false when platform returns null', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => null);

      final result = await MethodChannelPermission.requestPermission();

      expect(result, false);
    });

    test('returns false on PlatformException', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(code: 'ERROR', message: 'Request failed');
      });

      final result = await MethodChannelPermission.requestPermission();

      expect(result, false);
    });
  });

  // ---------------------------------------------------------------------------
  // openAppSettings
  // ---------------------------------------------------------------------------

  group('openAppSettings', () {
    test('calls openAppSettings method on channel without throwing', () async {
      var methodCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'openAppSettings');
        methodCalled = true;
        return true;
      });

      await MethodChannelPermission.openAppSettings();

      expect(methodCalled, true);
    });

    test('does not throw on PlatformException', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(code: 'SETTINGS_ERROR');
      });

      // Should not throw
      await expectLater(
        MethodChannelPermission.openAppSettings(),
        completes,
      );
    });
  });
}
