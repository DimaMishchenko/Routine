import LocalAuthentication

enum BiometryType {
  case none
  case touchID
  case faceID
}

protocol Authenticator {
  var biometryType: BiometryType { get }
  func auth(biometryOnly: Bool) async -> Bool
  func isLockout() -> Bool
}

final class AuthenticatorImpl: Authenticator {
  // MARK: - Dependencies
  private let context = LAContext()

  // MARK: - Properties
  var biometryType: BiometryType {
    var error: NSError?
    guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else { return .none }
    
    if let error = error {
      Logger.log(error)
      return .none
    }
    
    switch context.biometryType {
    case .none: return .none
    case .touchID: return .touchID
    case .faceID: return .faceID
    @unknown default: return .none
    }
  }

  func auth(biometryOnly: Bool) async -> Bool {
    defer { context.localizedFallbackTitle = nil }
    if biometryOnly { context.localizedFallbackTitle = .empty }
    
    let policy: LAPolicy = biometryOnly ? .deviceOwnerAuthenticationWithBiometrics : .deviceOwnerAuthentication
    do {
      return try await context.evaluatePolicy(policy, localizedReason: RoutineAppStrings.FaceID.requestReason)
    } catch {
      if isLockout() {
        return await auth(biometryOnly: false)
      } else {
        Logger.log(error)
        return false
      }
    }
  }
  
  func isLockout() -> Bool {
    var error: NSError?
    _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    return (error as? LAError)?.code == .biometryLockout
  }
}
