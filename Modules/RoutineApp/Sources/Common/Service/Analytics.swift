import FirebaseAnalytics

enum Analytics {
  static func send(_ event: Event, parameters: [Param: Any]? = nil) {
    FirebaseAnalytics.Analytics.logEvent(
      event.rawValue,
      parameters: parameters?.reduce(into: [:]) { $0[$1.key.rawValue] = $1.value }
    )
  }
}

extension Analytics {
  struct Event: Hashable, RawRepresentable, ExpressibleByStringLiteral {
    let rawValue: String
    init(rawValue: String) { self.rawValue = rawValue }
    init(stringLiteral value: String) { rawValue = value }
  }
  
  struct Param: Hashable, RawRepresentable, ExpressibleByStringLiteral {
    let rawValue: String
    init(rawValue: String) { self.rawValue = rawValue }
    init(stringLiteral value: String) { rawValue = value }
  }
}

extension Analytics.Event {
  static let createRoutine: Self = "create_routine"
  static let deleteRoutine: Self = "delete_routine"
  static let routineComplete: Self = "routine_complete"
  static let paywallOpen: Self = "paywall_open"
  static let restorePurchases: Self = "restore_purchases"
  static let purchase: Self = "purchase"
  static let rateApp: Self = "rate_app"
  static let supportMail: Self = "support_mail"
  static let supportTG: Self = "support_tg"
  static let share: Self = "share"
  static let macLink: Self = "mac_link"
  static let intentComplete: Self = "intent_complete"
  static let intentIncrease: Self = "intent_increase"
  static let biometrics: Self = "biometrics"
  static let updateApp: Self = "update_app"
}

extension Analytics.Param {
  static let frequency: Self = "frequency"
  static let subscribed: Self = "subscribed"
  static let purchaseId: Self = "purchase_id"
  static let biometricsEnabled: Self = "biometrics_enabled"
}
