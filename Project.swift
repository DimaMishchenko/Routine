import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: "Routine",
  organizationName: "D&M",
  settings: Settings(configurations: CustomConfiguration.project),
  targets: [
    .routineApp(
      dependencies: [
        .carthage(.pinLayout)
      ]
    ),
    .routineAppTests()
  ],
  schemes: Scheme.routine,
  resourceSynthesizers: .default
)
