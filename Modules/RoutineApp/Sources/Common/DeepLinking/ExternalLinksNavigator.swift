import UIKit

enum ExternalLinksNavigator {
  static func systemSettings() {
    #if targetEnvironment(macCatalyst)
    open(with: URL(string: "x-apple.systempreferences:com.apple.preference.localization"))
    #else
    open(with: URL(string: UIApplication.openSettingsURLString))
    #endif
  }
  
  static func telegramSupport() {
    // TODO: - Update contact url
    let tgAppLink = URL(string: "tg://resolve?domain=dimasik_karasik")
    
    if canOpen(tgAppLink) {
      open(with: tgAppLink)
    } else {
      open(with: URL(string: "https://github.com/DimaMishchenko/Routine/issues"))      
    }
  }
  
  static func macApp() {
    // TODO: - replace withr remote config
    open(with: URL(string: "https://apps.apple.com/us/app/routine-daily-tracker/id1643340709"))
  }
  
  // MARK: - Private
  private static func canOpen(_ url: URL?) -> Bool {
    url.flatMap { UIApplication.shared.canOpenURL($0) } ?? false
  }
  
  private static func open(with url: URL?) {
    url.flatMap {
      UIApplication.shared.open($0)
    }
  }
}
