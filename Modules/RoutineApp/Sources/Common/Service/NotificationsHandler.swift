import UIKit.UIApplication
import UserNotifications

protocol NotificationsHandler {
  func isAuthorized() async -> Bool
  func request() async -> Bool
  func reconcile(_ routines: [Routine]) async throws
  func clearDelivered()
}

struct NotificationRequestsClient {
  var pending: () async -> [UNNotificationRequest]
  var add: (UNNotificationRequest) async throws -> Void
  var remove: ([String]) -> Void

  static var live: NotificationRequestsClient {
    let center = UNUserNotificationCenter.current()
    return NotificationRequestsClient(
      pending: {
        await withCheckedContinuation { continuation in
          center.getPendingNotificationRequests { continuation.resume(returning: $0) }
        }
      },
      add: { request in
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
          center.add(request) { error in
            if let error = error {
              continuation.resume(throwing: error)
            } else {
              continuation.resume(returning: ())
            }
          }
        }
      },
      remove: { center.removePendingNotificationRequests(withIdentifiers: $0) }
    )
  }
}

final class NotificationsHandlerImpl: NotificationsHandler {
  private let reconciler: ReminderReconciler

  init(client: NotificationRequestsClient = .live) {
    reconciler = ReminderReconciler(client: client)
  }

  func isAuthorized() async -> Bool {
    let settings = await withCheckedContinuation { continuation in
      UNUserNotificationCenter.current().getNotificationSettings { continuation.resume(returning: $0) }
    }
    return settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
  }

  func request() async -> Bool {
    await withCheckedContinuation { continuation in
      UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { allowed, _ in
        continuation.resume(returning: allowed)
      }
    }
  }

  func reconcile(_ routines: [Routine]) async throws {
    try await reconciler.reconcile(routines)
  }

  func clearDelivered() {
    UIApplication.shared.applicationIconBadgeNumber = .zero
    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
  }

  static func notification(for reminder: Reminder, title: String, body: String) -> UNNotificationRequest {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.badge = 1
    content.sound = .default
    var components = DateComponents()
    switch reminder.type {
    case .daily(let daily):
      components.hour = daily.hours
      components.minute = daily.minutes
    }
    return UNNotificationRequest(
      identifier: reminder.uuid.uuidString,
      content: content,
      trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
    )
  }
}

private actor ReminderReconciler {
  private let client: NotificationRequestsClient
  private var latest: [Routine]?
  private var running = false
  private var waiters: [CheckedContinuation<Void, Error>] = []

  init(client: NotificationRequestsClient) { self.client = client }

  func reconcile(_ routines: [Routine]) async throws {
    try await withCheckedThrowingContinuation { continuation in
      latest = routines
      waiters.append(continuation)
      guard !running else { return }
      running = true
      Task { await drain() }
    }
  }

  private func drain() async {
    while let routines = latest {
      latest = nil
      let completing = waiters
      waiters = []
      do {
        try await apply(routines)
        completing.forEach { $0.resume(returning: ()) }
      } catch {
        completing.forEach { $0.resume(throwing: error) }
      }
    }
    running = false
  }

  private func apply(_ routines: [Routine]) async throws {
    let body = NSLocalizedString("reminder.body.0", bundle: .module, comment: "")
    let desired = routines.filter(\.remind).flatMap { routine in
      routine.reminders.map {
        NotificationsHandlerImpl.notification(for: $0, title: "\(routine.emoji) \(routine.name)", body: body)
      }
    }
    let pending = await client.pending()
    let desiredIDs = Set(desired.map(\.identifier))
    client.remove(pending.filter { UUID(uuidString: $0.identifier) != nil && !desiredIDs.contains($0.identifier) }
      .map(\.identifier))
    for request in desired {
      if let existing = pending.first(where: { $0.identifier == request.identifier }),
         existing.content.title == request.content.title,
         existing.content.body == request.content.body,
         let current = existing.trigger as? UNCalendarNotificationTrigger,
         let replacement = request.trigger as? UNCalendarNotificationTrigger,
         current.dateComponents == replacement.dateComponents,
         current.repeats == replacement.repeats {
        continue
      }
      try await client.add(request)
    }
  }
}
