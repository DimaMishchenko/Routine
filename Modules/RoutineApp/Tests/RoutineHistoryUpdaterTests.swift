import Combine
@testable import Routine
import XCTest

final class RoutineHistoryUpdaterTests: XCTestCase {
  func testDelayedSnapshotCannotFinishAfterNewerDeletion() async {
    let store = SnapshotStore()
    let notifications = DelayedNotifications()
    let updater = RoutineHistoryUpdaterImpl(store: store, notifications: notifications)
    store.snapshots.send([Routine.new])
    await fulfillment(of: [notifications.firstStarted], timeout: 2)
    store.snapshots.send([])
    await withCheckedContinuation { continuation in
      DispatchQueue.main.async { continuation.resume(returning: ()) }
    }
    notifications.releaseFirst()
    await fulfillment(of: [notifications.deletionApplied], timeout: 2)
    XCTAssertEqual(notifications.maximumActive, 1)
    XCTAssertEqual(notifications.completed.last?.count, 0)
    updater.handleForeground()
    await fulfillment(of: [notifications.retryApplied], timeout: 2)
    XCTAssertEqual(notifications.completed.map(\.count), [1, 0, 0])
    withExtendedLifetime(updater) {}
  }
}

private final class SnapshotStore: RoutineStore {
  let snapshots = PassthroughSubject<[Routine], Error>()
  func allRoutines() async throws -> [Routine] { XCTFail("Refresh must use the ordered snapshot stream"); return [] }
  func save(_ routine: Routine) async throws {}
  func update(_ routine: Routine) async throws {}
  func delete(_ routine: Routine) async throws {}
  func removeHistory(id: UUID, from routineID: UUID) async throws {}
  func observeAll() -> AnyPublisher<[Routine], Error> { snapshots.eraseToAnyPublisher() }
  func fillHistoryIfNeeded() async throws {}
}

private final class DelayedNotifications: NotificationsHandler {
  let firstStarted = XCTestExpectation(description: "First snapshot suspended")
  let deletionApplied = XCTestExpectation(description: "Newer deletion applied")
  let retryApplied = XCTestExpectation(description: "Foreground retries the latest deletion")
  private let lock = NSLock()
  private var firstContinuation: CheckedContinuation<Void, Never>?
  private var active = 0
  private(set) var maximumActive = 0
  private(set) var completed: [[Routine]] = []

  func reconcile(_ routines: [Routine]) async throws {
    let first = begin()
    if first {
      await withCheckedContinuation { continuation in
        lock.lock()
        firstContinuation = continuation
        lock.unlock()
        firstStarted.fulfill()
      }
    }
    let emptyCount = complete(routines)
    if routines.isEmpty {
      if emptyCount == 1 { deletionApplied.fulfill() }
      if emptyCount == 2 { retryApplied.fulfill() }
    }
  }

  func releaseFirst() {
    lock.lock()
    let continuation = firstContinuation
    firstContinuation = nil
    lock.unlock()
    continuation?.resume(returning: ())
  }

  func isAuthorized() async -> Bool { true }
  func request() async -> Bool { true }
  func clearDelivered() {}

  private func begin() -> Bool {
    lock.lock()
    defer { lock.unlock() }
    let first = completed.isEmpty && active == 0
    active += 1
    maximumActive = max(maximumActive, active)
    return first
  }

  private func complete(_ routines: [Routine]) -> Int {
    lock.lock()
    defer { lock.unlock() }
    completed.append(routines)
    active -= 1
    return completed.filter(\.isEmpty).count
  }
}
