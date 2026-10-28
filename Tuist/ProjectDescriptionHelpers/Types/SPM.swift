import ProjectDescription

public enum SPM {
  public enum Package: CaseIterable {
    case pinLayout
    case snapKit
    case swipeCellKit
    case spConfetti
    case charts
    case popovers
    case emojiPicker
    case ckSyncMonitor
    
    // MARK: - Public
    public static var packages: [ProjectDescription.Package.Dependency] { allCases.map { $0.package } }
    public var package: ProjectDescription.Package.Dependency { .package(url: url, requirement) }
    
    // MARK: - Private
    private var url: String {
      switch self {
      case .pinLayout:          return "https://github.com/layoutBox/PinLayout"
      case .snapKit:            return "https://github.com/SnapKit/SnapKit.git"
      case .swipeCellKit:       return "https://github.com/SwipeCellKit/SwipeCellKit"
      case .spConfetti:         return "https://github.com/ivanvorobei/SPConfetti"
      case .charts:             return "https://github.com/ChartsOrg/Charts.git"
      case .popovers:           return "https://github.com/aheze/Popovers"
      case .emojiPicker:        return "https://github.com/htmlprogrammist/EmojiPicker"
      case .ckSyncMonitor:      return "https://github.com/ggruen/CloudKitSyncMonitor.git"
      }
    }
    
    private var requirement: ProjectDescription.Package.Dependency.SourceControlRequirement {
      switch self {
      case .pinLayout:          return .exact("1.10.0")
      case .snapKit:            return .exact("5.7.1")
      case .swipeCellKit:       return .exact("2.7.1")
      case .spConfetti:         return .exact("1.4.0")
      case .charts:             return .exact("5.1.0")
      case .popovers:           return .exact("1.3.2")
      case .emojiPicker:        return .exact("3.0.9")
      case .ckSyncMonitor:      return .exact("1.2.0")
      }
    }
  }
  
  public enum Dependency {
    case pinLayout
    case snapKit
    case swipeCellKit
    case spConfetti
    case charts
    case popovers
    case emojiPicker
    case ckSyncMonitor
    
    // MARK: - Public
    public var name: String {
      switch self {
      case .pinLayout:          return "PinLayout"
      case .snapKit:            return "SnapKit"
      case .swipeCellKit:       return "SwipeCellKit"
      case .spConfetti:         return "SPConfetti"
      case .charts:             return "DGCharts"
      case .popovers:           return "Popovers"
      case .emojiPicker:        return "EmojiPicker"
      case .ckSyncMonitor:      return "CloudKitSyncMonitor"
      }
    }
  }
}
