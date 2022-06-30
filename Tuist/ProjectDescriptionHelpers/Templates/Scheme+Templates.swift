import ProjectDescription

extension Scheme {
  public static var routine: [Scheme] {
    Environment.allCases.map { routine(for: $0) }
  }
  
  // MARK: - Private
  private static func routine(for environment: Environment) -> Scheme {
    let configurationName = (
      debug: Configuration.name(for: environment, type: .debug),
      release: Configuration.name(for: environment, type: .release)
    )
    
    let targetName = "RoutineApp"
    
    return Scheme(
      name: targetName + " " + environment.rawValue.capitalized,
      shared: true,
      buildAction: BuildAction(targets: ["\(targetName)"]),
      testAction: .targets(
        ["\(targetName)Tests"],
        configuration: .configuration(configurationName.debug),
        options: .options(coverage: true, codeCoverageTargets: ["\(targetName)"])
      ),
      runAction: .runAction(
        configuration: .configuration(configurationName.debug),
        executable: "\(targetName)",
        arguments: Arguments(
          environment: ["OS_ACTIVITY_MODE": "disable"]
        )
      ),
      archiveAction: .archiveAction(configuration: .configuration(configurationName.release)),
      profileAction: .profileAction(
        configuration: .configuration(configurationName.debug),
        executable: "\(targetName)"
      ),
      analyzeAction: .analyzeAction(configuration: .configuration(configurationName.debug))
    )
  }
}
