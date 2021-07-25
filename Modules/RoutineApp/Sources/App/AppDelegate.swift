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
    Appearance.setup()
    
    let assemblyFactory = AssemblyFactory(serviceFactory: ServiceFactory())
    let tabBarVC = assemblyFactory.tabBarAssembly().controller()
    
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = tabBarVC
    window?.makeKeyAndVisible()
    
    return true
  }
}
