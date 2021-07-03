import ProjectDescription

public enum SPMDependency: CaseIterable {
  case pinLayout
  case quick
  case nimble
  
  public static var packages: [Package] { allCases.map { $0.package } }
  
  public var name: String {
    switch self {
    case .pinLayout:  return "PinLayout"
    case .quick:      return "Quick"
    case .nimble:     return "Nimble"
    }
  }
  
  public var package: Package {
    switch self {
    case .pinLayout:  return .remote(url: url, requirement: .exact("1.10.0"))
    case .quick:      return .remote(url: url, requirement: .exact("4.0.0"))
    case .nimble:     return .remote(url: url, requirement: .exact("9.2.0"))
    }
  }
  
  private var url: String {
    switch self {
    case .pinLayout:  return "https://github.com/layoutBox/PinLayout"
    case .quick:      return "https://github.com/Quick/Quick.git"
    case .nimble:     return "https://github.com/Quick/Nimble.git"
    }
  }
}
