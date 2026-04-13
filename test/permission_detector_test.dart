import 'package:flutter_test/flutter_test.dart';
import 'package:notification_permission_pro/src/core/permission_detector.dart';
import 'package:notification_permission_pro/src/models/permission_state.dart';
import 'package:notification_permission_pro/src/storage/permission_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PermissionDetector', () {
    late PermissionDetector detector;
    late PermissionStorage storage;

    setUp(() async {
      // Mock SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storage = PermissionStorage(prefs);
      detector = PermissionDetector(storage);
    });

    group('Normalize iOS statuses', () {
      test('authorized maps to granted', () {
        final state = detector.normalize('authorized');
        expect(state, PermissionState.granted);
      });

      test('provisional maps to granted', () {
        final state = detector.normalize('provisional');
        expect(state, PermissionState.granted);
      });

      test('ephemeral maps to granted', () {
        final state = detector.normalize('ephemeral');
        expect(state, PermissionState.granted);
      });

      test('notDetermined maps to notRequested', () {
        final state = detector.normalize('notDetermined');
        expect(state, PermissionState.notRequested);
      });

      test('denied without request maps to denied', () async {
        final state = detector.normalize('denied');
        expect(state, PermissionState.denied);
      });

      test('denied after request maps to permanentlyDenied', () async {
        await storage.markPermissionRequested();
        final state = detector.normalize('denied');
        expect(state, PermissionState.permanentlyDenied);
      });

      test('restricted maps to restricted', () {
        final state = detector.normalize('restricted');
        expect(state, PermissionState.restricted);
      });
    });

    group('Normalize Android statuses', () {
      test('granted maps to granted', () {
        final state = detector.normalize('granted');
        expect(state, PermissionState.granted);
      });

      test('notRequested maps to notRequested', () {
        final state = detector.normalize('notRequested');
        expect(state, PermissionState.notRequested);
      });

      test('denied without request maps to denied', () {
        final state = detector.normalize('denied');
        expect(state, PermissionState.denied);
      });

      test('denied after request maps to permanentlyDenied', () async {
        await storage.markPermissionRequested();
        final state = detector.normalize('denied');
        expect(state, PermissionState.permanentlyDenied);
      });

      test('restricted maps to restricted', () {
        final state = detector.normalize('restricted');
        expect(state, PermissionState.restricted);
      });
    });

    group('Permission request handling', () {
      test('shouldRequestPermission is true for notRequested', () {
        final shouldRequest =
            detector.shouldRequestPermission(PermissionState.notRequested);
        expect(shouldRequest, true);
      });

      test('shouldRequestPermission is false for granted', () {
        final shouldRequest =
            detector.shouldRequestPermission(PermissionState.granted);
        expect(shouldRequest, false);
      });

      test('shouldRequestPermission is false for permanentlyDenied', () {
        final shouldRequest = detector
            .shouldRequestPermission(PermissionState.permanentlyDenied);
        expect(shouldRequest, false);
      });
    });

    group('App settings handling', () {
      test('shouldOpenSettings is true for permanentlyDenied', () {
        final shouldOpen =
            detector.shouldOpenSettings(PermissionState.permanentlyDenied);
        expect(shouldOpen, true);
      });

      test('shouldOpenSettings is true for restricted', () {
        final shouldOpen =
            detector.shouldOpenSettings(PermissionState.restricted);
        expect(shouldOpen, true);
      });

      test('shouldOpenSettings is false for granted', () {
        final shouldOpen =
            detector.shouldOpenSettings(PermissionState.granted);
        expect(shouldOpen, false);
      });
    });
  });
}
