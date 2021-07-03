import ProjectDescription

extension CustomConfiguration {
  internal static func name(for environment: Environment, type: CustomConfiguration.Variant) -> String {
    environment.rawValue.capitalized + type.rawValue.capitalized
  }
  
  public static var project: [CustomConfiguration] {
    configurations { .project(for: $0) }
  }
  
  public static var routine: [CustomConfiguration] {
    configurations { .routine(for: $0) }
  }
  
  // MARK: - Private
  private static func configurations(settingsProvider: (Environment) -> SettingsDictionary) -> [CustomConfiguration] {
    Environment.allCases.map { environment -> [CustomConfiguration] in
      [
        .debug(name: name(for: environment, type: .debug), settings: settingsProvider(environment)),
        .release(name: name(for: environment, type: .release), settings: settingsProvider(environment))
      ]
    }.flatMap { $0 }
  }
}
