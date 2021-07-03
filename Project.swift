import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: "Routine",
  organizationName: "D&M",
  packages: SPMDependency.packages,
  settings: Settings(configurations: CustomConfiguration.project),
  targets: [
    .routineApp(
      dependencies: [
        .package(.pinLayout),
        .cocoapods(path: ".")
      ]
    ),
    .routineAppTests()
  ],
  schemes: Scheme.routine,
  resourceSynthesizers: .default
)
