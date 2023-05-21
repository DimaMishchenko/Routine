import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  // MARK: - Dependencies
  private let assemblyFactory: AssemblyFactory
  private let authenticator: Authenticator
  private let historyUpdater: RoutineHistoryUpdater
  
  // MARK: - Properties
  var window: UIWindow?
  
  private lazy var backgroundWindow: UIWindow = with(UIWindow(frame: UIScreen.main.bounds)) {
    $0.windowScene = window?.windowScene
    $0.rootViewController = assemblyFactory.blocker().controller()
    $0.windowLevel = .alert
  }
  
  @Defaults(key: .useFaceID, initial: false) private var authWithFaceID: Bool
  
  // MARK: - Init
  override init() {
    let serviceFactory = ServiceFactory(coreDataStack: CoreDataStackAssembly.routineStack(), purchases: .init())
    assemblyFactory = AssemblyFactory(serviceFactory: serviceFactory)
    authenticator = serviceFactory.authenticator()
    historyUpdater = serviceFactory.routineHistoryUpdater()
    IntentDependenciesRegisterer.register(with: serviceFactory)
    super.init()
  }
  
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
    
    updateBlockerIfNeeded(visible: true)
    CommonAppearance.setupTheme()
  }
  
  func sceneWillResignActive(_ scene: UIScene) {
    updateBlockerIfNeeded(visible: true)
  }
  
  func sceneDidBecomeActive(_ scene: UIScene) {
    updateBlockerIfNeeded(visible: false)
  }
  
  func sceneWillEnterForeground(_ scene: UIScene) {
    authIfNeeded()
  }

  // MARK: - Properties
  private func authIfNeeded() {
    guard authWithFaceID else { return }
    Task {
      guard await !authenticator.auth(biometryOnly: false) else { return }
      
      updateBlockerIfNeeded(visible: true)
      authIfNeeded()
    }
  }
  
  private func updateBlockerIfNeeded(visible: Bool) {
    guard authWithFaceID else { return }
    backgroundWindow.isHidden = !visible
  }
}
