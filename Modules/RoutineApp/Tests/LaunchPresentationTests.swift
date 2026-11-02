@testable import Routine
import SwiftUI
import UIKit
import XCTest

@MainActor final class LaunchPresentationTests: XCTestCase {
  private final class GroupedContentController: UIViewController, NavigationContentLayout {
    var navigationContentInset: CGFloat { 20 }
  }
}

@MainActor extension LaunchPresentationTests {
  private final class DetailsLayoutModel: RoutineDetailsViewModel {
    let description = ""
    let statsVMs = ["Current streak", "Best streak", "Missed times", "Start date"].map {
      StatsViewModel(image: RoutineAppAsset.Icon.bestStreak.image, title: "1", description: $0)
    }
    let calendarVM = CalendarVM(selections: [])
    let barChartVM = BarChartVM(entries: [])
    let lineChartVM = LineChartVM(entries: [])
    let successRate = 0.0

    func close() {}
    func edit() {}
    func loadDetails() {}
    func select(date: Date) {}
    func deselect(date: Date) {}
  }

  func testDetailsContentFitsAfterResizingWithinWiderWindow() async throws {
    let host = RoutineDetailsVC(viewModel: DetailsLayoutModel())
    let container = UIViewController()
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1200, height: 1000))
    window.rootViewController = container
    container.addChild(host)
    container.view.addSubview(host.view)
    host.didMove(toParent: container)
    window.isHidden = false
    defer { window.isHidden = true }

    func descendants(of view: UIView) -> [UIView] {
      view.subviews.flatMap { [$0] + descendants(of: $0) }
    }

    for width: CGFloat in [951, 466, 669, 430] {
      host.view.frame = CGRect(x: 0, y: 0, width: width, height: 678)
      host.view.setNeedsLayout()
      host.view.layoutIfNeeded()
      try await Task.sleep(for: .milliseconds(100))
      host.view.layoutIfNeeded()
      let views = descendants(of: host.view)
      let scroll = try XCTUnwrap(views.compactMap { $0 as? UIScrollView }.first)
      let calendar = try XCTUnwrap(views.compactMap { $0 as? UICalendarView }.first)
      let calendarFrame = calendar.convert(calendar.bounds, to: host.view)
      XCTAssertLessThanOrEqual(scroll.contentSize.width, scroll.bounds.width + 1, "Width \(width)")
      XCTAssertGreaterThanOrEqual(calendarFrame.minX, -1, "Width \(width)")
      XCTAssertLessThanOrEqual(calendarFrame.maxX, width + 1, "Width \(width)")
      XCTAssertGreaterThan(calendarFrame.width, 200)
    }
  }

  func testDetailsSymbolButtonsRetainAccessibleNames() throws {
    let host = RoutineDetailsVC(viewModel: DetailsLayoutModel())
    host.loadViewIfNeeded()
    let close = try XCTUnwrap(host.navigationItem.leftBarButtonItem)
    let edit = try XCTUnwrap(host.navigationItem.rightBarButtonItem)
    XCTAssertNotNil(close.image)
    XCTAssertNotNil(edit.image)
    XCTAssertEqual(close.accessibilityLabel, RoutineAppStrings.Localizable.NavBar.close)
    XCTAssertEqual(edit.accessibilityLabel, RoutineAppStrings.Localizable.NavBar.edit)
  }
}

@MainActor extension LaunchPresentationTests {
  func testSettingsSwitchUsesSlidingStyle() throws {
    let cell = SwitchCell(frame: CGRect(x: 0, y: 0, width: 400, height: 44))
    func findSwitch(in view: UIView) -> UISwitch? {
      if let control = view as? UISwitch { return control }
      return view.subviews.lazy.compactMap { findSwitch(in: $0) }.first
    }
    let control = try XCTUnwrap(findSwitch(in: cell))
    XCTAssertEqual(control.preferredStyle, .sliding)
  }

  #if targetEnvironment(macCatalyst)
  func testMacUsesLargeNavigationTitlesInsteadOfWindowTitle() throws {
    let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
    XCTAssertEqual(scene.titlebar?.titleVisibility, .hidden)
    let navigation = ReadableNavigationController(rootViewController: UIViewController())
    let window = UIWindow(windowScene: scene)
    window.rootViewController = navigation
    window.isHidden = false
    defer { window.isHidden = true }
    window.layoutIfNeeded()
    XCTAssertEqual(navigation.navigationBar.behavioralStyle, .pad)
    XCTAssertTrue(navigation.navigationBar.prefersLargeTitles)
  }

