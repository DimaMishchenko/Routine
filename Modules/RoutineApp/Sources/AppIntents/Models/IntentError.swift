import Foundation

enum IntentError: Error, LocalizedError {
  case noDependencies
  
  var errorDescription: String? {
    switch self {
    case .noDependencies: return "Oops, something went wrong; please try reloading the application"
    }
  }
}
