import Flutter
import UIKit
import os.log

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let didFinish = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    // Register native log channel after Flutter engine is ready
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      if let controller = self.window?.rootViewController as? FlutterViewController {
        let channel = FlutterMethodChannel(
          name: "com.inkbattle.app/native_log",
          binaryMessenger: controller.binaryMessenger
        )
        channel.setMethodCallHandler { (call, result) in
          guard call.method == "log" else { result.notImplemented(); return }
          let args = call.arguments as? [String: Any]
          let message = args?["message"] as? String ?? ""
          let tag = args?["tag"] as? String ?? "InkBattle"
          let level = (args?["level"] as? String)?.lowercased() ?? "info"
          let log = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.inkbattle.app", category: tag)
          switch level {
          case "error": os_log("%{public}@", log: log, type: .error, message)
          case "warning": os_log("%{public}@", log: log, type: .default, message)
          case "debug": os_log("%{public}@", log: log, type: .debug, message)
          default: os_log("%{public}@", log: log, type: .info, message)
          }
          result(nil)
        }
      }
    }
    return didFinish
  }
  
  // Handle URL schemes for Google and Facebook sign-in
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    return super.application(app, open: url, options: options)
  }
}
