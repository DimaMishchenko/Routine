import Foundation

@MainActor final class NavigationViewModelImpl {
  enum Presentation: Equatable {
    case tutorial
    case freeAnnouncement
  }

  private let defaults: UserDefaults
  private var presenting = false

  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
  }

  func nextPresentation() -> Presentation? {
    guard !presenting else { return nil }
    if defaults.string(forKey: DefaultsKey.firstLaunch.rawValue) != "false" {
      presenting = true
      return .tutorial
    }
    if !defaults.bool(forKey: "free.announcement.shown") {
      presenting = true
      return .freeAnnouncement
    }
    return nil
  }

  func completeTutorial() {
    defaults.set("false", forKey: DefaultsKey.firstLaunch.rawValue)
    presenting = false
  }

  func announcementDidAppear() {
    defaults.set(true, forKey: "free.announcement.shown")
  }

  func completeAnnouncement() {
    presenting = false
  }
}

extension DefaultsKey {
  static let firstLaunch: DefaultsKey = "first.launch"
}
