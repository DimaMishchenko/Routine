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
        devices: [.iphone]
      ),
      infoPlist: .routineApp,
      sources: "Modules/RoutineApp/Sources/**",
      resources: "Modules/RoutineApp/Resources/**",
      actions: [
        .swiftlint,
        .crashlytics
      ],
      dependencies: dependencies,
      settings: Settings(configurations: CustomConfiguration.routine)
    )
  }
  
  public static func routineAppTests() -> Target {
    Target(
      name: "RoutineTests",
      platform: .iOS,
      product: .unitTests,
      bundleId: "com.dm.RoutineTests",
      infoPlist: .default,
      sources: ["Modules/RoutineApp/Tests/**"],
      dependencies: [
        .target(name: "RoutineApp"),
        .package(.quick),
        .package(.nimble)
      ]
    )
  }
}
