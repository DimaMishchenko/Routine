import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: "Routine",
  organizationName: "D&M",
  packages: SPMDependency.allCases.map { $0.package },
  settings: Settings(configurations: CustomConfiguration.project),
  targets: [
    .routineApp(
      dependencies: [
        .package(.pinLayout)
      ]
    ),
    .routineAppTests()
  ],
  schemes: Scheme.routine,
  resourceSynthesizers: .default
)
