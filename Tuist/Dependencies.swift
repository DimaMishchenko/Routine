import Foundation

import ProjectDescription

let dependencies = Dependencies(
  carthage: [
    .github(path: "layoutBox/PinLayout", requirement: .exact("1.10.0")),
    .github(path: "Quick/Quick", requirement: .exact("4.0.0")),
    .github(path: "Quick/Nimble", requirement: .exact("9.2.0"))
  ],
  platforms: [.iOS]
)
