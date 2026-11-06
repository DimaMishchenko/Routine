import Combine
import Foundation
@testable import Routine
import SPConfetti
import UIKit
import XCTest

final class FreeAppTests: XCTestCase {
  func testPrivacyPolicyUsesProductionWebsite() {
    XCTAssertEqual(AppConfiguration.privacyPolicyLink?.absoluteString, "https://routine.dimasike.com/privacy.html")
  }

  func testFeedbackAndTermsKeepTheirDestinations() {
    XCTAssertEqual(AppConfiguration.supportLink?.absoluteString, "https://github.com/DimaMishchenko/Routine/issues")
    XCTAssertEqual(
      AppConfiguration.termsOfUseLink?.absoluteString,
      "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
    )
  }

  @MainActor func testAddRoutineUsesNativeSymbolButton() throws {
    let presenter = RoutineListPresenterImpl(
      store: FreeRoutineStore(routines: []),
      itemFactory: RoutineListItemFactoryImpl(),
      appStateObserver: FreeAppStateObserver(),
      notificationsHandler: FreeNotificationsHandler()
    )
    let controller = RoutineListVC(presenter: presenter)
    controller.loadViewIfNeeded()
    let add = try XCTUnwrap(controller.navigationItem.rightBarButtonItem)
    XCTAssertNil(add.customView)
    XCTAssertNotNil(add.image)
    XCTAssertEqual(add.style, .prominent)
    XCTAssertEqual(add.accessibilityLabel, RoutineAppStrings.Localizable.RoutineList.add)
  }

  @MainActor func testRoutineEditorUsesAccessibleSymbolButtons() throws {
    let presenter = RoutineEditPresenterImpl(
      moduleType: .new,
      itemFactory: RoutineEditItemFactoryImpl(),
      notificationsHandler: FreeNotificationsHandler()
    )
    let controller = RoutineEditVC(presenter: presenter)
    controller.loadViewIfNeeded()
    let cancel = try XCTUnwrap(controller.navigationItem.leftBarButtonItem)
    let save = try XCTUnwrap(controller.navigationItem.rightBarButtonItem)
    XCTAssertNil(cancel.title)
    XCTAssertNil(save.title)
    XCTAssertNotNil(cancel.image)
    XCTAssertNotNil(save.image)
    XCTAssertEqual(cancel.accessibilityLabel, RoutineAppStrings.Localizable.NavBar.cancel)
    XCTAssertEqual(save.accessibilityLabel, RoutineAppStrings.Localizable.NavBar.save)
  }

  func testCreatingRoutineRemainsAvailableAfterTwentyExistingRoutines() {
    let presenter = RoutineListPresenterImpl(
      store: FreeRoutineStore(routines: (0..<20).map { _ in .new }),
      itemFactory: RoutineListItemFactoryImpl(),
      appStateObserver: FreeAppStateObserver(),
      notificationsHandler: FreeNotificationsHandler()
    )
    var openedEditor = false
    presenter.addNewRoutine = { _ in openedEditor = true }
    presenter.viewDidLoad()
    presenter.addRoutine()
    XCTAssertTrue(openedEditor)
  }

  func testEnablingRemindersRequiresOnlyNotificationPermission() async {
    let enabled = expectation(description: "Reminder switch enabled")
    let view = FreeRoutineEditView {
      if $0.items.contains(where: { item in
        item.section == .remindMe && item.rows.contains(where: { row in
          if case .switch(let model) = row.type { return model.state }
          return false
        })
      }) {
        enabled.fulfill()
      }
    }
    let presenter = RoutineEditPresenterImpl(
      moduleType: .new,
      itemFactory: RoutineEditItemFactoryImpl(),
      notificationsHandler: FreeNotificationsHandler()
    )
    presenter.view = view
    presenter.remindMeChangeRequest(false)
    await fulfillment(of: [enabled], timeout: 2)
  }

  @MainActor func testSettingsOpenSourceRowTriggersRepositoryAction() async {
    let snapshotLoaded = expectation(description: "Settings source row loaded")
    var openSourceRequested = false
    let view = FreeSettingsView { snapshot in
      let sourceRows = snapshot.items.flatMap { $0.rows }.filter { row in
        if case .value(let model) = row.type {
          return model.title == RoutineAppStrings.Localizable.Settings.Row.openSource
        }
        return false
      }
      XCTAssertEqual(sourceRows.count, 1)
      if let row = sourceRows.first, case .value(let model) = row.type {
        XCTAssertNil(model.value)
        XCTAssertNotNil(model.icon)
        XCTAssertEqual(model.accessory, .disclosure)
        row.action?()
      }
      snapshotLoaded.fulfill()
    }
    let presenter = SettingsPresenterImpl(
      rowFactory: SettingsRowFactoryImpl(),
      appStateObserver: FreeAppStateObserver(),
      notificationsHandler: FreeNotificationsHandler(),
      authenticator: UnavailableBiometricsAuthenticator()
    )
    presenter.view = view
    presenter.openSource = { openSourceRequested = true }
    presenter.viewDidLoad()
    await fulfillment(of: [snapshotLoaded], timeout: 2)
    XCTAssertTrue(openSourceRequested)
    XCTAssertEqual(AppConfiguration.sourceLinkURL?.absoluteString, "https://github.com/DimaMishchenko/Routine")
  }

