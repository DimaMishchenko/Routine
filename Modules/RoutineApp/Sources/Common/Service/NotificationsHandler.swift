import UIKit.UIApplication
import UserNotifications

protocol NotificationsHandler {
  func isAuthorized() async -> Bool
  func request() async -> Bool
  func schedule(_ reminders: [Reminder], title: String, body: String) async throws
  func delete(_ reminder: Reminder)
  func clearDelivered()
}

final class NotificationsHandlerImpl: NotificationsHandler {
  // MARK: - Public
  func isAuthorized() async -> Bool {
    let status = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    return status == .authorized
  }
  
  func request() async -> Bool {
    do {
      let result = try await UNUserNotificationCenter.current().requestAuthorization(
        options: [.badge, .sound, .alert]
      )
      return result
    } catch {
      Logger.log(error)
      return false
    }
  }
  
  func schedule(_ reminders: [Reminder], title: String, body: String) async throws {
    try await withCheckedThrowingContinuation { continuation in
      schedule(reminders, title: title, body: body) {
        continuation.resume(with: $0)
      }
    }
  }
  
  func delete(_ reminder: Reminder) {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.uuid.uuidString])
  }
  
  func clearDelivered() {
    UIApplication.shared.applicationIconBadgeNumber = .zero
    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
  }
  
  // MARK: - Private
  private func schedule(
    _ reminders: [Reminder],
    title: String,
    body: String,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    UNUserNotificationCenter.current().getPendingNotificationRequests { [weak self] requests in
      let currentUUIDs = requests.map { $0.identifier }
      
      reminders.forEach {
        // clean old reminders
        if currentUUIDs.contains($0.uuid.uuidString) { self?.delete($0) }
        
        // setup new
        let content = with(UNMutableNotificationContent()) {
          $0.title = title
          $0.body = body
          // TODO: - Increase on every new item
          $0.badge = 1
        }
        
        let trigger: UNNotificationTrigger
        
        switch $0.type {
        case .daily(let daily):
          var dateComponents = DateComponents()
          dateComponents.hour = daily.hours
          dateComponents.minute = daily.minutes
          trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        }
        
        let request = UNNotificationRequest(identifier: $0.uuid.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) {
          guard let error = $0 else { return }
          completion(.failure(error))
        }
      }
      
      completion(.success(()))
    }
  }
}
