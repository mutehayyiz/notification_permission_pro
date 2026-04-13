import Flutter
import UIKit
import UserNotifications

public class NotificationPermissionPro: NSObject, FlutterPlugin {
  /// Required: Register the plugin with the Flutter engine
  /// This is called automatically by Flutter during app initialization
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "notification_permission_pro/channel",
      binaryMessenger: registrar.messenger()
    )
    let instance = NotificationPermissionPro()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  /// Required: Dummy method for FutterPlugin protocol conformance
  /// Ensures plugin is properly linked and not stripped by linker
  public static func dummyMethodToEnforceBundling() {}

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

    switch call.method {

    case "getPermissionStatus":
      getPermissionStatus(result: result)

    case "requestPermission":
      requestPermission(result: result)

    case "openAppSettings":
      openAppSettings(result: result)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func getPermissionStatus(result: @escaping FlutterResult) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in

      let status: String

      switch settings.authorizationStatus {
      case .authorized:
        status = "authorized"
      case .provisional:
        status = "provisional"
      case .ephemeral:
        status = "ephemeral"
      case .denied:
        status = "denied"
      case .notDetermined:
        status = "notDetermined"
      @unknown default:
        status = "unknown"
      }

      result([
        "status": status,
        "timestamp": Int64(Date().timeIntervalSince1970 * 1000)
      ])
    }
  }

  private func requestPermission(result: @escaping FlutterResult) {
    UNUserNotificationCenter.current().requestAuthorization(
      options: [.alert, .sound, .badge]
    ) { granted, error in

      if let error = error {
        print("Permission error: \(error)")
        result(false)
        return
      }

      result(granted)
    }
  }

  private func openAppSettings(result: @escaping FlutterResult) {
    DispatchQueue.main.async {
      guard let url = URL(string: UIApplication.openSettingsURLString) else {
        result(false)
        return
      }

      UIApplication.shared.open(url) { success in
        result(success)
      }
    }
  }
}