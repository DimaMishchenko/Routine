import ProjectDescription

public enum SPMDependency: CaseIterable {
  case pinLayout
  case quick
  case nimble
  case sfSafeSymbols
  
  // MARK: - Public
  public static var packages: [Package] { allCases.map { $0.package } }
  
  public var name: String {
    switch self {
    case .pinLayout:      return "PinLayout"
    case .quick:          return "Quick"
    case .nimble:         return "Nimble"
    case .sfSafeSymbols:  return "SFSafeSymbols"
    }
  }
  
  public var package: Package { .remote(url: url, requirement: requirement) }
  
  // MARK: - Private
  private var url: String {
    switch self {
    case .pinLayout:      return "https://github.com/layoutBox/PinLayout"
    case .quick:          return "https://github.com/Quick/Quick.git"
    case .nimble:         return "https://github.com/Quick/Nimble.git"
    case .sfSafeSymbols:  return "https://github.com/piknotech/SFSafeSymbols.git"
    }
  }
  
  private var requirement: Package.Requirement {
    switch self {
    case .pinLayout:      return .upToNextMajor(from: "1.10.0")
    case .quick:          return .upToNextMajor(from: "4.0.0")
    case .nimble:         return .upToNextMajor(from: "9.2.0")
    case .sfSafeSymbols:  return .upToNextMajor(from: "2.1.3")
    }
  }
}
