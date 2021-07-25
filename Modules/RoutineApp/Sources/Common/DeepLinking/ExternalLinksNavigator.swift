import UIKit

enum ExternalLinksNavigator {
  static func systemSettings() {
    open(with: URL(string: UIApplication.openSettingsURLString))
  }
  
  static func telegramSupport() {
    open(with: URL(string: "https://github.com/DimaMishchenko/Routine/issues"))
  }
  
  private static func open(with url: URL?) {
    url.flatMap {
      UIApplication.shared.open($0)
    }
  }
}
