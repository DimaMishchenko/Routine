import ProjectDescription

extension TargetDependency {
  public static func spm(_ dependency: SPM.Dependency) -> TargetDependency {
    .package(product: dependency.name)
  }
  
  public static func appExtension(_ appExtension: AppExtension) -> TargetDependency {
    .target(name: appExtension.name)
  }
}
