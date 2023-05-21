import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: "Routine",
  options: .options(
    automaticSchemesOptions: .disabled,
    textSettings: .textSettings(indentWidth: 2, tabWidth: 2)
  ),
  packages: SPM.Package.packages,
  settings: .settings(configurations: Configuration.project),
  targets: [
    .routineApp(
      dependencies: [
        .appExtension(.notificationsService),
        .sdk(name: "StoreKit", type: .framework),
        .spm(.pinLayout),
        .spm(.deviceKit),
        .spm(.snapKit),
        .spm(.swipeCellKit),
        .spm(.spConfetti),
        .spm(.charts),
        .spm(.keychainAccess),
        .spm(.popovers),
        .spm(.emojiPicker),
        .spm(.ckSyncMonitor),
        .spm(.revenueCat),
        .spm(.firebase(.analytics)),
        .spm(.firebase(.crashlytics)),
        .spm(.firebase(.performance)),
        .spm(.firebase(.messaging))
      ]
    ),
    .routineAppTests(),
    .appExtension(.notificationsService)
  ],
  schemes: Scheme.routine,
  fileHeaderTemplate: "",
  additionalFiles: ["Modules/RoutineApp/Entitlements/**"],
  resourceSynthesizers: .default
)
