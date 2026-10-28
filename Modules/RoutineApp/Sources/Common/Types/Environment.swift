import Foundation

enum Environment: String {
  private enum Constants {
    static let infoKey = "ENVIRONMENT"
  }
  
  case local
  case dev
  case prod
  
  static var current: Environment {
    guard
      let infoValue = Bundle.module.infoDictionary?[Constants.infoKey] as? String,
      let environment = Environment(rawValue: infoValue)
    else {
      fatalError("Environment is missing")
    }
    
    return environment
  }
}
