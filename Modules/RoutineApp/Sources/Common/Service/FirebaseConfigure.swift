import Firebase

protocol FirebaseConfigure {
  func configure()
}

final class FirebaseConfigureImpl: FirebaseConfigure {
  // MARK: - Constants
  private enum Constants {
    enum ConfigFileName {
      static let dev = "Routine-Dev-GoogleService-Info"
      static let prod = "Routine-Prod-GoogleService-Info"
    }
    static let plistExtension = "plist"
  }
  
  // MARK: - Public
  func configure() {
    guard
      let configPath = configPath(),
      let options = FirebaseOptions(contentsOfFile: configPath)
    else {
      return
    }
    
    if FirebaseApp.app() == nil {
      FirebaseApp.configure(options: options)
    }
    Firebase.Analytics.setUserID(UserIdentifier.current)
    Crashlytics.crashlytics().setUserID(UserIdentifier.current)
    
    #if DEBUG
      Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)
    #else
      Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
    #endif

    let settings = RemoteConfigSettings()
    settings.minimumFetchInterval = .zero
    RemoteConfig.remoteConfig().configSettings = settings

    RemoteConfig.remoteConfig().fetch { status, error -> Void in
      if status == .success {
        RemoteConfig.remoteConfig().activate()
      } else {
        error.flatMap { Logger.log($0) }
      }
    }
    RemoteConfig.remoteConfig().addOnConfigUpdateListener { _, error in
      if let error {
        Logger.log(error)
        return
      }
      RemoteConfig.remoteConfig().activate()
    }
  }
  
  // MARK: - Private
  private func configPath() -> String? {
    switch Environment.current {
    case .dev:
      return Bundle.module.path(forResource: Constants.ConfigFileName.dev, ofType: Constants.plistExtension)
    case .prod:
      return Bundle.module.path(forResource: Constants.ConfigFileName.prod, ofType: Constants.plistExtension)
    }
  }
}
