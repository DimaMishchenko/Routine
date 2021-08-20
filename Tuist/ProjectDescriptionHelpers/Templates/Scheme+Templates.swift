import ProjectDescription

extension Scheme {
  public static var routine: [Scheme] {
    Environment.allCases.map { routine(for: $0) }
  }
  
  // MARK: - Private
  private static func routine(for environment: Environment) -> Scheme {
    let configurationName = (
      debug: CustomConfiguration.name(for: environment, type: .debug),
      release: CustomConfiguration.name(for: environment, type: .release)
    )
    
    let targetName = "RoutineApp"
    
    return Scheme(
      name: targetName + " " + environment.rawValue.capitalized,
      shared: true,
      buildAction: BuildAction(targets: ["\(targetName)"]),
      testAction: TestAction(
        targets: ["\(targetName)Tests"],
        configurationName: configurationName.debug,
        coverage: true,
        codeCoverageTargets: ["\(targetName)"]
      ),
      runAction: RunAction(
        configurationName: configurationName.debug,
        executable: "\(targetName)",
        arguments: Arguments(
          environment: ["OS_ACTIVITY_MODE": "disable"]
        )
      ),
      archiveAction: ArchiveAction(configurationName: configurationName.release),
      profileAction: ProfileAction(
        configurationName: configurationName.debug,
        executable: "\(targetName)"
      ),
      analyzeAction: AnalyzeAction(configurationName: configurationName.debug)
    )
  }
}
