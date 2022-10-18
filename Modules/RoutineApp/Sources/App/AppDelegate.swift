import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
  // MARK: - Dependencies
  private let assemblyFactory: AssemblyFactory
  private let historyUpdater: RoutineHistoryUpdater
  
  // MARK: - Init
  override init() {
    let serviceFactory = ServiceFactory(coreDataStack: CoreDataStackAssembly.routineStack())
    assemblyFactory = AssemblyFactory(serviceFactory: serviceFactory)
    historyUpdater = serviceFactory.routineHistoryUpdater()
    super.init()
  }
  
  // MARK: - Properties
  var window: UIWindow?
  
  // MARK: - Public
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    FirebaseConfigureImpl().configure()
    CommonAppearance.setup()
    historyUpdater.handleAppLaunch()
    
    let tabBarVC = assemblyFactory.tabBarAssembly().controller()
    
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = tabBarVC
    window?.makeKeyAndVisible()
    
    CommonAppearance.setupTheme()
    
    return true
  }
}
