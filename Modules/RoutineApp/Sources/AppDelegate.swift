import Firebase
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
    FirebaseConfigureImpl().configure()
    
    window = UIWindow(frame: UIScreen.main.bounds)
    let viewController = UIViewController()
    viewController.view.backgroundColor = .green
    window?.rootViewController = viewController
    window?.makeKeyAndVisible()
    
    return true
  }
}
