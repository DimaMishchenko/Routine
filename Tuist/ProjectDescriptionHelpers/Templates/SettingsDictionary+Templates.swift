import ProjectDescription

extension SettingsDictionary {
  public static func project(for environment: Environment) -> SettingsDictionary {
    [
      "ENVIRONMENT": .string(environment.rawValue)
    ]
  }
  
  public static func routine(for environment: Environment) -> SettingsDictionary {
    [
      "PRODUCT_BUNDLE_IDENTIFIER": .string(routineBundleId(for: environment))
    ]
  }
  
  // MARK: - Private
  private static func routineBundleId(for environment: Environment) -> String {
    let base = "com.dm.routine"
    
    switch environment {
    case .dev:  return base + "." + "dev"
    case .prod: return base
    }
  }
}
