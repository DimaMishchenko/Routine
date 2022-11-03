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
    Analytics.setUserID(UserIdentifier.current)
    Crashlytics.crashlytics().setUserID(UserIdentifier.current)
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
