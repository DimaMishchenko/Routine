import Foundation

enum Theme: Codable {
  case light
  case dark
  case system
  
  @Defaults(key: .appTheme, initial: .system) static var current: Theme {
    didSet {
      CommonAppearance.setupTheme()
    }
  }
}

extension DefaultsKey {
  static let appTheme: DefaultsKey = "app.theme"
}
