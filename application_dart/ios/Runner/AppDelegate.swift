import Flutter
import UIKit
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    GMSServices.provideAPIKey("AIzaSyA3eH1agsc9M4XQo4xe0SzobaYjgrJ3nc4")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
