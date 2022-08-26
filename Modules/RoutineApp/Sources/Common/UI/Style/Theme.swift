import Foundation

enum Theme: Codable {
  case light
  case dark
  case system
  
  @Defaults(key: .key, initial: .system) static var current: Theme {
    didSet {
      CommonAppearance.setupTheme()
    }
  }
}

extension DefaultsKey {
  static let key: DefaultsKey = "app.theme"
}
