import ProjectDescription
import ProjectDescriptionHelpers

let dependencies = Dependencies(
  carthage: CarthageDependencies(
    CarthageDependency.allCases.map { $0.dependency }
  ),
  platforms: [.iOS]
)
