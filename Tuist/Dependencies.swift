import ProjectDescription
import ProjectDescriptionHelpers

let dependencies = Dependencies(
  carthage: [],
  swiftPackageManager: .init(
    SPM.Package.packages,
    productTypes: [:],
    baseSettings: .settings(configurations: Configuration.dependecy),
    targetSettings: [:]
  ),
  platforms: [.iOS]
)