  @MainActor func testSettingsOnlyShowsICloudInCloudEnabledBuilds() async {
    let loaded = expectation(description: "Settings cloud availability loaded")
    let view = FreeSettingsView { snapshot in
      let cloudRows = snapshot.items.flatMap { $0.rows }.filter { row in
        guard case .value(let model) = row.type else { return false }
        return model.title == RoutineAppStrings.Localizable.Settings.Row.iCloudSync
      }
      XCTAssertEqual(cloudRows.count, Environment.current == .local ? 0 : 1)
      loaded.fulfill()
    }
    let presenter = SettingsPresenterImpl(
      rowFactory: SettingsRowFactoryImpl(),
      appStateObserver: FreeAppStateObserver(),
      notificationsHandler: FreeNotificationsHandler(),
      authenticator: UnavailableBiometricsAuthenticator()
    )
    presenter.view = view
    presenter.viewDidLoad()
    await fulfillment(of: [loaded], timeout: 2)
  }

  @MainActor func testSettingsSupportPrecedesMoreAndReplacesAuthorRows() async {
    let loaded = expectation(description: "Settings support row loaded")
    var supportRequested = false
    let view = FreeSettingsView { snapshot in
      let titles = snapshot.items.flatMap { $0.rows }.compactMap { row -> String? in
        guard case .value(let model) = row.type else { return nil }
        return model.title
      }
      XCTAssertFalse(titles.contains("Dima Mishchenko"))
      XCTAssertFalse(titles.contains("Misha"))
      XCTAssertEqual(Array(titles.suffix(7)), [
        String(localized: "support.title"),
        RoutineAppStrings.Localizable.Settings.Row.onboarding,
        RoutineAppStrings.Localizable.Settings.Row.openSource,
        RoutineAppStrings.Localizable.Settings.Row.acknowledgements,
        RoutineAppStrings.Localizable.Settings.Row.privacyPolicy,
        RoutineAppStrings.Localizable.Settings.Row.termsOfUse,
        RoutineAppStrings.Localizable.Settings.Row.appVersion
      ])
      let sectionTitles = snapshot.items.compactMap { $0.section?.model.title }
      XCTAssertEqual(Array(sectionTitles.suffix(4)), [
        RoutineAppStrings.Localizable.Settings.Section.security,
        RoutineAppStrings.Localizable.Settings.Section.feedback,
        String(localized: "settings.section.support"),
        RoutineAppStrings.Localizable.Settings.Section.more
      ])
      snapshot.items.first {
        $0.section?.model.title == String(localized: "settings.section.support")
      }?.rows.first?.action?()
      loaded.fulfill()
    }
    let presenter = SettingsPresenterImpl(
      rowFactory: SettingsRowFactoryImpl(),
      appStateObserver: FreeAppStateObserver(),
      notificationsHandler: FreeNotificationsHandler(),
      authenticator: UnavailableBiometricsAuthenticator()
    )
    presenter.view = view
    presenter.openSupport = { supportRequested = true }
    presenter.viewDidLoad()
    await fulfillment(of: [loaded], timeout: 2)
    XCTAssertTrue(supportRequested)
  }

  func testUnavailableBiometricsDoesNotDisableExistingProtection() {
    let defaults = UserDefaults.standard
    let originalPreference = defaults.object(forKey: "use.faceid")
    defer {
      if let originalPreference {
        defaults.set(originalPreference, forKey: "use.faceid")
      } else {
        defaults.removeObject(forKey: "use.faceid")
      }
    }
    defaults.set("true", forKey: "use.faceid")
    let presenter = SettingsPresenterImpl(
      rowFactory: SettingsRowFactoryImpl(),
      appStateObserver: FreeAppStateObserver(),
      notificationsHandler: FreeNotificationsHandler(),
      authenticator: UnavailableBiometricsAuthenticator()
    )
    withExtendedLifetime(presenter) {
      XCTAssertEqual(defaults.string(forKey: "use.faceid"), "true")
    }
  }

  @MainActor func testEnablingBiometricsReachesNativeAuthentication() async {
    let enabled = expectation(description: "Biometric protection enabled")
    var authenticationRequested = false
    let view = FreeSettingsView { snapshot in
      if snapshot.items.flatMap({ $0.rows }).contains(where: { row in
        if case .switch(let model, .faceID) = row.type { return model.state }
        return false
      }) {
        enabled.fulfill()
      }
    }
    let originalPreference = UserDefaults.standard.object(forKey: "use.faceid")
    defer {
      if let originalPreference {
        UserDefaults.standard.set(originalPreference, forKey: "use.faceid")
      } else {
        UserDefaults.standard.removeObject(forKey: "use.faceid")
      }
    }
    let presenter = SettingsPresenterImpl(
      rowFactory: SettingsRowFactoryImpl(),
      appStateObserver: FreeAppStateObserver(),
      notificationsHandler: FreeNotificationsHandler(),
      authenticator: FreeAuthenticator { authenticationRequested = true }
    )
    presenter.view = view
    presenter.faceIDStateUpdateRequest(false)
    await fulfillment(of: [enabled], timeout: 2)
    XCTAssertTrue(authenticationRequested)
  }
}

