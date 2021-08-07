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
        .package(.sfSafeSymbols),
        .package(.deviceKit),
        .package(.snapKit),
        .cocoapods(path: ".")
      ]
    ),
    .routineAppTests()
  ],
  schemes: Scheme.routine,
  fileHeaderTemplate: "",
  resourceSynthesizers: .default
)
