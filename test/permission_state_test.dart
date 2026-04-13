import 'package:flutter_test/flutter_test.dart';
import 'package:notification_permission_pro/src/models/permission_state.dart';

void main() {
  group('PermissionState', () {
    test('granted state has correct properties', () {
      const state = PermissionState.granted;
      expect(state.isGranted, true);
      expect(state.isDenied, false);
      expect(state.isNotRequested, false);
      expect(state.isPermanentlyDenied, false);
      expect(state.isRestricted, false);
      expect(state.isUnknown, false);
    });

    test('denied state has correct properties', () {
      const state = PermissionState.denied;
      expect(state.isGranted, false);
      expect(state.isDenied, true);
      expect(state.isNotRequested, false);
      expect(state.isPermanentlyDenied, false);
      expect(state.isRestricted, false);
      expect(state.isUnknown, false);
    });

    test('notRequested state has correct properties', () {
      const state = PermissionState.notRequested;
      expect(state.isGranted, false);
      expect(state.isDenied, false);
      expect(state.isNotRequested, true);
      expect(state.isPermanentlyDenied, false);
      expect(state.isRestricted, false);
      expect(state.isUnknown, false);
    });

    test('permanentlyDenied state has correct properties', () {
      const state = PermissionState.permanentlyDenied;
      expect(state.isGranted, false);
      expect(state.isDenied, false);
      expect(state.isNotRequested, false);
      expect(state.isPermanentlyDenied, true);
      expect(state.isRestricted, false);
      expect(state.isUnknown, false);
    });

    test('restricted state has correct properties', () {
      const state = PermissionState.restricted;
      expect(state.isGranted, false);
      expect(state.isDenied, false);
      expect(state.isNotRequested, false);
      expect(state.isPermanentlyDenied, false);
      expect(state.isRestricted, true);
      expect(state.isUnknown, false);
    });

    test('unknown state has correct properties', () {
      const state = PermissionState.unknown;
      expect(state.isGranted, false);
      expect(state.isDenied, false);
      expect(state.isNotRequested, false);
      expect(state.isPermanentlyDenied, false);
      expect(state.isRestricted, false);
      expect(state.isUnknown, true);
    });

    test('descriptions are correct', () {
      expect(PermissionState.granted.description, 'Granted');
      expect(PermissionState.denied.description, 'Denied');
      expect(PermissionState.notRequested.description, 'Not Requested');
      expect(PermissionState.permanentlyDenied.description, 'Permanently Denied');
      expect(PermissionState.restricted.description, 'Restricted');
      expect(PermissionState.unknown.description, 'Unknown');
    });
  });
}
