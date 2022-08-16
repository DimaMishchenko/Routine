import ProjectDescription

extension TargetDependency {
  public static func spm(_ dependency: SPM.Dependency) -> TargetDependency {
    .external(name: dependency.name)
  }
}
