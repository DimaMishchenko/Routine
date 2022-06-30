import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: "Routine",
  options: .options(
    automaticSchemesOptions: .disabled,
    textSettings: .textSettings(indentWidth: 2, tabWidth: 2)
  ),
  packages: SPMDependency.packages,
  settings: .settings(configurations: Configuration.project),
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
        .package(.spConfetti),
      ]
    ),
    .routineAppTests()
  ],
  schemes: Scheme.routine,
  fileHeaderTemplate: "",
  additionalFiles: ["Modules/RoutineApp/Entitlements/**"],
  resourceSynthesizers: .default
)
