import FirebaseMessaging
import UserNotifications

final class NotificationsService: UNNotificationServiceExtension {
  override func didReceive(
    _ request: UNNotificationRequest,
    withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
  ) {
    guard let content = request.content.mutableCopy() as? UNMutableNotificationContent else {
      contentHandler(request.content)
      return
    }
    content.badge = 1
    Messaging.serviceExtension().populateNotificationContent(
      content,
      withContentHandler: contentHandler
    )
  }
}
