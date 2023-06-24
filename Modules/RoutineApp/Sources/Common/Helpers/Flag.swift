import FirebaseRemoteConfig

enum Flag {
  static var enablePremium: Bool {
    let result = RemoteConfig.remoteConfig().configValue(forKey: "enablePremium")
    if result.source == .static { return true }
    return result.boolValue
  }

  static var appStoreLink: URL? {
    let result = RemoteConfig.remoteConfig().configValue(forKey: "appStoreLink")
    if result.source == .static { return nil }
    return result.stringValue.flatMap { URL(string: $0) }
  }

  static var contactEmail: String {
    let result = RemoteConfig.remoteConfig().configValue(forKey: "contactEmail")
    if result.source == .static { return "dimasike.dev@gmail.com" }
    return result.stringValue ?? "dimasike.dev@gmail.com"
  }

  static var tgSupportNick: String {
    let result = RemoteConfig.remoteConfig().configValue(forKey: "tgSupportNick")
    if result.source == .static { return "dimasik_karasik" }
    return result.stringValue ?? "dimasik_karasik"
  }

  static var maxFreeRoutines: Int {
    let result = RemoteConfig.remoteConfig().configValue(forKey: "maxFreeRoutines")
    if result.source == .static { return 5 }
    return result.numberValue.intValue
  }

  static var currectAppVersion: String? {
    let result = RemoteConfig.remoteConfig().configValue(forKey: "currectAppVersion")
    if result.source == .static { return nil }
    return result.stringValue
  }

  static var privacyPolicyLink: URL? {
    let result = RemoteConfig.remoteConfig().configValue(forKey: "privacyPolicyLink")
    if result.source == .static { return nil }
    return result.stringValue.flatMap { URL(string: $0) }
  }
}
