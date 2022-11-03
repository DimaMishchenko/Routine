import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
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
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let scene = scene as? UIWindowScene else { return }
    
    FirebaseConfigureImpl().configure()
    CommonAppearance.setup(for: scene)
    historyUpdater.handleAppLaunch()
    
    let navigationVC = assemblyFactory.navigationAssembly().controller()
    
    window = UIWindow(windowScene: scene)
    window?.rootViewController = navigationVC
    window?.makeKeyAndVisible()
    
    CommonAppearance.setupTheme()
  }
}
