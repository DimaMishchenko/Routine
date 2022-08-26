import ProjectDescription

extension Target {
  public static func routineApp(dependencies: [TargetDependency] = []) -> Target {
    Target(
      name: "RoutineApp",
      platform: .iOS,
      product: .app,
      bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}",
      deploymentTarget: .iOS(
        targetVersion: "14.0",
        devices: [.iphone, .ipad, .mac]
      ),
      infoPlist: .routineApp,
      sources: "Modules/RoutineApp/Sources/**",
      resources: "Modules/RoutineApp/Resources/**",
      scripts: [
        .swiftlint
      ],
      dependencies: dependencies,
      settings: .settings(configurations: Configuration.routine),
      coreDataModels: [.init("Modules/RoutineApp/CoreData/Routine.xcdatamodeld")]
    )
  }
  
  public static func routineAppTests() -> Target {
    Target(
      name: "RoutineAppTests",
      platform: .iOS,
      product: .unitTests,
      bundleId: "com.dm.routine.app.tests",
      infoPlist: .default,
      sources: ["Modules/RoutineApp/Tests/**"],
      dependencies: [
        .target(name: "RoutineApp"),
        .spm(.quick),
        .spm(.nimble)
      ],
      settings: .settings(configurations: Configuration.routineTests)
    )
  }
}
