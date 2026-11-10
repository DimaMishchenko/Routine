@testable import Routine
import XCTest

final class RoutineEditPresenterTests: XCTestCase {
  @MainActor func testAuthorizedReminderUpdatesViewOnMainThread() async {
    await assertPermissionResult(authorized: true, granted: false, expectsAlert: false)
  }

  @MainActor func testFirstPermissionGrantUpdatesViewOnMainThread() async {
    await assertPermissionResult(authorized: false, granted: true, expectsAlert: false)
  }

  @MainActor func testPermissionDenialShowsAlertOnMainThread() async {
    await assertPermissionResult(authorized: false, granted: false, expectsAlert: true)
  }

  @MainActor private func assertPermissionResult(authorized: Bool, granted: Bool, expectsAlert: Bool) async {
    let completed = expectation(description: "Permission result reaches the editor")
    let view = PermissionResultView(expectsAlert: expectsAlert, completed: completed)
    let presenter = RoutineEditPresenterImpl(
      moduleType: .new,
      itemFactory: RoutineEditItemFactoryImpl(),
      notificationsHandler: PermissionHandler(authorized: authorized, granted: granted)
    )
    presenter.view = view
    presenter.remindMeChangeRequest(false)
    await fulfillment(of: [completed], timeout: 3)
  }
}

private final class PermissionResultView: RoutineEditViewInterface {
  let expectsAlert: Bool
  let completed: XCTestExpectation

  init(expectsAlert: Bool, completed: XCTestExpectation) {
    self.expectsAlert = expectsAlert
    self.completed = completed
  }

  func update(title: String) {}
  func updateDelete(visibility isVisible: Bool) {}

  func update(with snapshot: Snapshot<RoutineEdit.Section, RoutineEdit.Row>) {
    XCTAssertTrue(Thread.isMainThread, "Permission results must update UIKit on the main thread")
    XCTAssertFalse(expectsAlert)
    let enabled = snapshot.items.flatMap(\.rows).contains {
      if case .switch(let model) = $0.type { return model.state }
      return false
    }
    XCTAssertTrue(enabled)
    completed.fulfill()
  }

  func showAlert(with viewModel: Alert.VM) {
    XCTAssertTrue(Thread.isMainThread, "Permission denial must present UIKit alerts on the main thread")
    XCTAssertTrue(expectsAlert)
    completed.fulfill()
  }
}

private struct PermissionHandler: NotificationsHandler {
  let authorized: Bool
  let granted: Bool

  func isAuthorized() async -> Bool { await resumedOffMain(authorized) }
  func request() async -> Bool { await resumedOffMain(granted) }
  func reconcile(_ routines: [Routine]) async throws {}
  func clearDelivered() {}

  private func resumedOffMain(_ value: Bool) async -> Bool {
    await withCheckedContinuation { continuation in
      DispatchQueue.global().async { continuation.resume(returning: value) }
    }
  }
}
