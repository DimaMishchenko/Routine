import Foundation
import Security

enum LegacyTrackingCleanup {
  static func removeIdentifier() {
    guard let service = Bundle.main.bundleIdentifier else { return }
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: "userIdentifier",
      kSecAttrSynchronizable as String: false
    ]
    let result = SecItemDelete(query as CFDictionary)
    if result != errSecSuccess && result != errSecItemNotFound {
      Logger.log(.warning, "Unable to remove legacy tracking identifier: \(result)")
    }
  }
}
