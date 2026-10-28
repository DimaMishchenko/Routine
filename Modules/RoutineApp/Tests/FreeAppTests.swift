import Combine
import Foundation
@testable import Routine
import XCTest

final class FreeAppTests: XCTestCase {
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
        XCTAssertEqual(model.value, .text(RoutineAppStrings.Localizable.Common.github))
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
