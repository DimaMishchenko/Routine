import ProjectDescription

extension SettingsDictionary {
  public static func project(for environment: Environment) -> SettingsDictionary {
    [
      "ENVIRONMENT": .string(environment.rawValue),
      "DEVELOPMENT_TEAM": "77X75EH6F4",
      "CLANG_ANALYZER_LOCALIZABILITY_NONLOCALIZED": "YES"
    ]
  }
  
  public static func routine(for environment: Environment) -> SettingsDictionary {
    [
      "PRODUCT_BUNDLE_IDENTIFIER": .string(routineBundleId(for: environment)),
      "GOOGLE_SERVICE_INFO_NAME": .string(routineGoogleInfoName(for: environment)),
      "CODE_SIGN_ENTITLEMENTS": .string(routineEntitlementsPath(for: environment)),
      "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
      "OTHER_LDFLAGS": ["$(inherited)", "-ObjC"]
    ]
  }
  
  // MARK: - Private
  private static func routineBundleId(for environment: Environment) -> String {
    let base = "com.dm.routine.app"
    
    switch environment {
    case .dev:  return base + "." + "dev"
    case .prod: return base
    }
  }
  
  private static func routineGoogleInfoName(for environment: Environment) -> String {
    switch environment {
    case .dev:  return "Routine-Dev-GoogleService-Info"
    case .prod: return "Routine-Prod-GoogleService-Info"
    }
  }
  
  private static func routineEntitlementsPath(for environment: Environment) -> String {
    switch environment {
    case .dev:  return "Modules/RoutineApp/Entitlements/RoutineAppDev.entitlements"
    case .prod: return "Modules/RoutineApp/Entitlements/RoutineApp.entitlements"
    }
  }
}
