import Foundation
import KeychainAccess

enum UserIdentifier {
  // MARK: - Constants
  private enum Constants {
    static let userIdentifierKey = "userIdentifier"
  }
  
  // MARK: - Properties
  static var current: String { userIdentifier() }
  
  // MARK: - Private
  private static func userIdentifier() -> String {
    let keychain = Keychain()
      .accessibility(.afterFirstUnlock)
    if let identifier = keychain[Constants.userIdentifierKey] {
      return identifier
    } else {
      let identifier = UUID().uuidString
      keychain[Constants.userIdentifierKey] = identifier
      return identifier
    }
  }
}
