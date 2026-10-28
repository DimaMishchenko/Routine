import ProjectDescription

extension TargetDependency {
  public static func spm(_ dependency: SPM.Dependency) -> TargetDependency {
    .package(product: dependency.name)
  }
  
}
