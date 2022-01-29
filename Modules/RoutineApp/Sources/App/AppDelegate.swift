import Firebase
import IQKeyboardManagerSwift
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
    IQKeyboardManager.shared.enable = true
    IQKeyboardManager.shared.shouldPlayInputClicks = false
    Appearance.setup()
    
    let assemblyFactory = AssemblyFactory(serviceFactory: ServiceFactory())
    let tabBarVC = assemblyFactory.tabBarAssembly().controller()
    
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = tabBarVC
    window?.makeKeyAndVisible()
    
    return true
  }
}
