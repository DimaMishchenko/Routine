import Foundation

enum AppInfo {
  // MARK: - Constants
  private enum Constants {
    static let shortVersion = "CFBundleShortVersionString"
  }
  
  // MARK: - Fields
  static let appVersion = Bundle.main.infoDictionary?[Constants.shortVersion] as? String
}
