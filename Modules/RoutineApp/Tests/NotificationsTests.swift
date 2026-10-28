@testable import Routine
import UserNotifications
import XCTest

final class NotificationsTests: XCTestCase {
  func testReconciliationFailureIsReportedExactlyOnce() async throws {
    enum Failure: Error { case rejected }
    let handler = NotificationsHandlerImpl(client: NotificationRequestsClient(
      pending: { [] }, add: { _ in throw Failure.rejected }, remove: { _ in }
    ))
    do {
      try await handler.reconcile([routine(reminders: [reminder()])])
      XCTFail("The scheduling error must propagate")
    } catch Failure.rejected {
    }
  }

  func testReconciliationRemovesStaleRemindersAndPreservesUnrelatedRequests() async throws {
    let stale = reminder()
    let current = reminder()
    let requests = RequestsFixture()
    requests.requests = [
      NotificationsHandlerImpl.notification(for: stale, title: "Old", body: "Time"),
      UNNotificationRequest(identifier: "unrelated", content: UNMutableNotificationContent(), trigger: nil)
    ]
    let handler = NotificationsHandlerImpl(client: requests.client)
    let value = routine(reminders: [current])
    try await handler.reconcile([value])
    XCTAssertEqual(Set(requests.requests.map(\.identifier)), ["unrelated", current.uuid.uuidString])
    XCTAssertEqual(requests.requests.first { $0.identifier == current.uuid.uuidString }?.content.title, "📚 Read")
    let addCount = requests.addCount
    try await handler.reconcile([value])
    XCTAssertEqual(requests.addCount, addCount)
    try await handler.reconcile([])
    XCTAssertEqual(requests.requests.map(\.identifier), ["unrelated"])
  }

  func testReconciliationCanRecoverAfterSchedulingFailure() async throws {
    enum Failure: Error { case rejected }
    let requests = RequestsFixture()
    var failNextAdd = true
    let working = requests.client
    let handler = NotificationsHandlerImpl(client: NotificationRequestsClient(
      pending: working.pending,
      add: { request in
        if failNextAdd {
          failNextAdd = false
          throw Failure.rejected
        }
        try await working.add(request)
      },
      remove: working.remove
    ))
    let value = routine(reminders: [reminder()])
    do {
      try await handler.reconcile([value])
      XCTFail("The first scheduling attempt must report its error")
    } catch Failure.rejected {
    }
    try await handler.reconcile([value])
    XCTAssertEqual(requests.requests.map(\.identifier), value.reminders.map { $0.uuid.uuidString })
  }

  private func reminder() -> Reminder {
    Reminder(uuid: UUID(), type: .daily(.form(hours: 9, minutes: 30)))
  }

  private func routine(reminders: [Reminder]) -> Routine {
    Routine(
      uuid: UUID(),
      name: "Read",
      description: "",
      emoji: "📚",
      startDate: Date(),
      frequency: .daily,
      progress: Progress(goal: 1, current: 0),
      remind: true,
      reminders: reminders,
      history: []
    )
  }
}

private final class RequestsFixture {
  var requests: [UNNotificationRequest] = []
  var addCount = 0

  var client: NotificationRequestsClient {
    NotificationRequestsClient(
      pending: { self.requests },
      add: { request in
        self.addCount += 1
        self.requests.removeAll { $0.identifier == request.identifier }
        self.requests.append(request)
      },
      remove: { identifiers in self.requests.removeAll { identifiers.contains($0.identifier) } }
    )
  }
}
