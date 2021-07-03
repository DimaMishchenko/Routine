import ProjectDescription

extension TargetDependency {
  public static func package(_ dependency: SPMDependency) -> TargetDependency {
    .package(product: dependency.name)
  }
}
