import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: "Routine",
  organizationName: "D&M",
  targets: [
    .routineApp(
      dependencies: [
        .xcFramework(path: "Tuist/Dependencies/Carthage/PinLayout.xcframework")
      ]
    ),
    .routineAppTests()
  ],
  resourceSynthesizers: .default
)
