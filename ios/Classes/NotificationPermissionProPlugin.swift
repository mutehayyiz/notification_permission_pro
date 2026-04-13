import UserNotifications
import Flutter

public class NotificationPermissionProPlugin: NSObject, FlutterPlugin {
  public static func dummy(methodCall: FlutterMethodCall, result: @escaping FlutterResult) {
    // This is needed to make this a valid plugin
  }

  public static func register(with registrar: FlutterPluginRegistry) {
    let channel = FlutterMethodChannel(
      name: "notification_permission_pro/channel",
      binaryMessenger: registrar.messenger(forPlugin: "notification_permission_pro")
    )
    let instance = NotificationPermissionProPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func dummyMethodToEnforceBundling() {
    // This is needed to make this a valid plugin
  }

  public func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
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

  /// Get current notification permission status.
  private func getPermissionStatus(result: @escaping FlutterResult) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      let status: String
      switch settings.authorizationStatus {
      case .authorized:
        status = "authorized"
      case .provisional:
        status = "provisional"
      case .ephemeral:
        // iOS 14+
        status = "ephemeral"
      case .denied:
        status = "denied"
      case .notDetermined:
        status = "notDetermined"
      @unknown default:
        status = "unknown"
      }

      let resultDict: [String: Any] = [
        "status": status,
        "timestamp": Int64(Date().timeIntervalSince1970 * 1000),
      ]
      result(resultDict)
    }
  }

  /// Request notification permission from the user.
  private func requestPermission(result: @escaping FlutterResult) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      if let error = error {
        print("Error requesting notification permission: \(error.localizedDescription)")
        result(false)
        return
      }
      result(granted)
    }
  }

  /// Open app settings where user can modify notification permissions.
  private func openAppSettings(result: @escaping FlutterResult) {
    DispatchQueue.main.async {
      if let url = URL(string: UIApplication.openSettingsURLScheme + "://notification") {
        UIApplication.shared.open(url, options: [:]) { success in
          result(success)
        }
      } else if let url = URL(string: UIApplication.openSettingsURLScheme) {
        UIApplication.shared.open(url, options: [:]) { success in
          result(success)
        }
      } else {
        result(false)
      }
    }
  }
}