@MainActor extension FreeAppTests {
  func testConfettiIsEnabledWithoutSavedPreference() {
    withConfettiPreference {
      UserDefaults.standard.removeObject(forKey: DefaultsKey.confettiEnabled.rawValue)
      XCTAssertTrue(Confetti.isEnabled)
      XCTAssertTrue(AppearanceViewModelImpl().confettiEnabled)
    }
  }

  func testAppearancePersistsConfettiSelection() {
    withConfettiPreference {
      Confetti.isEnabled = true
      let model = AppearanceViewModelImpl()
      model.confettiEnabled = false
      XCTAssertFalse(Confetti.isEnabled)
      let reopenedModel = AppearanceViewModelImpl()
      XCTAssertFalse(reopenedModel.confettiEnabled)
      reopenedModel.confettiEnabled = true
      XCTAssertTrue(Confetti.isEnabled)
      XCTAssertTrue(AppearanceViewModelImpl().confettiEnabled)
    }
  }

  func testConfettiOnlyEmitsWhenEnabled() throws {
    try withConfettiPreference {
      let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
      let previousKeyWindow = scene.keyWindow
      let window = UIWindow(windowScene: scene)
      window.rootViewController = UIViewController()
      window.makeKeyAndVisible()
      defer {
        SPConfetti.stopAnimating()
        window.isHidden = true
        previousKeyWindow?.makeKey()
      }
      SPConfetti.stopAnimating()
      Confetti.isEnabled = false
      Confetti.run(with: "🎉")
      XCTAssertFalse(SPConfetti.isReleasesParticles)
      Confetti.isEnabled = true
      Confetti.run(with: "🎉")
      XCTAssertTrue(SPConfetti.isReleasesParticles)
    }
  }

  private func withConfettiPreference(_ body: () throws -> Void) rethrows {
    let defaults = UserDefaults.standard
    let key = DefaultsKey.confettiEnabled.rawValue
    let original = defaults.object(forKey: key)
    defer {
      if let original {
        defaults.set(original, forKey: key)
      } else {
        defaults.removeObject(forKey: key)
      }
    }
    try body()
  }
}

private final class FreeRoutineStore: RoutineStore {
  private let routines: [Routine]

  init(routines: [Routine]) { self.routines = routines }
  func allRoutines() async throws -> [Routine] { routines }
  func save(_ routine: Routine) async throws {}
  func update(_ routine: Routine) async throws {}
  func delete(_ routine: Routine) async throws {}
  func removeHistory(id: UUID, from routineID: UUID) async throws {}
  func fillHistoryIfNeeded() async throws {}
  func observeAll() -> AnyPublisher<[Routine], Error> {
    Just(routines).setFailureType(to: Error.self).eraseToAnyPublisher()
  }
}

private struct FreeAppStateObserver: AppStateObserver {
  func on(_ event: AppStateEvent) -> AnyPublisher<Void, Never> {
    Empty().eraseToAnyPublisher()
  }
}

private struct FreeNotificationsHandler: NotificationsHandler {
  func isAuthorized() async -> Bool { true }
  func request() async -> Bool { true }
  func reconcile(_ routines: [Routine]) async throws {}
  func clearDelivered() {}
}

private struct FreeAuthenticator: Authenticator {
  let onAuthenticate: () -> Void
  var biometryType: BiometryType { .faceID }
  func auth(biometryOnly: Bool) async -> Bool {
    onAuthenticate()
    return true
  }
  func isLockout() -> Bool { false }
}

private final class FreeRoutineEditView: RoutineEditViewInterface {
  let onUpdate: (Snapshot<RoutineEdit.Section, RoutineEdit.Row>) -> Void

  init(onUpdate: @escaping (Snapshot<RoutineEdit.Section, RoutineEdit.Row>) -> Void) {
    self.onUpdate = onUpdate
  }
  func update(title: String) {}
  func updateDelete(visibility isVisible: Bool) {}
  func update(with snapshot: Snapshot<RoutineEdit.Section, RoutineEdit.Row>) { onUpdate(snapshot) }
  func showAlert(with viewModel: Alert.VM) {}
}

@MainActor private final class FreeSettingsView: SettingsViewInterface {
  let onUpdate: (Snapshot<Settings.Section?, Settings.Row>) -> Void

  init(onUpdate: @escaping (Snapshot<Settings.Section?, Settings.Row>) -> Void) {
    self.onUpdate = onUpdate
  }
  func update(with snapshot: Snapshot<Settings.Section?, Settings.Row>) { onUpdate(snapshot) }
  func showAlert(with viewModel: Alert.VM) {}
}

private struct UnavailableBiometricsAuthenticator: Authenticator {
  var biometryType: BiometryType { .none }
  func auth(biometryOnly: Bool) async -> Bool { false }
  func isLockout() -> Bool { true }
}
