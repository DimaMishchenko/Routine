import ProjectDescription

extension TargetDependency {
  public static func carthage(_ dependency: CarthageDependency) -> TargetDependency {
    .xcFramework(path: "Tuist/Dependencies/Carthage/\(dependency.name).xcframework")
  }
}
