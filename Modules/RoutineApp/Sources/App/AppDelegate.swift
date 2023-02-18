import FirebaseMessaging
import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
  // MARK: - Properties
  var window: UIWindow?
  
  // MARK: - Public
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    application.registerForRemoteNotifications()
    return true
  }
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    #if DEBUG
    Logger.log(.debug, "FCM token \(Messaging.messaging().fcmToken ?? "nil")")
    #endif
  }
}