  func testMacWindowHasBoundedSize() throws {
    let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
    let restrictions = try XCTUnwrap(scene.sizeRestrictions)
    XCTAssertEqual(restrictions.minimumSize, CGSize(width: 480, height: 560))
    XCTAssertEqual(restrictions.maximumSize, CGSize(width: 1000, height: 900))
  }
  #endif

  func testCollapsedNavigationTitleRemainsVisible() async throws {
    let controller = UIViewController()
    controller.title = "Settings"
    let contentView = SettingsView()
    controller.view = contentView
    contentView.update(with: Snapshot(items: [
      .init(section: nil, rows: (0..<40).map { index in .init(.value(.init(title: "Row \(index)"))) })
    ]))
    let navigation = ReadableNavigationController(rootViewController: UIViewController())
    navigation.setViewControllers([UIViewController(), controller], animated: false)
    navigation.navigationBar.prefersLargeTitles = true
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1376, height: 1032))
    window.rootViewController = navigation
    window.isHidden = false
    defer { window.isHidden = true }
    window.layoutIfNeeded()
    let scrollView = try XCTUnwrap(contentView.subviews.compactMap { $0 as? UICollectionView }.first)
    let loaded = expectation(description: "Settings content lays out")
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { loaded.fulfill() }
    await fulfillment(of: [loaded], timeout: 2)
    XCTAssertGreaterThan(scrollView.contentSize.height, window.bounds.height)
    scrollView.setContentOffset(CGPoint(x: 0, y: 400), animated: false)
    let settled = expectation(description: "Navigation layout settles")
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { settled.fulfill() }
    await fulfillment(of: [settled], timeout: 2)
    navigation.view.layoutIfNeeded()
    func visibleTitle(in view: UIView) -> Bool {
      guard !view.isHidden, view.alpha > 0.9 else { return false }
      if let label = view as? UILabel, label.text == "Settings" {
        return navigation.navigationBar.bounds.contains(label.convert(label.bounds, to: navigation.navigationBar))
      }
      return view.subviews.contains { visibleTitle(in: $0) }
    }
    XCTAssertTrue(visibleTitle(in: navigation.navigationBar))
  }

  func testNavigationTitleInsetsFollowContentAndResizing() {
    let navigation = ReadableNavigationController(rootViewController: UIViewController())
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1032, height: 1376))
    window.rootViewController = navigation
    window.isHidden = false
    defer { window.isHidden = true }

    for width: CGFloat in [1032, 1376, 1032] {
      window.frame.size.width = width
      window.layoutIfNeeded()
      for (controller, contentInset): (UIViewController, CGFloat) in [
        (UIViewController(), 16), (GroupedContentController(), 20), (UIViewController(), 16)
      ] {
        navigation.setViewControllers([controller], animated: false)
        navigation.view.setNeedsLayout()
        navigation.view.layoutIfNeeded()
        let bar = navigation.navigationBar
        let expectedInset = (bar.bounds.width - Size.View.contentWidth(for: bar.bounds.width)) / 2 + contentInset
        let isRightToLeft = bar.effectiveUserInterfaceLayoutDirection == .rightToLeft
        let leadingSafeArea = isRightToLeft ? bar.safeAreaInsets.right : bar.safeAreaInsets.left
        let trailingSafeArea = isRightToLeft ? bar.safeAreaInsets.left : bar.safeAreaInsets.right
        XCTAssertEqual(bar.directionalLayoutMargins.leading, expectedInset + leadingSafeArea, accuracy: 1)
        XCTAssertEqual(bar.directionalLayoutMargins.trailing, expectedInset + trailingSafeArea, accuracy: 1)
      }
    }
  }

  func testUIKitListsOnlyConstrainWideLayoutsAndRespondToResizing() throws {
    let contentViews: [UIView] = [RoutineListView(), SettingsView(), RoutineEditView()]
    for contentView in contentViews {
      let controller = UIViewController()
      controller.view = contentView
      let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 900))
      window.rootViewController = controller
      window.isHidden = false
      defer { window.isHidden = true }
      let widths: [(CGFloat, CGFloat)] = [
        (390, 390), (834, 834), (1032, 1032), (1100, 1100), (1194, 760), (1376, 760), (1032, 1032), (390, 390)
      ]
      for (width, expectedWidth) in widths {
        window.frame.size.width = width
        contentView.frame = window.bounds
        window.layoutIfNeeded()
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
        let collection = try XCTUnwrap(contentView.subviews.compactMap { $0 as? UICollectionView }.first)
        XCTAssertEqual(collection.frame.width, width, accuracy: 1)
        #if targetEnvironment(macCatalyst)
        XCTAssertEqual(Size.View.contentWidth(for: collection.bounds.width), min(width, 760), accuracy: 1)
        #else
        XCTAssertEqual(Size.View.contentWidth(for: collection.bounds.width), expectedWidth, accuracy: 1)
        #endif
        XCTAssertEqual(collection.contentInset.left, 0)
        XCTAssertEqual(collection.contentInset.right, 0)
        XCTAssertEqual(collection.center.x, width / 2, accuracy: 1)
      }
    }
  }

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

  func testTutorialIncludesFormerPaidBenefitsWithoutPurchaseMessaging() {
    let features = TutorialViewModelImpl(environment: .local).featuresVM.features
    let expectedBenefits = [
      (RoutineAppStrings.Localizable.Tutorial.Features.Unlimited.title,
       RoutineAppStrings.Localizable.Tutorial.Features.Unlimited.message),
      (RoutineAppStrings.Localizable.Tutorial.Features.Reminders.title,
       RoutineAppStrings.Localizable.Tutorial.Features.Reminders.message),
      (RoutineAppStrings.Localizable.Tutorial.Features.Security.title,
       RoutineAppStrings.Localizable.Tutorial.Features.Security.message)
    ]

    XCTAssertEqual(features.count, 5)
    for (title, description) in expectedBenefits {
      XCTAssertEqual(features.filter { $0.title == title && $0.description == description }.count, 1)
    }
    XCTAssertTrue(features.contains { $0.title == RoutineAppStrings.Localizable.Tutorial.Features.Maintain.title })
    XCTAssertTrue(features.contains { $0.title == RoutineAppStrings.Localizable.Tutorial.Features.Overview.title })
  }

  func testTutorialOnlyAdvertisesICloudInCloudEnabledEnvironments() {
    let localFeatures = TutorialViewModelImpl(environment: .local).featuresVM.features
    let cloudTitle = RoutineAppStrings.Localizable.Tutorial.Features.Icloud.title
    XCTAssertFalse(localFeatures.contains { $0.title == cloudTitle })

    for environment in [Environment.dev, .prod] {
      let features = TutorialViewModelImpl(environment: environment).featuresVM.features
      XCTAssertEqual(features.count, localFeatures.count + 1)
      XCTAssertEqual(Array(features.dropLast()).map(\.title), localFeatures.map(\.title))
      XCTAssertEqual(features.last?.title, cloudTitle)
      XCTAssertEqual(features.last?.description, RoutineAppStrings.Localizable.Tutorial.Features.Icloud.message)
    }
  }

  func testTutorialUsesCurrentBuildEnvironmentByDefault() {
    XCTAssertEqual(
      TutorialViewModelImpl().featuresVM.features.map(\.title),
      TutorialViewModelImpl(environment: .current).featuresVM.features.map(\.title)
    )
  }

  func testSupportStoryPreservesMultilineTextUnderHeightPressure() {
    let host = UIHostingController(rootView: FreeAnnouncementView.StoryView(context: .support))
    let fullSize = host.sizeThatFits(in: CGSize(width: 272, height: 10_000))
    let constrainedSize = host.sizeThatFits(in: CGSize(width: 272, height: 44))

    XCTAssertGreaterThan(fullSize.height, 200)
    XCTAssertEqual(constrainedSize.height, fullSize.height, accuracy: 1)
    XCTAssertLessThanOrEqual(constrainedSize.width, 272)
  }

  func testSupportFitsStandardPhoneAtDefaultTextSize() async throws {
    let host = UIHostingController(rootView:
      FreeAnnouncementView(context: .support, onContinue: {})
        .environment(\.dynamicTypeSize, .large)
    )
    host.navigationItem.largeTitleDisplayMode = .never
    let navigation = UINavigationController(rootViewController: host)
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
    window.rootViewController = navigation
    window.isHidden = false
    defer { window.isHidden = true }
    window.layoutIfNeeded()
    navigation.view.layoutIfNeeded()
    host.view.layoutIfNeeded()
    await Task.yield()
    host.view.layoutIfNeeded()

    func findScrollView(in view: UIView) -> UIScrollView? {
      if let scrollView = view as? UIScrollView { return scrollView }
      return view.subviews.lazy.compactMap { findScrollView(in: $0) }.first
    }

    let scrollView = try XCTUnwrap(findScrollView(in: host.view))
    let visibleHeight = scrollView.bounds.height
      - scrollView.adjustedContentInset.top
      - scrollView.adjustedContentInset.bottom
    XCTAssertGreaterThan(visibleHeight, 0)
    XCTAssertLessThanOrEqual(scrollView.contentSize.height, visibleHeight + 1)
  }

  func testSupportStoryRespondsToAccessibilityDynamicType() throws {
    #if targetEnvironment(macCatalyst)
    throw XCTSkip("Mac Catalyst system fonts do not scale with Dynamic Type, per Apple's typography guidelines.")
    #else
    let view = FreeAnnouncementView.StoryView(context: .support)
    let standardHost = UIHostingController(rootView: view.environment(\.dynamicTypeSize, .large))
    let accessibleHost = UIHostingController(rootView: view.environment(\.dynamicTypeSize, .accessibility5))
    let proposal = CGSize(width: 272, height: 10_000)
    let standardSize = standardHost.sizeThatFits(in: proposal)
    let accessibleSize = accessibleHost.sizeThatFits(in: proposal)

    XCTAssertGreaterThan(accessibleSize.height, standardSize.height)
    XCTAssertLessThanOrEqual(accessibleSize.width, proposal.width)
    #endif
  }

  func testSupportStoryWrapsAtNarrowWidths() {
    let host = UIHostingController(rootView: FreeAnnouncementView.StoryView(context: .support))
    let wideSize = host.sizeThatFits(in: CGSize(width: 512, height: 10_000))
    let narrowSize = host.sizeThatFits(in: CGSize(width: 272, height: 10_000))

    XCTAssertGreaterThan(narrowSize.height, wideSize.height)
    XCTAssertLessThanOrEqual(narrowSize.width, 272)
  }

  func testTutorialFeaturePreservesMultilineDescriptionUnderHeightPressure() throws {
    let feature = try XCTUnwrap(TutorialViewModelImpl().featuresVM.features.first)
    let view = TutorialView<TutorialViewModelImpl>.FeatureView(vm: .init(
      icon: feature.icon,
      title: feature.title,
      description: String(repeating: feature.description + " ", count: 6)
    ))
    let host = UIHostingController(rootView: view)
    let fullSize = host.sizeThatFits(in: CGSize(width: 272, height: 10_000))
    let constrainedSize = host.sizeThatFits(in: CGSize(width: 272, height: 44))

    XCTAssertGreaterThan(fullSize.height, 80)
    XCTAssertEqual(constrainedSize.height, fullSize.height, accuracy: 1)
    XCTAssertLessThanOrEqual(constrainedSize.width, 272)
  }

  func testTutorialFeatureRespondsToAccessibilityDynamicType() throws {
    let feature = try XCTUnwrap(TutorialViewModelImpl().featuresVM.features.first)
    let view = TutorialView<TutorialViewModelImpl>.FeatureView(vm: feature)
    let standardHost = UIHostingController(rootView: view.environment(\.dynamicTypeSize, .large))
    let accessibleHost = UIHostingController(rootView: view.environment(\.dynamicTypeSize, .accessibility5))
    let proposal = CGSize(width: 272, height: 10_000)
    let standardSize = standardHost.sizeThatFits(in: proposal)
    let accessibleSize = accessibleHost.sizeThatFits(in: proposal)

    XCTAssertGreaterThan(accessibleSize.height, standardSize.height)
    XCTAssertLessThanOrEqual(accessibleSize.width, proposal.width)
  }

  func testTutorialWelcomeWrapsAtAccessibilityDynamicType() throws {
    #if targetEnvironment(macCatalyst)
    throw XCTSkip("Mac Catalyst system fonts do not scale with Dynamic Type, per Apple's typography guidelines.")
    #else
    let view = TutorialView<TutorialViewModelImpl>.WelcomeView(vm: TutorialViewModelImpl().welcomeVM)
    let standardHost = UIHostingController(rootView: view.environment(\.dynamicTypeSize, .large))
    let accessibleHost = UIHostingController(rootView: view.environment(\.dynamicTypeSize, .accessibility5))
    let proposal = CGSize(width: 272, height: 10_000)
    let standardSize = standardHost.sizeThatFits(in: proposal)
    let accessibleSize = accessibleHost.sizeThatFits(in: proposal)

    XCTAssertGreaterThan(accessibleSize.height, standardSize.height)
    XCTAssertLessThanOrEqual(accessibleSize.width, proposal.width)
    #endif
  }

  func testTutorialWelcomeWrapsAtNarrowWidths() {
    let view = TutorialView<TutorialViewModelImpl>.WelcomeView(vm: TutorialViewModelImpl().welcomeVM)
    let host = UIHostingController(rootView: view)
    let wideSize = host.sizeThatFits(in: CGSize(width: 512, height: 10_000))
    let narrowSize = host.sizeThatFits(in: CGSize(width: 272, height: 10_000))
    let constrainedSize = host.sizeThatFits(in: CGSize(width: 272, height: 44))

    XCTAssertGreaterThan(narrowSize.height, wideSize.height)
    XCTAssertLessThanOrEqual(narrowSize.width, 272)
    XCTAssertEqual(constrainedSize.height, narrowSize.height, accuracy: 1)
  }
}
