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
  var biometryType: BiometryType {
    let context = LAContext()
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
    default: return .none
    }
  }

  func auth(biometryOnly: Bool) async -> Bool {
    let context = LAContext()
    defer { context.invalidate() }
    if biometryOnly { context.localizedFallbackTitle = .empty }
    let policy: LAPolicy = biometryOnly ? .deviceOwnerAuthenticationWithBiometrics : .deviceOwnerAuthentication
    do {
      return try await context.evaluatePolicy(
        policy,
        localizedReason: RoutineAppStrings.Localizable.FaceID.requestReason
      )
    } catch {
      guard biometryOnly, (error as? LAError)?.code == .biometryLockout else {
        Logger.log(error)
        return false
      }
      do {
        return try await context.evaluatePolicy(
          .deviceOwnerAuthentication,
          localizedReason: RoutineAppStrings.Localizable.FaceID.requestReason
        )
      } catch {
        Logger.log(error)
        return false
      }
    }
  }

  func isLockout() -> Bool {
    let context = LAContext()
    var error: NSError?
    _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    return (error as? LAError)?.code == .biometryLockout
  }
}
