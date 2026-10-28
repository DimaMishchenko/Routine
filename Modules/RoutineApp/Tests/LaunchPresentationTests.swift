@testable import Routine
import UIKit
import XCTest

@MainActor final class LaunchPresentationTests: XCTestCase {
  private func withDefaults(_ body: (UserDefaults) -> Void) {
    let suite = "LaunchPresentationTests.\(UUID().uuidString)"
    guard let defaults = UserDefaults(suiteName: suite) else {
      XCTFail("Unable to create isolated preferences")
      return
    }
    defer { defaults.removePersistentDomain(forName: suite) }
    body(defaults)
  }

  func testNewUserSeesOnboardingBeforeFreeAnnouncement() {
    withDefaults { defaults in
      let model = NavigationViewModelImpl(defaults: defaults)
      XCTAssertEqual(model.nextPresentation(), .tutorial)
      XCTAssertNil(model.nextPresentation())
      model.completeTutorial()
      XCTAssertEqual(model.nextPresentation(), .freeAnnouncement)
    }
  }

  func testExistingUserSeesFreeAnnouncementOnceAcrossLaunches() {
    withDefaults { defaults in
      defaults.set("false", forKey: DefaultsKey.firstLaunch.rawValue)
      let model = NavigationViewModelImpl(defaults: defaults)
      XCTAssertEqual(model.nextPresentation(), .freeAnnouncement)
      model.announcementDidAppear()
      model.completeAnnouncement()
      XCTAssertNil(model.nextPresentation())
      XCTAssertNil(NavigationViewModelImpl(defaults: defaults).nextPresentation())
    }
  }

  func testInterruptedOnboardingRemainsRequired() {
    withDefaults { defaults in
      XCTAssertEqual(NavigationViewModelImpl(defaults: defaults).nextPresentation(), .tutorial)
      XCTAssertEqual(NavigationViewModelImpl(defaults: defaults).nextPresentation(), .tutorial)
    }
  }

  func testAnnouncementNotShownUntilActuallyPresented() {
    withDefaults { defaults in
      defaults.set("false", forKey: DefaultsKey.firstLaunch.rawValue)
      XCTAssertEqual(NavigationViewModelImpl(defaults: defaults).nextPresentation(), .freeAnnouncement)
      XCTAssertEqual(NavigationViewModelImpl(defaults: defaults).nextPresentation(), .freeAnnouncement)
    }
  }
  func testLaunchPresentationWaitsForAttachedUnlockedContent() {
    let controller = RoutineNavigationController(rootViewController: UIViewController())
    var presentations = 0
    controller.onAppear = { presentations += 1 }
    controller.setContentAvailable(true)
    XCTAssertEqual(presentations, 0)
    controller.setContentAvailable(false)
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
    window.rootViewController = controller
    window.isHidden = false
    defer { window.isHidden = true }
    controller.viewDidAppear(false)
    XCTAssertEqual(presentations, 0)
    controller.setContentAvailable(true)
    XCTAssertGreaterThan(presentations, 0)
    let beforeRelocking = presentations
    controller.setContentAvailable(false)
    controller.viewDidAppear(false)
    XCTAssertEqual(presentations, beforeRelocking)
    controller.setContentAvailable(true)
    XCTAssertGreaterThan(presentations, beforeRelocking)
  }
}
