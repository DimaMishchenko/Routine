import ProjectDescription

public enum CarthageDependency: CaseIterable {
  case pinLayout
  case quick
  case nimble
  
  public var name: String {
    switch self {
    case .pinLayout:  return "PinLayout"
    case .quick:      return "Quick"
    case .nimble:     return "Nimble"
    }
  }
  
  public var dependency: CarthageDependencies.Dependency {
    switch self {
    case .pinLayout:  return .github(path: "layoutBox/\(name)", requirement: .exact("1.10.0"))
    case .quick:      return .github(path: "Quick/\(name)", requirement: .exact("4.0.0"))
    case .nimble:     return .github(path: "Quick/\(name)", requirement: .exact("9.2.0"))
    }
  }
}
