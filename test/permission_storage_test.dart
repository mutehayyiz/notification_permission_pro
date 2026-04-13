import 'package:flutter_test/flutter_test.dart';
import 'package:notification_permission_pro/src/storage/permission_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PermissionStorage', () {
    late PermissionStorage storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storage = PermissionStorage(prefs);
    });

    test('setState and getState work correctly', () async {
      await storage.setState('authorized');
      expect(storage.getState(), 'authorized');
    });

    test('getStateTimestamp returns recent timestamp after setState', () async {
      final before = DateTime.now().millisecondsSinceEpoch;
      await storage.setState('authorized');
      final after = DateTime.now().millisecondsSinceEpoch;
      final timestamp = storage.getStateTimestamp();

      expect(timestamp >= before, true);
      expect(timestamp <= after + 100, true);
    });

    test('wasPermissionRequested is false initially', () {
      expect(storage.wasPermissionRequested(), false);
    });

    test('wasPermissionRequested is true after markPermissionRequested',
        () async {
      await storage.markPermissionRequested();
      expect(storage.wasPermissionRequested(), true);
    });

    test('getRequestCount increments on each markPermissionRequested',
        () async {
      expect(storage.getRequestCount(), 0);
      await storage.markPermissionRequested();
      expect(storage.getRequestCount(), 1);
      await storage.markPermissionRequested();
      expect(storage.getRequestCount(), 2);
    });

    test('clear resets all data', () async {
      await storage.setState('authorized');
      await storage.markPermissionRequested();

      expect(storage.getState(), isNotNull);
      expect(storage.wasPermissionRequested(), true);
      expect(storage.getRequestCount(), 1);

      await storage.clear();

      expect(storage.getState(), isNull);
      expect(storage.wasPermissionRequested(), false);
      expect(storage.getRequestCount(), 0);
    });

    test('isCacheValid returns false for old cache', () async {
      // Set state in the past
      final prefs = await SharedPreferences.getInstance();
      const pastTimestamp = 0; // Very old
      await prefs.setInt(
        'notification_permission_pro_timestamp',
        pastTimestamp,
      );

      final isValid = storage.isCacheValid(const Duration(seconds: 5));
      expect(isValid, false);
    });

    test('isCacheValid returns true for fresh cache', () async {
      await storage.setState('authorized');
      final isValid = storage.isCacheValid(const Duration(seconds: 60));
      expect(isValid, true);
    });

    test('isCacheValid returns false before any state set', () {
      final isValid = storage.isCacheValid(const Duration(seconds: 5));
      expect(isValid, false);
    });
  });
}
