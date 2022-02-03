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
        .package(.iqKeyboardManager),
        .package(.actionSheetPicker),
        .package(.swipeCellKit),
        .cocoapods(path: ".")
      ]
    ),
    .routineAppTests()
  ],
  schemes: Scheme.routine,
  fileHeaderTemplate: "",
  additionalFiles: ["Modules/RoutineApp/Entitlements/**"],
  resourceSynthesizers: .default
)
