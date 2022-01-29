import ProjectDescription

public enum SPMDependency: CaseIterable {
  case pinLayout
  case quick
  case nimble
  case sfSafeSymbols
  case deviceKit
  case snapKit
  case iqKeyboardManager
  case actionSheetPicker
  
  // MARK: - Public
  public static var packages: [Package] { allCases.map { $0.package } }
  
  public var name: String {
    switch self {
    case .pinLayout:          return "PinLayout"
    case .quick:              return "Quick"
    case .nimble:             return "Nimble"
    case .sfSafeSymbols:      return "SFSafeSymbols"
    case .deviceKit:          return "DeviceKit"
    case .snapKit:            return "SnapKit"
    case .iqKeyboardManager:  return "IQKeyboardManagerSwift"
    case .actionSheetPicker:  return "ActionSheetPicker-3.0"
    }
  }
  
  public var package: Package { .remote(url: url, requirement: requirement) }
  
  // MARK: - Private
  private var url: String {
    switch self {
    case .pinLayout:          return "https://github.com/layoutBox/PinLayout"
    case .quick:              return "https://github.com/Quick/Quick.git"
    case .nimble:             return "https://github.com/Quick/Nimble.git"
    case .sfSafeSymbols:      return "https://github.com/piknotech/SFSafeSymbols.git"
    case .deviceKit:          return "https://github.com/devicekit/DeviceKit.git"
    case .snapKit:            return "https://github.com/SnapKit/SnapKit.git"
    case .iqKeyboardManager:  return "https://github.com/hackiftekhar/IQKeyboardManager.git"
    case .actionSheetPicker:  return "https://github.com/skywinder/ActionSheetPicker-3.0"
    }
  }
  
  private var requirement: Package.Requirement {
    switch self {
    case .pinLayout:          return .upToNextMajor(from: "1.10.0")
    case .quick:              return .upToNextMajor(from: "4.0.0")
    case .nimble:             return .upToNextMajor(from: "9.2.0")
    case .sfSafeSymbols:      return .upToNextMajor(from: "2.1.3")
    case .deviceKit:          return .upToNextMajor(from: "4.0.0")
    case .snapKit:            return .upToNextMajor(from: "5.0.1")
    case .iqKeyboardManager:  return .upToNextMajor(from: "6.5.0")
    case .actionSheetPicker:  return .branch("develop")
    }
  }
}
