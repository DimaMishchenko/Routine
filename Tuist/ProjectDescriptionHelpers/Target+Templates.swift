import ProjectDescription

extension Target {
  public static func routineApp(dependencies: [TargetDependency] = []) -> Target {
    Target(
      name: "Routine",
      platform: .iOS,
      product: .app,
      bundleId: "com.dm.routine",
      deploymentTarget: .iOS(
        targetVersion: "13.0",
        devices: [.iphone]
      ),
      infoPlist: .extendingDefault(
        with: [
          "CFBundleShortVersionString": "0.0.1",
          "CFBundleVersion": "1",
          "UIMainStoryboardFile": "",
          "UILaunchStoryboardName": "LaunchScreen"
        ]
      ),
      sources: "Modules/RoutineApp/Sources/**",
      resources: "Modules/RoutineApp/Resources/**",
      actions: [.swiftlint],
      dependencies: dependencies
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
        .target(name: "Routine"),
        .xcFramework(path: "Tuist/Dependencies/Carthage/Quick.xcframework"),
        .xcFramework(path: "Tuist/Dependencies/Carthage/Nimble.xcframework")
      ]
    )
  }
}
