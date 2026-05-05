import Flutter
import UIKit
import awesome_notifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Required for awesome_notifications background isolate to register plugins.
    SwiftAwesomeNotificationsPlugin.setPluginRegistrantCallback { registry in
      SwiftAwesomeNotificationsPlugin.register(
        with: registry.registrar(forPlugin:
          "io.flutter.plugins.awesomenotifications.AwesomeNotificationsPlugin")!)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
