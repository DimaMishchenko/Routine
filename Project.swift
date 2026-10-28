import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: "Routine",
  options: .options(
    automaticSchemesOptions: .disabled,
    textSettings: .textSettings(indentWidth: 2, tabWidth: 2)
  ),
  packages: SPM.Package.packages,
  settings: .settings(configurations: Configuration.project, defaultConfiguration: "LocalDebug"),
  targets: [
    .routineApp(
      dependencies: [
        .sdk(name: "StoreKit", type: .framework),
        .spm(.pinLayout),
        .spm(.snapKit),
        .spm(.swipeCellKit),
        .spm(.spConfetti),
        .spm(.charts),
        .spm(.popovers),
        .spm(.emojiPicker),
        .spm(.ckSyncMonitor)
      ]
    ),
    .routineAppTests()
  ],
  schemes: Scheme.routine,
  fileHeaderTemplate: "",
  additionalFiles: ["Modules/RoutineApp/Entitlements/**"],
  resourceSynthesizers: .default
)
