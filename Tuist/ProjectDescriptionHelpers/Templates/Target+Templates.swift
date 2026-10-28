import ProjectDescription

extension Target {
  public static func routineApp(dependencies: [TargetDependency] = []) -> Target {
    .target(
      name: "RoutineApp",
      destinations: [.iPhone, .iPad, .macCatalyst],
      product: .app,
      bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}",
      deploymentTargets: .iOS("26.0"),
      infoPlist: .routineApp,
      sources: "Modules/RoutineApp/Sources/**",
      resources: "Modules/RoutineApp/Resources/**",
      scripts: [
        .swiftlint
      ],
      dependencies: dependencies,
      settings: .settings(configurations: Configuration.routine),
      coreDataModels: [.coreDataModel("Modules/RoutineApp/CoreData/Routine.xcdatamodeld")]
    )
  }
  
  public static func routineAppTests() -> Target {
    .target(
      name: "RoutineAppTests",
      destinations: [.iPhone, .iPad, .macCatalyst],
      product: .unitTests,
      bundleId: "com.dm.routine.app.tests",
      deploymentTargets: .iOS("26.0"),
      infoPlist: .default,
      sources: ["Modules/RoutineApp/Tests/**"],
      dependencies: [
        .target(name: "RoutineApp")
      ],
      settings: .settings(configurations: Configuration.routineTests)
    )
  }
  
}
