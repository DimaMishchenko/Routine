import ProjectDescription

extension SettingsDictionary {
  public static func project(for environment: Environment) -> SettingsDictionary {
    var settings: SettingsDictionary = [
      "ENVIRONMENT": .string(environment.rawValue),
      "CLANG_ANALYZER_LOCALIZABILITY_NONLOCALIZED": "YES",
      "SWIFT_VERSION": "5.0"
    ]
    if environment == .local {
      settings["CODE_SIGNING_ALLOWED"] = "NO"
    }
    return settings
  }

  public static func routine(for environment: Environment) -> SettingsDictionary {
    var settings: SettingsDictionary = [
      "PRODUCT_NAME": "Routine",
      "PRODUCT_BUNDLE_IDENTIFIER": .string(routineBundleId(for: environment)),
      "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
      "DERIVE_MACCATALYST_PRODUCT_BUNDLE_IDENTIFIER": false,
      "CODE_SIGN_IDENTITY[sdk=macosx*]": "Apple Development"
    ]
    switch environment {
    case .local:
      settings["CODE_SIGN_ENTITLEMENTS"] = ""
    case .dev:
      settings["CODE_SIGN_ENTITLEMENTS"] = "Modules/RoutineApp/Entitlements/RoutineAppDev.entitlements"
    case .prod:
      settings["CODE_SIGN_ENTITLEMENTS"] = "Modules/RoutineApp/Entitlements/RoutineAppProd.entitlements"
    }
    return settings
  }

  public static func routineTests() -> SettingsDictionary {
    ["TEST_HOST": "$(BUILT_PRODUCTS_DIR)/Routine.app/Routine"]
  }

  private static func routineBundleId(for environment: Environment) -> String {
    switch environment {
    case .local: return "org.example.routine.local"
    case .dev: return "com.dm.routine.app.dev"
    case .prod: return "com.dm.routine.app.prod"
    }
  }
}
