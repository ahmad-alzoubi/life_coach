import UIKit
import Flutter
import FirebaseAnalytics
import Clarity
import TikTokBusinessSDK

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    Analytics.setConsent([
      .analyticsStorage: .granted,
      .adStorage: .granted,
      .adUserData: .granted,
      .adPersonalization: .granted,
    ])
    let clarityConfig = ClarityConfig(projectId: "qfwbloalgo")
    ClaritySDK.initialize(config: clarityConfig)
    let config = TikTokConfig(accessToken: "TTbzDmthMjErecbOHL8gGXSDacuueu0t", appId: "6499420390", tiktokAppId: "7524648149428813832")
    TikTokBusiness.initializeSdk(config) { success, error in
        if (!success) { // initialization failed
            print(error!.localizedDescription)
        } else { // initialization successful
            print("TikTok SDK initialized successfully")
        }
    }
    
    // Set up MethodChannel
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "tiktok_events", binaryMessenger: controller.binaryMessenger)

      channel.setMethodCallHandler { call, result in
        switch call.method {
        case "trackEvent":
          if let args = call.arguments as? [String: Any],
             let eventName = args["event"] as? String {

            // Optionally get properties (not used by TikTok directly)
            let properties = args["properties"] as? [String: Any]

            let customEvent = TikTokBaseEvent(eventName:eventName)
            TikTokBusiness.trackTTEvent(customEvent)

            print("Tracked TikTok Event: \(eventName), props: \(properties ?? [:])")

            result(nil)
          } else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing event name", details: nil))
          }

        case "identify":
          if let args = call.arguments as? [String: Any] {
            let externalId = args["userId"] as? String ?? ""
            let externalUserName = args["userName"] as? String ?? ""
            let phoneNumber = args["phoneNumber"] as? String ?? ""
            let email = args["email"] as? String ?? ""

            // Identify TikTok User
            TikTokBusiness.identify(withExternalID: externalId, externalUserName: externalUserName, phoneNumber: phoneNumber, email: email)

            print("Identified TikTok User: \(externalId), \(externalUserName), \(phoneNumber), \(email)")

            result(nil)
          } else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing identifier", details: nil))
          }

        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
