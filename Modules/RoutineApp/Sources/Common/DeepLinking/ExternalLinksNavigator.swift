import UIKit

enum ExternalLinksNavigator {
  static func systemSettings() {
    #if targetEnvironment(macCatalyst)
    open(with: URL(string: "x-apple.systempreferences:com.apple.preference.localization"))
    #else
    open(with: URL(string: UIApplication.openSettingsURLString))
    #endif
  }
  
  static func githubSupport() {
    open(with: AppConfiguration.supportLink)
  }
  
  static func macApp() {
    open(with: AppConfiguration.appLink)
  }
  
  static func writeReview() {
    guard
      let url = AppConfiguration.appLink,
      var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    else { return }
    components.queryItems = [URLQueryItem(name: "action", value: "write-review")]
    guard let reviewURL = components.url else { return }
    open(with: reviewURL)
  }
  private static func open(with url: URL?) {
    url.flatMap {
      UIApplication.shared.open($0)
    }
  }
}
