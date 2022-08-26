import ProjectDescription

extension Configuration {
  internal static func name(for environment: Environment, type: Configuration.Variant) -> String {
    environment.rawValue.capitalized + type.rawValue.capitalized
  }
  
  public static var project: [Configuration] {
    configurations { .project(for: $0) }
  }
  
  public static var routine: [Configuration] {
    configurations { .routine(for: $0) }
  }
  
  // MARK: - Private
  private static func configurations(settingsProvider: (Environment) -> SettingsDictionary) -> [Configuration] {
    Environment.allCases.map { environment -> [Configuration] in
      [
        .debug(name: .configuration(name(for: environment, type: .debug)), settings: settingsProvider(environment)),
        .release(name: .configuration(name(for: environment, type: .release)), settings: settingsProvider(environment))
      ]
    }.flatMap { $0 }
  }
}
