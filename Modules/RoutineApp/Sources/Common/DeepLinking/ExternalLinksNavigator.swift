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
    let tgAppLink = URL(string: "tg://resolve?domain=\(Flag.tgSupportNick)")
    
    if canOpen(tgAppLink) {
      open(with: tgAppLink)
    } else {
      open(with: URL(string: "https://github.com/DimaMishchenko/Routine/issues)"))
    }
  }
  
  static func twitter() {
    open(with: Flag.twitterLink)
  }
  
  static func macApp() {
    open(with: Flag.appStoreLink)
  }
  
  static func appStore() {
    open(with: Flag.appStoreLink)
  }
  
  static func writeReview() {
    guard
      let url = Flag.appStoreLink,
      var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    else { return }

    components.queryItems = [
      URLQueryItem(name: "action", value: "write-review")
    ]

    guard let writeReviewURL = components.url else { return }
    open(with: writeReviewURL)
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
