import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  private struct Runtime {
    let assemblyFactory: AssemblyFactory
    let historyUpdater: RoutineHistoryUpdater
  }

  private var runtime: Runtime?
  private(set) var lockState = AppLockState()
  private var authenticationTask: Task<Void, Never>?
  private var authenticationOperation: (() async -> Bool)?
  var window: UIWindow?

  private var backgroundWindow: UIWindow?

  @Defaults(key: .useFaceID, initial: false) private var authWithFaceID: Bool

  override init() {
    super.init()
  }

  init(authenticate: @escaping () async -> Bool) {
    authenticationOperation = authenticate
    super.init()
  }

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let scene = scene as? UIWindowScene else { return }
    LegacyTrackingCleanup.removeIdentifier()
    CommonAppearance.setup(for: scene)
    window = UIWindow(windowScene: scene)
    backgroundWindow = with(UIWindow(windowScene: scene)) {
      $0.rootViewController = BlockerAssembly().controller { [weak self] in self?.authenticate() }
      $0.windowLevel = .alert
    }
    connect(to: scene)
    CommonAppearance.setupTheme()
  }

  func sceneWillResignActive(_ scene: UIScene) {
    guard runtime != nil else { return }
    deactivateLock(protectionEnabled: authWithFaceID)
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    backgroundLock()
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    guard runtime != nil else { return }
    activateLock(protectionEnabled: authWithFaceID)
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
    runtime?.historyUpdater.handleForeground()
  }

  func sceneDidDisconnect(_ scene: UIScene) {
    backgroundLock()
  }

  func activateLock(protectionEnabled: Bool) {
    lockState.activate(protectionEnabled: protectionEnabled)
    updateBlocker()
    authenticateAutomaticallyIfNeeded()
  }

  func deactivateLock(protectionEnabled: Bool) {
    lockState.deactivate(protectionEnabled: protectionEnabled)
    updateBlocker()
  }

  func backgroundLock() {
    lockState.enterBackground()
    authenticationTask?.cancel()
    authenticationTask = nil
    updateBlocker()
  }

  private func connect(to scene: UIWindowScene) {
    do {
      let serviceFactory = try AppRuntime.shared.serviceFactory()
      let assemblyFactory = AssemblyFactory(serviceFactory: serviceFactory)
      let historyUpdater = serviceFactory.routineHistoryUpdater()
      let authenticator = serviceFactory.authenticator()
      authenticationOperation = { await authenticator.auth(biometryOnly: false) }
      runtime = Runtime(
        assemblyFactory: assemblyFactory,
        historyUpdater: historyUpdater
      )
      lockState.configure(protectionEnabled: authWithFaceID)
      window?.rootViewController = assemblyFactory.navigationAssembly().controller()
      window?.makeKeyAndVisible()
      updateBlocker()
      historyUpdater.handleAppLaunch()
      if scene.activationState == .foregroundActive {
        sceneDidBecomeActive(scene)
      }
    } catch {
      Logger.log(error)
      window?.rootViewController = StorageRecoveryVC { [weak self, weak scene] in
        guard let scene else { return }
        self?.connect(to: scene)
      }
      window?.makeKeyAndVisible()
    }
  }

  private func authenticateAutomaticallyIfNeeded() {
    guard lockState.shouldAuthenticateAutomatically else { return }
    authenticate()
  }

  func authenticate() {
    guard authenticationTask == nil, let operation = authenticationOperation,
      let generation = lockState.beginAuthentication() else { return }
    updateBlocker()
    authenticationTask = Task { [weak self] in
      guard let self else { return }
      let succeeded = await operation()
      guard !Task.isCancelled else { return }
      self.authenticationTask = nil
      let accepted = self.lockState.completeAuthentication(succeeded: succeeded, generation: generation)
      self.updateBlocker()
      if !accepted { self.authenticateAutomaticallyIfNeeded() }
    }
  }

  private func updateBlocker() {
    backgroundWindow?.isHidden = !lockState.blocksContent
    (window?.rootViewController as? RoutineNavigationController)?.setContentAvailable(
      !lockState.blocksContent && window?.windowScene?.activationState == .foregroundActive
    )
    (backgroundWindow?.rootViewController as? BlockerVC)?.update(authenticating: lockState.phase == .authenticating)
  }
}
