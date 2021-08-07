import UIKit

enum ExternalLinksNavigator {
  static func systemSettings() {
    open(with: URL(string: UIApplication.openSettingsURLString))
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
