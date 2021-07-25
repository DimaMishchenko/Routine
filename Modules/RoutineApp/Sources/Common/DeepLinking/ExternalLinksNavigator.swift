import UIKit

enum ExternalLinksNavigator {
  static func systemSettings() {
    open(with: URL(string: UIApplication.openSettingsURLString))
  }
  
  private static func open(with url: URL?) {
    url.flatMap {
      UIApplication.shared.open($0)
    }
  }
}
