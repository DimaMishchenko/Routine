import ProjectDescription

public enum SPM {
  public enum Package: CaseIterable {
    case pinLayout
    case quick
    case nimble
    case deviceKit
    case snapKit
    case swipeCellKit
    case spConfetti
    case charts
    case keychainAccess
    case popovers
    case emojiPicker
    case ckSyncMonitor
    case firebase
    
    // MARK: - Public
    public static var packages: [ProjectDescription.Package] { allCases.map { $0.package } }
    public var package: ProjectDescription.Package { .package(url: url, requirement) }
    
    // MARK: - Private
    private var url: String {
      switch self {
      case .pinLayout:          return "https://github.com/layoutBox/PinLayout"
      case .quick:              return "https://github.com/Quick/Quick.git"
      case .nimble:             return "https://github.com/Quick/Nimble.git"
      case .deviceKit:          return "https://github.com/devicekit/DeviceKit.git"
      case .snapKit:            return "https://github.com/SnapKit/SnapKit.git"
      case .swipeCellKit:       return "https://github.com/SwipeCellKit/SwipeCellKit"
      case .spConfetti:         return "https://github.com/ivanvorobei/SPConfetti"
      case .charts:             return "https://github.com/danielgindi/Charts.git"
      case .keychainAccess:     return "https://github.com/kishikawakatsumi/KeychainAccess.git"
      case .popovers:           return "https://github.com/aheze/Popovers"
      case .emojiPicker:        return "https://github.com/htmlprogrammist/EmojiPicker"
      case .ckSyncMonitor:      return "https://github.com/ggruen/CloudKitSyncMonitor.git"
      case .firebase:           return "https://github.com/firebase/firebase-ios-sdk.git"
      }
    }
    
    private var requirement: ProjectDescription.Package.Requirement {
      switch self {
      case .pinLayout:          return .upToNextMajor(from: "1.10.0")
      case .quick:              return .upToNextMajor(from: "4.0.0")
      case .nimble:             return .upToNextMajor(from: "9.2.0")
      case .deviceKit:          return .upToNextMajor(from: "4.6.0")
      case .snapKit:            return .upToNextMajor(from: "5.0.1")
      case .swipeCellKit:       return .upToNextMajor(from: "2.7.1")
      case .spConfetti:         return .upToNextMajor(from: "1.4.0")
      case .charts:             return .branch("master")
      case .keychainAccess:     return .upToNextMajor(from: "4.2.2")
      case .popovers:           return .upToNextMajor(from: "1.0.0")
      case .emojiPicker:        return .upToNextMajor(from: "3.0.9")
      case .ckSyncMonitor:      return .upToNextMajor(from: "1.2.0")
      case .firebase:           return .upToNextMajor(from: "9.1.0")
      }
    }
  }
  
  public enum Dependency {
    case pinLayout
    case quick
    case nimble
    case deviceKit
    case snapKit
    case swipeCellKit
    case spConfetti
    case charts
    case keychainAccess
    case popovers
    case emojiPicker
    case ckSyncMonitor
    case firebase(Firebase)
    
    public enum Firebase {
      case analytics
      case crashlytics
      case performance
    }
    
    // MARK: - Public
    public var name: String {
      switch self {
      case .pinLayout:          return "PinLayout"
      case .quick:              return "Quick"
      case .nimble:             return "Nimble"
      case .deviceKit:          return "DeviceKit"
      case .snapKit:            return "SnapKit"
      case .swipeCellKit:       return "SwipeCellKit"
      case .spConfetti:         return "SPConfetti"
      case .charts:             return "Charts"
      case .keychainAccess:     return "KeychainAccess"
      case .popovers:           return "Popovers"
      case .emojiPicker:        return "EmojiPicker"
      case .ckSyncMonitor:      return "CloudKitSyncMonitor"
      case .firebase(let type):
        switch type {
        case .analytics:        return "FirebaseAnalyticsWithoutAdIdSupport"
        case .crashlytics:      return "FirebaseCrashlytics"
        case .performance:      return "FirebasePerformance"
        }
      }
    }
  }
}
