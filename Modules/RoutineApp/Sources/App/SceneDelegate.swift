import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  private struct Runtime {
    let assemblyFactory: AssemblyFactory
    let authenticator: Authenticator
    let historyUpdater: RoutineHistoryUpdater
  }

  private var runtime: Runtime?
  private var lockState = AppLockState()
  private var authenticationTask: Task<Void, Never>?
  var window: UIWindow?

  private var backgroundWindow: UIWindow?

  @Defaults(key: .useFaceID, initial: false) private var authWithFaceID: Bool

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
    lockState.deactivate(protectionEnabled: authWithFaceID)
    updateBlocker()
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    lockState.enterBackground()
    updateBlocker()
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    guard runtime != nil else { return }
    lockState.activate(protectionEnabled: authWithFaceID)
    updateBlocker()
    authenticateAutomaticallyIfNeeded()
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
    runtime?.historyUpdater.handleForeground()
  }

  func sceneDidDisconnect(_ scene: UIScene) {
    lockState.enterBackground()
    authenticationTask?.cancel()
    updateBlocker()
  }

  private func connect(to scene: UIWindowScene) {
    do {
      let serviceFactory = try AppRuntime.shared.serviceFactory()
      let assemblyFactory = AssemblyFactory(serviceFactory: serviceFactory)
      let historyUpdater = serviceFactory.routineHistoryUpdater()
      runtime = Runtime(
        assemblyFactory: assemblyFactory,
        authenticator: serviceFactory.authenticator(),
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

  private func authenticate() {
    guard authenticationTask == nil, let runtime, let generation = lockState.beginAuthentication() else { return }
    updateBlocker()
    authenticationTask = Task { [weak self] in
      guard let self else { return }
      let succeeded = await runtime.authenticator.auth(biometryOnly: false)
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
