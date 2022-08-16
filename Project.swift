import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: "Routine",
  options: .options(
    automaticSchemesOptions: .disabled,
    textSettings: .textSettings(indentWidth: 2, tabWidth: 2)
  ),
  settings: .settings(configurations: Configuration.project),
  targets: [
    .routineApp(
      dependencies: [
        .spm(.pinLayout),
        .spm(.deviceKit),
        .spm(.snapKit),
        .spm(.iqKeyboardManager),
        .spm(.swipeCellKit),
        .spm(.spConfetti),
        .spm(.firebase(.analytics)),
        .spm(.firebase(.crashlytics)),
        .spm(.firebase(.performance))
      ]
    ),
    .routineAppTests()
  ],
  schemes: Scheme.routine,
  fileHeaderTemplate: "",
  additionalFiles: ["Modules/RoutineApp/Entitlements/**"],
  resourceSynthesizers: .default
)
